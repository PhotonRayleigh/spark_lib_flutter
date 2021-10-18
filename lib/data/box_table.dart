import 'package:flutter/foundation.dart';

import '../collections/boxlist.dart';
export '../collections/boxlist.dart';

class BoxColumn<T> {
  Type type = T;
  String name = "";
  T? defaultValue;
  int position;

  BoxColumn(this.name, this.defaultValue, {this.position = 0});

  Box<T?> makeCell([T? value]) {
    if (value == null) {
      return Box<T?>(defaultValue);
    } else {
      return Box<T?>(value);
    }
  }
}

class BoxRow {
  int position = 0;
  BoxList cells = BoxList();

  BoxRow([BoxList? cells, this.position = 0]) {
    if (cells != null) {
      this.cells = cells;
    }
  }

  dynamic operator [](int index) {
    return cells[index];
  }

  operator []=(int index, dynamic value) {
    cells[index] = value;
  }
}

class BoxTable {
  /* 
    Note on position versus ID's:
      position is the internal location of a row or column in memory.
      Position and index are interchangeable, and can be used to iterate
      through items.

      Any sort of ID row in a table is specific to the data scheme of the table.
      If you want to work in terms of ID's, the code using the table has to manage it.
      An associative map could work. 

      I will want to eventually add ways to get sorted data. Maybe view tables
      would be appropriate. Will have to experiment.
  */
  List<BoxColumn> columns = <BoxColumn>[];
  List<BoxRow> rows = <BoxRow>[];
  static const String _columnMismatchErrorMsg =
      "Error: new row's cells do not match table's column definitions";

  BoxTable({List<BoxColumn>? columns}) {
    if (columns != null) {
      setColumns(columns);
    }
  }

  BoxTable.from(BoxTable table) {
    columns = List.from(table.columns);
    rows = List.from(table.rows);
  }

  void setColumns(List<BoxColumn> columns) {
    if (rows.isNotEmpty)
      throw ErrorDescription(
          "Error: cannot set columns in a table populated with rows");
    this.columns = columns;
    _numberColumns();
  }

  List<T> getColumnData<T>(int index) {
    List<T> data = <T>[];
    for (var row in rows) {
      data.add(row.cells[index]);
    }

    return data;
  }

  void setRows(List<BoxRow> newRows) {
    // WARNING: This operation will DROP ALL ROWS IN A TABLE
    for (var row in newRows) {
      var matched = _matchColumns(row);
      if (!matched) {
        throw ErrorDescription(_columnMismatchErrorMsg);
      }
    }
    rows = newRows;
    _numberRows();
  }

  void _numberColumns() {
    int i = 0;
    for (var col in columns) {
      col.position = i;
      i++;
    }
  }

  void _numberRows() {
    int i = 0;
    for (var row in rows) {
      row.position = i;
      i++;
    }
  }

  void addColumn<T>(BoxColumn<T> col) {
    columns.add(col);
    col.position = columns.length - 1;
    for (var row in rows) {
      row.cells.add(col.makeCell());
    }
  }

  BoxColumn removeColumn(BoxColumn col) {
    int index = col.position;
    for (var row in rows) {
      row.cells.removeAt(index);
    }
    var result = columns.removeAt(index);
    _numberColumns();
    return result;
  }

  BoxColumn removeColumnAt(int index) {
    for (var row in rows) {
      row.cells.removeAt(index);
    }
    var result = columns.removeAt(index);
    _numberColumns();
    return result;
  }

  void insertColumn<T>(int index, BoxColumn<T> col) {
    columns.insert(index, col);
    _numberColumns();
    for (var row in rows) {
      row.cells.insert(index, col.makeCell());
    }
  }

  BoxRow addRow([BoxRow? row]) {
    BoxRow newRow;
    if (row != null) {
      if (_matchColumns(row)) {
        newRow = row;
      } else {
        throw ErrorDescription(_columnMismatchErrorMsg);
      }
    } else {
      newRow = BoxRow(BoxList(
          List.generate(columns.length, (index) => columns[index].makeCell())));
    }
    newRow.position = rows.length - 1;
    rows.add(newRow);
    return newRow;
  }

  void addAllRows(List<BoxRow> newRows) {
    int rowNumber = rows.length;
    for (var row in newRows) {
      if (!_matchColumns(row)) throw ErrorDescription(_columnMismatchErrorMsg);
      row.position = rowNumber;
      rowNumber++;
    }
    rows.addAll(newRows);
  }

  void insertRow(int index, [BoxRow? row]) {
    BoxRow newRow;
    if (row != null) {
      if (_matchColumns(row)) {
        newRow = row;
      } else {
        throw ErrorDescription(_columnMismatchErrorMsg);
      }
    } else {
      newRow = BoxRow(BoxList(List.generate(
          columns.length, (index) => columns[index].defaultValue)));
    }
    newRow.position = index;
    rows.insert(index, newRow);
    _numberRows();
  }

  void insertAllRows(int index, List<BoxRow> newRows) {
    for (var row in newRows) {
      if (!_matchColumns(row)) throw ErrorDescription(_columnMismatchErrorMsg);
    }
    rows.insertAll(index, newRows);
    _numberRows();
  }

  void removeRow(BoxRow row) {
    rows.remove(row);
  }

  void removeRowAt(int index) {
    rows.removeAt(index);
  }

  bool _matchColumns(BoxRow row) {
    bool match = true;
    if (row.cells.length != columns.length) {
      match = false;
    } else {
      for (int i = 0; i < columns.length; i++) {
        if (row.cells.type(i) != columns[i].type) {
          match = false;
          break;
        }
      }
    }

    return match;
  }
}
