import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PdfViewerPage extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerPage({
    Key? key,
    required this.pdfUrl,
    required this.title,
  }) : super(key: key);

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  String? localPath;
  bool isLoading = true;
  String? errorMessage;
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorText = '';

  @override
  void initState() {
    super.initState();
    _downloadAndOpenPdf();
  }

  Future<void> _downloadAndOpenPdf() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final dio = Dio();
      final dir = await getTemporaryDirectory();
      final fileName = widget.pdfUrl.split('/').last;
      final filePath = '${dir.path}/$fileName';

      // 检查文件是否已存在
      final file = File(filePath);
      if (!await file.exists()) {
        // 下载PDF文件
        await dio.download(widget.pdfUrl, filePath);
      }

      setState(() {
        localPath = filePath;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load PDF: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          if (pages != null && pages! > 0)
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${currentPage! + 1}/$pages',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading PDF...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _downloadAndOpenPdf,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (localPath == null) {
      return Center(
        child: Text(
          'No PDF file available',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
      );
    }

    return PDFView(
      filePath: localPath!,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: false,
      pageFling: true,
      pageSnap: true,
      defaultPage: currentPage!,
      fitPolicy: FitPolicy.BOTH,
      preventLinkNavigation: false,
      onRender: (pages) {
        setState(() {
          this.pages = pages;
          isReady = true;
        });
      },
      onError: (error) {
        setState(() {
          errorText = error.toString();
        });
      },
      onPageError: (page, error) {
        setState(() {
          errorText = '$page: ${error.toString()}';
        });
      },
      onViewCreated: (PDFViewController controller) {
        // PDF视图创建完成
      },
      onLinkHandler: (String? uri) {
        // 处理PDF中的链接
      },
      onPageChanged: (int? page, int? total) {
        setState(() {
          currentPage = page;
        });
      },
    );
  }
}