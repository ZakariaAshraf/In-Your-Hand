import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static late SharedPreferences prefs;

  static init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static set({required String key, required dynamic value}) async{
    if (value is String) {
      await prefs.setString(key, value);
    }else if (value is int) {
      await prefs.setInt(key, value);
    }else if (value is double) {
      await prefs.setDouble(key, value);
    }else if (value is bool) {
      await prefs.setBool(key, value);
    }else if (value is List<String>) {
      await prefs.setStringList(key, value);
    }else {
      throw UnsupportedError("Unsupported type");
    }
  }

  static String?getString({required String key}) => prefs.getString(key);
  static bool?getBool({required String key}) => prefs.getBool(key);
  static int?getInt({required String key}) => prefs.getInt(key);
  static double?getDouble({required String key}) => prefs.getDouble(key);
  static List<String>?getStringList({required String key}) => prefs.getStringList(key);
  static Future<bool>?remove({required String key})async => await prefs.remove(key);
  static Future<bool>?clearAllData()async => await prefs.clear();
}
class CacheKeys {
  static const String theme = 'is_dark_mode';
  static const String language = 'app_language';
  static const String uId = 'uId';
  static const String userName = 'user_name';
  static const String userEmail = 'user_email';
  static const String userPhone = 'user_phone';
  static const String userCharacter = 'user_character';
  static const String isOnBoardingSeen = 'is_on_boarding_seen';
}