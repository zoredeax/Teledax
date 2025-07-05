import 'package:Teledax/api/Api.dart';
import 'package:Teledax/screens/common/item_card.dart';
import 'package:Teledax/style/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for RawKeyboardListener

class FileSearch extends SearchDelegate {
  var chatid;
  var baseurl;
  FileSearch({@required this.chatid, @required this.baseurl});

  // FocusNode for the clear button
  final FocusNode _clearButtonFocusNode = FocusNode();
  // FocusNode for the back button
  final FocusNode _backButtonFocusNode = FocusNode();
  // Focus management for search results list items
  final Map<int, FocusNode> _resultItemFocusNodes = {};
  int _focusedResultItemIndex;

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: fontColor.withOpacity(0.7)),
      ),
      textTheme: theme.textTheme.copyWith(
        headline6: TextStyle(color: fontColor), // Style for the search query text
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightColor, // Match your app's AppBar color
        elevation: 0,
        iconTheme: IconThemeData(color: fontColor), // Color for leading/actions icons
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      Focus( // Make the clear button focusable
        focusNode: _clearButtonFocusNode,
        onFocusChange: (hasFocus) {
          if (hasFocus) {
            print("Clear button focused!");
          }
        },
        child: IconButton(
            icon: Icon(Icons.clear, color: _clearButtonFocusNode.hasFocus ? Colors.deepOrange : fontColor), // Visual feedback
            onPressed: () {
              query = "";
              // Request focus back to the search text field after clearing
              FocusScope.of(context).requestFocus(FocusNode()); // This will usually put focus back to the search field
            }),
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return Focus( // Make the back button focusable
      focusNode: _backButtonFocusNode,
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          print("Back button focused!");
        }
      },
      child: IconButton(
          icon: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow,
            progress: transitionAnimation,
            color: _backButtonFocusNode.hasFocus ? Colors.deepOrange : fontColor, // Visual feedback
          ),
          onPressed: () {
            close(context, null);
          }),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return query.isEmpty
        ? Center(
            child: Text(
              "No Data",
              style: TextStyle(color: fontColor, fontSize: 20),
            ),
          )
        : FutureBuilder(
            future: searchInTg(
                chatid: chatid.toString(), query: query, baseurl: baseurl),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final snap = snapshot.data;
                final items = snap.itemList;
                if (items.length < 1) {
                  return Center(
                    child: Text(
                      "Search Not Found",
                      style: TextStyle(color: fontColor, fontSize: 20),
                    ),
                  );
                }

                // Request initial focus for the first search result
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_focusedResultItemIndex == null && items.isNotEmpty) {
                    _resultItemFocusNodes[0]?.requestFocus();
                  }
                });

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    // Get or create a FocusNode for this item
                    if (!_resultItemFocusNodes.containsKey(index)) {
                      _resultItemFocusNodes[index] = FocusNode();
                    }
                    final FocusNode itemFocusNode = _resultItemFocusNodes[index];

                    return SingleChildScrollView(
                      padding: const EdgeInsets.only(top: 20),
                      child: Focus( // Wrap with Focus widget
                        focusNode: itemFocusNode,
                        onFocusChange: (hasFocus) {
                          if (hasFocus) {
                            _focusedResultItemIndex = index; // Update focused item index
                          } else if (_focusedResultItemIndex == index) {
                            _focusedResultItemIndex = null; // Clear focused item index if it loses focus
                          }
                          // Trigger rebuild for visual feedback in ItemCard
                          // This setState is important because SearchDelegate doesn't automatically rebuild its results
                          // when a child's focus state changes.
                          if (mounted) setState(() {});
                        },
                        child: GestureDetector( // Use GestureDetector to capture taps when focused
                          onTap: () {
                            // This onTap is for the entire ItemCard area when focused
                            Navigator.pushNamed(context, "/fileinfo",
                                arguments: {"item": items[index], "chatid": chatid, "baseurl": baseurl});
                          },
                          child: ItemCard(
                            item: items[index],
                            chatId: chatid,
                            baseurl: baseurl,
                            isFocused: _focusedResultItemIndex == index, // Pass focus state to ItemCard
                          ),
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
                        child: Image.asset("images/not-found.png"),
                      ),
                    ),
                    Text("Something went wrong"),
                  ],
                );
              }
              return Center(child: CircularProgressIndicator());
            },
          );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Center(
        child: Text(
      "No recent Search Found",
      style: TextStyle(color: fontColor, fontSize: 20),
    ));
  }

  @override
  void dispose() {
    _clearButtonFocusNode.dispose();
    _backButtonFocusNode.dispose();
    _resultItemFocusNodes.values.forEach((node) => node.dispose());
    super.dispose();
  }
}
