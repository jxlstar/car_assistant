import '../utils/logger_util.dart';
import '../storage/storage_service.dart';
import '../network/api_client.dart';

class AppService {
  static late ApiClient apiClient;
  
  static Future<void> init() async {
    try {
      // 初始化日志
      LoggerUtil.init();
      LoggerUtil.i('Initializing app services...');
      
      // 初始化本地存储
      await StorageService.init();
      
      // 初始化网络客户端
      apiClient = ApiClient.create();
      
      LoggerUtil.i('App services initialized successfully');
    } catch (e) {
      LoggerUtil.e('Failed to initialize app services: $e');
      rethrow;
    }
  }
}