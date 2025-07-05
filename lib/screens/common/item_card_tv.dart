import 'package:Teledax/screens/common/icon_selector.dart';
import 'package:Teledax/screens/common/reuseable_items.dart';
import 'package:Teledax/style/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for RawKeyboardListener (for D-pad)
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ItemCard extends StatelessWidget {
  final item;
  final chatId;
  final baseurl;
  final bool isFocused; // New property to receive focus state from parent

  ItemCard({
    @required this.item,
    @required this.chatId,
    @required this.baseurl,
    this.isFocused = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    return Card( // The Card itself will be the visual focus indicator
      elevation: isFocused ? 8 : 2, // Higher elevation when focused
      shadowColor: isFocused ? Colors.blueAccent : Colors.black, // Different shadow color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isFocused ? BorderSide(color: Colors.blue, width: 3) : BorderSide.none, // Border when focused
      ),
      color: isFocused ? Colors.blue.shade50 : cardLightColor, // Background color change
      child: InkWell(
        splashColor: accents,
        highlightColor: Colors.white30,
        onTap: () => Navigator.pushNamed(context, "/fileinfo",
            arguments: {"item": item, "chatid": chatId, "baseurl": baseurl}),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.all(5),
              leading: Padding(
                padding: const EdgeInsets.only(left: 3, top: 20),
                child: autoIconSelector(item.mimeType),
              ),
              title: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  item.insight,
                  style: TextStyle(color: fontColor, fontWeight: FontWeight.bold),
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(left: 20, top: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Flexible(
                          child: Container(
                            child: Text(
                              item.mimeType,
                              style: TextStyle(
                                color: fontColor,
                              ),
                              overflow: TextOverflow.clip,
                            ),
                          ),
                        ),
                        Text(
                          item.size,
                          style: TextStyle(color: fontColor),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 100, top: 10),
                      child: Text(
                        DateFormat('hh:mm:a - dd-MM-yy').format(item.date),
                        style: TextStyle(
                            color: fontColor, fontWeight: FontWeight.w400),
                      ),
                    )
                  ],
                ),
              ),
              trailing: FocusableActionDetector( // Make IconButton focusable
                builder: (context, isHovered, isFocusedIcon) {
                  return IconButton(
                      tooltip: "open in external apps",
                      icon: Icon(
                        MdiIcons.openInApp,
                        color: isFocusedIcon ? Colors.deepOrange : SecondaryColor, // Visual feedback for icon
                      ),
                      onPressed: () async => await showAutoIntent(
                          url: "$baseurl/$chatId/${item.fileId}/download",
                          mimeType: item.mimeType));
                },
              ),
            ),
            buildDivider(),
          ],
        ),
      ),
    );
  }
}
