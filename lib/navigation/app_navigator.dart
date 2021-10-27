import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:collection';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'dart:io';

class AppNavigator {
  static NavigatorState? _rootNavigator;
  static NavigatorState get rootNavigator {
    if (_rootNavigator == null) {
      return rootNavKey.currentState!;
    } else
      return _rootNavigator!;
  }

  static set rootNavigator(val) {
    _rootNavigator = val;
  }

  static GlobalKey<NavigatorState> rootNavKey = GlobalKey<NavigatorState>();

  static late Widget homeScreen;
  static Queue<Widget> screenStack = Queue<Widget>();
  static Widget get currentView => screenStack.last;

  static BackModel backModel = BackModel.toHome;

  static List<Function> preNavCallbacks = <Function>[];

  static bool _initialized = false;

  static initialize(
      {required Widget home, BackModel backModel = BackModel.toHome}) {
    // Prevent double initialization on hot reload or by error.
    if (_initialized) return;
    // Setup home and screen stack
    AppNavigator.homeScreen = home;
    screenStack.add(AppNavigator.homeScreen);

    // Setup back model for navigation
    AppNavigator.backModel = backModel;
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

  static void runPreNavCallbacks() {
    for (var callback in preNavCallbacks) {
      callback();
    }
    preNavCallbacks.clear();
  }

  static void navigateTo(Widget screen, {BuildContext? context}) {
    runPreNavCallbacks();
    navFunc(screen, context: context);
  }

  static NavigationFunc navFunc = _toHomeNavigateTo;

  static void navigateBack({BuildContext? context}) {
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

  static void _inOutNavigateTo(Widget screen, {BuildContext? context}) {
    screenStack.add(screen);
    rootNavigator.pushReplacement(MaterialPageRoute(
      builder: (context) {
        return screen;
      },
    ));
  }

  static void _toHomeNavigateTo(Widget screen, {BuildContext? context}) {
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

  static void safePop() {
    if (rootNavigator.canPop()) rootNavigator.pop();
  }

  static Future<bool> defaultOnWillPop() {
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

// inOut means back always takes you to the last navigated screen
// toHome means back always takes you towards home
enum BackModel { inOut, toHome }
typedef NavigationFunc = void Function(Widget screen, {BuildContext? context});
