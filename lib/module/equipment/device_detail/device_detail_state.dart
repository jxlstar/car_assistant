import 'package:get/get.dart';

class DeviceDetailState {
  // 加载状态
  bool isLoading = false;
  
  // 设备详情数据
  Map<String, dynamic>? deviceDetail;
  
  // 设备ID
  String? deviceId;
  
  // 错误信息
  String? errorMessage;
  
  // 控制开关状态
  bool inhibitRestart = false;
  
  DeviceDetailState();
}