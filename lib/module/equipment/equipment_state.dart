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
    this.operationManuals
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
      operationManuals: json['operation_manuals']
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
      'maintenance_manuals': maintenanceManuals
    };
  }
}