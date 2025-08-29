import 'package:car_assistant/core/network/api_service.dart';
import 'package:car_assistant/core/utils/logger_util.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'equipment_state.dart';

class EquipmentLogic extends GetxController {
  final EquipmentState state = EquipmentState();

  @override
  void onInit() {
    super.onInit();
    // Clear devices on initialization to avoid showing stale data
    state.devices.clear();
  }

  // 绑定设备（使用新的数据结构）
  Future<bool> bindDevice(String rockNumber, String name, {String? deviceId, String? pin,  String? model}) async {
    state.hasDevice = true;
    try{
      final response =  await ApiService.bindDevice(rockNumber: rockNumber, deviceName: name);
      LoggerUtil.i('绑定设备====$response');
      if(response.success) {
        LoggerUtil.i('绑定成功====$response');
        Fluttertoast.showToast(msg: '绑定成功');
        // 请求设备列表
        fetchDeviceList();
        // mockAddDevice(name, deviceId, model, pin);
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
        name: device.name,
        model: device.model,
        pin: device.pin,
        brand: device.brand,
        year: device.year,
        runtimeHours: device.runtimeHours,
        status: status,
        statusName: device.statusName,
        lastOnlineAt: device.lastOnlineAt,
        battery: device.battery,
        batteryStatus: device.batteryStatus,
        fuel: device.fuel,
        fuelStatus: device.fuelStatus,
        oilPressure: device.oilPressure,
        waterTemperature: device.waterTemperature,
        locationStatus: device.locationStatus,
        locationStatusName: device.locationStatusName,
        location: device.location,
        lockStatus: device.lockStatus,
        lockStatusName: device.lockStatusName,
        lastMaintenanceTime: device.lastMaintenanceTime,
        nextMaintenanceTime: device.nextMaintenanceTime,
        deviceImages: device.deviceImages,
        mainImageUrl: device.mainImageUrl,
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
      final updatedLocation = DeviceLocation(
        latitude: latitude,
        longitude: longitude,
        address: address,
        timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );
      
      final updatedDevice = Device(
        deviceId: device.deviceId,
        name: device.name,
        model: device.model,
        pin: device.pin,
        brand: device.brand,
        year: device.year,
        runtimeHours: device.runtimeHours,
        status: device.status,
        statusName: device.statusName,
        lastOnlineAt: device.lastOnlineAt,
        battery: device.battery,
        batteryStatus: device.batteryStatus,
        fuel: device.fuel,
        fuelStatus: device.fuelStatus,
        oilPressure: device.oilPressure,
        waterTemperature: device.waterTemperature,
        locationStatus: device.locationStatus,
        locationStatusName: device.locationStatusName,
        location: updatedLocation,
        lockStatus: device.lockStatus,
        lockStatusName: device.lockStatusName,
        lastMaintenanceTime: device.lastMaintenanceTime,
        nextMaintenanceTime: device.nextMaintenanceTime,
        deviceImages: device.deviceImages,
        mainImageUrl: device.mainImageUrl,
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
      final updatedDevice = Device(
        deviceId: device.deviceId,
        name: device.name,
        model: device.model,
        pin: device.pin,
        brand: device.brand,
        year: device.year,
        runtimeHours: device.runtimeHours,
        status: device.status,
        statusName: device.statusName,
        lastOnlineAt: device.lastOnlineAt,
        battery: device.battery,
        batteryStatus: device.batteryStatus,
        fuel: device.fuel,
        fuelStatus: device.fuelStatus,
        oilPressure: device.oilPressure,
        waterTemperature: device.waterTemperature,
        locationStatus: device.locationStatus,
        locationStatusName: device.locationStatusName,
        location: device.location,
        lockStatus: !(device.lockStatus ?? false),
        lockStatusName: device.lockStatusName,
        lastMaintenanceTime: device.lastMaintenanceTime,
        nextMaintenanceTime: device.nextMaintenanceTime,
        deviceImages: device.deviceImages,
        mainImageUrl: device.mainImageUrl,
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

  // Clear all device data, e.g., on logout
  void clearDeviceData() {
    state.devices.clear();
    state.hasDevice = false;
    state.deviceModel = '';
    state.deviceId = '';
    update();
  }

  Future<void> searchDevices(String keyword) async {
    if (keyword.isEmpty) {
      state.devices.clear();
      update();
    }
  }

  void mockAddDevice(String name, String deviceId, String model, String pin) {
  // 创建新设备实例
    final device = Device(
      deviceId: deviceId ?? 'EXC${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      model: model,
      pin: pin ?? 'CAT${model.replaceAll(' ', '')}${deviceId ?? ''}',
      runtimeHours: 134.9, // 默认运行小时数
      battery: 85,
      fuel: 72,
      oilPressure: 45,
      waterTemperature: 88,
      lockStatus: false,
      locationStatus: true,
      location: DeviceLocation(
        latitude: 39.9042,
        longitude: 116.4074,
        address: '北京市朝阳区建国路工地',
        timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      ),
      status: 1,
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

        // Correctly parse the new data structure
        final responseData = response.data?['data'];
        if (responseData != null && responseData['devices'] is List) {
          List<Device> list = (responseData['devices'] as List)
              .map((item) => Device.fromJson(item))
              .toList();
          
          state.devices.addAll(list);
        }
        
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
  int get onlineDeviceCount => state.devices.where((device) => device.statusName == '在线').length;
  
  // 获取离线设备数量
  int get offlineDeviceCount => state.devices.where((device) => device.statusName != '在线').length;
}