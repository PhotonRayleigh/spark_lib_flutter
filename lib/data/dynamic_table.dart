import 'package:flutter/foundation.dart';

import '../collections/rdynamic.dart';
export '../collections/rdynamic.dart';

class DtColumn<T> {
  Type type = T;
  String name = "";
  T? defaultValue;
  int position;

  DtColumn(this.name, this.defaultValue, {this.position = 0});
}

class DtRow {
  int position = 0;
  FixedList cells = FixedList();

  DtRow([List<dynamic>? cells, this.position = 0]) {
    if (cells != null) {
      this.cells = FixedList(cells);
    }
  }

  dynamic operator [](int index) {
    return cells[index];
  }

  operator []=(int index, dynamic value) {
    cells[index] = value;
  }
}

class DynamicTable {
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
  List<DtColumn> columns = <DtColumn>[];
  List<DtRow> rows = <DtRow>[];
  static const String _columnMismatchErrorMsg =
      "Error: new row's cells do not match table's column definitions";

  DynamicTable([List<DtColumn>? columns]) {
    if (columns != null) {
      setColumns(columns);
    }
  }

  DynamicTable.of(DynamicTable table) {
    columns = List.of(table.columns);
    rows = List.of(table.rows);
  }

  DynamicTable.from(DynamicTable table) {
    columns = List.from(table.columns);
    rows = List.from(table.rows);
  }

  void setColumns(List<DtColumn> columns) {
    if (rows.isNotEmpty)
      throw ErrorDescription(
          "Error: cannot set columns in a table populated with rows");
    this.columns = columns;
    _numberColumns();
  }

  List<T> getColumnData<T>(int index) {
    List<T> data = <T>[];
    for (var row in rows) {
      data.add(row.cells[index] as T);
    }

    return data;
  }

  void setRows(List<DtRow> newRows) {
    // WARNING: This operation will DROP ALL ROWS IN A TABLE
    for (var row in newRows) {
      try {
        _matchColumns(row);
      } catch (e) {
        throw e;
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

  void addColumn<T>(DtColumn<T> col) {
    columns.add(col);
    col.position = columns.length - 1;
    for (var row in rows) {
      row.cells.add(fix(col.defaultValue, col.type));
    }
  }

  DtColumn removeColumn(DtColumn col) {
    int index = col.position;
    for (var row in rows) {
      row.cells.removeAt(index);
    }
    var result = columns.removeAt(index);
    _numberColumns();
    return result;
  }

  DtColumn removeColumnAt(int index) {
    for (var row in rows) {
      row.cells.removeAt(index);
    }
    var result = columns.removeAt(index);
    _numberColumns();
    return result;
  }

  void insertColumn<T>(int index, DtColumn<T> col) {
    columns.insert(index, col);
    _numberColumns();
    for (var row in rows) {
      row.cells.insert(index, fix(col.defaultValue, col.type));
    }
  }

  DtRow addRow([DtRow? row]) {
    DtRow newRow;
    if (row != null) {
      try {
        _matchColumns(row);
        newRow = row;
      } catch (e) {
        throw e;
      }
    } else {
      newRow = DtRow(List.generate(
          columns.length, (index) => columns[index].defaultValue));
    }
    newRow.position = rows.length - 1;
    rows.add(newRow);
    return newRow;
  }

  void addAllRows(List<DtRow> newRows) {
    int rowNumber = rows.length;
    for (var row in newRows) {
      try {
        _matchColumns(row);
        row.position = rowNumber;
        rowNumber++;
      } catch (e) {
        throw e;
      }
    }
    rows.addAll(newRows);
  }

  void insertRow(int index, [DtRow? row]) {
    DtRow newRow;
    if (row != null) {
      try {
        _matchColumns(row);
        newRow = row;
      } catch (e) {
        // print("Columns failed to match: ${e.toString()}");
        throw e;
      }
    } else {
      newRow = DtRow(List.generate(
          columns.length, (index) => columns[index].defaultValue));
    }
    newRow.position = index;
    rows.insert(index, newRow);
    _numberRows();
  }

  void insertAllRows(int index, List<DtRow> newRows) {
    for (var row in newRows) {
      try {
        _matchColumns(row);
      } catch (e) {
        // print("Columns failed to match: ${e.toString()}");
        throw e;
      }
    }
    rows.insertAll(index, newRows);
    _numberRows();
  }

  void removeRow(DtRow row) {
    rows.remove(row);
  }

  void removeRowAt(int index) {
    rows.removeAt(index);
  }

  bool _matchColumns(DtRow row) {
    bool match = true;
    var errorList = <int>[];
    if (row.cells.length != columns.length) {
      match = false;
      throw "Column/row length mismatch - Expected row length of ${columns.length} but got ${row.cells.length} instead.";
    } else {
      for (int i = 0; i < columns.length; i++) {
        if (row.cells.type(i) != columns[i].type) {
          match = false;
          errorList.add(i);
        }
      }
      if (match == false) {
        String expected = "";
        String recieved = "";
        for (int i in errorList) {
          expected = expected + "[$i : ${columns[i].type}] ";
          recieved = recieved + "[$i : ${row.cells[i].runtimeType}] ";
        }

        throw "Column/row type mismatch. Expected $expected, recieved $recieved";
      }
    }

    return match;
  }
}
