import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../../core/network/api_service.dart';
import '../../core/utils/logger_util.dart';
import '../../core/utils/loading_util.dart';
import '../../utils/custom_text_field.dart';
import '../home/main_page.dart';
import 'login_page.dart';
import 'otp_verification_page.dart';

class SetPasswordPage extends StatefulWidget {
  final String email;
  final String verificationCode;
  final OtpType type;
  
  const SetPasswordPage({
    super.key,
    required this.email,
    required this.verificationCode,
    required this.type,
  });

  @override
  State<SetPasswordPage> createState() => _SetPasswordPageState();
}

class _SetPasswordPageState extends State<SetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isOkEnabled = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkOkButtonState);
    _confirmPasswordController.addListener(_checkOkButtonState);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkOkButtonState() {
    setState(() {
      _isOkEnabled = _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text &&
          _passwordController.text.length >= 8;
    });
  }

  bool _isValidPassword(String password) {
    // 密码格式：8到16位，包含字母或符号
    if (password.length < 8 || password.length > 16) {
      return false;
    }
    
    // 检查是否包含字母或符号
    bool hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    bool hasSymbol = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password);
    
    return hasLetter || hasSymbol;
  }

  Future<void> _handleSetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      Fluttertoast.showToast(
        msg: "Passwords do not match",
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    if (!_isValidPassword(_passwordController.text)) {
      Fluttertoast.showToast(
        msg: "Password format: 8 to 16 digits, letters or symbols",
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    LoadingUtil.show(context, message: 'loading...');
    
    try {
      if (widget.type == OtpType.register) {
        // 注册流程
        await _handleRegister();
      } else {
        // 修改密码或忘记密码流程
        await _handleResetPassword();
      }
    } catch (e) {
      LoadingUtil.hide();
      Fluttertoast.showToast(
        msg: "Operation failed: $e",
        gravity: ToastGravity.CENTER,
      );
      LoggerUtil.e('Operation error: $e');
    }
  }

  Future<void> _handleRegister() async {
    final response = await ApiService.register(
      email: widget.email,
      password: _passwordController.text,
      verificationCode: widget.verificationCode,
    );
    
    LoadingUtil.hide();
    
    if (response.success) {
      // 注册成功，保存token（如果有）
      final token = response.data?['token'];
      if (token != null) {
        ApiService.setAuthToken(token);
      }
      
      LoggerUtil.i('注册成功: ${response.message}');
      
      Fluttertoast.showToast(
        msg: "Registration successful",
        gravity: ToastGravity.CENTER,
      );
      
      // 跳转到主页
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainPage()),
          (route) => false,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "Registration failed: ${response.message}",
        gravity: ToastGravity.CENTER,
      );
      LoggerUtil.e('注册失败: ${response.message}');
    }
  }

  Future<void> _handleResetPassword() async {
    // 调用验证码重置密码API
    final response = await ApiService.resetPasswordWithCode(
      email: widget.email,
      verificationCode: widget.verificationCode,
      newPassword: _passwordController.text,
    );
    
    LoadingUtil.hide();
    
    if (response.success) {
      Fluttertoast.showToast(
        msg: "Password reset successfully",
        gravity: ToastGravity.CENTER,
      );
      
      LoggerUtil.i('密码重置成功: ${response.message}');
      
      if (widget.type == OtpType.changePassword) {
        // 修改密码成功后，退出登录
        await ApiService.logout();
        
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        }
      } else {
        // 忘记密码成功后，跳转到登录页
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        }
      }
    } else {
      Fluttertoast.showToast(
        msg: "Password reset failed: ${response.message}",
        gravity: ToastGravity.CENTER,
      );
      LoggerUtil.e('密码重置失败: ${response.message}');
    }
  }

  void _goBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // 返回按钮
                  GestureDetector(
                    onTap: _goBack,
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 24,
                      color: Colors.black,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // 标题
                  const Text(
                    'Set a new password',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 密码格式说明
                  Text(
                    'Password format: 8 to 16 digits, letters or symbols',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // 新密码输入框
                  const Text(
                    'Enter new password',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _passwordController,
                    hintText: '',
                    labelText: '',
                    obscureText: !_isPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (!_isValidPassword(value)) {
                        return 'Password format: 8 to 16 digits, letters or symbols';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 确认密码输入框
                  const Text(
                    'Re-enter new password',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    hintText: 'Please enter the password',
                    labelText: '',
                    obscureText: !_isConfirmPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // OK按钮
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isOkEnabled ? _handleSetPassword : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isOkEnabled ? Colors.blue : Colors.blue.shade100,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  // 底部间距
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}