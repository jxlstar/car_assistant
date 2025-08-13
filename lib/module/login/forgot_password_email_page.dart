import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../core/network/api_service.dart';
import '../../core/utils/logger_util.dart';
import '../../utils/custom_text_field.dart';
import 'otp_verification_page.dart';

class ForgotPasswordEmailPage extends StatefulWidget {
  const ForgotPasswordEmailPage({super.key});

  @override
  State<ForgotPasswordEmailPage> createState() => _ForgotPasswordEmailPageState();
}

class _ForgotPasswordEmailPageState extends State<ForgotPasswordEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isGetCodeEnabled = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_checkGetCodeButtonState);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _checkGetCodeButtonState() {
    setState(() {
      _isGetCodeEnabled = _emailController.text.isNotEmpty;
    });
  }

  Future<void> _handleGetVerificationCode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final response = await ApiService.sendVerificationCode(
        email: _emailController.text,
        type: 'reset_password',
      );
      
      if (response.success) {
        // 发送成功，跳转到验证码页面
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OtpVerificationPage(
              email: _emailController.text,
              type: OtpType.forgotPassword,
            ),
          ),
        );
        
        Fluttertoast.showToast(
          msg: "Verification code sent to ${_emailController.text}",
          gravity: ToastGravity.CENTER,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Failed to send verification code: ${response.message}",
          gravity: ToastGravity.CENTER,
        );
      }
    } catch (e) {
      LoggerUtil.e('Send verification code error: $e');
      Fluttertoast.showToast(
        msg: "Failed to send verification code",
        gravity: ToastGravity.CENTER,
      );
    } finally {
      setState(() {
        _isSending = false;
      });
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
                    'Forget the password',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // 邮箱输入框
                  const Text(
                    'Email Address',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _emailController,
                    hintText: 'Please enter your email address',
                    labelText: '',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email address';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // 获取验证码按钮
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (_isGetCodeEnabled && !_isSending) ? _handleGetVerificationCode : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (_isGetCodeEnabled && !_isSending) ? Colors.blue : Colors.blue.shade100,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Get the verification code',
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