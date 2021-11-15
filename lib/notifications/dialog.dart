import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

// TODO: How to keep title bar drag working while dialog is active?
Future<T?> flashDialog<T>(BuildContext context,
    {String? title, String? message}) async {
  Widget buildDialog(
    BuildContext context,
    FlashController<Object?> controller,
  ) {
    return Flash.dialog(
      controller: controller,
      barrierDismissible: true,
      barrierBlur: 3.0,
      // margin: EdgeInsets.only(left: 30, right: 30),
      backgroundColor: Colors.transparent, //Theme.of(context).backgroundColor,
      //borderRadius: BorderRadius.circular(6),
      // alignment: Alignment.center,
      child: Stack(children: [
        ConstrainedBox(
            constraints: BoxConstraints.expand(),
            child: GestureDetector(
              onTap: controller.dismiss,
            )),
        Center(
            child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).backgroundColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints.loose(Size(
                          MediaQuery.of(context).size.width * 0.5,
                          MediaQuery.of(context).size.height)),
                      child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            children: [
                              Text(
                                title ?? "Alert",
                                style: Theme.of(context).textTheme.headline5,
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
                                onPressed: controller.dismiss,
                              ),
                            ],
                          )),
                    )))),
        if (!kIsWeb &&
            (Platform.isLinux || Platform.isMacOS || Platform.isWindows))
          Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints.tight(
                Size(MediaQuery.of(context).size.width, 50),
              ),
              child: MoveWindow(),
            ),
          ),
      ]),
    );
  }

  return showFlash(context: context, builder: buildDialog);
}
