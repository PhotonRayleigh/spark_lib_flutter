import 'package:flutter/cupertino.dart';

import '../collections/typed_list.dart';

class TableCell<T> extends Cell<T> {
  Column<T>? column;
  Row? row;

  TableCell(T value, {this.column, this.row}) : super(value);
}

class Column<T> {
  Type type = T;
  T? defaultValue;
  int position;
  List<Cell<T>> cells = <Cell<T>>[];

  Column(this.defaultValue, {this.position = 0});
}

class Row {
  int position = 0;
  TypedList cells = TypedList();

  Row({TypedList? cells, this.position = 0}) {
    if (cells != null) {
      this.cells = cells;
    }
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
  List<Column> columns = <Column>[];
  List<Row> rows = <Row>[];
  static const String _columnMismatchErrorMsg =
      "Error: new row's cells do not match table's column definitions";

  DynamicTable({List<Column>? columns}) {
    if (columns != null) {
      setColumns(columns);
    }
  }

  void setColumns(List<Column> columns) {
    if (rows.isNotEmpty)
      throw ErrorDescription(
          "Error: cannot set columns in a table populated with rows");
    this.columns = columns;
    _numberColumns();
  }

  void setRows(List<Row> newRows) {
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

  void addColumn<T>(Column<T> col) {
    columns.add(col);
    col.position = columns.length - 1;
    for (var row in rows) {
      row.cells.add(Cell<T?>(col.defaultValue));
    }
  }

  Column removeColumn(Column col) {
    int index = col.position;
    for (var row in rows) {
      row.cells.removeAt(index);
    }
    var result = columns.removeAt(index);
    _numberColumns();
    return result;
  }

  Column removeColumnAt(int index) {
    for (var row in rows) {
      row.cells.removeAt(index);
    }
    var result = columns.removeAt(index);
    _numberColumns();
    return result;
  }

  void insertColumn<T>(int index, Column<T> col) {
    columns.insert(index, col);
    _numberColumns();
    for (var row in rows) {
      row.cells.insert(index, Cell<T?>(col.defaultValue));
    }
  }

  Row addRow({Row? row}) {
    Row newRow;
    if (row != null) {
      if (_matchColumns(row)) {
        newRow = row;
      } else {
        throw ErrorDescription(_columnMismatchErrorMsg);
      }
    } else {
      newRow = Row(
          cells: TypedList(
              list: List.generate(
                  columns.length, (index) => columns[index].defaultValue)));
    }
    newRow.position = rows.length - 1;
    return newRow;
  }

  void addAllRows(List<Row> newRows) {
    int rowNumber = rows.length;
    for (var row in newRows) {
      if (!_matchColumns(row)) throw ErrorDescription(_columnMismatchErrorMsg);
      row.position = rowNumber;
      rowNumber++;
    }
    rows.addAll(newRows);
  }

  void insertRow(int index, {Row? row}) {
    Row newRow;
    if (row != null) {
      if (_matchColumns(row)) {
        newRow = row;
      } else {
        throw ErrorDescription(_columnMismatchErrorMsg);
      }
    } else {
      newRow = Row(
          cells: TypedList(
              list: List.generate(
                  columns.length, (index) => columns[index].defaultValue)));
    }
    newRow.position = index;
    rows.insert(index, newRow);
    _numberRows();
  }

  void insertAllRows(int index, List<Row> newRows) {
    for (var row in newRows) {
      if (!_matchColumns(row)) throw ErrorDescription(_columnMismatchErrorMsg);
    }
    rows.insertAll(index, newRows);
    _numberRows();
  }

  bool _matchColumns(Row row) {
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
