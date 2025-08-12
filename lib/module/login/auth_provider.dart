import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'login_model.dart';
import '../../core/utils/logger_util.dart';
import '../../core/storage/storage_service.dart';

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

  // Apple登录
  Future<void> signInWithApple() async {
    _setLoading(true);
    _error = null;
    
    try {
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

  // 登出
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      // 这里应该调用实际的登出API
      // 模拟网络请求延迟
      await Future.delayed(const Duration(seconds: 1));
      
      _isAuthenticated = false;
      // 清除登录状态
      await StorageService.setBool(_authKey, false);
      LoggerUtil.i('User logged out');
    } catch (e) {
      _error = e.toString();
      LoggerUtil.e('Logout error: $_error');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}