import 'package:car_assistant/core/storage/storage_service.dart';
import 'package:car_assistant/module/login/login_page.dart';
import 'package:get/get.dart';

import '../home/main_page.dart';

class SplashLogic extends GetxController {

  @override
  void onReady() {
    super.onReady();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    // 延迟2秒，用于展示启动页
    await Future.delayed(const Duration(seconds: 2));

    // 检查是否存在token
    final token = StorageService.getString('auth_token');

    if (token != null && token.isNotEmpty) {
      // 如果token存在，跳转到主页
      Get.offAll(() => const MainPage());
    } else {
      // 如果token不存在，跳转到登录页
      Get.offAll(() => const LoginPage());
    }
  }
}