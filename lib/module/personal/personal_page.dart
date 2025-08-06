import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../notification/notification_page.dart';
import '../../r.dart';
import '../login/auth_provider.dart';

class PersonalPage extends StatelessWidget {
  const PersonalPage({super.key});

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
        child: Column(
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
                      child: Image.asset(
                        R.assetsImageAvatar, // 确保添加此资源
                        height: 60,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 账户名称
                    const Text(
                      'Account name',
                      style: TextStyle(
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
                        const Text(
                          '88874576abeach@gmail.com',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // 电话
                    Row(
                      children: [
                        Icon(Icons.phone, color: Colors.blue.shade300, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          '86-1029348',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // About 标题
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'About',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
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