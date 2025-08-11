import 'package:car_assistant/module/login/forgot_password_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/storage/storage_service.dart';
import '../../notification/notification_page.dart';
import '../../r.dart';
import '../login/auth_provider.dart';

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
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // 邮箱
                          Row(
                            children: [
                              Icon(Icons.email, color: Colors.blue.shade300, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _user?.email ?? '',
                                  style: const TextStyle(color: Colors.black87),
                                  overflow: TextOverflow.ellipsis,
                                ),
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
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                            );
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
                          onTap: () {
                            // 打开网站链接
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildSettingItem(
                          context,
                          icon: Icons.logout,
                          title: 'Sign Out',
                          onTap: () {
                            // 登出
                            final authProvider = context.read<AuthProvider>();
                            authProvider.logout().then((_) {
                              // 登出成功后返回登录页面
                              Navigator.of(context).pushReplacementNamed('/');
                            });
                          },
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
        leading: Icon(icon, color: Colors.black54),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

// 占位页面 - 实际项目中应该创建单独的文件
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: const Center(child: Text('About Page')),
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