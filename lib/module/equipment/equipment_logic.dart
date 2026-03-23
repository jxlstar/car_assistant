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

  // Bind device (using new data structure)
  Future<bool> bindDevice(String rockNumber, String name, {String? deviceId, String? pin,  String? model}) async {
    state.hasDevice = true;
    try{
      final response =  await ApiService.bindDevice(rockNumber: rockNumber, deviceName: name);
      LoggerUtil.i('Bind device====$response');
      if(response.success) {
        LoggerUtil.i('Bind successful====$response');
        Fluttertoast.showToast(msg: 'Bind successful');
        // Request device list
        fetchDeviceList();
        // mockAddDevice(name, deviceId, model, pin);
        return true;
      }else {
        LoggerUtil.i('Bind failed====${response.message}');
        Fluttertoast.showToast(msg: response.message, gravity: ToastGravity.CENTER);
        return false;
      }
    }catch(e){
      LoggerUtil.i('Bind failed====$e');
      return false;
    }
  }

  // Add device from JSON data
  void addDeviceFromJson(Map<String, dynamic> deviceJson) {
    final device = Device.fromJson(deviceJson);
    state.devices.add(device);
    state.hasDevice = true;
    update();
  }

  // Update device status
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
        ctrlStatus: device.ctrlStatus,
        engStatus: device.engStatus,
        lastOnlineAt: device.lastOnlineAt,
        lastUpdatedAt: device.lastUpdatedAt,
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
        maintenanceManuals: device.maintenanceManuals,
        operationManuals: device.operationManuals,
        // 新增字段
        runningTime: device.runningTime,
        engineSpeed: device.engineSpeed,
        pilotStatus: device.pilotStatus,
        latestReports: device.latestReports,
      );
      state.devices[index] = updatedDevice;
      update();
    }
  }

  // Update device location
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
        ctrlStatus: device.ctrlStatus,
        engStatus: device.engStatus,
        lastOnlineAt: device.lastOnlineAt,
        lastUpdatedAt: device.lastUpdatedAt,
        battery: device.battery,
        batteryStatus: device.batteryStatus,
        fuel: device.fuel ?? 0,
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
        maintenanceManuals: device.maintenanceManuals,
        operationManuals: device.operationManuals,
        // 新增字段
        runningTime: device.runningTime,
        engineSpeed: device.engineSpeed,
        pilotStatus: device.pilotStatus,
        latestReports: device.latestReports,
      );
      state.devices[index] = updatedDevice;
      update();
    }
  }

  // Toggle device lock status
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
        ctrlStatus: device.ctrlStatus,
        engStatus: device.engStatus,
        lastOnlineAt: device.lastOnlineAt,
        lastUpdatedAt: device.lastUpdatedAt,
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
        maintenanceManuals: device.maintenanceManuals,
        operationManuals: device.operationManuals,
        // 新增字段
        runningTime: device.runningTime,
        engineSpeed: device.engineSpeed,
        pilotStatus: device.pilotStatus,
        latestReports: device.latestReports,
      );
      state.devices[index] = updatedDevice;
      update();
    }
  }

  // Unbind device
  Future<void> unbindDevice(String deviceID) async {
    if(deviceID == '') return;
    try{
      final response =  await ApiService.unbindDevice(deviceID);
      LoggerUtil.i('Bind device====$response');
      if(response.success) {
        LoggerUtil.i('Bind successful====$response');
        Fluttertoast.showToast(msg: 'unBind successful', gravity: ToastGravity.CENTER);
        // Request device list
        fetchDeviceList();
        // mockAddDevice(name, deviceId, model, pin);
      }else {
        LoggerUtil.i('Bind failed====${response.message}');
        Fluttertoast.showToast(msg: response.message, gravity: ToastGravity.CENTER);
      }
    }catch(e){
      LoggerUtil.i('Bind failed====$e');
    }
  }
  Future<void> updateDeviceName(String deviceId, String newName) async {
    if(deviceId == '' || newName.isEmpty) return;
    try{
      final response = await ApiService.updateDeviceName(
          deviceId: deviceId,
          deviceName: newName
      );
      if(response.success) {
        Fluttertoast.showToast(msg: 'Device name updated successfully',gravity: ToastGravity.CENTER);
        // Update local device name
        fetchDeviceList();
      }
    }catch(e){
      Fluttertoast.showToast(msg: 'Failed to update device name',gravity: ToastGravity.CENTER);
    }
  }

  // Remove device by device ID
  void removeDevice(String deviceId) {
    state.devices.removeWhere((device) => device.deviceId == deviceId);
    if (state.devices.isEmpty) {
      state.hasDevice = false;
      state.deviceModel = '';
      state.deviceId = '';
    }
    update();
  }

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

  Future<void> fetchDeviceList() async {
    try{
      final response = await ApiService.getDeviceList();
      LoggerUtil.i('Device list==$response');
      if(response.success) {
        LoggerUtil.e('Get list successful');
        state.devices.clear();

        // Correctly parse the new data structure
        final responseData = response.data?['data'];
        if (responseData != null && responseData['devices'] is List) {
          List<Device> list = (responseData['devices'] as List)
              .map((item) => Device.fromJson(item))
              .toList();
          LoggerUtil.i('Device list first==${list.first.systemPress.toString()}');
          state.devices.addAll(list);
        }
        
        update();
      }else {
        LoggerUtil.e('Get list failed：${response.message}');
      }
    }catch(e){
      LoggerUtil.e('Get list failed：$e');
    }
}
  // Get device list
  List<Device> get devices => state.devices;
  
  // Has device
  bool get hasDevice => state.hasDevice;
  
  // Device model
  String get deviceModel => state.deviceModel;
  
  // Device ID
  String get deviceId => state.deviceId;
  
  // Get online device count
  int get onlineDeviceCount => state.devices.where((device) => device.statusName == 'Online').length;
  
  // Get offline device count
  int get offlineDeviceCount => state.devices.where((device) => device.statusName != 'Online').length;
}