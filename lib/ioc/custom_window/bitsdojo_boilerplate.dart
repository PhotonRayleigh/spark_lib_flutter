import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter/widgets.dart';

import 'window_data.dart';

/// Required when using Bitsdojo for custom Window behavior on desktop.
/// Window will not show without this.
/// REMINDER: Custom native code is required per platform per Bitsdojo
/// documentation.
void initializeBitsdojo(WindowData? data) {
  WindowData d = data ?? WindowData();
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    doWhenWindowReady(() {
      appWindow.size = d.initialSize;
      appWindow.minSize = d.minimumSize;
      appWindow.alignment = d.windowAlignment;
      appWindow.title = d.windowTitle;
      appWindow.show();
    });
  }
}
