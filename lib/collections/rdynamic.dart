extension RDynamic on dynamic {
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
}

class _TypeAccess {
  List target;
  _TypeAccess(this.target);
  Type operator [](int index) => this[index].runtimeType;
}
