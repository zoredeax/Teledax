import 'package:Teledax/database/database_helper.dart';
import 'package:Teledax/screens/common/custom_appbar.dart';
import 'package:Teledax/style/constants.dart';
import 'package:Teledax/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for RawKeyboardListener
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddApi extends StatefulWidget {
  @override
  _AddApiState createState() => _AddApiState();
}

class _AddApiState extends State<AddApi> {
  DatabaseHelper db = DatabaseHelper.instance;
  var _value;
  SharedPreferences pref;

  final Map<int, FocusNode> _focusNodes = {};
  int _focusedItemId;

  // FocusNode for the FloatingActionButton
  final FocusNode _fabFocusNode = FocusNode();

  @override
  void initState() {
    SharedPreferences.getInstance().then((value) {
      pref = value;
      _value = value.getInt(apiValue.apidefault);
      print(_value);
    });
    super.initState();
  }

  @override
  void dispose() {
    _focusNodes.values.forEach((node) => node.dispose());
    _fabFocusNode.dispose(); // Dispose FAB focus node
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: customAppbar("API List", context),
        backgroundColor: lightColor,
        body: FutureBuilder(
          future: db.queryAllRows(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data;

              if (data.length < 1) {
                return Center(
                    child: Text(
                  "No API Available !! ",
                  style: TextStyle(fontSize: 20),
                ));
              }

              return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final int itemId = data[index][DatabaseHelper.columnId];
                    if (!_focusNodes.containsKey(itemId)) {
                      _focusNodes[itemId] = FocusNode();
                    }
                    final FocusNode itemFocusNode = _focusNodes[itemId];

                    return SingleChildScrollView(
                      padding: EdgeInsets.all(8),
                      child: Focus(
                        focusNode: itemFocusNode,
                        onFocusChange: (hasFocus) {
                          if (hasFocus) {
                            setState(() {
                              _focusedItemId = itemId;
                            });
                          } else if (_focusedItemId == itemId) {
                            setState(() {
                              _focusedItemId = null;
                            });
                          }
                        },
                        child: GestureDetector(
                          // GestureDetector for the whole ListTile area
                          onTap: () {
                            // This onTap is for the entire ListTile area when focused
                            // It navigates to chatids, which is the primary action for the list item
                            Navigator.of(context).popAndPushNamed("/chatids", arguments: {
                              "baseurl": snapshot.data[index]['url']
                            });
                          },
                          child: Card(
                            elevation: 1,
                            shadowColor: Colors.black,
                            color: _focusedItemId == itemId ? Colors.blue.shade100 : cardLightColor,
                            child: ListTile(
                                leading: FocusableActionDetector( // Make Radio focusable
                                  // Use a builder to get the context for the focus node
                                  builder: (context, isHovered, isFocused) {
                                    return Radio<int>(
                                      value: data[index][DatabaseHelper.columnId],
                                      groupValue: _value,
                                      onChanged: (value) async {
                                        await pref.setInt(
                                            apiValue.apidefault, data[index][DatabaseHelper.columnId]);
                                        print(pref.getKeys());
                                        setState(() {
                                          _value = data[index][DatabaseHelper.columnId];
                                        });
                                      },
                                      // Add visual feedback for the radio button when focused
                                      activeColor: isFocused ? Colors.red : Theme.of(context).radioTheme.fillColor,
                                    );
                                  },
                                ),
                                title: Text(snapshot.data[index][DatabaseHelper.columnName]),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FocusableActionDetector( // Make IconButton focusable
                                      builder: (context, isHovered, isFocused) {
                                        return IconButton(
                                          icon: Icon(
                                            MdiIcons.pencil,
                                            color: isFocused ? Colors.deepOrange : Colors.blue, // Visual feedback
                                          ),
                                          onPressed: () async {
                                            await _showEditDialog(
                                              context,
                                              db,
                                              snapshot.data[index][DatabaseHelper.columnId],
                                              snapshot.data[index][DatabaseHelper.columnName],
                                            );
                                            setState(() {});
                                          },
                                        );
                                      },
                                    ),
                                    FocusableActionDetector( // Make IconButton focusable
                                      builder: (context, isHovered, isFocused) {
                                        return IconButton(
                                            icon: Icon(
                                              MdiIcons.delete,
                                              color: isFocused ? Colors.deepOrange : Colors.red, // Visual feedback
                                            ),
                                            onPressed: () async {
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  content: Text("Really Delete ?"),
                                                  actions: [
                                                    FlatButton(
                                                      color: Colors.green,
                                                      child: new Text("No!! Go Back"),
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                    ),
                                                    FlatButton(
                                                      color: Colors.red,
                                                      child: new Text("Yes!! Delete"),
                                                      onPressed: () async {
                                                        await db.delete(
                                                            snapshot.data[index][DatabaseHelper.columnId]);
                                                        setState(() {});
                                                        Navigator.of(context).pop();
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              );
                                            });
                                      },
                                    ),
                                  ],
                                )),
                          ),
                        ),
                      ),
                    );
                  });
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
        floatingActionButton: Focus( // Make FAB focusable
          focusNode: _fabFocusNode,
          onFocusChange: (hasFocus) {
            // You can add visual feedback for the FAB here if needed
            // For example, change its color or scale it slightly
            if (hasFocus) {
              print("FAB is focused!");
              // You might want to add a visual effect here
            } else {
              print("FAB lost focus.");
            }
          },
          child: FloatingActionButton.extended(
            onPressed: () async {
              await _showDialog(context, db);
              setState(() {});
            },
            splashColor: SecondaryColor,
            elevation: 10,
            label: Text("Add API"),
            icon: Icon(MdiIcons.plus),
          ),
        ),
      ),
    );
  }

  Future _showDialog(BuildContext context, DatabaseHelper db) async {
    TextEditingController _controller = TextEditingController();
    // Create FocusNodes for dialog elements
    final FocusNode textFieldFocusNode = FocusNode();
    final FocusNode closeButtonFocusNode = FocusNode();
    final FocusNode addButtonFocusNode = FocusNode();

    await showDialog( // Use await here to ensure dialog is dismissed before continuing
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Focus( // Make TextField focusable
            focusNode: textFieldFocusNode,
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                  icon: Icon(MdiIcons.link), hintText: 'https://example.com'),
              autofocus: true, // This will try to give it initial focus
            ),
          ),
          actions: <Widget>[
            Focus( // Make FlatButton focusable
              focusNode: closeButtonFocusNode,
              child: FlatButton(
                color: Colors.red,
                child: new Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Focus( // Make FlatButton focusable
              focusNode: addButtonFocusNode,
              child: FlatButton(
                color: Colors.green,
                child: Text("Add"),
                onPressed: () async {
                  var _textvalue = _controller.text.toString();

                  if (RegExp(r"(.+)/$").hasMatch(_textvalue)) {
                    _textvalue = _textvalue.substring(0, _textvalue.length - 1);
                  }

                  if (!RegExp(r"^(http|https)://").hasMatch(_textvalue)) {
                    _textvalue = "http://" + _textvalue;
                  }
                  await db.insert({DatabaseHelper.columnName: _textvalue});

                  Navigator.of(context).pop();
                  setState(() {});
                },
              ),
            ),
          ],
        );
      },
    );
    // Dispose focus nodes after dialog is dismissed
    textFieldFocusNode.dispose();
    closeButtonFocusNode.dispose();
    addButtonFocusNode.dispose();
  }

  Future _showEditDialog(BuildContext context, DatabaseHelper db, int id, String currentUrl) async {
    TextEditingController _controller = TextEditingController(text: currentUrl);
    // Create FocusNodes for dialog elements
    final FocusNode editTextFieldFocusNode = FocusNode();
    final FocusNode editCloseButtonFocusNode = FocusNode();
    final FocusNode updateButtonFocusNode = FocusNode();

    await showDialog( // Use await here
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit API URL"),
          content: Focus( // Make TextField focusable
            focusNode: editTextFieldFocusNode,
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                  icon: Icon(MdiIcons.link), hintText: 'https://example.com'),
              autofocus: true,
            ),
          ),
          actions: <Widget>[
            Focus( // Make FlatButton focusable
              focusNode: editCloseButtonFocusNode,
              child: FlatButton(
                color: Colors.red,
                child: new Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Focus( // Make FlatButton focusable
              focusNode: updateButtonFocusNode,
              child: FlatButton(
                color: Colors.green,
                child: Text("Update"),
                onPressed: () async {
                  var _textvalue = _controller.text.toString();

                  if (RegExp(r"(.+)/$").hasMatch(_textvalue)) {
                    _textvalue = _textvalue.substring(0, _textvalue.length - 1);
                  }

                  if (!RegExp(r"^(http|https)://").hasMatch(_textvalue)) {
                    _textvalue = "http://" + _textvalue;
                  }

                  await db.update({
                    DatabaseHelper.columnId: id,
                    DatabaseHelper.columnName: _textvalue,
                  });

                  Navigator.of(context).pop();
                  setState(() {}); // Refresh the UI
                },
              ),
            ),
          ],
        );
      },
    );
    // Dispose focus nodes after dialog is dismissed
    editTextFieldFocusNode.dispose();
    editCloseButtonFocusNode.dispose();
    updateButtonFocusNode.dispose();
  }
}
