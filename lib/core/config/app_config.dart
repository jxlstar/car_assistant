class AppConfig {
  static const String appName = 'Car Assistant';
  static const String baseUrl = 'http://ec2-18-208-182-137.compute-1.amazonaws.com:8081/api-test-center';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  
  // 调试模式
  static const bool isDebug = true;
  
  // 日志级别
  static const String logLevel = 'debug';
}