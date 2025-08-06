import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../utils/logger_util.dart';
import '../storage/storage_service.dart';

class AppRequest {
  // 单例模式
  static final AppRequest _instance = AppRequest._internal();
  factory AppRequest() => _instance;
  AppRequest._internal();

  late Dio _dio;
  String? _authToken;

  // 初始化dio实例
  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: Duration(milliseconds: AppConfig.connectTimeout),
      receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // 添加拦截器
    _dio.interceptors.addAll([
      // 请求拦截器
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // 添加认证token
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          LoggerUtil.d('Request: ${options.method} ${options.path}');
          LoggerUtil.d('Headers: ${options.headers}');
          LoggerUtil.d('Data: ${options.data}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          LoggerUtil.d('Response: ${response.statusCode} ${response.data}');
          handler.next(response);
        },
        onError: (error, handler) {
          LoggerUtil.e('API Error: ${error.message}');
          LoggerUtil.e('Error Data: ${error.response?.data}');
          handler.next(error);
        },
      ),
      // 日志拦截器
      if (AppConfig.isDebug)
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => LoggerUtil.d(obj.toString()),
        ),
    ]);
  }

  // 设置认证token
  void setAuthToken(String token) {
    _authToken = token;
    StorageService.setString('auth_token', token);
  }

  // 获取存储的token
  Future<void> loadAuthToken() async {
    _authToken = StorageService.getString('auth_token');
  }

  // 清除认证token
  void clearAuthToken() {
    _authToken = null;
    StorageService.remove('auth_token');
  }

  // 通用请求方法
  Future<ApiResponse<T>> _request<T>(
    String method,
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _dio.get(
            path,
            queryParameters: queryParameters,
            options: options,
          );
          break;
        case 'POST':
          response = await _dio.post(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
          );
          break;
        case 'PUT':
          response = await _dio.put(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
          );
          break;
        case 'DELETE':
          response = await _dio.delete(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
          );
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      return ApiResponse<T>.success(
        data: response.data,
        message: response.data['message'] ?? 'Success',
        statusCode: response.statusCode ?? 200,
      );
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return ApiResponse<T>.error(
        message: '未知错误: $e',
        statusCode: -1,
      );
    }
  }

  // 处理Dio错误
  ApiResponse<T> _handleDioError<T>(DioException error) {
    String message;
    int statusCode = error.response?.statusCode ?? -1;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = '连接超时';
        break;
      case DioExceptionType.sendTimeout:
        message = '发送超时';
        break;
      case DioExceptionType.receiveTimeout:
        message = '接收超时';
        break;
      case DioExceptionType.badResponse:
        message = error.response?.data['message'] ?? '服务器错误';
        break;
      case DioExceptionType.cancel:
        message = '请求已取消';
        break;
      case DioExceptionType.connectionError:
        message = '网络连接错误';
        break;
      default:
        message = '网络请求失败';
    }

    return ApiResponse<T>.error(
      message: message,
      statusCode: statusCode,
      data: error.response?.data,
    );
  }

  // GET请求
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _request<T>('GET', path,
        queryParameters: queryParameters, options: options);
  }

  // POST请求
  Future<ApiResponse<T>> post<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {

    return _request<T>('POST', path,
        data: data, queryParameters: queryParameters, options: options);
  }

  // PUT请求
  Future<ApiResponse<T>> put<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _request<T>('PUT', path,
        data: data, queryParameters: queryParameters, options: options);
  }

  // DELETE请求
  Future<ApiResponse<T>> delete<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _request<T>('DELETE', path,
        data: data, queryParameters: queryParameters, options: options);
  }

  // 文件上传
  Future<ApiResponse<T>> uploadFile<T>(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        if (data != null) ...data,
      });

      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );

      return ApiResponse<T>.success(
        data: response.data,
        message: response.data['message'] ?? 'Upload successful',
        statusCode: response.statusCode ?? 200,
      );
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return ApiResponse<T>.error(
        message: '文件上传失败: $e',
        statusCode: -1,
      );
    }
  }

  // 下载文件
  Future<ApiResponse<String>> downloadFile(
    String url,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );

      return ApiResponse<String>.success(
        data: savePath,
        message: '下载成功',
        statusCode: 200,
      );
    } on DioException catch (e) {
      return _handleDioError<String>(e);
    } catch (e) {
      return ApiResponse<String>.error(
        message: '文件下载失败: $e',
        statusCode: -1,
      );
    }
  }
}

// API响应封装类
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final int statusCode;
  final dynamic rawData;

  ApiResponse._({
    required this.success,
    this.data,
    required this.message,
    required this.statusCode,
    this.rawData,
  });

  factory ApiResponse.success({
    T? data,
    required String message,
    required int statusCode,
    dynamic rawData,
  }) {
    return ApiResponse._(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
      rawData: rawData,
    );
  }

  factory ApiResponse.error({
    required String message,
    required int statusCode,
    T? data,
    dynamic rawData,
  }) {
    return ApiResponse._(
      success: false,
      data: data,
      message: message,
      statusCode: statusCode,
      rawData: rawData,
    );
  }

  @override
  String toString() {
    return 'ApiResponse{success: $success, message: $message, statusCode: $statusCode, data: $data}';
  }
}