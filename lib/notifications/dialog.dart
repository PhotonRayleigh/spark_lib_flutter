import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

import '../navigation/app_navigator.dart';

Future<T?> showBaseDialog<T>(BuildContext context,
    {String? title, String? message}) async {
  Widget buildDialog(
    BuildContext context,
  ) {
    var headingTextStyle = Theme.of(context).textTheme.headline6!.copyWith(
          decoration: TextDecoration.underline,
        );
    return Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: BoxConstraints.expand(),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Stack(children: [
              ConstrainedBox(
                  constraints: BoxConstraints.expand(),
                  child: GestureDetector(
                    onTap: AppNavigator.safePop,
                  )),
              Center(
                  child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      child: ConstrainedBox(
                        constraints: BoxConstraints.loose(Size(
                            MediaQuery.of(context).size.width * 0.5,
                            MediaQuery.of(context).size.height)),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).dialogBackgroundColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: EdgeInsets.all(10),
                          child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (title != null)
                                    Text(
                                      title,
                                      style: headingTextStyle,
                                      textAlign: TextAlign.center,
                                    ), // Title
                                  if (message != null)
                                    Text(
                                      message,
                                      softWrap: true,
                                      textAlign: TextAlign.center,
                                    ),
                                  TextButton(
                                    child: Text("Ok"),
                                    onPressed: AppNavigator.safePop,
                                  ),
                                ],
                              )),
                        ),
                      ))),
              if (!kIsWeb &&
                  (Platform.isLinux || Platform.isMacOS || Platform.isWindows))
                Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints.tight(
                      Size(MediaQuery.of(context).size.width, 50),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: MoveWindow(),
                        ),
                        SizedBox(
                          child: MinimizeWindowButton(),
                          height: 50,
                        ),
                        SizedBox(height: 50, child: MaximizeWindowButton()),
                        SizedBox(height: 50, child: CloseWindowButton()),
                      ],
                    ),
                  ),
                ),
            ]),
          ),
        ));
  }

  return showDialog(context: context, builder: buildDialog);
}
