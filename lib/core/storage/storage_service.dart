import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/logger_util.dart';

// 用户数据模型
class UserModel {
  final int id;
  final String email;
  final String fullName;
  final String phone;
  final String avatar;
  final int createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.avatar,
    required this.createdAt,
  });

  // 从JSON创建UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? 'No Email',
      fullName: json['full_name'] ?? 'No Account Name',
      phone: json['phone'] ?? 'No Phone',
      avatar: json['avatar'] ?? '',
      createdAt: json['created_at'] ?? 0,
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'avatar': avatar,
      'created_at': createdAt,
    };
  }
}

class StorageService {
  static late SharedPreferences _prefs;
  
  // 用户信息存储键名
  static const String _userKey = 'user_info';
  
  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      LoggerUtil.i('Storage service initialized');
    } catch (e) {
      LoggerUtil.e('Failed to initialize storage service: $e');
    }
  }
  
  // 保存用户信息
  static Future<bool> saveUser(UserModel user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      final result = await _prefs.setString(_userKey, userJson);
      if (result) {
        LoggerUtil.i('User info saved successfully');
      }
      return result;
    } catch (e) {
      LoggerUtil.e('Failed to save user info: $e');
      return false;
    }
  }
  
  // 获取用户信息
  static UserModel? getUser() {
    try {
      final userJson = _prefs.getString(_userKey);
      if (userJson != null && userJson.isNotEmpty) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(userMap);
      }
      return null;
    } catch (e) {
      LoggerUtil.e('Failed to get user info: $e');
      return null;
    }
  }
  
  // 清除用户信息
  static Future<bool> clearUser() async {
    try {
      final result = await _prefs.remove(_userKey);
      if (result) {
        LoggerUtil.i('User info cleared successfully');
      }
      return result;
    } catch (e) {
      LoggerUtil.e('Failed to clear user info: $e');
      return false;
    }
  }
  
  // 检查是否有用户信息
  static bool hasUser() {
    try {
      final userJson = _prefs.getString(_userKey);
      return userJson != null && userJson.isNotEmpty;
    } catch (e) {
      LoggerUtil.e('Failed to check user info: $e');
      return false;
    }
  }
  
  // 更新用户信息的某个字段
  static Future<bool> updateUserField(String field, dynamic value) async {
    try {
      final currentUser = getUser();
      if (currentUser == null) {
        LoggerUtil.w('No user info found to update');
        return false;
      }
      
      final userMap = currentUser.toJson();
      userMap[field] = value;
      
      final updatedUser = UserModel.fromJson(userMap);
      return await saveUser(updatedUser);
    } catch (e) {
      LoggerUtil.e('Failed to update user field: $e');
      return false;
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