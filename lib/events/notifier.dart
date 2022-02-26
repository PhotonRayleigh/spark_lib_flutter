import 'package:flutter/widgets.dart';
import 'dart:async';

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

class DataNotifier<T> {
  final List<void Function(T data)> _callbacks = [];
  void notify(T data) {
    for (var func in _callbacks) {
      func(data);
    }
  }

  void addListener(void Function(T data) callback) {
    if (_callbacks.contains(callback)) return;
    _callbacks.add(callback);
  }

  void removeListener(void Function(T data) callback) {
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

class StreamNotifier<T> {
  T? cache;
  bool pause = true;
  late StreamController<T> _controller = StreamController.broadcast(
    onListen: _onListen,
    onCancel: _onCancel,
  );
  Stream<T> get stream => _controller.stream;
  void close() {
    _controller.close();
  }

  void notify(T data) {
    if (!pause)
      _controller.add(data);
    else
      cache = data;
  }

  void _onListen() {
    pause = false;
    if (cache != null) {
      T localCache = cache!;
      _controller.add(localCache);
      cache = null;
    }
  }

  void _onCancel() {
    pause = true;
  }
}

// This won't actually work. Need to be able to capture the last state,
// which I currently can't do. RIP, guess this is how it goes.
// class WhenStreamBuilder<T> extends StreamBuilder<T> {
//   WhenStreamBuilder(
//       {required Stream<T> stream,
//       required T initialData,
//       required Widget Function(BuildContext context, AsyncSnapshot<T> snapshot)
//           builder,
//       this.buildWhen})
//       : super(stream: stream, initialData: initialData, builder: builder);

//   final bool Function(T data)? buildWhen;

//   @override
//   State<StreamBuilderBase<T, AsyncSnapshot<T>>> createState() {
//     return StreamNotifierState<T, AsyncSnapshot<T>>();
//   }
// }

// class StreamNotifierState<T, S> extends State<StreamBuilderBase<T, S>> {
//   StreamSubscription<T>? _subscription; // ignore: cancel_subscriptions
//   late S _summary;

//   @override
//   void initState() {
//     super.initState();
//     _summary = widget.initial();
//     if ((widget as WhenStreamBuilder<T>).buildWhen == null) {
//       onData = (T data) {
//         setState(() {
//           _summary = widget.afterData(_summary, data);
//         });
//       };
//     } else {
//       bool Function(T) buildWhen = (widget as WhenStreamBuilder<T>).buildWhen!;
//       onData = (T data) {
//         if (buildWhen(data))
//           setState(() {
//             _summary = widget.afterData(_summary, data);
//           });
//       };
//     }
//     _subscribe();
//   }

//   @override
//   void didUpdateWidget(StreamBuilderBase<T, S> oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.stream != widget.stream) {
//       if (_subscription != null) {
//         _unsubscribe();
//         _summary = widget.afterDisconnected(_summary);
//       }
//       _subscribe();
//     }
//   }

//   @override
//   Widget build(BuildContext context) => widget.build(context, _summary);

//   @override
//   void dispose() {
//     _unsubscribe();
//     super.dispose();
//   }

//   late void Function(T) onData;

//   void _subscribe() {
//     if (widget.stream != null) {
//       _subscription = widget.stream!.listen((T data) {
//         onData(data);
//       }, onError: (Object error, StackTrace stackTrace) {
//         setState(() {
//           _summary = widget.afterError(_summary, error, stackTrace);
//         });
//       }, onDone: () {
//         setState(() {
//           _summary = widget.afterDone(_summary);
//         });
//       });
//       _summary = widget.afterConnected(_summary);
//     }
//   }

//   void _unsubscribe() {
//     if (_subscription != null) {
//       _subscription!.cancel();
//       _subscription = null;
//     }
//   }
// }

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
