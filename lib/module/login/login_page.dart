import 'package:car_assistant/core/utils/loading_util.dart';
import 'package:car_assistant/core/utils/logger_util.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/network/api_service.dart';
import '../../core/storage/storage_service.dart';
import '../../utils/social_login_button.dart';
import '../../utils/custom_text_field.dart';
import 'forgot_password_email_page.dart';
import 'login_model.dart';
import 'auth_provider.dart';
import '../home/main_page.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoginEnabled = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // 设置默认用户名和密码
    _emailController.text = 'jiangxl1377@gmail.com';
    _passwordController.text = '111111';
    
    // 添加监听器，当输入变化时检查是否可以启用登录按钮
    _emailController.addListener(_checkLoginButtonState);
    _passwordController.addListener(_checkLoginButtonState);
    
    // 初始化时检查登录按钮状态
    _checkLoginButtonState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 检查登录按钮状态
  void _checkLoginButtonState() {
    setState(() {
      _isLoginEnabled = _emailController.text.isNotEmpty && 
                       _passwordController.text.isNotEmpty;
    });
  }

  // 处理登录按钮点击
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      if(_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        Fluttertoast.showToast(msg: "用户名或者密码不能为空", gravity: ToastGravity.CENTER);
        return;
      }
      LoadingUtil.show(context, message: "登录中...");
      try{
        final response = await ApiService.login(
          email: _emailController.text,
          password: _passwordController.text,
        );
        LoadingUtil.hide();
        if (response.success) {
          // 登录成功，保存token
          final token = response.data?['data']['token'];
          LoggerUtil.i('保存data==: ${response.data}');
          LoggerUtil.i('保存token信息==: $token');
          if (token != null) {
            ApiService.setAuthToken(token);
          }
          final userInfo = response.data?['data']['user'];
          LoggerUtil.i('保存用户信息==: $userInfo');
          final user = UserModel(
            id: userInfo['id'] ?? '',
            email: userInfo['email'] ?? '',
            fullName: userInfo['full_name'] ?? '',
            phone: userInfo['phone'] ?? '',
            avatar: userInfo['avatar'] ?? '',
            createdAt: 0,
          );
         bool isOk = await StorageService.saveUser(user);
          LoggerUtil.i('保存用户信息: $isOk');
          LoggerUtil.i('登录成功: ${response.message}');
          FocusScope.of(context).unfocus();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
        } else {
          Fluttertoast.showToast(msg: "登录失败：${response.message}", gravity: ToastGravity.CENTER);
          LoggerUtil.e('登录失败: ${response.message}');
        }
      }catch(e){
        LoadingUtil.hide();
        Fluttertoast.showToast(msg: "登录失败：$e", gravity: ToastGravity.CENTER);
        LoggerUtil.e('登录异常: $e');
      }
    }
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
                  // 登录标题
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 欢迎文本
                  const Text(
                    'Welcome back to the app',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // 邮箱/手机号输入框
                  CustomTextField(
                    controller: _emailController,
                    hintText: 'hello@example.com',
                    labelText: 'Email Address/Phone Number',
                    keyboardType: TextInputType.emailAddress,
                    obscureText: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email or phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // 密码输入框
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CustomTextField(
                        controller: _passwordController,
                        hintText: '',
                        labelText: 'Password',
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
                          return null;
                        },
                      ),

                      // 忘记密码链接
                      TextButton(
                        onPressed: () {
                          // 导航到忘记密码邮箱输入页面
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordEmailPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Forgot Password ?',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 登录按钮
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoginEnabled ? _handleLogin : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade200,
                        disabledBackgroundColor: Colors.blue.shade100,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  // 添加分隔线和"or sign in with"文本
                  // const SizedBox(height: 30),
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: Divider(
                  //         color: Colors.grey.shade300,
                  //         thickness: 1,
                  //       ),
                  //     ),
                  //     Padding(
                  //       padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  //       child: Text(
                  //         'or sign in with',
                  //         style: TextStyle(
                  //           color: Colors.grey.shade500,
                  //           fontSize: 14,
                  //         ),
                  //       ),
                  //     ),
                  //     Expanded(
                  //       child: Divider(
                  //         color: Colors.grey.shade300,
                  //         thickness: 1,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  //
                  // // 社交登录按钮
                  // const SizedBox(height: 30),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //   children: [
                  //     // Google登录按钮
                  //     SocialLoginButton(
                  //       icon: FontAwesomeIcons.google,
                  //       backgroundColor: Colors.white,
                  //       onPressed: () {
                  //         final authProvider = context.read<AuthProvider>();
                  //         authProvider.signInWithGoogle().then((_) {
                  //           if (mounted) {
                  //             if (authProvider.isAuthenticated) {
                  //               Navigator.of(context).pushReplacement(
                  //                 MaterialPageRoute(builder: (context) => const MainPage()),
                  //               );
                  //             } else if (authProvider.error != null) {
                  //               ScaffoldMessenger.of(context).showSnackBar(
                  //                 SnackBar(
                  //                   content: Text(authProvider.error!),
                  //                   backgroundColor: Colors.red,
                  //                 ),
                  //               );
                  //             }
                  //           }
                  //         });
                  //       },
                  //     ),
                  //
                  //     // Facebook登录按钮
                  //     SocialLoginButton(
                  //       icon: FontAwesomeIcons.facebook,
                  //       backgroundColor: Colors.white,
                  //       onPressed: () {
                  //         final authProvider = context.read<AuthProvider>();
                  //         authProvider.signInWithFacebook().then((_) {
                  //           if (authProvider.isAuthenticated) {
                  //             Navigator.of(context).pushReplacement(
                  //               MaterialPageRoute(builder: (context) => const MainPage()),
                  //             );
                  //           }
                  //         });
                  //       },
                  //     ),
                  //
                  //     // Apple登录按钮
                  //     SocialLoginButton(
                  //       icon: FontAwesomeIcons.apple,
                  //       backgroundColor: Colors.white,
                  //       onPressed: () {
                  //         final authProvider = context.read<AuthProvider>();
                  //         authProvider.signInWithApple().then((_) {
                  //           if (authProvider.isAuthenticated) {
                  //             Navigator.of(context).pushReplacement(
                  //               MaterialPageRoute(builder: (context) => const MainPage()),
                  //             );
                  //           }
                  //         });
                  //       },
                  //     ),
                  //   ],
                  // ),
                  //
                  // // 创建账号链接
                  const SizedBox(height: 30),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // 导航到注册页面
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Create an account',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}