import 'package:Teledax/screens/common/developer_tiles.dart'; // Ensure this import is correct
import 'package:Teledax/style/constants.dart';
import 'package:Teledax/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for RawKeyboardListener
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:package_info/package_info.dart';
import 'common/reuseable_items.dart';

class Dev extends StatefulWidget {
  @override
  _DevState createState() => _DevState();
}

class _DevState extends State<Dev> {
  var version;
  var buildNumber;

  // FocusNode for the AppBar back button
  final FocusNode _appBarBackFocusNode = FocusNode();
  // FocusNode for the first interactive element (e.g., first GitHub icon)
  final FocusNode _firstDevTileFocusNode = FocusNode();

  setversion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    setversion();

    // Request initial focus after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Try to focus the AppBar back button first, or the first interactive element
      _appBarBackFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _appBarBackFocusNode.dispose();
    _firstDevTileFocusNode.dispose(); // Dispose if you explicitly use it
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar( // Add an AppBar for consistent navigation
          backgroundColor: lightColor,
          elevation: 0,
          leading: Focus( // Make the AppBar back button focusable
            focusNode: _appBarBackFocusNode,
            onFocusChange: (hasFocus) {
              // You can add visual feedback here if needed
              if (hasFocus) print("Dev screen back button focused!");
              setState(() {}); // Trigger rebuild for visual feedback
            },
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: _appBarBackFocusNode.hasFocus ? Colors.deepOrange : fontColor, // Visual feedback
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          title: Text(
            "About", // Title for the AppBar
            style: TextStyle(color: fontColor, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              // Removed the old "About" Text as it's now in the AppBar
              Wrap(
                direction: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Center(
                      child: Text(
                        // This text is now redundant with the AppBar title
                        // "About",
                        // style: TextStyle(color: fontColor, fontSize: 20),
                      ),
                    ),
                  ),
                ],
              ),
              Image.asset("images/logo.png"),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  "TeleDax",
                  style: TextStyle(color: fontColor, fontSize: 30),
                ),
              ),
              SizedBox(height: 20),
              // Pass the first focus node to the first developerTile
              // This is a bit tricky with a function returning a Widget.
              // We'll make the _devsinfo function accept a FocusNode.
              _devsinfo(firstFocusNode: _firstDevTileFocusNode),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Version ${version ?? ''} || Build ${buildNumber ?? ''}", // Handle null for initial build
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

// Modified _devsinfo to accept a FocusNode for the first item
Widget _devsinfo({FocusNode firstFocusNode}) {
  return Card(
    elevation: 1,
    color: cardLightColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: Column(
      children: [
        // Pass the focus node to the first developerTile's GitHub button
        developerTile(
            name: "Aryan vikash",
            githubUsername: "aryanvikash",
            profileImage: "https://avatars3.githubusercontent.com/u/31583400",
            telegramUsername: "aryanvikash",
            devtype: "App Developer",
            githubFocusNode: firstFocusNode // Pass the focus node here
        ),
        SizedBox(
          height: 10,
        ),
        buildDivider(),
        developerTile(
            name: "Christy Roys",
            githubUsername: "odysseusmax",
            profileImage: "https://avatars1.githubusercontent.com/u/35767464",
            telegramUsername: "odysseusmax",
            devtype: "API Developer"),
      ],
    ),
  );
}

// Modify developerTile to accept a FocusNode for its GitHub button
Widget developerTile({
  @required name,
  @required githubUsername,
  @required profileImage,
  @required telegramUsername,
  @required devtype,
  FocusNode githubFocusNode, // New parameter for initial focus
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
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FocusableActionDetector(
          focusNode: githubFocusNode, // Assign the passed focus node
          builder: (context, isHovered, isFocused) {
            return IconButton(
              icon: Icon(
                MdiIcons.github,
                color: isFocused ? Colors.deepOrange : fontColor,
              ),
              onPressed: () async {
                await launchurl("https://github.com/${githubUsername}");
              },
            );
          },
        ),
        FocusableActionDetector(
          builder: (context, isHovered, isFocused) {
            return IconButton(
              icon: Icon(
                MdiIcons.telegram,
                color: isFocused ? Colors.deepOrange : Colors.blueAccent,
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
