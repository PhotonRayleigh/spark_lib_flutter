import 'package:flutter/material.dart';
import 'package:spark_lib/navigation/app_navigator.dart';

class SparkPage extends StatelessWidget {
  final Widget child;
  final Future<bool> Function()? onWillPop;
  final Key? key;

  SparkPage(
      {this.key,
      required this.child,
      this.onWillPop = AppNavigator.defaultOnWillPop})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(child: child, onWillPop: onWillPop);
  }
}
