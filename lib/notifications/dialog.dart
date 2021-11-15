import 'package:flash/flash.dart';
import 'package:flutter/material.dart';

Future<T?> flashDialog<T>(BuildContext context,
    {String? title, String? message}) async {
  Widget buildDialog(
    BuildContext context,
    FlashController<Object?> controller,
  ) {
    return Flash.dialog(
      controller: controller,
      // margin: EdgeInsets.only(left: 30, right: 30),
      backgroundColor: Theme.of(context).backgroundColor,
      borderRadius: BorderRadius.circular(1),
      child: FractionallySizedBox(
          widthFactor: 0.5,
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
      barrierDismissible: true,
    );
  }

  return showFlash(context: context, builder: buildDialog);
}
