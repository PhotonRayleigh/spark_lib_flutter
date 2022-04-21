import 'package:flutter/material.dart';
import 'package:spark_lib/navigation/app_navigator.dart';

class SparkPage extends StatelessWidget {
  final Widget child;
  late final Future<bool> Function() onWillPop;
  final Key? key;
  final AppNavigator navigator;

  SparkPage(
      {this.key,
      required this.child,
      required this.navigator,
      Future<bool> Function()? onWillPop})
      : super(key: key) {
    this.onWillPop = onWillPop ?? navigator.defaultOnWillPop;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(child: child, onWillPop: onWillPop);
  }
}
