import 'package:flutter/material.dart';
import 'dart:io';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'package:spark_lib/navigation/spark_nav.dart';
import 'package:spark_lib/app/app_system_manager.dart';

/// Container class for root app widget in Spark apps.
/// On creation, this class creates the root widget for the app
/// and stores it in [SparkApp.treeRoot].
class SparkApp {
  // Input parameters
  Widget home;
  ThemeData? theme;
  String? title;
  AppSystemManager Function({Key? key, required Widget child})?
      systemManagerBuilder;
  Key? sysManagerKey;

  // Build app-root
  late Widget treeRoot;

  SparkApp({
    required this.home,
    this.theme,
    this.title,
    this.systemManagerBuilder,
    this.sysManagerKey,
  }) {
    AppNavigator.initialize(home: home);

    Widget tempChild = MaterialApp(
      navigatorKey: AppNavigator.rootNavKey,
      debugShowCheckedModeBanner: false,
      home: home,
      theme: theme ?? ThemeData.light(),
      title: title ?? "Flutter App",
    );

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      tempChild =
          WindowBorder(color: Colors.blueGrey, width: 1, child: tempChild);
    }

    var makeSystemManager = systemManagerBuilder ??
        ({Key? key, required Widget child}) {
          return AppSystemManager(key: key, child: child);
        };

    tempChild = makeSystemManager(child: tempChild, key: sysManagerKey);
    treeRoot = tempChild;
  }

  static Widget build({
    required Widget home,
    ThemeData? theme,
    String? title,
    AppSystemManager Function({Key? key, required Widget child})? systemManager,
    Key? sysManagerKey,
  }) {
    AppNavigator.initialize(home: home);

    Widget tempChild = MaterialApp(
      navigatorKey: AppNavigator.rootNavKey,
      debugShowCheckedModeBanner: false,
      home: home,
      theme: theme ?? ThemeData.light(),
      title: title ?? "Flutter App",
    );

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      tempChild =
          WindowBorder(color: Colors.blueGrey, width: 1, child: tempChild);
    }

    var makeSystemManager = systemManager ??
        ({Key? key, required Widget child}) {
          return AppSystemManager(key: key, child: child);
        };

    tempChild = makeSystemManager(child: tempChild, key: sysManagerKey);

    // return ShiftRightFixer(child: tempChild);
    return tempChild;
  }
}
