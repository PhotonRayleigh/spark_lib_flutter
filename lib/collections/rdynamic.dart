// Helper functions, classes, and extensions for working safely with
// dynamic variables at runtime.
// I'm unsure if anything I made here is actually helpful or not.

T safeVal<T>(Object obj) {
  if (obj is Fixed) {
    return obj.value as T;
  } else {
    return obj as T;
  }
}

Fixed fix(Object? value, [Type? type]) {
  if (value is Fixed) {
    return value;
  } else if (type == null) {
    return Fixed.implicit(value!);
  } else {
    return Fixed(type, value);
  }
}

/// In lieu of an overridable '=' sign,
/// you can use this where you expect either a Fixed
/// or dynamic value to assign the right-hand value to the
/// left-hand variable.
/// Type parameter is optional to enforce type checking.
void safeAssign<T, E>(T left, E right) {
  if (left is Fixed && right is Fixed) {
    left.value = right.value;
  } else if (left is Fixed && !(right is Fixed)) {
    left.value = right;
  } else if (!(left is Fixed) && (right is Fixed)) {
    left = right.value as T;
  } else if (E is T) {
    left = right as T;
  }
}

Fixed nullFixed(Type type) => Fixed.asNull(type);

extension RList on List {
  E getAs<E>(int index) => this[index] as E;
  void setAs<E>(int index, E value) => this[index] = value;
  Type getType(int index) => this[index].runtimeType;

  /// A little trick to let you use square brackets
  /// to access the type of a list item.
  /// Example: myList.type[0] // returns the type of the item at index 0.
  _TypeAccess get type => _TypeAccess(this);

  /// Returns true if the list matches the types specified in
  /// the types list
  bool checkTypes(List<Type> types) {
    if (types.length != this.length)
      throw "Error: types list must mach target list's length";
    for (int i = 0; i < this.length; i++) {
      if (this[i].runtimeType != types[i]) return false;
    }
    return true;
  }
}

class _TypeAccess {
  List target;
  _TypeAccess(this.target);
  Type operator [](int index) {
    if (this[index] is Fixed)
      return (this[index] as Fixed).type;
    else
      return this[index].runtimeType;
  }
}

class Fixed {
  late final Type type;
  Object? _value;
  Object? get value => _value;
  set value(Object? val) {
    if (val.runtimeType == type || val == null)
      _value = val;
    else
      throw "Error setting RDynamic value: type $type expected, but ${val.runtimeType} was provided.";
  }

  E valueAs<E>() => _value as E;
  void setAs<E>(E val) {
    if (E == type)
      _value = val;
    else
      throw "Error setting RDynamic value: type $type expected, but $E was provided.";
  }

  Fixed(this.type, [Object? value]) {
    this.value = value;
  }
  Fixed.asNull(this.type) {
    makeNull();
  }
  Fixed.implicit(Object value) {
    type = value.runtimeType;
    this.value = value;
  }

  void makeNull() {
    _value = null;
  }
}

class FixedList extends Iterable {
  List<Fixed> _list = <Fixed>[];

  int get length {
    return _list.length;
  }

  bool get isEmpty => _list.isEmpty;
  bool get isNotEmpty => _list.isNotEmpty;

  Iterator get iterator {
    return _TypedListIterator(this);
  }

  FixedList([List<Object?>? list]) {
    if (list != null) {
      if (list is List<Fixed>)
        _list = list;
      else {
        for (var item in list) {
          if (item == null) {
            nullFixed(Object);
          } else
            _list.add(fix(item));
        }
      }
    }
  }

  /// Makes a full copy of the source list into a new list.
  FixedList.of(FixedList list) {
    _list = List.of(list._list);
  }

  /// Adds all the elements from the source list to a new list.
  FixedList.from(FixedList list) {
    _list = List.from(list._list);
  }

  /// Bracket notation will return the value contained
  /// in the [Fixed] at the index, like a normal [List].
  Object? operator [](int index) {
    return _list[index].value;
  }

  /// Bracket assignment will assign the value directly to
  /// the [Fixed]'s value, like a normal [List].
  operator []=(int index, Object? value) {
    _list[index].value = value;
  }

  /// Shorthand to get the value of a box as a specific type.
  T getAs<T>(int index) => _list[index] as T;

  /// Shorthand to set the value of a box with a specific type.
  /// Not really necessary, this just offers a way to set values
  /// that makes it apparent what type the programmer intends to insert
  /// into the box.
  void setAs<T>(int index, T value) => _list[index].value = value;

  Type type(int index) {
    return _list[index].type;
  }

  Fixed cell(int index) {
    return _list[index];
  }

  void replace(int index, Fixed newFixed) {
    _list[index] = newFixed;
  }

  void add(Fixed newFixed) {
    _list.add(newFixed);
  }

  void insert(int index, Fixed newFixed) {
    _list.insert(index, newFixed);
  }

  bool remove(Fixed value) {
    return _list.remove(value);
  }

  Fixed removeAt(int index) {
    return _list.removeAt(index);
  }

  @override
  void forEach(void Function(dynamic element) action) {
    super.forEach(action);
    for (int i = 0; i < _list.length; i++) {
      action(_list[i].value);
    }
  }

  void forEachFixed(void Function(Fixed element) action) {
    for (int i = 0; i < _list.length; i++) {
      action(_list[i]);
    }
  }
}

class _TypedListIterator extends Iterator {
  int index = -1;
  FixedList owner;

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
