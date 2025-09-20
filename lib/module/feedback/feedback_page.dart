import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:device_info_plus/device_info_plus.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _feedbackController = TextEditingController();
  final _email = ' weiping737@gmail.com';
  final _subject = 'App Feedback';
  final List<XFile> _selectedImages = [];

  Future<bool> _requestPermissions(ImageSource source) async {
    try {
      PermissionStatus status;

      if (source == ImageSource.camera) {
        status = await Permission.camera.request();
        print('Camera permission status: $status');
      } else {
        // Android 13+ uses new permission model
        if (Platform.isAndroid) {
          final deviceInfo = await DeviceInfoPlugin().androidInfo;
          if (deviceInfo.version.sdkInt >= 33) {
            final photosStatus = await Permission.photos.request();
            final videosStatus = await Permission.videos.request();
            status = photosStatus.isGranted || videosStatus.isGranted
                ? PermissionStatus.granted
                : PermissionStatus.denied;
            print(
                'Android 13+ media permissions - photos: $photosStatus, videos: $videosStatus');
          } else {
            // Android 12 and below
            status = await Permission.storage.request();
            print('Android 12- storage permission status: $status');
          }
        } else {
          // iOS
          status = await Permission.photos.request();
          print('iOS photos permission status: $status');
        }
      }

      return status.isGranted;
    } catch (e) {
      print('Permission request error: $e');
      return false;
    }
  }

  void _showPermissionDeniedDialog(String permissionType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Required'),
          content: Text(
              'Access to $permissionType is required to select images. Please enable it in Settings.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                // Open app settings
                await openAppSettings();
              },
              child: const Text('Go to Settings'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_selectedImages.length >= 4) {
      Fluttertoast.showToast(
        msg: 'Maximum 4 images allowed',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    try {
      // Request permissions
      final hasPermission = await _requestPermissions(source);
      if (!hasPermission) {
        // Permission denied, show guidance dialog
        final permissionType =
            source == ImageSource.camera ? 'Camera' : 'Photo Library';
        _showPermissionDeniedDialog(permissionType);
        return;
      }

      // Configure image picker
      final ImagePicker picker = ImagePicker();
      XFile? image;

      if (source == ImageSource.camera) {
        image = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
          maxWidth: 1920,
          maxHeight: 1080,
        );
      } else {
        image = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
          maxWidth: 1920,
          maxHeight: 1080,
        );
      }

      if (image != null) {
        // Validate image file exists and is readable
        final file = File(image.path);
        if (await file.exists() && await file.length() > 0) {
          setState(() {
            _selectedImages.add(image!);
          });
          Fluttertoast.showToast(
            msg: 'Image selected successfully',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        } else {
          Fluttertoast.showToast(
            msg: 'Invalid image file',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        }
      }
    } catch (e) {
      String errorMessage = 'Error selecting image';

      if (e.toString().contains('PlatformException')) {
        if (e.toString().contains('photo_access_denied')) {
          errorMessage =
              'Photo access denied. Please allow access in Settings.';
        } else if (e.toString().contains('camera_access_denied')) {
          errorMessage =
              'Camera access denied. Please allow access in Settings.';
        } else {
          errorMessage =
              'Unable to access ${source == ImageSource.camera ? "camera" : "photo library"}. Please check permissions.';
        }
      } else {
        errorMessage = 'Error: ${e.toString()}';
      }

      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );

      print('Image picker error: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
    Fluttertoast.showToast(
      msg: 'Image removed',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_selectedImages.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Clear All Images'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedImages.clear();
                    });
                    Fluttertoast.showToast(
                      msg: 'All images cleared',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _sendFeedback() async {
    if (_feedbackController.text.trim().isEmpty && _selectedImages.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please enter feedback or select an image',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    Navigator.of(context).pop();
    // TODO: Implement actual feedback sending logic
    Fluttertoast.showToast(
      msg: 'Feedback submitted successfully',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Feedback'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _feedbackController,
              decoration: const InputDecoration(
                labelText: 'Please enter your feedback',
                border: OutlineInputBorder(),
                hintText: 'Describe your issue or suggestion...',
              ),
              maxLines: 8,
            ),
            const SizedBox(height: 20),

            // Image Upload Section
            const Text(
              'Upload Images (Max 4)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Image Grid
            if (_selectedImages.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(_selectedImages.length, (index) {
                  return SizedBox(
                    width: 80,
                    height: 80,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_selectedImages[index].path),
                              fit: BoxFit.cover,
                              width: 80,
                              height: 80,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                    size: 30,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),

            const SizedBox(height: 8),

            // Add Image Button
            if (_selectedImages.length < 4)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showImagePickerOptions,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: Text('Add Image (${_selectedImages.length}/4)'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sendFeedback,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Submit Feedback',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
