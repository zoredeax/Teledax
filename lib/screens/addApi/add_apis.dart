import 'package:Teledax/database/database_helper.dart';
import 'package:Teledax/screens/common/custom_appbar.dart';
import 'package:Teledax/style/constants.dart';
import 'package:Teledax/values.dart';
import 'package:flutter/material.dart';
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

              // if array contain 0 data
              if (data.length < 1)
                return Center(
                    child: Text(
                  "No API Available !! ",
                  style: TextStyle(fontSize: 20),
                ));

              // If have more than 0 data

              return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.all(8),
                      child: Card(
                        elevation: 1,
                        shadowColor: Colors.black,
                        color: cardLightColor,
                        child: ListTile(
                            onTap: () => Navigator.of(context)
                                    .popAndPushNamed("/chatids", arguments: {
                                  "baseurl": snapshot.data[index]['url']
                                }),
                            leading: Radio(
                              value: data[index][DatabaseHelper.columnId], // Use columnId
                              groupValue: _value,
                              onChanged: (value) async {
                                await pref.setInt(
                                    apiValue.apidefault, data[index][DatabaseHelper.columnId]); // Use columnId
                                print(pref.getKeys());

                                setState(() {
                                  _value = data[index][DatabaseHelper.columnId]; // Use columnId
                                });
                              },
                            ),
                            title: Text(snapshot.data[index][DatabaseHelper.columnName]), // Use columnName
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    MdiIcons.pencil,
                                    color: Colors.blue,
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
                                ),
                                IconButton(
                                    icon: Icon(
                                      MdiIcons.delete,
                                      color: Colors.red,
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
                                                    snapshot.data[index][DatabaseHelper.columnId]); // Use columnId
                                                setState(() {});
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                              ],
                            )),
                      ),
                    );
                  });
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
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
    );
  }

  Future _showDialog(BuildContext context, DatabaseHelper db) async {
    TextEditingController _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
                icon: Icon(MdiIcons.link), hintText: 'https://example.com'),
            autofocus: true,
          ),
          actions: <Widget>[
            FlatButton(
              color: Colors.red,
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              color: Colors.green,
              child: Text("Add"),
              onPressed: () async {
                var _textvalue = _controller.text.toString();

                if (RegExp(r"(.+)/$").hasMatch(_textvalue)) {
                  _textvalue = _textvalue.substring(0, _textvalue.length - 1);
                }

                if (!RegExp(r"^(http|https)://").hasMatch(_textvalue)) { // Corrected regex
                  _textvalue = "http://" + _textvalue;
                }
                await db.insert({DatabaseHelper.columnName: _textvalue});

                Navigator.of(context).pop();
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  Future _showEditDialog(BuildContext context, DatabaseHelper db, int id, String currentUrl) async {
    TextEditingController _controller = TextEditingController(text: currentUrl);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit API URL"),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
                icon: Icon(MdiIcons.link), hintText: 'https://example.com'),
            autofocus: true,
          ),
          actions: <Widget>[
            FlatButton(
              color: Colors.red,
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              color: Colors.green,
              child: Text("Update"),
              onPressed: () async {
                var _textvalue = _controller.text.toString();

                if (RegExp(r"(.+)/$").hasMatch(_textvalue)) {
                  _textvalue = _textvalue.substring(0, _textvalue.length - 1);
                }

                if (!RegExp(r"^(http|https)://").hasMatch(_textvalue)) { // Corrected regex
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
          ],
        );
      },
    );
  }
}
