import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../core/network/api_service.dart';
import '../../core/utils/loading_util.dart';
import '../../core/utils/logger_util.dart';
import '../../utils/custom_text_field.dart';
import '../home/main_page.dart';
import 'otp_verification_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSignUpEnabled = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_checkSignUpButtonState);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _checkSignUpButtonState() {
    setState(() {
      _isSignUpEnabled = _emailController.text.isNotEmpty;
    });
  }

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      try{
        final response = await ApiService.register(
          email: 'jiangxl1377@gmail.com',
          password: '111111',
          fullName: '',
          phone: ''
        );
        LoadingUtil.hide();
        if (response.success) {
          // 登录成功，保存token
          // final token = response.data?['token'];
          // if (token != null) {
          //   ApiService.setAuthToken(token);
          // }
          LoggerUtil.i('注册成功: ${response.message}');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
        } else {
          Fluttertoast.showToast(msg: "注册失败：${response.message}", gravity: ToastGravity.CENTER);
          LoggerUtil.e('注册失败: ${response.message}');
        }
      }catch(e){
        LoadingUtil.hide();
        Fluttertoast.showToast(msg: "注册失败：$e", gravity: ToastGravity.CENTER);
        LoggerUtil.e('注册异常: $e');
      }



      // 导航到OTP验证页面
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OtpVerificationPage(
            email: _emailController.text,
          ),
        ),
      );
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  // 注册标题
                  const Text(
                    'Create an account',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // 邮箱/手机号输入框
                  CustomTextField(
                    controller: _emailController,
                    hintText: 'hello@example.com',
                    labelText: 'Email Address/Phone Number',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email or phone number';
                      }
                      // 简单的邮箱验证
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value) &&
                          !RegExp(r'^[0-9]{10,}$').hasMatch(value)) {
                        return 'Please enter a valid email or phone number';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // 服务条款文本
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Create an account,you agree to our ',
                        ),
                        TextSpan(
                          text: 'terms of service',
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // 打开服务条款页面
                            },
                        ),
                        const TextSpan(text: '/'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // 注册按钮
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSignUpEnabled ? _handleSignUp : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isSignUpEnabled ? Colors.blue : Colors.blue.shade100,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // 已有账号登录链接
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Already have an account? ',
                          ),
                          TextSpan(
                            text: 'Sign in here',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = _navigateToLogin,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}