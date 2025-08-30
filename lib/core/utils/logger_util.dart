import 'package:logger/logger.dart';
import '../config/app_config.dart';

class LoggerUtil {
  static late Logger _logger;

  // 初始化Logger
  static void init() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2, // 每个日志输出中包含的方法调用数
        errorMethodCount: 8, // 错误日志中包含的方法调用数
        lineLength: 120, // 每行的宽度
        colors: true, // 彩色日志输出
        printEmojis: true, // 打印表情符号
        printTime: true, // 打印时间戳
      ),
      level: AppConfig.isDebug ? Level.debug : Level.warning, // 设置日志级别
    );
  }

  static void d(String message) {
    _logger.d(message);
  }

  static void i(String message) {
    _logger.i(message);
  }

  static void w(String message) {
    _logger.w(message);
  }

  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}