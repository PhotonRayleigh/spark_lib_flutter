import 'package:flutter/widgets.dart';

/*
  The important thing with this paradigm is that you have
  you manualy invoke UI rebuilds. There is no automatic
  binding by default. Every change that you make that you
  want reflected in the UI has to be manually invoked via notify().

  It is more verbose, but offers tight control over how and when things update.
  Furthermore, it decouples the component API from the data. 
  The UI and Component can decide when it is relevant to notify subscribers of
  changes. Data is read directly without wrappers.

  This does violate immutability, but not strictly so. I can freely implement
  patterns that make state immutable. One thing this does make harder though,
  without explicit state objects, is an undo system. I'll have to think
  about that one.

  Either way, I think this is a good base to start from. It can be extended
  later.
 */

/// A simple construct to notify subscribers of an event.
/// Subscribers can register callbacks with [addListener]
/// that get called when [notify] is invoked.
///
/// Can also be used as a mixin on classes.
class Notifier {
  final List<void Function()> _callbacks = [];

  void notify() {
    for (var func in _callbacks) {
      func();
    }
  }

  void addListener(void Function() callback) {
    if (_callbacks.contains(callback)) return;
    _callbacks.add(callback);
  }

  void removeListener(void Function() callback) {
    _callbacks.remove(callback);
  }

  void clearListeners() {
    _callbacks.clear();
  }

  void printListeners() {
    for (var callback in _callbacks) {
      print(callback);
    }
  }
}

/// Designed to work with [Notifier], [NotifierBuilder] will subscribe
/// to a given [Notifier] and will rebuild whenever [Notifier.notify]
/// is called.
///
/// No mechanism for communicating state is provided. With this system,
/// you are expected to provide the state object(s) to watch, the state
/// of which will be captured at the time [Notifier.notify] is called.
class NotifierBuilder extends StatefulWidget {
  const NotifierBuilder(
      {required this.builder,
      required this.notifier,
      this.callbackAction,
      Key? key})
      : super(key: key);
  final Widget Function(BuildContext context) builder;
  final Notifier notifier;
  final void Function()? callbackAction;

  @override
  _NotifierBuilderState createState() => _NotifierBuilderState();
}

class _NotifierBuilderState extends State<NotifierBuilder> {
  void callback() {
    setState(() {
      if (widget.callbackAction != null) widget.callbackAction;
    });
  }

  @override
  void initState() {
    super.initState();

    widget.notifier.addListener(callback);
  }

  @override
  void dispose() {
    widget.notifier.removeListener(callback);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}
