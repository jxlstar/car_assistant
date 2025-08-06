import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../r.dart';

class DealersPage extends StatefulWidget {
  const DealersPage({super.key});

  @override
  State<DealersPage> createState() => _DealersPageState();
}

class _DealersPageState extends State<DealersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search Equipment...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 标签页
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'LOCATIONS'),
                Tab(text: 'FAVOROTES'), // 注意：UI中拼写错误，应为FAVORITES
              ],
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              indicatorWeight: 3.0,
            ),
            
            // 标签页内容
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 位置标签页
                  _buildLocationsTab(),
                  
                  // 收藏标签页
                  const Center(child: Text('收藏列表')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLocationsTab() {
    return Column(
      children: [
        // 地图区域
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.grey.shade200,
            child: Stack(
              children: [
                // 这里应该集成实际的地图组件
                // 例如 GoogleMap 或 MapBox
                Center(child: Text('地图区域')),
              ],
            ),
          ),
        ),
        
        // 经销商列表
        Expanded(
          flex: 1,
          child: ListView.builder(
            padding: const EdgeInsets.all(0),
            itemCount: 1, // 示例中只有一个经销商
            itemBuilder: (context, index) {
              return _buildDealerItem(
                name: 'Brightline Optics of Dalls',
                address: '1023 S. Walton Walker Blvd Irving, TX 7560',
                phone: '86-1029348',
                isFavorite: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DealerDetailPage(
                        name: 'Brightline Optics of Dalls',
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildDealerItem({
    required String name,
    required String address,
    required String phone,
    required bool isFavorite,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                    color: isFavorite ? Colors.amber : Colors.grey,
                  ),
                  onPressed: () {
                    // 切换收藏状态
                  },
                ),
              ],
            ),
            Text(
              address,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                // 拨打电话
              },
              child: Row(
                children: [
                  const Icon(Icons.phone, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    phone,
                    style: const TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 经销商详情页面
class DealerDetailPage extends StatelessWidget {
  final String name;
  
  const DealerDetailPage({super.key, required this.name});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Center(
        child: Text('$name 详情页面'),
      ),
    );
  }
}