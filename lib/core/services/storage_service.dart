import 'package:shared_preferences/shared_preferences.dart';

abstract class StorageService {
  Future<bool> setString(String key, String value);

  Future<bool> setBool(String key, bool value);

  Future<bool> setInt(String key, int value);

  Future<bool> setDouble(String key, double value);

  Future<bool> setStringList(String key, List<String> value);

  String? getString(String key);

  bool? getBool(String key);

  int? getInt(String key);

  double? getDouble(String key);

  List<String>? getStringList(String key);

  Future<bool> remove(String key);

  Future<bool> clear();

  bool containsKey(String key);

  Set<String> getKeys();
}

class StorageServiceImpl implements StorageService {
  StorageServiceImpl(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  @override
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  @override
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  @override
  Future<bool> setDouble(String key, double value) =>
      _prefs.setDouble(key, value);

  @override
  Future<bool> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  bool? getBool(String key) => _prefs.getBool(key);

  @override
  int? getInt(String key) => _prefs.getInt(key);

  @override
  double? getDouble(String key) => _prefs.getDouble(key);

  @override
  List<String>? getStringList(String key) => _prefs.getStringList(key);

  @override
  Future<bool> remove(String key) => _prefs.remove(key);

  @override
  Future<bool> clear() => _prefs.clear();

  @override
  bool containsKey(String key) => _prefs.containsKey(key);

  @override
  Set<String> getKeys() => _prefs.getKeys();
}
