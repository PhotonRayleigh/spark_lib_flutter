import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:collection';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'dart:io';

import 'package:spark_lib/navigation/nav_types.dart';

class AppNavigator {
  AppNavigator({this.backModel = BackModel.toHome, Widget? home}) {
    if (home != null) {
      initialize(home: home, backModel: backModel);
    }
  }
  NavigatorState? _rootNavigator;
  NavigatorState get rootNavigator {
    if (_rootNavigator == null) {
      return rootNavKey.currentState!;
    } else
      return _rootNavigator!;
  }

  set rootNavigator(val) {
    _rootNavigator = val;
  }

  GlobalKey<NavigatorState> rootNavKey = GlobalKey<NavigatorState>();

  late Widget homeScreen;
  Queue<Widget> screenStack = Queue<Widget>();
  Widget get currentView => screenStack.last;

  BackModel backModel = BackModel.toHome;

  List<Function> preNavCallbacks = <Function>[];

  bool _initialized = false;

  initialize({required Widget home, BackModel backModel = BackModel.toHome}) {
    // Prevent double initialization on hot reload or by error.
    if (_initialized) return;
    // Setup home and screen stack
    homeScreen = home;
    screenStack.add(homeScreen);

    // Setup back model for navigation
    backModel = backModel;
    switch (backModel) {
      case (BackModel.toHome):
        navFunc = _toHomeNavigateTo;
        break;
      case (BackModel.inOut):
        navFunc = _inOutNavigateTo;
        break;
    }

    bool navigationOverride(bool stopDefaultbuttonEvent, RouteInfo info) {
      if (screenStack.length == 1) return false;
      navigateBack();
      return true;
    }

    // WARNING: This will break backing out of popups.
    // BackButtonInterceptor.add(navigationOverride);
    _initialized = true;
  }

  void runPreNavCallbacks() {
    for (var callback in preNavCallbacks) {
      callback();
    }
    preNavCallbacks.clear();
  }

  void navigateTo(Widget screen, {BuildContext? context}) {
    runPreNavCallbacks();
    navFunc(screen, context: context);
  }

  late NavigationFunc navFunc; // = _toHomeNavigateTo;

  void navigateBack({BuildContext? context}) {
    if (screenStack.length == 1) return;
    runPreNavCallbacks();
    screenStack.removeLast();
    rootNavigator.pushReplacement(MaterialPageRoute(
      builder: (context) {
        return screenStack.last;
      },
    ));
    // if (rootNavigator.canPop()) rootNavigator.pop();
  }

  void _inOutNavigateTo(Widget screen, {BuildContext? context}) {
    screenStack.add(screen);
    rootNavigator.pushReplacement(MaterialPageRoute(
      builder: (context) {
        return screen;
      },
    ));
  }

  void _toHomeNavigateTo(Widget screen, {BuildContext? context}) {
    // Default navigation behavior is to make the back
    // button take you towards the home screen.
    if (screen == homeScreen) {
      screenStack.clear();
    }
    screenStack.add(screen);
    rootNavigator.pushReplacement(MaterialPageRoute(
      builder: (context) {
        return screen;
      },
    ));
  }

  void safePop() {
    if (rootNavigator.canPop()) rootNavigator.pop();
  }

  Future<bool> defaultOnWillPop() {
    // Normal pop if we're not on first layer of navigator (so overlay is up)
    // Quits to launcher if back button is pressed at home
    if ((Platform.isAndroid || Platform.isIOS) &&
        currentView == homeScreen &&
        !rootNavigator.canPop()) {
      return Future<bool>(() => true);
    } else if (rootNavigator.canPop()) {
      safePop();
    } else {
      navigateBack();
    }
    return Future<bool>(() => false);
  }
}
