import 'package:quiver/core.dart';

class Cache<T> {
  final Map<int, T> _list = {};

  Optional<T> operator [](int index) {
    if (_list.containsKey(index) && _list[index] != null) {
      return Optional.of(_list[index]!);
    } else {
      return Optional.absent();
    }
  }

  operator []=(int index, T item) {
    _list[index] = item;
  }
}

class GlobalCache {}
