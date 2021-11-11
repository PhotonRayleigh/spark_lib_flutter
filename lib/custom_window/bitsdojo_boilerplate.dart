import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter/widgets.dart';

/// Required when using Bitsdojo for custom Window behavior on desktop.
/// Window will not show without this.
/// REMINDER: Custom native code is required per platform per Bitsdojo
/// documentation.
void initializeBitsdojo(
    {Size initialSize = const Size(900, 600),
    Size minSize = const Size(200, 200),
    Alignment alignment = Alignment.center,
    String title = "Flutter App"}) {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    doWhenWindowReady(() {
      appWindow.size = initialSize;
      appWindow.minSize = minSize;
      appWindow.alignment = alignment;
      appWindow.title = title;
      appWindow.show();
    });
  }
}
