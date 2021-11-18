import 'package:flutter/material.dart';

void showBanner(BuildContext context,
    {required String message, List<BannerAction>? actions}) {
  var sm = ScaffoldMessenger.of(context);

  List<Widget> bannerActions = [];

  if (actions != null) {
    for (var action in actions) {
      bannerActions.add(TextButton(
        child: Text(action.label),
        onPressed: () {
          action.action();
          sm.hideCurrentMaterialBanner();
        },
      ));
    }
  } else {
    bannerActions.add(TextButton(
      child: Text("Dismiss"),
      onPressed: () {
        sm.hideCurrentMaterialBanner();
      },
    ));
  }

  MaterialBanner banner = MaterialBanner(
    content: Text(message),
    actions: bannerActions,
    backgroundColor: Theme.of(context).secondaryHeaderColor,
  );

  sm.showMaterialBanner(banner);
}

class BannerAction {
  void Function() action;
  String label;

  BannerAction(this.label, this.action);
}
