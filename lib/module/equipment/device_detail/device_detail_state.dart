import 'package:get/get.dart';
import '../equipment_state.dart';

class DeviceDetailState {
  // 加载状态
  bool isLoading = false;
  
  // 设备详情数据
  Device? deviceDetail;
  
  // 设备ID
  String? deviceId;
  
  // 错误信息
  String? errorMessage;
  
  // 控制开关状态
  bool inhibitRestart = false;
  
  // Pro按钮状态
  bool isProMode = false;
  
  DeviceDetailState();
}