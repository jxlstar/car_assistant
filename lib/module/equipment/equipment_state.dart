class EquipmentState {
  bool hasDevice = false;
  String deviceModel = '';
  String deviceId = '';
  List<Device> devices = [];
}

class LockStatus {
  final bool isLocked;
  final String lockType; // remote(远程)、auto(自动)

  LockStatus({
    required this.isLocked,
    required this.lockType,
  });

  factory LockStatus.fromJson(Map<String, dynamic> json) {
    return LockStatus(
      isLocked: json['is_locked'] ?? false,
      lockType: json['lock_type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_locked': isLocked,
      'lock_type': lockType,
    };
  }
}

class LocationStatus {
  final bool gpsAvailable;
  final int lastUpdate;

  LocationStatus({
    required this.gpsAvailable,
    required this.lastUpdate,
  });

  factory LocationStatus.fromJson(Map<String, dynamic> json) {
    return LocationStatus(
      gpsAvailable: json['gps_available'] ?? false,
      lastUpdate: json['last_update'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gps_available': gpsAvailable,
      'last_update': lastUpdate,
    };
  }
}

class CurrentLocation {
  final double latitude;
  final double longitude;
  final String address;
  final int updateTime;

  CurrentLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.updateTime,
  });

  factory CurrentLocation.fromJson(Map<String, dynamic> json) {
    return CurrentLocation(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      address: json['address'] ?? '',
      updateTime: json['update_time'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'update_time': updateTime,
    };
  }
}

class Device {
  final String? deviceId;        // 设备ID
  final String? deviceName;      // 设备名称
  final String? model;           // 设备型号
  final String? pin;             // 设备PIN码
  final double? runtimeHours;    // 运行时长（小时）
  final int? batteryLevel;       // 电量百分比
  final int? fuelLevel;          // 油量百分比
  final int? oilPressure;        // 机油压力（psi）
  final int? waterTemperature;   // 水温（摄氏度）
  final LockStatus? lockStatus;  // 锁机状态
  final LocationStatus? locationStatus; // 位置状态
  final CurrentLocation? currentLocation; // 当前位置
  final int? status;          // 设备状态：online(在线)、offline(离线)
  final String? statusName;
  final int? bindTime;           // 绑定时间戳

  Device({
    this.deviceId,
    this.deviceName,
    this.model,
    this.pin,
    this.runtimeHours,
     this.batteryLevel,
     this.fuelLevel,
     this.oilPressure,
     this.waterTemperature,
     this.lockStatus,
     this.locationStatus,
     this.currentLocation,
     this.status,
     this.statusName,
     this.bindTime,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      deviceId: json['device_id'] ?? '',
      deviceName: json['name'] ?? '',
      model: json['model'] ?? '',
      pin: json['pin'] ?? '',
      runtimeHours: (json['runtime_hours'] ?? 0.0).toDouble(),
      batteryLevel: json['battery_level'] ?? 0,
      fuelLevel: json['fuel_level'] ?? 0,
      oilPressure: json['oil_pressure'] ?? 0,
      waterTemperature: json['water_temperature'] ?? 0,
      lockStatus: LockStatus.fromJson(json['lock_status'] ?? {}),
      locationStatus: LocationStatus.fromJson(json['location_status'] ?? {}),
      currentLocation: CurrentLocation.fromJson(json['current_location'] ?? {}),
      status: json['status'] ?? 0,
      statusName: json['status_name'] ?? '离线',
      bindTime: json['bind_time'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'name': deviceName,
      'model': model,
      'pin': pin,
      'runtime_hours': runtimeHours,
      'battery_level': batteryLevel,
      'fuel_level': fuelLevel,
      'oil_pressure': oilPressure,
      'water_temperature': waterTemperature,
      'lock_status': lockStatus?.toJson(),
      'location_status': locationStatus?.toJson(),
      'current_location': currentLocation?.toJson(),
      'status': status,
      'bind_time': bindTime,
    };
  }

  // 兼容旧版本的getter方法
  String? get rackNumber => deviceName;
  String? get modelNo => model;
  String get hours => runtimeHours.toString();
}