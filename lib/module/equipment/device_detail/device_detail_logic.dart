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
      LoggerUtil.i('Device detail====${response.data?['data']}  ');
      if (response.success && response.data != null) {
        state.deviceDetail = Device.fromJson(response.data?['data']);
        // 根据设备的ctrl_status设置inhibitRestart状态
        state.inhibitRestart = (state.deviceDetail?.ctrlStatus == 1);
        LoggerUtil.d('system_press: ${state.deviceDetail?.systemPress}');
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
        LoggerUtil.i('Device ${value ? "lock" : "unlock"} successful: ${response.message}');
        
        // 显示成功提示
        Fluttertoast.showToast(msg: response.message, gravity: ToastGravity.CENTER);
        
        // API调用成功，重新请求设备详情接口刷新页面数据
        await loadDeviceDetail();
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
  
  // 在折线图数据中添加一个rpm数据点
  void _addRpmDataPoint() {
    if (state.deviceDetail?.latestReports != null) {
      // 获取当前引擎转速，如果没有则使用默认值
      final currentEngineSpeed = state.deviceDetail?.engineSpeed ?? 1000;
      
      // 创建新的报告数据点
      final newReport = LatestReport(
        engineSpeed: currentEngineSpeed + 1, // 增加1个单位rpm
        reportTimestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        deviceId: state.deviceId,
      );
      
      // 添加到latestReports数组中
      final updatedReports = List<LatestReport>.from(state.deviceDetail!.latestReports!);
      updatedReports.add(newReport);
      
      // 更新设备详情中的latestReports
      state.deviceDetail = Device(
        deviceId: state.deviceDetail?.deviceId,
        name: state.deviceDetail?.name,
        model: state.deviceDetail?.model,
        pin: state.deviceDetail?.pin,
        brand: state.deviceDetail?.brand,
        year: state.deviceDetail?.year,
        runtimeHours: state.deviceDetail?.runtimeHours,
        status: state.deviceDetail?.status,
        statusName: state.deviceDetail?.statusName,
        ctrlStatus: state.deviceDetail?.ctrlStatus,
        engStatus: state.deviceDetail?.engStatus,
        lastOnlineAt: state.deviceDetail?.lastOnlineAt,
        battery: state.deviceDetail?.battery,
        batteryStatus: state.deviceDetail?.batteryStatus,
        fuel: state.deviceDetail?.fuel,
        fuelStatus: state.deviceDetail?.fuelStatus,
        oilPressure: state.deviceDetail?.oilPressure,
        waterTemperature: state.deviceDetail?.waterTemperature,
        locationStatus: state.deviceDetail?.locationStatus,
        locationStatusName: state.deviceDetail?.locationStatusName,
        location: state.deviceDetail?.location,
        lockStatus: state.deviceDetail?.lockStatus,
        lockStatusName: state.deviceDetail?.lockStatusName,
        lastMaintenanceTime: state.deviceDetail?.lastMaintenanceTime,
        nextMaintenanceTime: state.deviceDetail?.nextMaintenanceTime,
        deviceImages: state.deviceDetail?.deviceImages,
        mainImageUrl: state.deviceDetail?.mainImageUrl,
        maintenanceManuals: state.deviceDetail?.maintenanceManuals,
        operationManuals: state.deviceDetail?.operationManuals,
        runningTime: state.deviceDetail?.runningTime,
        engineSpeed: currentEngineSpeed + 1, // 同时更新当前引擎转速
        pilotStatus: state.deviceDetail?.pilotStatus,
        latestReports: updatedReports,
      );
      
      LoggerUtil.i('Added new RPM data point: ${currentEngineSpeed + 1}');
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
    return '${((state.deviceDetail?.runningTime ?? 0) / 60).toStringAsFixed(2)} h';
  }
  
  // 获取上次在线时间（根据时间差显示相对时间，使用UTC时间）
  String get lastOnlineTime {
    if (state.deviceDetail?.lastOnlineAt == null) {
      return 'N/A';
    }
    final timestamp = state.deviceDetail!.lastOnlineAt!;
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true);
    final now = DateTime.now().toUtc();
    final difference = now.difference(dateTime);
    
    final minutes = difference.inMinutes;
    final hours = difference.inHours;
    
    if (minutes < 5) {
      return 'Within 5 minutes';
    } else if (minutes < 30) {
      return 'Within half an hour';
    } else if (hours < 2) {
      return 'Within 2 hours';
    } else {
      return 'Over 2 hours';
    }
  }
  
  // 获取电量
  String get batteryLevel {
    String? formatted = ((state.deviceDetail?.battery ?? 0) / 1000).toStringAsFixed(1);
    return ' ${formatted}v';
  }
  
  // 判断是否运行（eng_status: 1=运行，2=停机）
  bool get isRunning {
    final engStatus = state.deviceDetail?.engStatus;
    return engStatus == 1;
  }
  
  // 判断是否在线（status: 0=离线，1=在线）
  bool get isOnline {
    final status = state.deviceDetail?.status;
    return status == 1;
  }
  
  // 获取状态名称
  String get statusName {
    return state.deviceDetail?.statusName ?? 'Unknown';
  }
  
  // 获取油量
  String get fuelLevel {
    return '${(state.deviceDetail?.fuel ?? 0).toStringAsFixed(1)}%';
  } 
  
  // 获取水温（华氏整数 + 摄氏整数，如 89℉/30℃）
  String get waterTemperature {
    final f = (state.deviceDetail?.waterTemperature ?? 0).round();
    final c = ((f - 32) * 5 / 9).round();
    return '$f℉/$c℃';
  }

  String get enginSpeed {
    return '${state.deviceDetail?.engineSpeed ?? 0}rpm';
  }

  String get pilot {
    final value = state.deviceDetail?.pilotStatus ?? 0;
    if (value >= 32767) return '--';
    return '${(value / 100).toStringAsFixed(0)}MPa';
  }
  String get sysPress {
    final value = state.deviceDetail?.systemPress ?? 0;
    if (value >= 32767) return '--';
    return '${(value / 100).toStringAsFixed(0)}MPa';
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
  // 获取inhibit restart状态（基于ctrl_status）
  bool get inhibitRestartStatus {
    return state.inhibitRestart;
  }
  
  // 切换Pro模式
  void toggleProMode() {
    state.isProMode = !state.isProMode;
    update();
  }
}