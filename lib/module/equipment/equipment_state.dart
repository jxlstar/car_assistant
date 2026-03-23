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

class DeviceLocation {
  final double? latitude;
  final double? longitude;
  final String? address;
  final double? accuracy;
  final double? speed;
  final double? heading;
  final double? altitude;
  final int? timestamp;

  DeviceLocation({
    this.latitude,
    this.longitude,
    this.address,
    this.accuracy,
    this.speed,
    this.heading,
    this.altitude,
    this.timestamp,
  });

  factory DeviceLocation.fromJson(Map<String, dynamic> json) {
    return DeviceLocation(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address'],
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
      heading: (json['heading'] as num?)?.toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'accuracy': accuracy,
      'speed': speed,
      'heading': heading,
      'altitude': altitude,
      'timestamp': timestamp,
    };
  }
}

class DeviceImage {
  final int? id;
  final String? imageUrl;
  final String? imageType;
  final String? description;
  final int? status;
  final int? createdAt;

  DeviceImage({
    this.id,
    this.imageUrl,
    this.imageType,
    this.description,
    this.status,
    this.createdAt,
  });

  factory DeviceImage.fromJson(Map<String, dynamic> json) {
    return DeviceImage(
      id: json['id'],
      imageUrl: json['image_url'],
      imageType: json['image_type'],
      description: json['description'],
      status: json['status'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'image_type': imageType,
      'description': description,
      'status': status,
      'created_at': createdAt,
    };
  }
}

class LatestReport {
  final int? batteryVoltage;
  final int? beidouSatellites;
  final String? deviceId;
  final int? engineSpeed;
  final int? failureStatus;
  final int? galileoSatellites;
  final int? glonassSatellites;
  final int? gpsSatellites;
  final int? id;
  final int? ioControl;
  final int? ioStatus;
  final int? oilLevel;
  final int? oilPressure1;
  final int? oilPressure2;
  final int? packetLoss;
  final int? pilotStatus;
  final int? rawLatitude;
  final int? rawLongitude;
  final int? reportTimestamp;
  final int? reportType;
  final int? runningTime;
  final int? sequenceNumber;
  final int? signalStrength;
  final int? systemStatus;
  final int? temperature;

  LatestReport({
    this.batteryVoltage,
    this.beidouSatellites,
    this.deviceId,
    this.engineSpeed,
    this.failureStatus,
    this.galileoSatellites,
    this.glonassSatellites,
    this.gpsSatellites,
    this.id,
    this.ioControl,
    this.ioStatus,
    this.oilLevel,
    this.oilPressure1,
    this.oilPressure2,
    this.packetLoss,
    this.pilotStatus,
    this.rawLatitude,
    this.rawLongitude,
    this.reportTimestamp,
    this.reportType,
    this.runningTime,
    this.sequenceNumber,
    this.signalStrength,
    this.systemStatus,
    this.temperature,
  });

  factory LatestReport.fromJson(Map<String, dynamic> json) {
    return LatestReport(
      batteryVoltage: json['battery_voltage'],
      beidouSatellites: json['beidou_satellites'],
      deviceId: json['device_id'],
      engineSpeed: json['engine_speed'],
      failureStatus: json['failure_status'],
      galileoSatellites: json['galileo_satellites'],
      glonassSatellites: json['glonass_satellites'],
      gpsSatellites: json['gps_satellites'],
      id: json['id'],
      ioControl: json['io_control'],
      ioStatus: json['io_status'],
      oilLevel: json['oil_level'],
      oilPressure1: json['oil_pressure_1'],
      oilPressure2: json['oil_pressure_2'],
      packetLoss: json['packet_loss'],
      pilotStatus: json['pilot_status'],
      rawLatitude: json['raw_latitude'],
      rawLongitude: json['raw_longitude'],
      reportTimestamp: json['report_timestamp'],
      reportType: json['report_type'],
      runningTime: json['running_time'],
      sequenceNumber: json['sequence_number'],
      signalStrength: json['signal_strength'],
      systemStatus: json['system_status'],
      temperature: json['temperature'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'battery_voltage': batteryVoltage,
      'beidou_satellites': beidouSatellites,
      'device_id': deviceId,
      'engine_speed': engineSpeed,
      'failure_status': failureStatus,
      'galileo_satellites': galileoSatellites,
      'glonass_satellites': glonassSatellites,
      'gps_satellites': gpsSatellites,
      'id': id,
      'io_control': ioControl,
      'io_status': ioStatus,
      'oil_level': oilLevel,
      'oil_pressure_1': oilPressure1,
      'oil_pressure_2': oilPressure2,
      'packet_loss': packetLoss,
      'pilot_status': pilotStatus,
      'raw_latitude': rawLatitude,
      'raw_longitude': rawLongitude,
      'report_timestamp': reportTimestamp,
      'report_type': reportType,
      'running_time': runningTime,
      'sequence_number': sequenceNumber,
      'signal_strength': signalStrength,
      'system_status': systemStatus,
      'temperature': temperature,
    };
  }
}

class Device {
  final String? deviceId;
  final String? name;
  final String? model;
  final String? pin;
  final String? brand;
  final int? year;
  final double? runtimeHours;
  final int? status;
  final String? statusName;
  final int? ctrlStatus;
  final int? engStatus;
  final int? lastOnlineAt;
  final int? lastUpdatedAt;
  final double? battery;
  final String? batteryStatus;
  final double? fuel;
  final String? fuelStatus;
  final double? oilPressure;
  final double? waterTemperature;
  final bool? locationStatus;
  final String? locationStatusName;
  final DeviceLocation? location;
  final bool? lockStatus;
  final String? lockStatusName;
  final int? lastMaintenanceTime;
  final int? nextMaintenanceTime;
  final List<DeviceImage>? deviceImages;
  final String? mainImageUrl;
  final List<dynamic>? maintenanceManuals;
  final List<dynamic>? operationManuals;
  // 新增字段
  final int? runningTime;
  final int? engineSpeed;
  final int? pilotStatus;
  final int? systemPress;
  final List<LatestReport>? latestReports;

