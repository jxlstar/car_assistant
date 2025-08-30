import 'package:car_assistant/core/network/api_service.dart';
import 'package:car_assistant/core/utils/logger_util.dart';
import 'package:car_assistant/module/login/otp_verification_page.dart';
import 'package:car_assistant/module/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/storage/storage_service.dart';
import '../../notification/notification_page.dart';
import '../../r.dart';
class PersonalPage extends StatefulWidget {
  const PersonalPage({super.key});

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final user = await StorageService.getUser();
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _performLogout();
              },
            ),
          ],
        );
      },
    );
  }

  void _performLogout() async {
    try {
      await ApiService.logout();
      // Navigate to login page and remove all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      // Handle logout error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // 用户信息卡片
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // 头像
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: Colors.blue.shade100,
                            backgroundImage: _user?.avatar != null && _user!.avatar!.isNotEmpty
                                ? NetworkImage(_user!.avatar!)
                                : null,
                            child: _user?.avatar == null || _user!.avatar!.isEmpty
                                ? Image.asset(
                                    R.assetsImageAvatar,
                                    height: 60,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 16),
                          
                          // 账户名称
                          Text(
                            _user?.fullName ?? 'No Account name',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          
                          // 邮箱
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.email, color: Colors.blue.shade300, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                _user?.email ?? '',
                                style: const TextStyle(color: Colors.black87),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  
                  // 设置项列表
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      children: [
                        _buildSettingItem(
                          context,
                          icon: Icons.info_outline,
                          title: 'Change Password',
                          onTap: () async {
                            // 在Change Password的点击事件中
                                // 获取当前用户邮箱
                                final user = await StorageService.getUser();
                                if (user?.email != null) {
                                  try {
                                    // 发送验证码
                                    final response = await ApiService.sendVerificationCode(
                                      email: user!.email!,
                                      type: 'reset_password',
                                    );

                                    if (response.success) {
                                      // 跳转到验证码页面
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => OtpVerificationPage(
                                            email: user.email!,
                                            type: OtpType.changePassword,
                                          ),
                                        ),
                                      );

                                      Fluttertoast.showToast(
                                        msg: "Verification code sent to ${user.email}",
                                        gravity: ToastGravity.CENTER,
                                      );
                                    } else {
                                      Fluttertoast.showToast(
                                        msg: "Failed to send verification code: ${response.message}",
                                        gravity: ToastGravity.CENTER,
                                      );
                                    }
                                  } catch (e) {
                                    Fluttertoast.showToast(
                                      msg: "Failed to send verification code",
                                      gravity: ToastGravity.CENTER,
                                    );
                                  }
                                } else {
                                  Fluttertoast.showToast(
                                    msg: "User email not found",
                                    gravity: ToastGravity.CENTER,
                                  );
                                }
                              },
                        ),
                        _buildSettingItem(
                          context,
                          icon: Icons.info_outline,
                          title: 'About',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AboutPage()),
                            );
                          },
                        ),
                        _buildSettingItem(
                          context,
                          icon: Icons.description_outlined,
                          title: 'Legal Terms',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LegalTermsPage()),
                            );
                          },
                        ),
                        _buildSettingItem(
                          context,
                          icon: Icons.language_outlined,
                          title: 'RIPPA Website',
                          onTap: () async {
                            await _openRippaWebsite();
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildSettingItem(
                          context,
                          icon: Icons.logout,
                          title: 'Sign Out',
                          titleColor: Colors.red,
                          onTap: _showLogoutDialog, // 修改为显示确认对话框
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
  
  Widget _buildSettingItem(BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: titleColor ?? Colors.black54),
        title: Text(
          title,
          style: TextStyle(color: titleColor),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

// 打开RIPPA官网
Future<void> _openRippaWebsite() async {
  const String url = 'https://www.rippa.com/';
  try {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // 在外部浏览器中打开
      );
    } else {
      Fluttertoast.showToast(
        msg: "Could not open website link",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      LoggerUtil.e('Could not launch $url');
    }
  } catch (e) {
    Fluttertoast.showToast(
      msg: "An error occurred while opening the website",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
    );
    LoggerUtil.e('Error launching URL: $e');
  }
}

// 占位页面 - 实际项目中应该创建单独的文件
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'About Us',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Logo section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // RIPPA Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E3A8A), // 深蓝色背景
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.terrain, // 使用山形图标代替RIPPA logo
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // RIPPA text
                  const Text(
                    'RIPPA',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Version
                  const Text(
                    'v1.0.0',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // About Us section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'About Us',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Company description
            Text(
              'Shandong RIPPA Machinery Co., Ltd. is a global machinery manufacturing company headquartered in Jining City, Shandong Province, China. It focuses on the research, development, production and sales of high-quality construction machinery and equipment. The company\'s products include excavators, loaders, forklifts, skid steer loaders and their accessories, which are widely used in agriculture, construction, mining and other industries. With its innovative R&D capabilities and strict quality control, the equipment provided by RIPPA Machinery enjoys a high reputation worldwide. We offer a one-year quality guarantee and are committed to meeting customers\' demands for affordable and high-quality products. RIPPA has multiple agents around the world. We offer a one-stop service from pre-sale consultation to after-sale service to ensure that customers have the best experience in product selection, delivery and maintenance.',
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}

class LegalTermsPage extends StatelessWidget {
  const LegalTermsPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Legal Terms')),
      body: const Center(child: Text('Legal Terms Page')),
    );
  }
}