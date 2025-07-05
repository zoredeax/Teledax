import 'package:Teledax/player/audioPlayer.dart';
import 'package:Teledax/screens/common/reuseable_items.dart';
import 'package:Teledax/style/constants.dart';
import 'package:Teledax/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for RawKeyboardListener
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Needed for audio/video playback settings

class FIleInfo extends StatefulWidget {
  @override
  _FIleInfoState createState() => _FIleInfoState();
}

class _FIleInfoState extends State<FIleInfo> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var item;
  var data;
  var baseurl;

  // FocusNodes for interactive elements
  final FocusNode _fabFocusNode = FocusNode();
  final FocusNode _playButtonFocusNode = FocusNode();
  final FocusNode _backButtonFocusNode = FocusNode(); // For the implicit back button

  @override
  void initState() {
    super.initState();
    // Request initial focus after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Determine which button should get initial focus
      // If it's a video, focus the play button, otherwise the FAB
      if (item != null && item.mimeType != null && item.mimeType.contains("video")) {
        _playButtonFocusNode.requestFocus();
      } else {
        _fabFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _fabFocusNode.dispose();
    _playButtonFocusNode.dispose();
    _backButtonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    data = ModalRoute.of(context).settings.arguments;
    item = data['item'];
    baseurl = data["baseurl"];

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: lightColor,
        // AppBar with a back button for TV navigation
        appBar: AppBar(
          backgroundColor: lightColor,
          elevation: 0,
          leading: Focus( // Make the AppBar back button focusable
            focusNode: _backButtonFocusNode,
            onFocusChange: (hasFocus) {
              // You can add visual feedback here if needed
              if (hasFocus) print("Back button focused!");
            },
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: _backButtonFocusNode.hasFocus ? Colors.deepOrange : fontColor, // Visual feedback
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          title: Text(
            "File Info", // You might want to make this dynamic based on item.insight
            style: TextStyle(color: fontColor),
          ),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 100 * 25,
              child: urlImageLoader(data, item),
            ),
            Expanded( // Use Expanded to allow SingleChildScrollView to take available space
              child: SingleChildScrollView(
                child: Card(
                  child: ListTile(
                    title: Text(
                      "${item.insight}",
                      style: TextStyle(
                          color: fontColor,
                          fontSize:
                              MediaQuery.of(context).size.height / 100 * 2.7,
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        ListTile(
                          title: Text(
                            "${item.size}",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: fontColor, fontSize: 15),
                          ),
                        ),
                        buildDivider(),
                        ListTile(
                          title: Text(
                            " ${item.mimeType}",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: fontColor, fontSize: 15),
                          ),
                        ),
                        buildDivider(),
                        ListTile(
                          title: Text(
                            "${DateFormat('hh:mm:a - dd-MM-yy').format(item.date)}",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: fontColor, fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        floatingActionButton: Focus( // Make FAB focusable
          focusNode: _fabFocusNode,
          onFocusChange: (hasFocus) {
            // Add visual feedback for FAB if needed
            if (hasFocus) print("FAB focused!");
          },
          child: FloatingActionButton(
            onPressed: () async {
              await showAutoIntent(
                url: "$baseurl/${data['chatid']}/${item.fileId}/download",
                mimeType: item.mimeType,
              );
            },
            backgroundColor: SecondaryColor,
            child: Icon(
              MdiIcons.openInApp,
              color: Colors.white,
            ),
            elevation: _fabFocusNode.hasFocus ? 25 : 20, // Increase elevation when focused
          ),
        ),
        bottomNavigationBar: _autoplayer(item),
      ),
    );
  }

  Widget _autoplayer(item) {
    if (item.mimeType.contains("video")) {
      return _bottomPlayButton();
    } else if (item.mimeType.contains("audio")) {
      return PlayerWidget(
          url: "$baseurl/${data['chatid']}/${item.fileId}/download");
    }
    return null;
  }

  Widget urlImageLoader(data, item) {
    return Image.network(
      "$baseurl/${data['chatid']}/${item.fileId}/thumbnail",
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          "images/not-found.png",
        );
      },
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes
                : null,
          ),
        );
      },
    );
  }

  // Bottom Button
  Widget _bottomPlayButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height / 100 * 8,
        child: Focus( // Make the FlatButton focusable
          focusNode: _playButtonFocusNode,
          onFocusChange: (hasFocus) {
            // Add visual feedback for the play button if needed
            if (hasFocus) print("Play button focused!");
          },
          child: FlatButton.icon(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
            onPressed: () {
              Navigator.of(context).pushNamed("/videoplayer", arguments: {
                "item": item,
                "baseurl": baseurl,
                "chatid": data['chatid'],
              });
            },
            icon: Icon(
              MdiIcons.play,
              color: Colors.white,
              size: 40,
            ),
            label: Text(
              "Play",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            splashColor: accents,
            color: _playButtonFocusNode.hasFocus ? Colors.blue.shade700 : accents, // Change color when focused
          ),
        ),
      ),
    );
  }
}
