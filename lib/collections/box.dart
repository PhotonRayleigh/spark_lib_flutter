/// A simple type-safe container for runtime
/// type checking.
/// Can be used in dynamic collections
/// to ensure a given element can only hold
/// a specific type.
class Box<T> {
  T value;
  Type type = T;

  /// Shorthand function to easily
  /// get value back out as it's contained type.
  /// This is for situations where Box<dynamic>
  /// is used, such as in TypedList.
  E valueAs<E>() => value as E;
  void setAs<E>(E val) => value = val as T;

  Box(this.value);
}
