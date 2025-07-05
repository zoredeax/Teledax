import 'dart:developer';
import 'package:Teledax/api/Api.dart';
import 'package:Teledax/models/chatItems_model.dart';
import 'package:Teledax/screens/common/item_card.dart'; // Make sure this import is correct
import 'package:Teledax/screens/listfiles/search_file.dart';
import 'package:Teledax/style/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For RawKeyboardListener

class FilesScreen extends StatefulWidget {
  @override
  _FilesScreenState createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  Map<String, dynamic> data = {};
  int _nextpageno = 0;
  bool _isnext = false;
  List<ItemList> items = [];
  var baseurl;
  ScrollController _paginationctr = new ScrollController();

  // Focus management for ListView items
  final Map<int, FocusNode> _itemFocusNodes = {};
  int _focusedItemIndex;

  // FocusNode for the AppBar search icon
  final FocusNode _searchIconFocusNode = FocusNode();

  @override
  void initState() {
    _paginationctr.addListener(() {
      if (_paginationctr.position.pixels ==
          _paginationctr.position.maxScrollExtent) {
        print("fetch again");
        _getNext();
      }
    });

    // Use addPostFrameCallback to ensure context is available and data is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      data = ModalRoute.of(context).settings.arguments;
      baseurl = data["baseurl"];
      _getFiles().then((_) {
        // After files are loaded, try to set initial focus
        if (items.isNotEmpty) {
          _itemFocusNodes[0]?.requestFocus();
          setState(() {
            _focusedItemIndex = 0; // Set initial focused index
          });
        }
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _paginationctr.dispose();
    _itemFocusNodes.values.forEach((node) => node.dispose()); // Dispose all item focus nodes
    _searchIconFocusNode.dispose(); // Dispose search icon focus node
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: lightColor,
        appBar: AppBar(
          backgroundColor: lightColor,
          centerTitle: true,
          elevation: 0,
          title: Text(
            data['chat'] != null ? data['chat'].name : "loading",
            style: TextStyle(
              color: fontColor,
              fontSize: 15,
            ),
          ),
          actions: [
            Focus( // Make the IconButton focusable
              focusNode: _searchIconFocusNode,
              onFocusChange: (hasFocus) {
                // You can add visual feedback for the search icon here if needed
                // e.g., change its color or size
                if (hasFocus) {
                  print("Search icon focused!");
                }
              },
              child: IconButton(
                  icon: Icon(
                    Icons.search,
                    color: _searchIconFocusNode.hasFocus ? Colors.deepOrange : fontColor, // Visual feedback
                  ),
                  onPressed: () {
                    showSearch(
                        context: context,
                        delegate: FileSearch(
                            chatid: data['chat'].id.toString(),
                            baseurl: baseurl));
                  }),
            )
          ],
        ),
        body: items.length > 0
            ? _list(items)
            : Center(
                child: CircularProgressIndicator(),
              ));
  }

  _getFiles() async {
    print("Data: $data");
    ChatItems chatitem =
        await getFiles(chatid: data['chat'].id, baseurl: baseurl);
    items = chatitem.itemList;
    print(chatitem.nextPage);
    setState(() {
      if (chatitem.nextPage != false) {
        _isnext = true;
        _nextpageno = chatitem.nextPage["no"];
      }
    });
  }

  _getNext() async {
    if (!_isnext) {
      print("No data!");
      return;
    }
    _isnext = false;
    print(items.length);
    ChatItems nextitem =
        await getNextPage("$baseurl/${data['chat'].id}?page=$_nextpageno");
    items.addAll(nextitem.itemList);
    print(items.length);
    setState(() {
      if (nextitem.nextPage != false) {
        _isnext = true;
        _nextpageno = nextitem.nextPage["no"];
      }
    });
  }

  _list(items) {
    return ListView.builder(
      controller: _paginationctr,
      itemCount: items.length,
      itemBuilder: (context, index) {
        // Get or create a FocusNode for this item
        if (!_itemFocusNodes.containsKey(index)) {
          _itemFocusNodes[index] = FocusNode();
        }
        final FocusNode itemFocusNode = _itemFocusNodes[index];

        return SingleChildScrollView(
          padding: EdgeInsets.all(4),
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
                // This onTap is for the entire ItemCard area when focused
                Navigator.pushNamed(context, "/fileinfo",
                    arguments: {"item": items[index], "chatid": data['chat'].id, "baseurl": baseurl});
              },
              child: ItemCard(
                item: items[index],
                chatId: data['chat'].id,
                baseurl: baseurl,
                isFocused: _focusedItemIndex == index, // Pass focus state to ItemCard
              ),
            ),
          ),
        );
      },
    );
  }

  _errorWidget() {
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
}
