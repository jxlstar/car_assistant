import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../r.dart';
import 'equipment_provider.dart';

class DeviceResultPage extends StatelessWidget {
  final String rackNumber;
  final String modelNo;
  
  const DeviceResultPage({
    super.key,
    required this.rackNumber,
    required this.modelNo,
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
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 120,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.blue[600],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset(R.assetsImageAvatar)
                ),
              ),),
              const SizedBox(height: 40),
              Text(
                rackNumber,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                modelNo,
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
                  onPressed: () {
                    // 更新设备绑定状态
                    Provider.of<EquipmentProvider>(context, listen: false)
                        .bindDevice(rackNumber, modelNo);
                    
                    // 返回到主页面，MainPage会自动显示EquipmentPageWithDevice
                    Navigator.of(context).popUntil((route) => route.isFirst);
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