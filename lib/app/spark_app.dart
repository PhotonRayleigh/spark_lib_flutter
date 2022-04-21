import 'package:flutter/material.dart';
import 'dart:io';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'package:spark_lib/navigation/app_navigator.dart';
import 'package:spark_lib/app/app_system_manager.dart';

import '../custom_window/window_data.dart';
import '../custom_window/bitsdojo_boilerplate.dart';

/// Container class for root app widget in Spark apps.
/// On creation, this class creates the root widget for the app
/// and stores it in [SparkApp.treeRoot].
class SparkApp {
  // Input parameters
  Widget home;
  ThemeData theme = ThemeData.light()..useMaterial3;
  String title = "Flutter App";
  late AppSystemManagerFactory systemManagerFactory;

  WindowData? windowData;

  // Build app-root
  late Widget treeRoot;

  SparkApp({
    required this.home,
    ThemeData? theme,
    String? title,
    AppSystemManagerFactory? systemManagerFactory,
    this.windowData,
  }) {
    AppNavigator.I.initialize(home: home);
    this.theme = theme ?? this.theme;
    this.title = title ?? this.title;

    this.systemManagerFactory = systemManagerFactory ??
        ({Key? key, required Widget child}) {
          return AppSystemManager(
            key: key,
            child: child,
          );
        };

    Widget tempChild = MaterialApp(
      navigatorKey: AppNavigator.I.rootNavKey,
      debugShowCheckedModeBanner: false,
      home: home,
      theme: this.theme,
      title: this.title,
    );

    // TODO: Make this configurable from theme
    // Note: This only works on Windows.
    if (Platform.isWindows) {
      tempChild = WindowBorder(
          color: this.theme.primaryColor, width: 1, child: tempChild);
    }

    tempChild = this.systemManagerFactory(child: tempChild);
    treeRoot = tempChild;
  }

  void run() {
    runApp(treeRoot);
    initializeBitsdojo(windowData);
  }
}
