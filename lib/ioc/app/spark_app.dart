import 'package:flutter/material.dart';
import 'dart:io';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'package:spark_lib/ioc/navigation/app_navigator.dart';
import 'package:spark_lib/ioc/app/app_system_manager.dart';

/// Container class for root app widget in Spark apps.
/// On creation, this class creates the root widget for the app
/// and stores it in [SparkApp.treeRoot].
class SparkApp {
  // Input parameters
  Widget home;
  ThemeData? theme;
  String? title;
  AppSystemManagerFactory systemManagerBuilder;
  late GlobalKey<AppSystemManagerState> sysManagerKey;

  AppNavigator navigator;

  // Build app-root
  late Widget treeRoot;

  SparkApp({
    required this.home,
    required this.navigator,
    this.theme,
    this.title,
    required this.systemManagerBuilder,
    GlobalKey<AppSystemManagerState>? sysManagerKey,
  }) {
    navigator.initialize(home: home);

    Widget tempChild = MaterialApp(
      navigatorKey: navigator.rootNavKey,
      debugShowCheckedModeBanner: false,
      home: home,
      theme: theme ?? ThemeData.light(),
      title: title ?? "Flutter App",
    );

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      tempChild =
          WindowBorder(color: Colors.blueGrey, width: 1, child: tempChild);
    }

    // var makeSystemManager = systemManagerBuilder ??
    //     ({Key? key, required Widget child}) {
    //       return AppSystemManager(key: key, child: child);
    //     };
    this.sysManagerKey = sysManagerKey ?? GlobalKey<AppSystemManagerState>();
    tempChild = systemManagerBuilder(child: tempChild, key: sysManagerKey);
    treeRoot = tempChild;
  }
}
