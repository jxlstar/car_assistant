import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../utils/social_login_button.dart';
import '../../utils/custom_text_field.dart';
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
    // 添加监听器，当输入变化时检查是否可以启用登录按钮
    _emailController.addListener(_checkLoginButtonState);
    _passwordController.addListener(_checkLoginButtonState);
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
  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      final loginModel = LoginModel(
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      // 使用Provider进行登录
      final authProvider = context.read<AuthProvider>();
      authProvider.login(loginModel).then((_) {
        // 检查widget是否仍然挂载
        if (mounted && authProvider.isAuthenticated) {
          // 登录成功后跳转到主页面
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
        }
      });
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
                          // 导航到忘记密码页面
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordPage(),
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
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade300,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'or sign in with',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade300,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  
                  // 社交登录按钮
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Google登录按钮
                      SocialLoginButton(
                        icon: FontAwesomeIcons.google,
                        backgroundColor: Colors.white,
                        onPressed: () {
                          final authProvider = context.read<AuthProvider>();
                          authProvider.signInWithGoogle().then((_) {
                            if (mounted) {
                              if (authProvider.isAuthenticated) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (context) => const MainPage()),
                                );
                              } else if (authProvider.error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(authProvider.error!),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          });
                        },
                      ),
                      
                      // Facebook登录按钮
                      SocialLoginButton(
                        icon: FontAwesomeIcons.facebook,
                        backgroundColor: Colors.white,
                        onPressed: () {
                          final authProvider = context.read<AuthProvider>();
                          authProvider.signInWithFacebook().then((_) {
                            if (authProvider.isAuthenticated) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => const MainPage()),
                              );
                            }
                          });
                        },
                      ),
                      
                      // Apple登录按钮
                      SocialLoginButton(
                        icon: FontAwesomeIcons.apple,
                        backgroundColor: Colors.white,
                        onPressed: () {
                          final authProvider = context.read<AuthProvider>();
                          authProvider.signInWithApple().then((_) {
                            if (authProvider.isAuthenticated) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => const MainPage()),
                              );
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  
                  // 创建账号链接
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