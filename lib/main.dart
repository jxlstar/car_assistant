import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'module/login/auth_provider.dart';
import 'module/splash/splash_page.dart';
import 'core/services/app_service.dart';
import 'core/utils/logger_util.dart';
import 'module/resources/resources_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // 初始化应用服务
    await AppService.init();
    
    runApp(const MyApp());
  } catch (e) {
    // LoggerUtil.e('Failed to start app: $e');
    runApp(const ErrorApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: GetMaterialApp(
        title: '车载助手',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        // 将启动页面设为初始页面
        home: const SplashPage(),
        // 添加路由配置
        getPages: [
          GetPage(name: '/resource_detail', page: () => ResourcesPage()),
          // 其他路由...
        ],
      ),
    );
  }
}

// ErrorApp 类保持不变
class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                '应用启动失败',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  // 重启应用
                },
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
