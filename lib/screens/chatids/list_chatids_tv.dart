import 'package:Teledax/api/Api.dart';
import 'package:Teledax/models/chatid_model.dart';
import 'package:Teledax/screens/common/custom_appbar.dart';
import 'package:Teledax/style/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for RawKeyboardListener (though not directly used here, good to have for D-pad)
import 'package:fluttertoast/fluttertoast.dart';

class ChatIds extends StatefulWidget {
  @override
  _ChatIdsState createState() => _ChatIdsState();
}

class _ChatIdsState extends State<ChatIds> {
  DateTime currentBackPressTime;

  var data;
  var baseurl;

  // To manage focus nodes for each list item dynamically
  final Map<int, FocusNode> _focusNodes = {};
  // To manage the currently focused item for visual feedback
  int _focusedItemIndex; // Using index for simplicity, assuming unique indices in ListView.builder

  @override
  void initState() {
    super.initState();
    // Initialize _focusedItemIndex to 0 to give initial focus to the first item
    // This is a common pattern for TV apps to ensure something is focused on screen load.
    // However, ensure your list is not empty before trying to set initial focus.
    // We'll handle this more robustly in the FutureBuilder.
  }

  @override
  void dispose() {
    // Dispose all focus nodes when the widget is removed
    _focusNodes.values.forEach((node) => node.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    data = ModalRoute.of(context).settings.arguments;
    baseurl = data["baseurl"];

    return Scaffold(
      backgroundColor: lightColor,
      appBar: customAppbar("Select Chat", context),
      body: WillPopScope(
        onWillPop: onWillPop,
        child: chatIdList(),
      ),
    );
  }

  Widget chatIdList() { // Changed to Widget to be explicit
    return FutureBuilder(
      future: getchatid(baseurl: baseurl),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Chatid chatid = snapshot.data;

          if (chatid.chats.isEmpty) { // Handle empty list case
            return Center(
                child: Text(
              "No chats available.",
              style: TextStyle(fontSize: 20),
            ));
          }

          // If there's data, ensure the first item gets initial focus if nothing is focused
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_focusedItemIndex == null && chatid.chats.isNotEmpty) {
              // Request focus for the first item after the frame is built
              _focusNodes[0]?.requestFocus();
            }
          });


          return ListView.builder(
            itemCount: chatid.chats.length,
            itemBuilder: (context, index) {
              final item = chatid.chats[index];

              // Get or create a FocusNode for this item
              if (!_focusNodes.containsKey(index)) {
                _focusNodes[index] = FocusNode();
              }
              final FocusNode itemFocusNode = _focusNodes[index];

              return SingleChildScrollView(
                padding: EdgeInsets.all(8),
                child: Focus( // Wrap with Focus widget
                  focusNode: itemFocusNode,
                  onFocusChange: (hasFocus) {
                    if (hasFocus) {
                      setState(() {
                        _focusedItemIndex = index; // Update focused item index
                      });
                    } else if (_focusedItemIndex == index) {
                      setState(() {
                        _focusedItemIndex = null; // Clear focused item index if it loses focus
                      });
                    }
                  },
                  child: GestureDetector( // Use GestureDetector to capture taps when focused
                    onTap: () {
                      // Programmatically trigger the ListTile's onTap
                      Navigator.pushNamed(context, "/files", arguments: {
                        "chat": item,
                        "baseurl": data['baseurl']
                      });
                    },
                    child: Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        shadowColor: Colors.black,
                        // Change card color based on focus
                        color: _focusedItemIndex == index ? Colors.blue.shade100 : cardLightColor,
                        child: ListTile(
                          // Remove original onTap, use GestureDetector above
                          // onTap: () {
                          //   Navigator.pushNamed(context, "/files", arguments: {
                          //     "chat": item,
                          //     "baseurl": data['baseurl']
                          //   });
                          // },
                          hoverColor: accents, // This is for mouse hover, not D-pad focus
                          contentPadding: EdgeInsets.all(5.0),
                          leading: CachedNetworkImage(
                            imageUrl: "$baseurl/${item.id}/logo",
                            errorWidget: (context, url, error) =>
                                Image.asset("images/logo.png"),
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                          ),
                          title: Text(
                            item.name,
                            style: TextStyle(
                                color: fontColor, fontWeight: FontWeight.bold),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: SecondaryColor,
                          ),
                        )),
                  ),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                    height: 100,
                    width: 100,
                    child: Image.asset("images/not-found.png")),
              ),
              Text("Something went wrong"),
            ],
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
        msg: "Press again to exit ",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: accents,
      );
      return Future.value(false);
    }
    return Future.value(true);
  }
}
