import 'cell_base.dart';

abstract class TypedListBase {
  List<CellBase> _list = <CellBase>[];

  int get length;

  TypedListBase({List<CellBase>? list}) {
    if (list != null) {
      _list = list;
    }
  }

  dynamic operator [](int index);

  operator []=(int index, dynamic value);
  Type type(int index);

  CellBase<dynamic> cell(int index);

  void replace(int index, CellBase value);

  void add(CellBase newCell);

  void insert(int index, CellBase newCell);

  bool remove(CellBase value);

  CellBase<dynamic> removeAt(int index);
}
