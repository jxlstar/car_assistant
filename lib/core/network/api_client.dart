import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../config/app_config.dart';
import '../utils/logger_util.dart';

part 'api_client.g.dart';

@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  static ApiClient create() {
    final dio = Dio();
    
    // 添加拦截器
    dio.interceptors.addAll([
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => LoggerUtil.d(obj.toString()),
      ),
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // 添加通用请求头
          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept'] = 'application/json';
          handler.next(options);
        },
        onError: (error, handler) {
          LoggerUtil.e('API Error: ${error.message}');
          handler.next(error);
        },
      ),
    ]);
    
    return ApiClient(dio, baseUrl: AppConfig.baseUrl);
  }
}