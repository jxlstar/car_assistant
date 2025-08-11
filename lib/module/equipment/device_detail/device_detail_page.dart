import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../r.dart';
import '../share_dialog/share_dialog.dart';
import '../map_detail/map_detail_page.dart';
import 'device_detail_logic.dart';

class DeviceDetailPage extends StatelessWidget {
  final String? deviceId;
  
  const DeviceDetailPage({Key? key, this.deviceId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 初始化Logic，传递deviceId
    final logic = Get.put(DeviceDetailLogic());
    
    // 如果通过构造函数传递了deviceId，则设置到state中
    if (deviceId != null) {
      logic.state.deviceId = deviceId;
      logic.loadDeviceDetail();
    }
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.lock_outline, color: Colors.grey[600]),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          ),
          GetBuilder<DeviceDetailLogic>(
            builder: (logic) {
              return IconButton(
                icon: Image.asset(R.assetsImageShareIcon, height: 20),
                onPressed: () {
                  if (logic.state.deviceDetail != null) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ShareDialog(device: logic.state.deviceDetail!);
                      },
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      body: GetBuilder<DeviceDetailLogic>(
        builder: (logic) {
          if (logic.state.isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (logic.state.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    logic.state.errorMessage!,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => logic.refreshDeviceDetail(),
                    child: Text('重试'),
                  ),
                ],
              ),
            );
          }
          
          if (logic.state.deviceDetail == null) {
            return Center(
              child: Text('暂无设备详情数据'),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () => logic.refreshDeviceDetail(),
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Device Header
                  _buildDeviceHeader(logic),
                  
                  // Status Cards
                  _buildStatusCards(logic),
                  
                  SizedBox(height: 16),
                  
                  // Coolant Temperature
                  _buildCoolantTemperature(logic),
                  
                  SizedBox(height: 20),
                  
                  // Map Section
                  _buildMapSection(logic, context),
                  
                  SizedBox(height: 16),
                  
                  // Location Info
                  _buildLocationInfo(logic),
                  
                  SizedBox(height: 24),
                  
                  // Machine Controls
                  _buildMachineControls(logic),
                  
                  SizedBox(height: 24),
                  
                  // Resources Section
                  _buildResourcesSection(),
                  
                  SizedBox(height: 100), // Bottom padding for navigation
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildDeviceHeader(DeviceDetailLogic logic) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.file(File(logic.headerImage), height: 30,),

          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  logic.deviceName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Model  ${logic.deviceModel}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Text(
                  'PIN     ${logic.devicePin}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Hours   ${logic.runtimeHours}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusCards(DeviceDetailLogic logic) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.battery_full, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Battery',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    logic.batteryLevel,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Fuel',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    logic.fuelLevel,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCoolantTemperature(DeviceDetailLogic logic) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.thermostat, color: Colors.green, size: 20),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Coolant Temp',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Text(
                  logic.waterTemperature,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMapSection(DeviceDetailLogic logic, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          final coordinates = logic.locationCoordinates;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MapDetailPage(
                latitude: coordinates['latitude']!,
                longitude: coordinates['longitude']!,
                locationName: logic.currentLocation,
                deviceName: logic.deviceName,
              ),
            ),
          );
        },
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.lightBlue[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.lightBlue[200]!,
                      Colors.lightBlue[100]!,
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 80,
                left: 120,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        logic.deviceName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                child: Text(
                  'Google',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '点击查看地图',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLocationInfo(DeviceDetailLogic logic) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            logic.currentLocation,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Today ${DateTime.now().toString().substring(0, 16)}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMachineControls(DeviceDetailLogic logic) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Machine Controls',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.power_settings_new, color: Colors.grey[600]),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Inhibit Restart',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Switch(
                  value: logic.state.inhibitRestart,
                  onChanged: (value) => logic.toggleInhibitRestart(value),
                  activeColor: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildResourcesSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resources',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          _buildResourceItem(
            icon: Icons.build,
            title: 'Machine maintenance',
            subtitle: 'Last May 31, 2025 at 159 Hours\nNext 200 Hours',
          ),
          _buildResourceItem(
            icon: Icons.error_outline,
            title: 'Fault code query',
          ),
          _buildResourceItem(
            icon: Icons.description,
            title: 'Documents and manuals',
          ),
          _buildResourceItem(
            icon: Icons.schedule,
            title: 'Maintenance plan',
          ),
          _buildResourceItem(
            icon: Icons.info_outline,
            title: 'Warranty Information',
          ),
        ],
      ),
    );
  }
  
  Widget _buildResourceItem({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
        ],
      ),
    );
  }
}