import 'package:car_assistant/core/utils/loading_util.dart';
import 'package:car_assistant/core/utils/logger_util.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/network/api_service.dart';
import 'device_result_page.dart';
import '../device_search/device_search_page.dart';

class FindDevicesPage extends StatefulWidget {
  const FindDevicesPage({super.key});

  @override
  State<FindDevicesPage> createState() => _FindDevicesPageState();
}

class _FindDevicesPageState extends State<FindDevicesPage> {
  final TextEditingController _rackController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();

  @override
  void dispose() {
    _rackController.dispose();
    _modelController.dispose();
    super.dispose();
  }

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
        title: const Text(
          'Find devices',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Rack number',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _rackController,
              decoration: InputDecoration(
                hintText: 'Rack number or last five digits',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Model No',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _modelController,
              decoration: InputDecoration(
                hintText: 'R-10',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                 try{
                   LoadingUtil.show(context, message: '查询中');
                   // 调用查询接口
                   final response = await ApiService.searchDevice(
                     rockNumber: _rackController.text,
                     model: _modelController.text,
                     // rockNumber: 'CAT0950MBLD001235',
                     // model: 'Cat 950M',
                   );
                   LoggerUtil.i('查询设别接口===$response');
                   LoadingUtil.hide();
                   if(response.success) {
                     LoggerUtil.i('设备信息===${response.data?['data']}');
                     Navigator.push(
                       context,
                       MaterialPageRoute(
                         builder: (context) => DeviceResultPage(
                           deviceInfo: response.data?['data'],
                         ),
                       ),
                     );
                   }else {
                     Fluttertoast.showToast(msg: response.message, gravity: ToastGravity.CENTER);
                   }
                 }catch(e){
                   LoadingUtil.hide();
                 }
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
                  'Find',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}