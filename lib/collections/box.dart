import 'package:flutter/cupertino.dart';

import '../utility/isnull.dart';

/// A simple type-safe container for runtime
/// type checking.
/// Can be used in dynamic collections
/// to ensure a given element can only hold
/// a specific type.
class Box<T> {
  late T _value;
  T get value => _value;
  set value(T val) => _value = val;
  Type? get type => T;

  /// Shorthand function to easily
  /// get value back out as it's contained type.
  /// This is for situations where Box<dynamic>
  /// is used, such as in TypedList.
  E valueAs<E>() => value as E;
  void setAs<E>(E val) => value = val as T;

  Box(T value) {
    _value = value;
  }
}

class RBox extends Box<dynamic> {
  @override
  dynamic get value => _value;

  @override
  set value(dynamic val) {
    if (val.runtimeType != type)
      throw ErrorDescription(
          "Error: $val as type of ${val.runtimeType}, does not match specified type of $type");
    _value = val;
  }

  @override
  Type? get type => _type;
  Type? _type = Object;

  RBox(dynamic value, [Type? type]) : super(value) {
    if (isNotNull(type)) {
      if (value.runtimeType != type)
        throw ErrorDescription(
            "Error: $value as type of ${value.runtimeType}, does not match specified type of $type");
      _type = type;
    } else {
      _type = value.runtimeType;
    }
  }
}
