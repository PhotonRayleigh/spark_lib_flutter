import 'dart:collection';

/*
  JSON supported types:
  List[x]
  Map<String, x>
  Where x can be List, Map, String, int, double, bool, or null
*/

// Never use dynamic containers for any other circumstance.
typedef JsonMap = Map<String, dynamic>;
typedef JsonList = List<dynamic>;

T as<T>(dynamic obj) => obj as T;
JsonMap asJsonMap(dynamic obj) => obj as JsonMap;
JsonList asJsonList(dynamic obj) => obj as JsonList;

extension dynMap<T, S> on Map<T, S> {
  /// Get a representation of the map with the keys represented as
  /// [E] instead of [S]. Meant for dynamic map access.
  Map<T, E> as<E>() => this as Map<T, E>;

  /// Shorthand to get a value from a map
  E? getAs<E>(T key) => this[key] as E?;

  void setAs<E>(T key, E value) => this.as<E>()[key] = value;
}

extension dynList<T> on List<T> {
  /// Represents [List] to type E for temporary access.
  /// Meant for dynamic or Object lists containing variable object types.
  List<E> as<E>() => this as List<E>;

  E getAs<E>(int key) => this[key] as E;

  void setAs<E>(int key, E value) => this.as<E>()[key] = value;
}

extension asWrap on Object {
  T as<T>() => this as T;
}

/// Base class for converting classes to JSON structures and back.
/// Each serializable class should have a JsonMapper associated with it.
/// Each serializable class should keep a static const reference to an instance
/// of it's JsonMapper in its class definition.
abstract class JsonMapper<T> {
  const JsonMapper();
  JsonMap toJsonMap(T obj);
  T fromJsonMap(JsonMap map);
}

extension jsonMapExt on JsonMap {
  JsonMap? asJsonMap(String key) => this[key] as JsonMap?;
  JsonList? asJsonList(String key) => this[key] as JsonList?;
  int? asInt(String key) => this[key] as int?;
  double? asDouble(String key) => this[key] as double?;
  bool? asBool(String key) => this[key] as bool?;
  String? asString(String key) => this[key] as String?;
}

extension jsonListExt on JsonList {
  JsonMap? asJsonMap(int key) => this[key] as JsonMap?;
  JsonList? asJsonList(int key) => this[key] as JsonList?;
  int? asInt(int key) => this[key] as int?;
  double? asDouble(int key) => this[key] as double?;
  bool? asBool(int key) => this[key] as bool?;
  String? asString(int key) => this[key] as String?;
}
