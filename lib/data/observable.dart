import 'package:flutter/widgets.dart';

class Rxb extends StatefulWidget {
  Rxb(this.builder, this.observee, {Key? key}) : super(key: key);

  final Widget Function() builder;
  final Observable observee;

  @override
  State<Rxb> createState() {
    return _RxbState();
  }
}

class _RxbState extends State<Rxb> {
  _RxbState();

  @override
  void initState() {
    super.initState();
    widget.observee.callbacks[widget] = () {
      setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder();
  }

  @override
  void dispose() {
    widget.observee.callbacks.remove(widget);
    super.dispose();
  }
}

class Observable<T> {
  T _value;
  T get value {
    Future(update);
    return _value;
  }

  set value(T value) {
    _value = value;
    Future(update);
  }

  final Map<Rxb, void Function()> callbacks = {};

  Observable(this._value);

  Rxb observe(Widget Function() builder) {
    return Rxb(builder, this);
  }

  void update() {
    callbacks.forEach((Rxb widget, Function callback) {
      callback();
    });
  }
}
