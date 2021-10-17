import 'cell.dart';
export 'cell.dart';

class TypedList {
  List<Cell> _list = <Cell>[];

  int get length {
    return _list.length;
  }

  TypedList({List<Cell>? list}) {
    if (list != null) {
      _list = list;
    }
  }

  dynamic operator [](int index) {
    return _list[index].value;
  }

  operator []=(int index, dynamic value) {
    _list[index] = value;
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
