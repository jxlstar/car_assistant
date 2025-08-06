import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../home/main_page.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;
  
  const OtpVerificationPage({super.key, required this.email});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _controllers = List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  int _currentIndex = 0;
  bool _isNextEnabled = false;

  @override
  void initState() {
    super.initState();
    // 初始焦点在第一个输入框
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
    
    // 为每个输入框添加监听器
    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].addListener(_checkNextButtonState);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _checkNextButtonState() {
    setState(() {
      _isNextEnabled = _controllers.every((controller) => controller.text.isNotEmpty);
    });
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      // 移动到下一个输入框
      if (index < 3) {
        setState(() {
          _currentIndex = index + 1;
        });
        _focusNodes[index + 1].requestFocus();
      } else {
        // 最后一个输入框，失去焦点
        _focusNodes[index].unfocus();
        setState(() {
          _currentIndex = -1; // 没有焦点
        });
      }
    }
  }

  void _onBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      // 如果当前输入框为空且不是第一个，移动到前一个
      setState(() {
        _currentIndex = index - 1;
      });
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _handleNext() {
    if (_isNextEnabled) {
      // 目前跳过API调用，直接进入首页
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainPage()),
          (route) => false,
        );
      }
    }
  }

  void _goBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                'OTP Verification',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 描述文本
              Text(
                'Enter the verification code we just sent on your email',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 60),
              
              // OTP输入框
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _currentIndex == index ? Colors.blue : Colors.grey.shade300,
                        width: _currentIndex == index ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: _currentIndex == index ? Colors.blue.shade50 : Colors.white,
                    ),
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        counterText: '',
                      ),
                      onChanged: (value) => _onChanged(value, index),
                      onTap: () {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      onSubmitted: (value) {
                        if (value.isEmpty) {
                          _onBackspace(index);
                        }
                      },
                    ),
                  );
                }),
              ),
              
              const SizedBox(height: 60),
              
              // Next按钮
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isNextEnabled ? _handleNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isNextEnabled ? Colors.blue : Colors.blue.shade100,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Next',
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
    );
  }
}