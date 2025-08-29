import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';
import '../../../core/network/app_request.dart';
import '../../../core/utils/logger_util.dart';
import '../equipment_state.dart';
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
      LoggerUtil.i('Device device_id detail====${state.deviceId}');
      LoggerUtil.i('Device detail====$response  ');
      if (response.success && response.data != null) {
        state.deviceDetail = Device.fromJson(response.data?['data']);
        LoggerUtil.d('Device detail loaded successfully: ${response.data}');
      } else {
        state.errorMessage = response.message ?? 'Failed to load device details';
        LoggerUtil.e('Failed to load device details: ${response.message}');
      }
    } catch (e) {
      state.errorMessage = 'Network error, please try again later';
      LoggerUtil.e('Exception loading device details: $e');
    } finally {
      state.isLoading = false;
      update();
    }
  }
  
  // 切换禁止重启开关
  Future<void> toggleInhibitRestart(bool value) async {
    if (state.deviceId == null) {
      LoggerUtil.e('Device ID is null, cannot perform lock/unlock operation');
      return;
    }

    try {
      // 显示加载状态
      // state.isLoading = true;
      update();

      ApiResponse<Map<String, dynamic>> response;
      
      if (value) {
        // 锁定设备
        response = await ApiService.lockDevice(state.deviceId!);
      } else {
        // 解锁设备
        response = await ApiService.unlockDevice(state.deviceId!);
      }
      LoggerUtil.i('Device lock/unlock response data===: $response');
      if (response.success) {
        // API调用成功，更新本地状态
        state.inhibitRestart = value;
        LoggerUtil.i('Device ${value ? "lock" : "unlock"} successful: ${response.message}');
        
        // 显示成功提示
        Fluttertoast.showToast(msg: response.message, gravity: ToastGravity.CENTER);
      } else {
        // API调用失败，显示错误信息
        Fluttertoast.showToast(msg: response.message, gravity: ToastGravity.CENTER);
      }
    } catch (e) {
      LoggerUtil.e('Device ${value ? "lock" : "unlock"} exception: $e');
      Fluttertoast.showToast(msg: '$e', gravity: ToastGravity.CENTER);
    } finally {
      // state.isLoading = false;
      update();
    }
  }
  
  // 刷新设备详情
  Future<void> refreshDeviceDetail() async {
    await loadDeviceDetail();
  }
  
  // 获取设备名称
  String get deviceName {
    return state.deviceDetail?.name ?? 'Unknown Device';
  }
  // 获取当前位置
  String get headerImage {
    return state.deviceDetail?.mainImageUrl ?? '';
  }
  // 获取设备型号
  String get deviceModel {
    return state.deviceDetail?.model ?? 'Unknown Model';
  }
  
  // 获取设备PIN
  String get devicePin {
    return state.deviceDetail?.pin ?? 'Unknown PIN';
  }
  
  // 获取运行时长
  String get runtimeHours {
    return state.deviceDetail?.runtimeHours.toString() ?? '0';
  }
  
  // 获取电量
  String get batteryLevel {
    String? formatted = state.deviceDetail?.battery?.toStringAsFixed(2);
    return ' ${formatted ?? 0}%';
  }
  
  // 获取油量
  String get fuelLevel {
    return '${state.deviceDetail?.fuel ?? 0}%';
  }
  
  // 获取水温
  String get waterTemperature {
    return '${state.deviceDetail?.waterTemperature ?? 0}°F';
  }
  
  // 获取当前位置
  String get currentLocation {
    return state.deviceDetail?.location?.address ?? 'No location available';
  }
  
  // 检查是否有有效的位置信息
  bool get hasValidLocation {
    final location = state.deviceDetail?.location;
    if (location == null) {
      return false;
    }
    final latitude = location.latitude;
    final longitude = location.longitude;
    if (latitude == null || longitude == null) {
      return false;
    }
    // Consider 0,0 as an invalid location
    if (latitude == 0.0 && longitude == 0.0) {
      return false;
    }
    return true;
  }
  
  // 获取位置坐标
  Map<String, double> get locationCoordinates {
    final location = state.deviceDetail?.location;
    if (location != null) {
      return {
        'latitude': location.latitude ?? 0.0,
        'longitude': location.longitude ?? 0.0,
      };
    }
    return {'latitude': 28.5383, 'longitude': -81.3792}; // Default Orlando coordinates
  }
}