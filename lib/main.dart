import 'package:car_assistant/module/splash/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/network/api_service.dart';
import 'core/storage/storage_service.dart';
import 'core/utils/logger_util.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LoggerUtil.init();
  await StorageService.init();
  ApiService.init();
  await ApiService.loadAuthToken(); // 加载已保存的token
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: navigatorKey,
      color: Colors.white,
      title: 'Car Assistant',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashPage(),
    );
  }
}
