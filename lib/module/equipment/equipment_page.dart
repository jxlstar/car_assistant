import 'dart:math';

import 'package:car_assistant/utils/colors_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../r.dart';
import 'device_detail/device_detail_page.dart';
import 'device_search/device_search_page.dart';
import 'equipment_logic.dart';
import 'bind_device/find_devices_page.dart';
import '../../notification/notification_page.dart';
import 'equipment_state.dart';
import 'package:intl/intl.dart';

class EquipmentPage extends StatefulWidget {
  const EquipmentPage({super.key});

  @override
  State<EquipmentPage> createState() => _EquipmentPageState();
}

class _EquipmentPageState extends State<EquipmentPage> {
  late final EquipmentLogic logic;

  @override
  void initState() {
    super.initState();
    logic = Get.put(EquipmentLogic());
    logic.fetchDeviceList();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EquipmentLogic>(
      init: logic,
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Image.asset(R.assetsImageLogoIcon, height: 30),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          body: controller.devices.isNotEmpty
              ? _haveDataWidget(controller, context)
              : _noDataWidget(context),
        );
      },
    );
  }

  Widget _noDataWidget(BuildContext context) {
    return Container(
      color: ColorsUtil.hexColor('#F1F5F8'),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            const Text(
              'No device available for the moment.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your device to access manuals, maintenance guides and schedules.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FindDevicesPage(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('ADD EQUIPMENT'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _haveDataWidget(EquipmentLogic logic, BuildContext context) {
    return Container(
      color: ColorsUtil.hexColor('#F1F5F8'),
      child: Column(
        children: [
          // Fixed header with search and add buttons
          Container(
            padding: const EdgeInsets.only(right: 16.0, top: 13),
            color: Colors.transparent,
            child: Row(
              children: [
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FindDevicesPage(),
                      ),
                    );
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 24),
                  ),
                ),
                // Search button
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DeviceSearchPage(
                          devices: logic.devices,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.search, color: Colors.blue, size: 24),
                  ),
                ),
              ],
            ),
          ),
          // Device list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: logic.devices.length,
              itemBuilder: (context, index) {
                final device = logic.devices[index];
                return _buildDeviceCard(device, context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildDeviceCard(Device device, BuildContext context) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    elevation: 2,
    color: Colors.white,
    child: InkWell(
      borderRadius: BorderRadius.circular(12.0),
      onTap: () {
        Get.to(() => DeviceDetailPage(deviceId: device.deviceId ?? ''));
      },
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _buildDeviceHeader(device),
            const SizedBox(height: 12),
            _buildStatusCards(device),
            const SizedBox(height: 12),
            _buildFooter(device),
          ],
        ),
      ),
    ),
  );
}

Widget _buildDeviceHeader(Device device) {
  return Row(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: (device.deviceImages != null && device.deviceImages!.isNotEmpty)
            ? Image.network(
                device.deviceImages![0].imageUrl!,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/image/waji.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              )
            : Image.asset(
                'assets/image/waji.png',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              device.name ?? 'Unknown Device',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Model', style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    Text('PIN', style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    Text('Hours', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(device.model ?? 'N/A',
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(device.pin ?? 'N/A',
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text('${device.runtimeHours?.toStringAsFixed(1) ?? 'N/A'}h',
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const Icon(Icons.chevron_right, color: Colors.blue),
    ],
  );
}

Widget _buildStatusCards(Device device) {
  return Row(
    children: [
      Expanded(
        child: Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const Icon(Icons.battery_full, color: Colors.blue, size: 30),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Battery', style: TextStyle(color: Colors.grey)),
                    Text(
                      '${device.battery?.toStringAsFixed(2) ?? 'N/A'}V',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                SizedBox(
                  width: 30,
                  height: 30,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: (device.fuel ?? 0) / 100.0,
                        strokeWidth: 4,
                        backgroundColor: Colors.grey[300],
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.red),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Fuel', style: TextStyle(color: Colors.grey)),
                    Text(
                      '${device.fuel?.toStringAsFixed(0) ?? 'N/A'}%',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

Widget _buildFooter(Device device) {
  final location = device.location;
  final address = location?.address ?? 'Unknown Location';
  DateTime date = DateTime.fromMillisecondsSinceEpoch(location?.timestamp ?? 0);

  final timestamp = location?.timestamp != null
      ? DateFormat('MMM dd, yyyy HH:mm').format(date)
      : '';

  return Container(
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8.0),
      border: Border.all(color: Colors.grey[200]!),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              device.lockStatus == true ? Icons.lock_outline : Icons.lock_open,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 16),
            Text(
              'P',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: device.status == 'Parking' ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Icon(Icons.location_on, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.length > 25
                      ? '${address.substring(0, 25)}...'
                      : address,
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  timestamp,
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