  Device({
    this.deviceId,
    this.name,
    this.model,
    this.pin,
    this.brand,
    this.year,
    this.runtimeHours,
    this.status,
    this.statusName,
    this.ctrlStatus,
    this.engStatus,
    this.lastOnlineAt,
    this.lastUpdatedAt,
    this.battery,
    this.batteryStatus,
    this.fuel,
    this.fuelStatus,
    this.oilPressure,
    this.waterTemperature,
    this.locationStatus,
    this.locationStatusName,
    this.location,
    this.lockStatus,
    this.lockStatusName,
    this.lastMaintenanceTime,
    this.nextMaintenanceTime,
    this.deviceImages,
    this.mainImageUrl,
    this.maintenanceManuals,
    this.operationManuals,
    // 新增字段
    this.runningTime,
    this.engineSpeed,
    this.pilotStatus,
    this.systemPress,
    this.latestReports,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      deviceId: json['device_id'],
      name: json['name'],
      model: json['model'],
      pin: json['pin'],
      brand: json['brand'],
      year: json['year'],
      runtimeHours: (json['runtime_hours'] as num?)?.toDouble(),
      status: json['status'],
      statusName: json['status_name'],
      ctrlStatus: json['ctrl_status'],
      engStatus: json['eng_status'],
      lastOnlineAt: json['last_online_at'],
      lastUpdatedAt: json['last_updated_at'],
      battery: (json['battery'] as num?)?.toDouble(),
      batteryStatus: json['battery_status'],
      fuel: (json['fuel'] as num?)?.toDouble(),
      fuelStatus: json['fuel_status'],
      oilPressure: (json['oil_pressure'] as num?)?.toDouble(),
      waterTemperature: (json['water_temperature'] as num?)?.toDouble(),
      locationStatus: json['location_status'],
      locationStatusName: json['location_status_name'],
      location: json['location'] != null
          ? DeviceLocation.fromJson(json['location'])
          : null,
      lockStatus: json['lock_status'],
      lockStatusName: json['lock_status_name'],
      lastMaintenanceTime: json['last_maintenance_time'],
      nextMaintenanceTime: json['next_maintenance_time'],
      deviceImages: (json['device_images'] as List<dynamic>?)
          ?.map((e) => DeviceImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      mainImageUrl: json['main_image_url'],
      maintenanceManuals: json['maintenance_manuals'],
      operationManuals: json['operation_manuals'],
      // 新增字段解析
      runningTime: json['running_time'],
      engineSpeed: json['engine_speed'],
      pilotStatus: json['pilot_status'],
      systemPress: json['system_status'],
      latestReports: (json['latest_reports'] as List<dynamic>?)
          ?.map((e) => LatestReport.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'name': name,
      'model': model,
      'pin': pin,
      'brand': brand,
      'year': year,
      'runtime_hours': runtimeHours,
      'status': status,
      'status_name': statusName,
      'ctrl_status': ctrlStatus,
      'eng_status': engStatus,
      'last_online_at': lastOnlineAt,
      'last_updated_at': lastUpdatedAt,
      'battery': battery,
      'battery_status': batteryStatus,
      'fuel': fuel,
      'fuel_status': fuelStatus,
      'oil_pressure': oilPressure,
      'water_temperature': waterTemperature,
      'location_status': locationStatus,
      'location_status_name': locationStatusName,
      'location': location?.toJson(),
      'lock_status': lockStatus,
      'lock_status_name': lockStatusName,
      'last_maintenance_time': lastMaintenanceTime,
      'next_maintenance_time': nextMaintenanceTime,
      'device_images': deviceImages?.map((e) => e.toJson()).toList(),
      'main_image_url': mainImageUrl,
      'operation_manuals': operationManuals,
      'maintenance_manuals': maintenanceManuals,
      // 新增字段序列化
      'running_time': runningTime,
      'engine_speed': engineSpeed,
      'pilot_status': pilotStatus,
      'latest_reports': latestReports?.map((e) => e.toJson()).toList(),
    };
  }
}