import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  late final SharedPreferences prefs;

  Future<StorageService> init() async {
    prefs = await SharedPreferences.getInstance();
    return this;
  }

  String? getString(String key) => prefs.getString(key);
  Future<bool> setString(String key, String value) =>
      prefs.setString(key, value);

  bool? getBool(String key) => prefs.getBool(key);
  Future<bool> setBool(String key, bool value) => prefs.setBool(key, value);

  int? getInt(String key) => prefs.getInt(key);
  Future<bool> setInt(String key, int value) => prefs.setInt(key, value);

  Future<bool> remove(String key) => prefs.remove(key);
  Future<bool> clear() => prefs.clear();
}
