import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger_util.dart';

class StorageService {
  static late SharedPreferences _prefs;
  
  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      LoggerUtil.i('Storage service initialized');
    } catch (e) {
      LoggerUtil.e('Failed to initialize storage service: $e');
    }
  }
  
  // 字符串存储
  static Future<bool> setString(String key, String value) async {
    try {
      return await _prefs.setString(key, value);
    } catch (e) {
      LoggerUtil.e('Failed to set string: $e');
      return false;
    }
  }
  
  static String? getString(String key) {
    try {
      return _prefs.getString(key);
    } catch (e) {
      LoggerUtil.e('Failed to get string: $e');
      return null;
    }
  }
  
  // 布尔值存储
  static Future<bool> setBool(String key, bool value) async {
    try {
      return await _prefs.setBool(key, value);
    } catch (e) {
      LoggerUtil.e('Failed to set bool: $e');
      return false;
    }
  }
  
  static bool? getBool(String key) {
    try {
      return _prefs.getBool(key);
    } catch (e) {
      LoggerUtil.e('Failed to get bool: $e');
      return null;
    }
  }
  
  // 清除数据
  static Future<bool> remove(String key) async {
    try {
      return await _prefs.remove(key);
    } catch (e) {
      LoggerUtil.e('Failed to remove key: $e');
      return false;
    }
  }
  
  static Future<bool> clear() async {
    try {
      return await _prefs.clear();
    } catch (e) {
      LoggerUtil.e('Failed to clear storage: $e');
      return false;
    }
  }
}