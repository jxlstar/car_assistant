import 'package:car_assistant/module/splash/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/network/api_service.dart';
import 'core/storage/storage_service.dart';
import 'core/utils/logger_util.dart';
import 'package:car_assistant/module/login/auth_provider.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LoggerUtil.init(); // 初始化日志
  await StorageService.init();
  ApiService.init();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: navigatorKey,
      title: 'Car Assistant',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashPage(),
    );
  }
}
