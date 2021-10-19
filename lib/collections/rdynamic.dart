extension Dynamic on dynamic {
  E as<E>() => this as E;
}

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
  Type operator [](int index) => this[index].runtimeType;
}

class RDynamic {
  late final Type type;
  dynamic _value;
  dynamic get value => _value;
  set value(dynamic val) {
    if (val.runtimeType == type)
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

  RDynamic(this.type, [dynamic value]) {
    this.value = value;
  }
  RDynamic.asNull(this.type) {
    makeNull();
  }
  RDynamic.implicit(dynamic value) {
    if (value == null) {
      throw "Error: null cannot be used to set type implicitly in RDynamic.";
    } else {
      type = value.runtimeType;
      this.value = value;
    }
  }

  void makeNull() {
    _value = null;
  }
}
