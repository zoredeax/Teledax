import 'package:Teledax/style/constants.dart';
import 'package:Teledax/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for RawKeyboardListener
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

// This function now returns a Widget, making it more explicit
Widget developerTile({
  @required name,
  @required githubUsername,
  @required profileImage,
  @required telegramUsername,
  @required devtype,
}) {
  return ListTile(
    leading: Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: NetworkImage(profileImage),
        ),
      ),
    ),
    title: Text(
      name,
      style: TextStyle(
        fontSize: 20,
        color: fontColor,
      ),
      textAlign: TextAlign.center,
    ),
    subtitle: Padding(
      padding: const EdgeInsets.only(left: 50, top: 5),
      child: Text(
        devtype,
        style: TextStyle(color: fontColor),
      ),
    ),
    trailing: Row( // Changed Wrap to Row for better focus traversal control
      mainAxisSize: MainAxisSize.min, // Important for Row in trailing
      children: [
        FocusableActionDetector( // Make GitHub IconButton focusable
          builder: (context, isHovered, isFocused) {
            return IconButton(
              icon: Icon(
                MdiIcons.github,
                color: isFocused ? Colors.deepOrange : fontColor, // Visual feedback
              ),
              onPressed: () async {
                await launchurl("https://github.com/${githubUsername}");
              },
            );
          },
        ),
        FocusableActionDetector( // Make Telegram IconButton focusable
          builder: (context, isHovered, isFocused) {
            return IconButton(
              icon: Icon(
                MdiIcons.telegram,
                color: isFocused ? Colors.deepOrange : Colors.blueAccent, // Visual feedback
              ),
              onPressed: () async {
                await launchurl("https://telegram.me/${telegramUsername}");
              },
            );
          },
        )
      ],
    ),
  );
}
