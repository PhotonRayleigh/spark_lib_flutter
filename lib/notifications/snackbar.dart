import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';
import 'package:tinycolor2/tinycolor2.dart';

class _SimpleTicker extends TickerProvider {
  @override
  Ticker createTicker(Function(Duration) callback) {
    return Ticker(callback);
  }
}

OverlayEntry? _activeSnackBar;

// TODO: This really needs better theme controls
Future<T?> showSnackBar<T>(BuildContext context, {String? message}) {
  var completer = Completer<T?>();
  Future<T?> future;
  var themeData = Theme.of(context);

  var dismissButtonColor = themeData.colorScheme.primary;
  var materialColor = MaterialStateColor.resolveWith((states) {
    if (states.contains(MaterialState.hovered)) {
      return TinyColor(dismissButtonColor).brighten(40).color;
    } else {
      return TinyColor(dismissButtonColor).brighten(20).color;
    }
    // return TinyColor(dismissButtonColor).darken().color;
  });
  var buttonStyle = ButtonStyle(foregroundColor: materialColor);
  var overlay = Overlay.of(context);
  void Function() entryProxy = () {};

  var animationController = AnimationController(
      vsync: _SimpleTicker(), duration: Duration(milliseconds: 150));
  Animation<double> animation =
      CurvedAnimation(parent: animationController, curve: Curves.easeIn);

  var entry = OverlayEntry(builder: (context) {
    var screenSize = MediaQuery.of(context).size;
    return Theme(
      data: themeData,
      child: FadeTransition(
        opacity: animation,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Transform.translate(
            offset: Offset(0, -20),
            child: ConstrainedBox(
              constraints: BoxConstraints.loose(
                  Size(screenSize.width * 0.8, screenSize.height)),
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white54,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            flex: 1,
                            fit: FlexFit.loose,
                            child: Text(
                              message ?? "Stub Notification",
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              style: themeData.primaryTextTheme.bodyText1!
                                  .copyWith(
                                      color: Colors.grey[900],
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal),
                            ),
                          ),
                          TextButton(
                            style: buttonStyle,
                            child: Text(
                              "Dismiss",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onPressed: () => entryProxy(),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  });

  bool cancelling = false;
  void cleanup() {
    if (!cancelling) {
      cancelling = true;
      entry.remove();
      _activeSnackBar = null;
      completer.complete(null);
    }
  }

  future = completer.future;

  if (_activeSnackBar != null) _activeSnackBar!.remove();
  overlay!.insert(entry);
  _activeSnackBar = entry;
  animationController.forward();
  var time = Timer(Duration(seconds: 3), () {
    animationController.reverse().whenComplete(cleanup);
  }); // TODO: implement user specified actions and return values
  entryProxy = () {
    time.cancel();
    animationController.reverse().whenComplete(cleanup);
  };

  return future;
}
