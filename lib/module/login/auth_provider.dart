import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'dart:io' show Platform;
// 条件导入Apple登录
import 'package:sign_in_with_apple/sign_in_with_apple.dart' if (dart.library.io) 'package:sign_in_with_apple/sign_in_with_apple.dart' if (dart.library.html) 'sign_in_with_apple_stub.dart';
import 'login_model.dart';
import '../../core/utils/logger_util.dart';
import '../../core/storage/storage_service.dart';
import '../../core/network/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  
  // 登录状态的键名
  static const String _authKey = 'is_authenticated';

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  // Google登录
  Future<void> signInWithGoogle() async {
    _setLoading(true);
    _error = null;
    
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser != null) {
        // 获取Google认证信息
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        
        // 这里应该将token发送到后端进行验证
        // 模拟登录成功
        _isAuthenticated = true;
        // 保存登录状态
        await StorageService.setBool(_authKey, true);
        LoggerUtil.i('User logged in with Google: ${googleUser.email}');
      } else {
        // 用户取消登录
        LoggerUtil.w('Google sign in was canceled by user');
      }
    } catch (e) {
      _error = 'Google登录配置错误，请联系开发者配置Google Client ID';
      LoggerUtil.e('Google sign in error: $e');
      // 如果是配置错误，不要让应用崩溃
      if (e.toString().contains('GIDClientID') || e.toString().contains('No active configuration')) {
        _error = 'Google登录功能暂时不可用，请使用其他登录方式';
      }
    } finally {
      _setLoading(false);
    }
  }

  // Facebook登录
  Future<void> signInWithFacebook() async {
    _setLoading(true);
    _error = null;
    
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      
      if (result.status == LoginStatus.success) {
        // 获取用户信息
        final userData = await FacebookAuth.instance.getUserData();
        
        // 这里应该将token发送到后端进行验证
        // 模拟登录成功
        _isAuthenticated = true;
        // 保存登录状态
        await StorageService.setBool(_authKey, true);
        LoggerUtil.i('User logged in with Facebook: ${userData['email']}');
      } else {
        // 登录失败或取消
        LoggerUtil.w('Facebook login failed or was canceled');
      }
    } catch (e) {
      _error = e.toString();
      LoggerUtil.e('Facebook sign in error: $_error');
    } finally {
      _setLoading(false);
    }
  }

  // Apple登录 - 仅iOS平台支持
  Future<void> signInWithApple() async {
    // 检查是否为iOS平台
    if (!Platform.isIOS) {
      _error = 'Apple Sign In is only available on iOS platform';
      LoggerUtil.w('Apple Sign In attempted on non-iOS platform');
      notifyListeners();
      return;
    }
    
    _setLoading(true);
    _error = null;
    
    try {
      // 检查Apple登录是否可用
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        throw Exception('Apple Sign In is not available on this device');
      }
      
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      
      // 这里应该将token发送到后端进行验证
      // 模拟登录成功
      _isAuthenticated = true;
      // 保存登录状态
      await StorageService.setBool(_authKey, true);
      LoggerUtil.i('User logged in with Apple: ${credential.email}');
    } catch (e) {
      _error = e.toString();
      LoggerUtil.e('Apple sign in error: $_error');
    } finally {
      _setLoading(false);
    }
  }
  
  // 检查Apple登录是否可用
  bool get isAppleSignInAvailable {
    return Platform.isIOS;
  }

  // 登出
  Future<bool> logout() async {
    _setLoading(true);
    _error = null;
    
    try {
      // 调用登出API
      final response = await ApiService.logout();
      LoggerUtil.i('登出API响应: $response');
      
      if (response.success) {
        // API调用成功，清除本地数据
        await _clearUserData();
        _isAuthenticated = false;
        LoggerUtil.i('用户登出成功');
        return true;
      } else {
        // API调用失败，但仍然清除本地数据
        LoggerUtil.w('登出API调用失败，但仍清除本地数据: ${response.message}');
        await _clearUserData();
        _isAuthenticated = false;
        return true;
      }
    } catch (e) {
      LoggerUtil.e('登出异常: $e');
      // 即使出现异常，也要清除本地数据
      await _clearUserData();
      _isAuthenticated = false;
      _error = '登出时发生错误，但已清除本地数据';
      return true;
    } finally {
      _setLoading(false);
    }
  }

  // 清除用户数据
  Future<void> _clearUserData() async {
    try {
      // 清除登录状态
      await StorageService.setBool(_authKey, false);
      
      // 清除认证token
      await StorageService.remove('auth_token');
      ApiService.clearAuthToken();
      
      // 清除用户信息
      await StorageService.remove('user_info');
      
      // 清除其他可能的用户相关数据
      await StorageService.remove('user_profile');
      await StorageService.remove('refresh_token');
      
      // 登出第三方登录
      await _logoutThirdPartyServices();
      
      LoggerUtil.i('用户数据清除完成');
    } catch (e) {
      LoggerUtil.e('清除用户数据时出错: $e');
    }
  }

  // 登出第三方服务
  Future<void> _logoutThirdPartyServices() async {
    try {
      // Google登出
      final GoogleSignIn googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
        LoggerUtil.i('Google登出成功');
      }
    } catch (e) {
      LoggerUtil.w('Google登出失败: $e');
    }

    try {
      // Facebook登出
      await FacebookAuth.instance.logOut();
      LoggerUtil.i('Facebook登出成功');
    } catch (e) {
      LoggerUtil.w('Facebook登出失败: $e');
    }
  }

  // 检查登录状态
  Future<void> checkAuthStatus() async {
    try {
      final isAuth = await StorageService.getBool(_authKey) ?? false;
      final hasToken = await StorageService.getString('auth_token') != null;
      _isAuthenticated = isAuth && hasToken;
      notifyListeners();
    } catch (e) {
      LoggerUtil.e('检查登录状态失败: $e');
      _isAuthenticated = false;
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}