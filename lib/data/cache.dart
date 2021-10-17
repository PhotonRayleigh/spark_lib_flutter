class Cache<T> {
  final Map<int, T> _list = {};

  T? operator [](int index) {
    if (_list.containsKey(index) && _list[index] != null) {
      return _list[index]!;
    } else {
      return null;
    }
  }

  operator []=(int index, T item) {
    _list[index] = item;
  }
}

class GlobalCache {
  static Map<String, Cache> cacheMap = <String, Cache>{};
}
