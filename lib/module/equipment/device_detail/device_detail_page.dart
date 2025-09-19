import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../r.dart';
import '../../../utils/colors_util.dart';
import '../equipment_state.dart';
import '../map_detail/map_detail_page.dart';
import '../pressure_chart/pressure_chart_page.dart';
import 'device_detail_logic.dart';
import '../fault_code_query/fault_code_query_page.dart';
import '../share_dialog/share_dialog.dart';
import '../../../module/pdf/pdf_viewer_page.dart';

class DeviceDetailPage extends StatelessWidget {
  final String? deviceId;

  const DeviceDetailPage({super.key, this.deviceId});

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
      backgroundColor: ColorsUtil.hexColor('F1F5F8'),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          GetBuilder<DeviceDetailLogic>(
            builder: (logic) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // // Pro按钮
                  // IconButton(
                  //   icon: Image.asset(
                  //     logic.state.isProMode
                  //         ? R.assetsImageProSelect
                  //         : R.assetsImageProUnselect,
                  //     height: 40,
                  //   ),
                  //   onPressed: () {
                  //     logic.toggleProMode();
                  //   },
                  // ),
                  // 分享按钮
                  IconButton(
                    icon: Image.asset(R.assetsImageShareIcon, height: 20),
                    onPressed: () {
                      if (logic.state.deviceDetail != null) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ShareDialog(
                              device: {},
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
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
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (logic.state.deviceDetail == null) {
            return Center(
              child: Text('No device detail data available'),
            );
          }

          return RefreshIndicator(
            color: Colors.white,
            backgroundColor: Colors.blue,
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
                  SizedBox(height: 16),

                  _buildCurveControls(logic, context),
                  SizedBox(height: 16),
                  if(logic.state.isProMode) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: _buildResourceItem(
                          icon: Icons.speed,
                          title: 'Pilot Pressure Curve',
                          context: context),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: _buildResourceItem(
                          icon: Icons.settings,
                          title: 'System Pressure Curve',
                          context: context),
                    ),
                  ],
                  // Map Section
                  _buildMapSection(logic, context),

                  SizedBox(height: 16),

                  SizedBox(height: 16),

                  // Location Info
                  // _buildLocationInfo(logic),

                  SizedBox(height: 24),

                  // Machine Controls
                  _buildMachineControls(logic, context),

                  SizedBox(height: 24),

                  // Resources Section
                  _buildResourcesSection(context, logic.state.deviceDetail),

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
            child: logic.headerImage.isNotEmpty
                ? Image.network(logic.headerImage, height: 30)
                : Image.asset(R.assetsImageWaji, height: 30),
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
                    textAlign: TextAlign.center,
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
                          color: (logic.state.deviceDetail?.fuel ?? 0) > 20
                              ? Colors.green
                              : Colors.red,
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
      child: Column(
        children: [
          Row(
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
                          Icon(Icons.thermostat, color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Water Temp',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        ' ${logic.waterTemperature}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
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
                          const Icon(Icons.autorenew,
                              color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Engine Speed',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        logic.enginSpeed,
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
          // Pro模式下显示的压力信息
          SizedBox(height: 12),
          Row(
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
                          Icon(Icons.speed, color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'System Pressure',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '0 MPa', // 暂时使用占位符
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
                          Icon(Icons.speed, color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Pilot Pressure',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        logic.pilot,
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
        ],
      ),
    );
  }

  Widget _buildMapSection(DeviceDetailLogic logic, BuildContext context) {
    navigateAction() {
      if (logic.hasValidLocation) {
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
      } else {
        Fluttertoast.showToast(
            msg: "No location available",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: navigateAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            child: Text('View Map Details'),
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: navigateAction,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.lightBlue[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: logic.hasValidLocation
                  ? GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          logic.locationCoordinates['latitude']!,
                          logic.locationCoordinates['longitude']!,
                        ),
                        zoom: 15,
                      ),
                      markers: {
                        Marker(
                          markerId: MarkerId(logic.deviceName),
                          position: LatLng(
                            logic.locationCoordinates['latitude']!,
                            logic.locationCoordinates['longitude']!,
                          ),
                          infoWindow: InfoWindow(
                            title: logic.deviceName,
                            snippet: logic.currentLocation,
                          ),
                        ),
                      },
                      scrollGesturesEnabled: false,
                      zoomGesturesEnabled: false,
                      myLocationButtonEnabled: false,
                    )
                  : Stack(
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
                                Icon(Icons.location_on,
                                    color: Colors.white, size: 16),
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Click to view map',
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
        ],
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
            logic.state.deviceDetail?.location?.timestamp != null
                ? DateTime.fromMillisecondsSinceEpoch(
                        logic.state.deviceDetail!.location!.timestamp! * 1000)
                    .toString()
                    .substring(0, 16)
                : '',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMachineControls(DeviceDetailLogic logic, BuildContext context) {
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
                  value: logic.inhibitRestartStatus,
                  onChanged: (value) =>
                      _showInhibitRestartConfirmDialog(context, logic, value),
                  activeColor: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //
  Widget _buildCurveControls(DeviceDetailLogic logic, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Curve',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Container(
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
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
                    'Curve Open',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Switch(
                  value: logic.state.isProMode,
                  onChanged: (value) =>
                      logic.toggleProMode(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // 显示禁止重启确认对话框
  void _showInhibitRestartConfirmDialog(
      BuildContext context, DeviceDetailLogic logic, bool value) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            value ? 'Lock Device' : 'Unlock Device',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            value
                ? 'Are you sure you want to lock this device? This will prevent the device from restarting.'
                : 'Are you sure you want to unlock this device? This will allow the device to restart normally.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                logic.toggleInhibitRestart(value);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: value ? Colors.red : Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Confirm',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResourcesSection(BuildContext context, Device? device) {
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
              subtitle:
                  'Last ${device?.lastMaintenanceTime != null ? DateTime.fromMillisecondsSinceEpoch(device!.lastMaintenanceTime! * 1000).toString().substring(0, 10) : 'N/A'}\nNext ${device?.nextMaintenanceTime != null ? DateTime.fromMillisecondsSinceEpoch(device!.nextMaintenanceTime! * 1000).toString().substring(0, 10) : 'N/A'}',
              context: context),
          _buildResourceItem(
              icon: Icons.error_outline,
              title: 'Fault code query',
              context: context),
          _buildResourceItem(
              icon: Icons.description,
              title: 'Documents and manuals',
              context: context),
          _buildResourceItem(
              icon: Icons.schedule,
              title: 'Maintenance plan',
              context: context),
          _buildResourceItem(
              icon: Icons.info_outline,
              title: 'Warranty Information',
              context: context),
        ],
      ),
    );
  }

  Widget _buildResourceItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () {
        if (title == 'Fault code query') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FaultCodeQueryPage(),
            ),
          );
        }
        if (title == 'Machine maintenance') {
          final logic = Get.find<DeviceDetailLogic>();
          final device = logic.state.deviceDetail;

          if (device?.maintenanceManuals != null &&
              device!.maintenanceManuals!.isNotEmpty) {
            // 取第一个PDF文件
            final pdfUrl = device.maintenanceManuals!.first;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PdfViewerPage(
                  pdfUrl: pdfUrl,
                  title: 'Machine Maintenance Manual',
                ),
              ),
            );
          } else {
            // 显示没有可用文档的提示
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No maintenance manual available'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
        if (title == 'Documents and manuals') {
          final logic = Get.find<DeviceDetailLogic>();
          final device = logic.state.deviceDetail;

          if (device?.operationManuals != null &&
              device!.operationManuals!.isNotEmpty) {
            // 取第一个PDF文件
            final pdfUrl = device.operationManuals!.first;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PdfViewerPage(
                  pdfUrl: pdfUrl,
                  title: 'Operation Manual',
                ),
              ),
            );
          } else {
            // 显示没有可用文档的提示
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No operation manual available'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
        if (title == 'System Pressure Curve') {
          final logic = Get.find<DeviceDetailLogic>();
          if (logic.state.deviceDetail?.latestReports != null &&
              logic.state.deviceDetail!.latestReports!.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PressureChartPage(
                  title: 'System Pressure',
                  latestReports: logic.state.deviceDetail!.latestReports!,
                  isSystemPressure: true,
                ),
              ),
            );
          } else {
            Fluttertoast.showToast(
              msg: "No pressure data available",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
        }
        if (title == 'Pilot Pressure Curve') {
          final logic = Get.find<DeviceDetailLogic>();
          if (logic.state.deviceDetail?.latestReports != null &&
              logic.state.deviceDetail!.latestReports!.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PressureChartPage(
                  title: 'Pilot Pressure',
                  latestReports: logic.state.deviceDetail!.latestReports!,
                  isSystemPressure: false,
                ),
              ),
            );
          } else {
            Fluttertoast.showToast(
              msg: "No pressure data available",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
        }
      },
      child: Container(
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
      ),
    );
  }
/*
  Widget _buildEngineSpeedChart(DeviceDetailLogic logic) {
    // ... 原有的转速图表代码 ...
  }
  */
}
