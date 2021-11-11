import 'package:flutter/material.dart';
import 'dart:io';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'package:spark_lib/widgets/shift_right_fixer.dart';
import 'package:spark_lib/navigation/spark_nav.dart';
import 'package:spark_lib/app/app_system_manager.dart';

/// Static class with convenience build method for building an
/// app using SparkLib.
class SparkApp {
  static Widget build({
    required Widget home,
    ThemeData? theme,
    String? title,
    AppSystemManager Function({Key? key, required Widget child})? systemManager,
    Key? sysManagerKey,
  }) {
    AppNavigator.initialize(home: home);

    var materialApp = MaterialApp(
      navigatorKey: AppNavigator.rootNavKey,
      debugShowCheckedModeBanner: false,
      home: home,
      theme: theme ?? ThemeData.light(),
      title: title ?? "Flutter App",
    );

    Widget sysManagerChild;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sysManagerChild =
          WindowBorder(color: Colors.blueGrey, width: 1, child: materialApp);
    } else {
      sysManagerChild = materialApp;
    }

    var makeSystemManager = systemManager ??
        ({Key? key, required Widget child}) {
          return AppSystemManager(key: key, child: sysManagerChild);
        };

    return ShiftRightFixer(
        child: makeSystemManager(child: sysManagerChild, key: sysManagerKey));
  }
}