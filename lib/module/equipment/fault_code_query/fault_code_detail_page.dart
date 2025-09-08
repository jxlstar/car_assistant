import 'package:flutter/material.dart';

class FaultCodeDetailPage extends StatelessWidget {
  final Map<String, dynamic> faultCodeData;

  const FaultCodeDetailPage({
    Key? key,
    required this.faultCodeData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = faultCodeData['data'] ?? {};
    final code = data['code'] ?? '';
    final title = data['title'] ?? '';
    final description = data['description'] ?? '';
    final causes = data['causes'] ?? [];
    
    // 将causes数组转换为字符串
    String causesText = '';
    if (causes is List && causes.isNotEmpty) {
      causesText = causes.join('、');
    }
    
    // 组合Problem内容：title + description
    String problemText = '';
    if (title.isNotEmpty && description.isNotEmpty) {
      problemText = '$title：$description';
    } else if (title.isNotEmpty) {
      problemText = title;
    } else if (description.isNotEmpty) {
      problemText = description;
    }

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
          'Fault Code - Query',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            // 故障码显示
            Center(
              child: Column(
                children: [
                  Text(
                    code,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Faulty model number',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            // 问题描述 (title + description)
            const Text(
              'Problem',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                problemText.isNotEmpty ? problemText : 'No problem description available',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // 原因说明 (causes)
            const Text(
              'Reason',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                causesText.isNotEmpty ? causesText : 'No cause description available',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24), // 底部额外间距
          ],
        ),
      ),
    );
  }
}