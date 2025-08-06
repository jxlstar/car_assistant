import 'package:flutter/material.dart';

class Device {
  final String rackNumber;
  final String modelNo;
  final String pin;
  final String hours;

  Device({
    required this.rackNumber,
    required this.modelNo,
    required this.pin,
    required this.hours,
  });
}

class EquipmentProvider with ChangeNotifier {
  bool _hasDevice = false;
  String _deviceModel = '';
  String _deviceId = '';
  List<Device> _devices = [];

  bool get hasDevice => _hasDevice;
  String get deviceModel => _deviceModel;
  String get deviceId => _deviceId;
  List<Device> get devices => _devices;

  void bindDevice(String model, String id) {
    _hasDevice = true;
    _deviceModel = model;
    _deviceId = id;
    
    // Add device to the list
    _devices.add(Device(
      rackNumber: model,
      modelNo: model,
      pin: id,
      hours: '134.9', // Default hours
    ));
    
    notifyListeners();
  }

  void unbindDevice() {
    _hasDevice = false;
    _deviceModel = '';
    _deviceId = '';
    _devices.clear();
    notifyListeners();
  }
}