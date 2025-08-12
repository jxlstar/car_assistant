import 'package:car_assistant/core/network/api_service.dart';
import 'package:car_assistant/core/services/app_service.dart';
import 'package:car_assistant/core/utils/logger_util.dart';
import 'package:car_assistant/r.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../home/main_page.dart';
import '../login/login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // 显示启动页面2秒
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    
    // 根据登录状态跳转
    if (ApiService.isLogin()) {
      // 已登录，跳转到主页面（设备页面是第一个tab）
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    } else {
      // 未登录，跳转到登录页面
      LoggerUtil.i("未登录");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // RIPPA Logo 占位符
            SizedBox(
              width: 120,
              height: 120,
              child: Image.asset(R.assetsImageLogo),
            ),
            const SizedBox(height: 40),
            // Welcome 文字
            Text(
              'Welcome to RAPPA',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 60),
            
            // 加载指示器
            SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}