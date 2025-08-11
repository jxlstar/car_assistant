import 'package:get/get.dart';
import '../../../core/network/api_service.dart';
import '../../../core/utils/logger_util.dart';
import 'device_detail_state.dart';

class DeviceDetailLogic extends GetxController {
  final DeviceDetailState state = DeviceDetailState();
  
  @override
  void onInit() {
    super.onInit();
    // 从路由参数获取deviceId
    final arguments = Get.arguments;
    if (arguments != null && arguments['deviceId'] != null) {
      state.deviceId = arguments['deviceId'];
      loadDeviceDetail();
    }
  }
  
  // 加载设备详情
  Future<void> loadDeviceDetail() async {
    if (state.deviceId == null) return;
    try {
      state.isLoading = true;
      state.errorMessage = null;
      update();
      
      final response = await ApiService.getDeviceDetail(state.deviceId!);
      LoggerUtil.i('设备device_id详情====${state.deviceId}');
      LoggerUtil.i('设备详情====$response  ');
      if (response.success && response.data != null) {
        state.deviceDetail = response.data?['data'];
        LoggerUtil.d('设备详情加载成功: ${response.data}');
      } else {
        state.errorMessage = response.message ?? '加载设备详情失败';
        LoggerUtil.e('设备详情加载失败: ${response.message}');
      }
    } catch (e) {
      state.errorMessage = '网络错误，请稍后重试';
      LoggerUtil.e('设备详情加载异常: $e');
    } finally {
      state.isLoading = false;
      update();
    }
  }
  
  // 切换禁止重启开关
  void toggleInhibitRestart(bool value) {
    state.inhibitRestart = value;
    update();
    // TODO: 调用API更新设备设置
  }
  
  // 刷新设备详情
  Future<void> refreshDeviceDetail() async {
    await loadDeviceDetail();
  }
  
  // 获取设备名称
  String get deviceName {
    return state.deviceDetail?['device_name'] ??
           state.deviceDetail?['name'] ??
           '未知设备';
  }
  // 获取当前位置
  String get headerImage {
    final imageUrl = state.deviceDetail?['device_images'][0];
    if (imageUrl != null) {
      return imageUrl['image_url'] ?? '';
    }
    return '';
  }
  // 获取设备型号
  String get deviceModel {
    return state.deviceDetail?['model'] ?? '未知型号';
  }
  
  // 获取设备PIN
  String get devicePin {
    return state.deviceDetail?['pin'] ?? '未知PIN';
  }
  
  // 获取运行时长
  String get runtimeHours {
    final hours = state.deviceDetail?['runtime_hours'] ?? 
                  state.deviceDetail?['runtimeHours'] ?? '0';
    return hours.toString();
  }
  
  // 获取电量
  String get batteryLevel {
    final battery = state.deviceDetail?['battery_level'] ?? 
                   state.deviceDetail?['batteryLevel'] ?? '0';
    return '${battery}%';
  }
  
  // 获取油量
  String get fuelLevel {
    final fuel = state.deviceDetail?['fuel_level'] ?? 
                state.deviceDetail?['fuelLevel'] ?? '0';
    return '${fuel}%';
  }
  
  // 获取水温
  String get waterTemperature {
    final temp = state.deviceDetail?['water_temperature'] ?? 
                state.deviceDetail?['waterTemperature'] ?? '0';
    return '${temp}°F';
  }
  
  // 获取当前位置
  String get currentLocation {
    final location = state.deviceDetail?['current_location'];
    if (location != null) {
      return location['address'] ?? '未知位置';
    }
    return '未知位置';
  }
  
  // 获取位置坐标
  Map<String, double> get locationCoordinates {
    final location = state.deviceDetail?['current_location'];
    if (location != null) {
      return {
        'latitude': double.tryParse(location['latitude']?.toString() ?? '0') ?? 0.0,
        'longitude': double.tryParse(location['longitude']?.toString() ?? '0') ?? 0.0,
      };
    }
    return {'latitude': 28.5383, 'longitude': -81.3792}; // 默认奥兰多坐标
  }
}