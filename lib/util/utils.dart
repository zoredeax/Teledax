import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

launchurl(urlString) async {
  if (await canLaunch(urlString)) {
    await launch(urlString);
  } else {
    log("Can't Launch");
  }
}
