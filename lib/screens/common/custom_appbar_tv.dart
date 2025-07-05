import 'package:Teledax/style/constants.dart';
import 'package:flutter/material.dart';

// This is the new StatefulWidget
class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String appbarText;

  // Constructor now takes named parameters
  CustomAppBar({Key key, @required this.appbarText}) : super(key: key);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight); // Standard AppBar height
}

class _CustomAppBarState extends State<CustomAppBar> {
  // Declare the FocusNode as a member of the State class
  FocusNode _settingsIconFocusNode;

  @override
  void initState() {
    super.initState();
    // Initialize the FocusNode in initState
    _settingsIconFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Dispose the FocusNode when the widget is removed from the tree
    _settingsIconFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [
        Focus( // Wrap the IconButton with Focus
          focusNode: _settingsIconFocusNode,
          onFocusChange: (hasFocus) {
            // Call setState to trigger a rebuild and update the icon's color
            setState(() {
              // No need to do anything specific here, just trigger rebuild
            });
          },
          child: IconButton(
            icon: Icon(
              Icons.settings,
              // Change color based on focus state
              color: _settingsIconFocusNode.hasFocus ? Colors.deepOrange : accents,
            ),
            onPressed: () => Navigator.of(context).pushNamed("/setting"),
          ),
        )
      ],
      backgroundColor: lightColor,
      elevation: 0,
      centerTitle: true,
      title: Text(
        widget.appbarText, // Access appbarText via widget.appbarText
        style: TextStyle(color: fontColor),
      ),
    );
  }
}
