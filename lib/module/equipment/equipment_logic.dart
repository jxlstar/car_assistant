import 'package:car_assistant/core/network/api_service.dart';
import 'package:car_assistant/core/utils/logger_util.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'equipment_state.dart';

class EquipmentLogic extends GetxController {
  final EquipmentState state = EquipmentState();

  // 绑定设备（使用新的数据结构）
  Future<bool> bindDevice(String rockNumber, String deviceName, {String? deviceId, String? pin,  String? model}) async {
    state.hasDevice = true;
    try{
      final response =  await ApiService.bindDevice(rockNumber: rockNumber, deviceName: deviceName);
      LoggerUtil.i('绑定设备====$response');
      if(response.success) {
        LoggerUtil.i('绑定成功====$response');
        Fluttertoast.showToast(msg: '绑定成功');
        // 请求设备列表
        fetchDeviceList();
        // mockAddDevice(deviceName, deviceId, model, pin);
        return true;
      }else {
        LoggerUtil.i('绑定失败====${response.message}');
        Fluttertoast.showToast(msg: response.message, gravity: ToastGravity.CENTER);
        return false;
      }
    }catch(e){
      LoggerUtil.i('绑定失败====$e');
      return false;
    }
  }

  // 从JSON数据添加设备
  void addDeviceFromJson(Map<String, dynamic> deviceJson) {
    final device = Device.fromJson(deviceJson);
    state.devices.add(device);
    state.hasDevice = true;
    update();
  }

  // 更新设备状态
  void updateDeviceStatus(String deviceId, int status) {
    final index = state.devices.indexWhere((device) => device.deviceId == deviceId);
    if (index != -1) {
      final device = state.devices[index];
      final updatedDevice = Device(
        deviceId: device.deviceId,
        deviceName: device.deviceName,
        model: device.model,
        pin: device.pin,
        runtimeHours: device.runtimeHours,
        batteryLevel: device.batteryLevel,
        fuelLevel: device.fuelLevel,
        oilPressure: device.oilPressure,
        waterTemperature: device.waterTemperature,
        lockStatus: device.lockStatus,
        locationStatus: device.locationStatus,
        currentLocation: device.currentLocation,
        status: status,
        bindTime: device.bindTime,
      );
      state.devices[index] = updatedDevice;
      update();
    }
  }

  // 更新设备位置
  void updateDeviceLocation(String deviceId, double latitude, double longitude, String address) {
    final index = state.devices.indexWhere((device) => device.deviceId == deviceId);
    if (index != -1) {
      final device = state.devices[index];
      final updatedLocation = CurrentLocation(
        latitude: latitude,
        longitude: longitude,
        address: address,
        updateTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );
      
      final updatedDevice = Device(
        deviceId: device.deviceId,
        deviceName: device.deviceName,
        model: device.model,
        pin: device.pin,
        runtimeHours: device.runtimeHours,
        batteryLevel: device.batteryLevel,
        fuelLevel: device.fuelLevel,
        oilPressure: device.oilPressure,
        waterTemperature: device.waterTemperature,
        lockStatus: device.lockStatus,
        locationStatus: device.locationStatus,
        currentLocation: updatedLocation,
        status: device.status,
        bindTime: device.bindTime,
      );
      state.devices[index] = updatedDevice;
      update();
    }
  }

  // 切换设备锁机状态
  void toggleDeviceLock(String deviceId) {
    final index = state.devices.indexWhere((device) => device.deviceId == deviceId);
    if (index != -1) {
      final device = state.devices[index];
      final updatedLockStatus = LockStatus(
        isLocked: !device.lockStatus!.isLocked,
        lockType: device.lockStatus!.lockType,
      );
      
      final updatedDevice = Device(
        deviceId: device.deviceId,
        deviceName: device.deviceName,
        model: device.model,
        pin: device.pin,
        runtimeHours: device.runtimeHours,
        batteryLevel: device.batteryLevel,
        fuelLevel: device.fuelLevel,
        oilPressure: device.oilPressure,
        waterTemperature: device.waterTemperature,
        lockStatus: updatedLockStatus,
        locationStatus: device.locationStatus,
        currentLocation: device.currentLocation,
        status: device.status,
        bindTime: device.bindTime,
      );
      state.devices[index] = updatedDevice;
      update();
    }
  }

  // 解绑设备
  void unbindDevice() {
    state.hasDevice = false;
    state.deviceModel = '';
    state.deviceId = '';
    state.devices.clear();
    update();
  }

  // 根据设备ID移除设备
  void removeDevice(String deviceId) {
    state.devices.removeWhere((device) => device.deviceId == deviceId);
    if (state.devices.isEmpty) {
      state.hasDevice = false;
      state.deviceModel = '';
      state.deviceId = '';
    }
    update();
  }

  void mockAddDevice(String deviceName, String deviceId, String model, String pin) {
  // 创建新设备实例
    final device = Device(
      deviceId: deviceId ?? 'EXC${DateTime.now().millisecondsSinceEpoch}',
      deviceName: deviceName,
      model: model,
      pin: pin ?? 'CAT${model.replaceAll(' ', '')}${deviceId ?? ''}',
      runtimeHours: 134.9, // 默认运行小时数
      batteryLevel: 85,
      fuelLevel: 72,
      oilPressure: 45,
      waterTemperature: 88,
      lockStatus: LockStatus(
        isLocked: false,
        lockType: 'remote',
      ),
      locationStatus: LocationStatus(
        gpsAvailable: true,
        lastUpdate: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      ),
      currentLocation: CurrentLocation(
        latitude: 39.9042,
        longitude: 116.4074,
        address: '北京市朝阳区建国路工地',
        updateTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      ),
      status: 1,
      bindTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
  state.devices.add(device);
  update(); // 通知UI更新
 }

 Future<void> fetchDeviceList() async {
    try{
      final response = await ApiService.getDeviceList();
      LoggerUtil.i('设备列表==$response');
      if(response.success) {
        LoggerUtil.e('获取列表成功');
        state.devices.clear();

        LoggerUtil.e('设备列表----：${response.data?['data']['devices']}');
        List<Device> list = ((response.data?['data']['devices']) as List)
            .map((item) => Device.fromJson(item))
            .toList();


        LoggerUtil.e('设备列表--list--：$list');
        state.devices.addAll(list);
        update();
      }else {
        LoggerUtil.e('获取列表失败：${response.message}');
      }
    }catch(e){
      LoggerUtil.e('获取列表失败：$e');
    }
}
  // 获取设备列表
  List<Device> get devices => state.devices;
  
  // 是否有设备
  bool get hasDevice => state.hasDevice;
  
  // 设备型号
  String get deviceModel => state.deviceModel;
  
  // 设备ID
  String get deviceId => state.deviceId;
  
  // 获取在线设备数量
  int get onlineDeviceCount => state.devices.where((device) => device.status == 'online').length;
  
  // 获取离线设备数量
  int get offlineDeviceCount => state.devices.where((device) => device.status == 'offline').length;
}