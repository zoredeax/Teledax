import 'package:Teledax/style/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for RawKeyboardListener (good practice)

AppBar customAppbar(appbarText, BuildContext context) {
  // Declare the FocusNode locally within the function
  final FocusNode settingsIconFocusNode = FocusNode();

  return AppBar(
    actions: [
      Focus( // Wrap the IconButton with Focus
        focusNode: settingsIconFocusNode,
        onFocusChange: (hasFocus) {
          // This setState is crucial for the visual feedback to work
          // as it forces a rebuild of the IconButton.
          // However, since this is a function, it relies on the parent
          // widget to rebuild the AppBar for this change to be visible.
          // In many cases, the parent Scaffold will rebuild when focus changes.
          if (hasFocus) {
            print("Settings icon focused!");
          }
        },
        child: IconButton(
          icon: Icon(
            Icons.settings,
            // Change color based on focus state
            color: settingsIconFocusNode.hasFocus ? Colors.deepOrange : accents,
          ),
          onPressed: () => Navigator.of(context).pushNamed("/setting"),
        ),
      )
    ],
    backgroundColor: lightColor,
    elevation: 0,
    centerTitle: true,
    title: Text(
      appbarText,
      style: TextStyle(color: fontColor),
    ),
  );
}
