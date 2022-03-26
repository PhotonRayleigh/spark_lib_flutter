import 'package:flutter/widgets.dart';

// inOut means back always takes you to the last navigated screen
// toHome means back always takes you towards home
enum BackModel { inOut, toHome }
typedef NavigationFunc = void Function(Widget screen, {BuildContext? context});
