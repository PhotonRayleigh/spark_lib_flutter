import 'cell.dart';
export 'cell.dart';

class TypedList extends Iterable {
  List<Cell> _list = <Cell>[];

  int get length {
    return _list.length;
  }

  bool get isEmpty => _list.isEmpty;
  bool get isNotEmpty => _list.isNotEmpty;

  Iterator get iterator {
    return _TypedListIterator(this);
  }

  TypedList({List<Cell>? list}) {
    if (list != null) {
      _list = list;
    }
  }

  TypedList.from(TypedList list) {
    _list = list._list;
  }

  dynamic operator [](int index) {
    return _list[index].value;
  }

  operator []=(int index, dynamic value) {
    _list[index].value = value;
  }

  Type type(int index) {
    return _list[index].type;
  }

  Cell<dynamic> cell(int index) {
    return _list[index];
  }

  void replace(int index, Cell value) {
    _list[index] = value;
  }

  void add(Cell newCell) {
    _list.add(newCell);
  }

  void insert(int index, Cell newCell) {
    _list.insert(index, newCell);
  }

  bool remove(Cell value) {
    return _list.remove(value);
  }

  Cell<dynamic> removeAt(int index) {
    return _list.removeAt(index);
  }
}

class _TypedListIterator extends Iterator {
  int index = -1;
  TypedList owner;

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
