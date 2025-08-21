import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';
import '../../../core/utils/loading_util.dart';
import '../../../core/utils/logger_util.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'fault_code_detail_page.dart';

class FaultCodeQueryPage extends StatefulWidget {
  const FaultCodeQueryPage({Key? key}) : super(key: key);

  @override
  _FaultCodeQueryPageState createState() => _FaultCodeQueryPageState();
}

class _FaultCodeQueryPageState extends State<FaultCodeQueryPage> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _searchFaultCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      Fluttertoast.showToast(
        msg: '请输入故障码',
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    try {
      LoadingUtil.show(context, message: '查询中...');
      final response = await ApiService.getFaultCodeDetail(code);
      LoadingUtil.hide();
      
      if (response.success && response.data != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FaultCodeDetailPage(
              faultCodeData: response.data!,
            ),
          ),
        );
      } else {
        Fluttertoast.showToast(
          msg: response.message ?? '查询失败',
          gravity: ToastGravity.CENTER,
        );
      }
    } catch (e) {
      LoadingUtil.hide();
      LoggerUtil.e('故障码查询失败: $e');
      Fluttertoast.showToast(
        msg: '查询失败，请重试',
        gravity: ToastGravity.CENTER,
      );
    }
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
          'Fault code query-R32',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
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
            const SizedBox(height: 40),
            const Text(
              'Faulty model number',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                hintText: 'R',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 60),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _searchFaultCode,
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
          ],
        ),
      ),
    );
  }
}