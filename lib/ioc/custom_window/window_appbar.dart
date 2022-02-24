import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:get_it/get_it.dart';
import 'dart:io';

import 'package:spark_lib/ioc/navigation/app_navigator.dart';

/// Static class that contains methods to build app bars that
/// automatically adapt between desktop and mobile environments.
class WindowAppBar {
  /// Default WindowAppBar.
  /// Supports dragging the app bar to move the window.
  /// Depends on an AppNavigator being provided via constructor or GetIt.
  /// ToDo: Add parameters for window button colors and theme override
  static AppBar build(BuildContext context,
      {AppNavigator? navigator,
      Key? key,
      required String titleText,
      List<Widget> actions = const []}) {
    AppNavigator nav = navigator ?? GetIt.I.get<AppNavigator>();
    Widget appBarTitle;
    List<Widget> appBarActions = [];
    WindowButtonColors windowButtonColors =
        WindowButtonColors(iconNormal: Colors.white, mouseOver: Colors.black38);

    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      appBarActions = [
        ...actions,
        if (nav.currentView != nav.homeScreen)
          IconButton(
            onPressed: () {
              nav.navigateBack();
            },
            icon: Icon(Icons.arrow_back),
          ),
        MinimizeWindowButton(
          colors: windowButtonColors,
        ),
        MaximizeWindowButton(colors: windowButtonColors),
        CloseWindowButton(
            colors: WindowButtonColors(
                iconNormal: Colors.white,
                mouseOver: Colors.pink[900]?.withOpacity(0.65),
                mouseDown: Colors.pink[200])),
      ];
      appBarTitle =
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(
            child: ConstrainedBox(
                constraints: BoxConstraints.loose(Size(double.infinity, 100)),
                child: MoveWindow(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          titleText,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize:
                                Theme.of(context).textTheme.headline5?.fontSize,
                          ),
                        )))))
      ]);
    } else {
      appBarTitle = Text(
        titleText,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: Theme.of(context).textTheme.headline5?.fontSize,
        ),
      );

      appBarActions = actions;
    }

    return AppBar(
      title: appBarTitle,
      actions: appBarActions,
    );
  }
}
