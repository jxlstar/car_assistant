import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareDialog extends StatelessWidget {
  final Map<String, dynamic> device;
  
  const ShareDialog({Key? key, required this.device}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE3F2FD),
              Color(0xFFBBDEFB),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 24), // Placeholder for alignment
                  // RIPPA Logo
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Color(0xFF1976D2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.waves,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'RIPPA',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                      Text(
                        '®',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                    ],
                  ),
                  // Close button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // Title
                  Text(
                    "The machine's running\nsmooth as usual!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Subtitle
                  Text(
                    "Thanks for all your hard work—hope\nyou have an awesome day, every\nsingle day!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  
                  SizedBox(height: 32),
                  
                  // QR Code section
                  Row(
                    children: [
                      // QR Code
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: CustomPaint(
                              painter: QRCodePainter(),
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(width: 16),
                      
                      // QR Code description
                      Expanded(
                        child: Text(
                          "Long press or scan\nthe QR code to\ndownload the APP.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 32),
                ],
              ),
            ),
            
            // Bottom section with share options
            Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Share text
                  Text(
                    'Share',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Share buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Facebook
                      _buildShareButton(
                        icon: Icons.facebook,
                        color: Color(0xFF1877F2),
                        label: 'Facebook',
                        onTap: () => _shareToFacebook(context),
                      ),
                      
                      // Instagram
                      _buildShareButton(
                        icon: Icons.camera_alt,
                        color: Color(0xFFE4405F),
                        label: 'instagram',
                        onTap: () => _shareToInstagram(context),
                      ),
                      
                      // Download
                      _buildShareButton(
                        icon: Icons.download,
                        color: Colors.grey[600]!,
                        label: 'Downloading',
                        onTap: () => _downloadImage(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildShareButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
  void _shareToFacebook(BuildContext context) async {
    try {
      final imageBytes = await _generateShareImage();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/rippa_share.png');
      await file.writeAsBytes(imageBytes);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: "The machine's running smooth as usual! Thanks for all your hard work—hope you have an awesome day, every single day!",
      );
    } catch (e) {
      _showMessage(context, 'Failed to share to Facebook');
    }
  }
  
  void _shareToInstagram(BuildContext context) async {
    try {
      final imageBytes = await _generateShareImage();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/rippa_share.png');
      await file.writeAsBytes(imageBytes);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: "The machine's running smooth as usual! Thanks for all your hard work—hope you have an awesome day, every single day!",
      );
    } catch (e) {
      _showMessage(context, 'Failed to share to Instagram');
    }
  }
  
  void _downloadImage(BuildContext context) async {
    try {
      final imageBytes = await _generateShareImage();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/rippa_share_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(imageBytes);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Image generated, please save to album',
      );
    } catch (e) {
      _showMessage(context, 'Failed to download image');
    }
  }

  Future<Uint8List> _generateShareImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(400, 600);
    
    // Draw background gradient
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFE3F2FD),
        const Color(0xFFBBDEFB),
      ],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(20),
      ),
      paint,
    );
    
    // Draw RIPPA title
    final titlePainter = TextPainter(
      text: const TextSpan(
        text: 'RIPPA®',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1976D2),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout();
    titlePainter.paint(canvas, const Offset(30, 40));
    
    // Draw main title
    final mainTitlePainter = TextPainter(
      text: const TextSpan(
        text: "The machine's running\nsmooth as usual!",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          height: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    mainTitlePainter.layout(maxWidth: size.width - 60);
    mainTitlePainter.paint(canvas, const Offset(30, 100));
    
    // Draw subtitle
    final subTitlePainter = TextPainter(
      text: const TextSpan(
        text: "Thanks for all your hard work—hope\nyou have an awesome day, every\nsingle day!",
        style: TextStyle(
          fontSize: 14,
          color: Colors.black54,
          height: 1.3,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    subTitlePainter.layout(maxWidth: size.width - 60);
    subTitlePainter.paint(canvas, const Offset(30, 180));
    
    // Draw QR code area
    final qrPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(30, 280, 120, 120),
        const Radius.circular(8),
      ),
      qrPaint,
    );
    
    // Draw simple QR code pattern
    final qrCodePaint = Paint()..color = Colors.black;
    for (int i = 0; i < 10; i++) {
      for (int j = 0; j < 10; j++) {
        if ((i + j) % 2 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(
              40 + i * 10.0,
              290 + j * 10.0,
              8,
              8,
            ),
            qrCodePaint,
          );
        }
      }
    }
    
    // Draw QR code description text
    final qrTextPainter = TextPainter(
      text: const TextSpan(
        text: "Long press or scan\nthe QR code to\ndownload the APP.",
        style: TextStyle(
          fontSize: 12,
          color: Colors.black54,
          height: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    qrTextPainter.layout();
    qrTextPainter.paint(canvas, const Offset(170, 320));
    
    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
  
  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

// Custom painter for QR code pattern
class QRCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    // Draw a simple QR code pattern
    final blockSize = size.width / 8;
    
    // Draw some blocks to simulate QR code
    final blocks = [
      [0, 0], [1, 0], [2, 0], [5, 0], [6, 0], [7, 0],
      [0, 1], [2, 1], [5, 1], [7, 1],
      [0, 2], [1, 2], [2, 2], [5, 2], [6, 2], [7, 2],
      [4, 3], [6, 3],
      [1, 4], [3, 4], [5, 4], [7, 4],
      [0, 5], [2, 5], [4, 5], [6, 5],
      [0, 6], [1, 6], [2, 6], [4, 6], [5, 6], [6, 6], [7, 6],
      [0, 7], [2, 7], [4, 7], [6, 7],
    ];
    
    for (final block in blocks) {
      canvas.drawRect(
        Rect.fromLTWH(
          block[0] * blockSize,
          block[1] * blockSize,
          blockSize,
          blockSize,
        ),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}