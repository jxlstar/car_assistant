import 'package:car_assistant/core/utils/loading_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../r.dart';
import '../equipment_logic.dart';
class DeviceResultPage extends StatelessWidget {
  final Map<dynamic, dynamic> deviceInfo;

  const DeviceResultPage({
    super.key,
    required this.deviceInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SafeArea(
          bottom: true,
          child: SingleChildScrollView(
            child: Column(
              children: [
              const SizedBox(height: 60),
              // 设备图片容器
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(R.assetsImageWaji)
              ),
                            ),
              const SizedBox(height: 40),
              Text(
                deviceInfo['device_type'] ?? '',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                deviceInfo['name'],
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 40,),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                  LoadingUtil.show(context, message: "绑定中...");
                  final equipmentLogic = Get.find<EquipmentLogic>();
                  final success = await equipmentLogic.bindDevice(deviceInfo['rock_number'], deviceInfo['name']);
                  LoadingUtil.hide();
                  if(success){
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                  // 返回到主页面
                  // Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Confirm binding',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}