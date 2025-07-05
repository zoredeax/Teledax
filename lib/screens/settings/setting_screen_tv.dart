import 'package:Teledax/screens/common/reuseable_items.dart';
import 'package:Teledax/style/constants.dart';
import 'package:Teledax/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for RawKeyboardListener
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  var _audioPlayback;
  var _videoPlayback;
  final TextStyle headerStyle = TextStyle(
    color: Colors.grey.shade800,
    fontWeight: FontWeight.bold,
    fontSize: 20.0,
  );

  // FocusNode for the AppBar back button
  final FocusNode _appBarBackFocusNode = FocusNode();

  // FocusNodes for the Switches
  final FocusNode _audioSwitchFocusNode = FocusNode();
  final FocusNode _videoSwitchFocusNode = FocusNode();

  // FocusNodes for the ListTiles
  final FocusNode _supportGroupFocusNode = FocusNode();
  final FocusNode _howToUseFocusNode = FocusNode();
  final FocusNode _aboutFocusNode = FocusNode();
  final FocusNode _manageApisFocusNode = FocusNode();

  // To track the currently focused widget for visual feedback
  FocusNode _currentFocusedNode;

  setInitSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _audioPlayback = prefs.getBool('audioplayback') ?? false;
    _videoPlayback = prefs.getBool('videoplayback') ?? false;

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    setInitSettings();

    // Request initial focus after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Try to focus the first interactive element, e.g., the audio playback switch
      _audioSwitchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _appBarBackFocusNode.dispose();
    _audioSwitchFocusNode.dispose();
    _videoSwitchFocusNode.dispose();
    _supportGroupFocusNode.dispose();
    _howToUseFocusNode.dispose();
    _aboutFocusNode.dispose();
    _manageApisFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Settings",
            style: TextStyle(color: fontColor, fontWeight: FontWeight.bold),
          ),
          leading: Focus( // Make the AppBar back button focusable
            focusNode: _appBarBackFocusNode,
            onFocusChange: (hasFocus) {
              if (hasFocus) {
                setState(() {
                  _currentFocusedNode = _appBarBackFocusNode;
                });
              } else if (_currentFocusedNode == _appBarBackFocusNode) {
                setState(() {
                  _currentFocusedNode = null;
                });
              }
            },
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: _currentFocusedNode == _appBarBackFocusNode ? Colors.deepOrange : fontColor, // Visual feedback
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Player", style: headerStyle),
              SizedBox(
                height: 10,
              ),
              _player(),
              SizedBox(
                height: 18,
              ),
              Text(
                "Additional",
                style: headerStyle,
              ),
              SizedBox(
                height: 10,
              ),
              _additional(),
              SizedBox(
                height: 18,
              ),
              Text(
                "Info",
                style: headerStyle,
              ),
              SizedBox(
                height: 10,
              ),
              info(),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Made in India ❤️", textAlign: TextAlign.center),
        ),
      ),
    );
  }

  // player catagory
  _player() {
    return Card(
      color: cardLightColor,
      child: Column(
        children: [
          Focus( // Make the ListTile focusable
            focusNode: _audioSwitchFocusNode,
            onFocusChange: (hasFocus) {
              if (hasFocus) {
                setState(() {
                  _currentFocusedNode = _audioSwitchFocusNode;
                });
              } else if (_currentFocusedNode == _audioSwitchFocusNode) {
                setState(() {
                  _currentFocusedNode = null;
                });
              }
            },
            child: GestureDetector( // Use GestureDetector to capture tap for the whole ListTile
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('audioplayback', !_audioPlayback);
                _audioPlayback = prefs.getBool("audioplayback");
                setState(() {});
              },
              child: ListTile(
                tileColor: _currentFocusedNode == _audioSwitchFocusNode ? Colors.blue.shade100 : null, // Visual feedback
                title: Text("Play Audio In Background"),
                trailing: Switch(
                  inactiveThumbColor: Colors.red,
                  inactiveTrackColor: Colors.redAccent,
                  activeColor: Colors.green,
                  activeTrackColor: Colors.greenAccent,
                  value: _audioPlayback ?? false,
                  onChanged: (value) async {
                    // This onChanged is for direct interaction with the switch,
                    // but the GestureDetector's onTap will also trigger it.
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('audioplayback', !_audioPlayback);
                    _audioPlayback = prefs.getBool("audioplayback");
                    setState(() {});
                  },
                ),
              ),
            ),
          ),
          buildDivider(),
          // ++++  Video Play in background+++++++
          Focus( // Make the ListTile focusable
            focusNode: _videoSwitchFocusNode,
            onFocusChange: (hasFocus) {
              if (hasFocus) {
                setState(() {
                  _currentFocusedNode = _videoSwitchFocusNode;
                });
              } else if (_currentFocusedNode == _videoSwitchFocusNode) {
                setState(() {
                  _currentFocusedNode = null;
                });
              }
            },
            child: GestureDetector( // Use GestureDetector to capture tap for the whole ListTile
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('videoplayback', !_videoPlayback);
                _videoPlayback = prefs.getBool("videoplayback");
                setState(() {});
              },
              child: ListTile(
                tileColor: _currentFocusedNode == _videoSwitchFocusNode ? Colors.blue.shade100 : null, // Visual feedback
                title: Text("Play Video In Background"),
                trailing: Switch(
                  inactiveThumbColor: Colors.red,
                  inactiveTrackColor: Colors.redAccent,
                  activeColor: Colors.green,
                  activeTrackColor: Colors.greenAccent,
                  value: _videoPlayback ?? false,
                  onChanged: (value) async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('videoplayback', !_videoPlayback);
                    _videoPlayback = prefs.getBool("videoplayback");
                    setState(() {});
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // info catagory
  info() {
    return Card(
      color: cardLightColor,
      child: Column(
        children: [
          Focus( // Make the ListTile focusable
            focusNode: _supportGroupFocusNode,
            onFocusChange: (hasFocus) {
              if (hasFocus) {
                setState(() {
                  _currentFocusedNode = _supportGroupFocusNode;
                });
              } else if (_currentFocusedNode == _supportGroupFocusNode) {
                setState(() {
                  _currentFocusedNode = null;
                });
              }
            },
            child: GestureDetector( // Use GestureDetector for onTap
              onTap: () => launchurl("https://t.me/teledax"),
              child: ListTile(
                tileColor: _currentFocusedNode == _supportGroupFocusNode ? Colors.blue.shade100 : null, // Visual feedback
                title: Text("Support Group"),
                trailing: Icon(
                  MdiIcons.telegram,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          buildDivider(),
          Focus( // Make the ListTile focusable
            focusNode: _howToUseFocusNode,
            onFocusChange: (hasFocus) {
              if (hasFocus) {
                setState(() {
                  _currentFocusedNode = _howToUseFocusNode;
                });
              } else if (_currentFocusedNode == _howToUseFocusNode) {
                setState(() {
                  _currentFocusedNode = null;
                });
              }
            },
            child: GestureDetector( // Use GestureDetector for onTap
              onTap: () => launchurl("https://telegra.ph/Teledax-tutorial-09-13"),
              child: ListTile(
                tileColor: _currentFocusedNode == _howToUseFocusNode ? Colors.blue.shade100 : null, // Visual feedback
                title: Text("How To Use ?"),
                trailing: Icon(
                  MdiIcons.frequentlyAskedQuestions,
                  color: SecondaryColor,
                ),
              ),
            ),
          ),
          buildDivider(),
          Focus( // Make the ListTile focusable
            focusNode: _aboutFocusNode,
            onFocusChange: (hasFocus) {
              if (hasFocus) {
                setState(() {
                  _currentFocusedNode = _aboutFocusNode;
                });
              } else if (_currentFocusedNode == _aboutFocusNode) {
                setState(() {
                  _currentFocusedNode = null;
                });
              }
            },
            child: GestureDetector( // Use GestureDetector for onTap
              onTap: () => Navigator.of(context).pushNamed("/devs"),
              child: ListTile(
                tileColor: _currentFocusedNode == _aboutFocusNode ? Colors.blue.shade100 : null, // Visual feedback
                title: Text("About"),
                trailing: Icon(
                  MdiIcons.information,
                  color: SecondaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _additional() {
    return Card(
      color: cardLightColor,
      child: Column(
        children: [
          Focus( // Make the ListTile focusable
            focusNode: _manageApisFocusNode,
            onFocusChange: (hasFocus) {
              if (hasFocus) {
                setState(() {
                  _currentFocusedNode = _manageApisFocusNode;
                });
              } else if (_currentFocusedNode == _manageApisFocusNode) {
                setState(() {
                  _currentFocusedNode = null;
                });
              }
            },
            child: GestureDetector( // Use GestureDetector for onTap
              onTap: () => Navigator.of(context).pushNamed("/addapi"),
              child: ListTile(
                tileColor: _currentFocusedNode == _manageApisFocusNode ? Colors.blue.shade100 : null, // Visual feedback
                title: Text("Manage APIs"),
                trailing: Icon(
                  MdiIcons.plus,
                  color: accents,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
