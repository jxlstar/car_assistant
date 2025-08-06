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
    static Future<ApiResponse<List<dynamic>>> getDeviceList({
      int page = 1,
      int limit = 20,
      String? search,
    }) {
      return _request.get<List<dynamic>>('/api/app/equipment/devices', queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null) 'search': search,
      });
    }

    // 获取设备详情
    static Future<ApiResponse<Map<String, dynamic>>> getDeviceDetail(String deviceId) {
      return _request.get<Map<String, dynamic>>('/api/app/equipment/devices/$deviceId');
    }

    // 绑定设备
    static Future<ApiResponse<Map<String, dynamic>>> bindDevice({
      required String deviceId,
      required String pin,
    }) {
      return _request.post<Map<String, dynamic>>('/api/app/equipment/bind', data: {
        'device_id': deviceId,
        'pin': pin,
      });
    }

    // 解绑设备
    static Future<ApiResponse<Map<String, dynamic>>> unbindDevice(String deviceId) {
      return _request.delete<Map<String, dynamic>>('/api/app/equipment/bind/$deviceId');
    }
    // 获取经销商列表
    static Future<ApiResponse<List<dynamic>>> getDealerList({
      double? latitude,
      double? longitude,
      int radius = 50,
    }) {
      return _request.get<List<dynamic>>('/api/app/dealers', queryParameters: {
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        'radius': radius,
      });
    }

    // 获取经销商详情
    static Future<ApiResponse<Map<String, dynamic>>> getDealerDetail(String dealerId) {
      return _request.get<Map<String, dynamic>>('/api/app/dealers/$dealerId');
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

  // 通用方法
  static void setAuthToken(String token) {
    _request.setAuthToken(token);
  }

  static void clearAuthToken() {
    _request.clearAuthToken();
  }

  static Future<void> loadAuthToken() {
    return _request.loadAuthToken();
  }
}