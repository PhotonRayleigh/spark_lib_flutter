import 'box.dart';
export 'box.dart';

/// A list collection that uses Box<T> object
/// to enforce types on a per-element basis.
class BoxList extends Iterable {
  List<Box> _list = <Box>[];

  int get length {
    return _list.length;
  }

  bool get isEmpty => _list.isEmpty;
  bool get isNotEmpty => _list.isNotEmpty;

  Iterator get iterator {
    return _TypedListIterator(this);
  }

  BoxList([List<Box>? list]) {
    if (list != null) {
      _list = list;
    }
  }

  /// Makes a full copy of the source list into a new list.
  BoxList.of(BoxList list) {
    _list = List.of(list._list);
  }

  /// Adds all the elements from the source list to a new list.
  BoxList.from(BoxList list) {
    _list = List.from(list._list);
  }

  /// Bracket notation will return the value contained
  /// in the [Box] at the index, like a normal [List].
  dynamic operator [](int index) {
    return _list[index].value;
  }

  /// Bracket assignment will assign the value directly to
  /// the [Box]'s value, like a normal [List].
  operator []=(int index, dynamic value) {
    _list[index].value = value;
  }

  /// Shorthand to get the value of a box as a specific type.
  T getAs<T>(int index) => _list[index].valueAs<T>();

  /// Shorthand to set the value of a box with a specific type.
  /// Not really necessary, this just offers a way to set values
  /// that makes it apparent what type the programmer intends to insert
  /// into the box.
  void setAs<T>(int index, T value) => _list[index].setAs<T>(value);

  Type type(int index) {
    return _list[index].type!;
  }

  Box<dynamic> cell(int index) {
    return _list[index];
  }

  void replace(int index, Box newBox) {
    _list[index] = newBox;
  }

  void add(Box newBox) {
    _list.add(newBox);
  }

  void insert(int index, Box newBox) {
    _list.insert(index, newBox);
  }

  bool remove(Box value) {
    return _list.remove(value);
  }

  Box<dynamic> removeAt(int index) {
    return _list.removeAt(index);
  }

  @override
  void forEach(void Function(dynamic element) action) {
    super.forEach(action);
    for (int i = 0; i < _list.length; i++) {
      action(_list[i].value);
    }
  }

  void forEachBox(void Function(Box<dynamic> element) action) {
    for (int i = 0; i < _list.length; i++) {
      action(_list[i]);
    }
  }
}

class _TypedListIterator extends Iterator {
  int index = -1;
  BoxList owner;

  _TypedListIterator(this.owner);

  bool moveNext() {
    if (owner.isEmpty) return false;
    if ((index + 1) < owner.length) {
      index++;
      return true;
    } else {
      return false;
    }
  }

  dynamic get current {
    return owner[index];
  }
}
