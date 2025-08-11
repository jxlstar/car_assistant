import '../utils/logger_util.dart';
import '../storage/storage_service.dart';
import '../network/api_service.dart';

class AppService {
  static Future<void> init() async {
    try {
      // 初始化日志
      LoggerUtil.init();
      // LoggerUtil.i('Initializing app services...');
      
      // 初始化本地存储
      await StorageService.init();
      
      // 初始化API服务
      ApiService.init();
      
      // 加载认证token
      await ApiService.loadAuthToken();
      
      // LoggerUtil.i('App services initialized successfully');
    } catch (e) {
      // LoggerUtil.e('Failed to initialize app services: $e');
      rethrow;
    }
  }
}