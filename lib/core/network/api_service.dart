import 'package:car_assistant/core/utils/logger_util.dart';

import '../storage/storage_service.dart' show StorageService;
import 'app_request.dart';

class ApiService {
  static final AppRequest _request = AppRequest();

  // 初始化
  static void init() {
    _request.init();
  }

  // 用户注册
    static Future<ApiResponse<Map<String, dynamic>>> register({
      required String email,
      required String password,
      String? fullName,
      String? phone,
    }) {
      return _request.post<Map<String, dynamic>>('/api/app/auth/register', data: {
        'email': email,
        'password': password,
        if (fullName != null) 'full_name': fullName,
        if (phone != null) 'phone': phone,
      });
    }

    // 用户登录
    static Future<ApiResponse<Map<String, dynamic>>> login({
      required String email,
      required String password,
    }) {
      return _request.post<Map<String, dynamic>>('/api/app/auth/login', data: {
        'email': email,
        'password': password,
      });
    }

    // 退出登录
    static Future<ApiResponse<Map<String, dynamic>>> logout() {
      return _request.post<Map<String, dynamic>>('/api/app/auth/logout');
    }

    // 刷新token
    static Future<ApiResponse<Map<String, dynamic>>> refreshToken() {
      return _request.post<Map<String, dynamic>>('/api/app/auth/refresh');
    }
    // 获取设备列表
    static Future<ApiResponse<Map<String, dynamic>>> getDeviceList() {
      return _request.get<Map<String, dynamic>>('/api/app/devices/bound');
    }

    // 获取设备详情
    static Future<ApiResponse<Map<String, dynamic>>> getDeviceDetail(String deviceId) {
      return _request.get<Map<String, dynamic>>('/api/app/devices/$deviceId/details');
    }

    // 绑定设备
    static Future<ApiResponse<Map<String, dynamic>>> bindDevice({
      required String rockNumber,
      required String deviceName,
    }) {
      return _request.post<Map<String, dynamic>>('/api/app/devices/bind', data: {
        'rock_number': rockNumber,
        'device_name': deviceName,
      });
    }

    // 解绑设备
    static Future<ApiResponse<Map<String, dynamic>>> unbindDevice(String deviceId) {
      return _request.delete<Map<String, dynamic>>('/api/app/equipment/bind/$deviceId');
    }
    // 获取经销商列表
    static Future<ApiResponse<Map<String, dynamic>>> getDealerList() {
      return _request.get<Map<String, dynamic>>('/api/app/dealers?page=1&page_size=50');
    }
    // 收藏代理商
    static Future<ApiResponse> addDealerToFavorites(dynamic dealerId) async {

      LoggerUtil.i('收藏&&addDealerToFavorites=====$dealerId =====');
      return await _request.post('/api/app/dealers/$dealerId/favorite',);
    }
  // 取消收藏代理商
    static Future<ApiResponse> removeDealerFromFavorites(dynamic dealerId) async {
      return await _request.delete('/api/app/dealers/$dealerId/favorite',
    );
  }
    static Future<ApiResponse> getFavoriteDealers() async {
      return await _request.get('/api/app/dealers/favorites?page=1&page_size=20',);
    }
    static Future<ApiResponse> getDealerDetail(dynamic dealerId) async {
      return await _request.get('/api/app/dealers/$dealerId');
    }

    // 获取用户信息
    static Future<ApiResponse<Map<String, dynamic>>> getUserInfo() {
      return _request.get<Map<String, dynamic>>('/api/app/user/profile');
    }

    // 更新用户信息
    static Future<ApiResponse<Map<String, dynamic>>> updateUserInfo(Map<String, dynamic> data) {
      return _request.put<Map<String, dynamic>>('/api/app/user/profile', data: data);
    }

    // 上传头像
    static Future<ApiResponse<Map<String, dynamic>>> uploadAvatar(String filePath) {
      return _request.uploadFile<Map<String, dynamic>>(
        '/api/app/user/avatar',
        filePath,
        fieldName: 'avatar',
      );
    }

  // 查询设备
  static Future<ApiResponse<Map<String, dynamic>>> searchDevice({
    required String rockNumber,
    required String model
  }) {
    return _request.post<Map<String, dynamic>>('/api/app/devices/search', data: {
      'rock_number': rockNumber,
      'model': model,
    });
  }

  // 通用方法
  static void setAuthToken(String token) {
    _request.setAuthToken(token);
  }
// 获取存储的token
 static bool isLogin() {
   String? authToken = StorageService.getString('auth_token');
    return authToken != null ? true : false;
  }
  static void clearAuthToken() {
    _request.clearAuthToken();
  }

  static Future<void> loadAuthToken() {
    return _request.loadAuthToken();
  }

  // 获取设备品牌分类（一级）
  static Future<ApiResponse<Map<String, dynamic>>> getResourceBrands() {
    return _request.get<Map<String, dynamic>>('/api/app/resources');
  }

  // 获取设备分类（二级）
  static Future<ApiResponse<Map<String, dynamic>>> getResourceCategories(String brandId) {
    return _request.get<Map<String, dynamic>>('/api/app/resources/categories/$brandId');
  }

  // 获取设备型号（三级）
  static Future<ApiResponse<Map<String, dynamic>>> getResourceModels(String categoryId) {
    return _request.get<Map<String, dynamic>>('/api/app/resources/models/$categoryId');
  }

}