import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/colors_util.dart';
import 'dealers_logic.dart';
import 'dealers_state.dart';

class DealersPage extends StatefulWidget {
  const DealersPage({super.key});

  @override
  State<DealersPage> createState() => _DealersPageState();
}

class _DealersPageState extends State<DealersPage> {

  late final DealersLogic logic;
  late final DealersState state;

  @override
  void initState() {
    super.initState();
    logic = Get.put(DealersLogic());
    logic.loadDealers();
    state = logic.state;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DealersLogic>(
      init: DealersLogic(),
      builder: (logic) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: Colors.grey.shade50,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  onChanged: (value) => logic.searchDealers(value),
                  decoration: const InputDecoration(
                    hintText: 'Search Equipment...',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            body: Column(
              children: [
                // 标签页
                Container(
                  color: Colors.white,
                  child: TabBar(
                    onTap: (index) => logic.switchTab(index),
                    tabs: const [
                      Tab(text: 'LOCATIONS'),
                      Tab(text: 'FAVORITES'),
                    ],
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.blue,
                    indicatorWeight: 2.0,
                    labelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // 内容区域
                Expanded(
                  child: _buildContent(logic),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(DealersLogic logic) {
    final state = logic.state;

    if (state.isLoading && state.dealers.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.errorMessage != null && state.dealers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              state.errorMessage!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => logic.refreshDealers(),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    final dealers = logic.currentDealers;
    if (dealers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              state.currentTabIndex == 1 ? Icons.favorite_border : Icons.location_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              state.currentTabIndex == 1 ? '暂无收藏的代理商' : '暂无代理商数据',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            if (state.currentTabIndex == 0) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => logic.refreshDealers(),
                child: const Text('刷新'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => logic.refreshDealers(),
      child: Column(
        children: [
          // 地图区域（仅在位置标签页显示）
          if (state.currentTabIndex == 0)
            Container(
              height: 200,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  '地图区域\n（待集成地图组件）',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),

          // 代理商列表
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: dealers.length,
              itemBuilder: (context, index) {
                final dealer = dealers[index];
                return _buildDealerItem(
                  dealer: dealer,
                  onTap: () => _navigateToDetail(dealer),
                  onFavoriteToggle: () => logic.toggleFavorite(dealer.id, dealer.isFavorited ?? false),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDealerItem({
    required DealerItem dealer,
    required VoidCallback onTap,
    required VoidCallback onFavoriteToggle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                dealer.dealerName ?? '未知经销商',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (dealer.isVerified == true)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '认证',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (dealer.brand?.isNotEmpty == true)
                          Text(
                            dealer.brand!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        if (dealer.dealerTypeName?.isNotEmpty == true) ...[
                          const SizedBox(height: 2),
                          Text(
                            dealer.dealerTypeName!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      dealer.isFavorited ?? false || logic.state.favoriteDealerIds.contains(dealer.id)
                          ? Icons.star
                          : Icons.star_border,
                      color: dealer.isFavorited ?? false  || logic.state.favoriteDealerIds.contains(dealer.id)
                          ? Colors.red
                          : Colors.grey,
                    ),
                    onPressed: onFavoriteToggle,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                dealer.fullAddress ?? '',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (dealer.phone != null) ...[
                    const Icon(Icons.phone, color: Colors.blue, size: 16),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => _makePhoneCall(dealer.phone!),
                      child: Text(
                        dealer.phone ?? '',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                  if (dealer.mobile != null) ...[
                    if (dealer.phone != null) const SizedBox(width: 16),
                    const Icon(Icons.phone_android, color: Colors.green, size: 16),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => _makePhoneCall(dealer.mobile!),
                      child: Text(
                        dealer.mobile ?? '',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '(${dealer.reviewCount})',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              if (dealer.serviceDisplayNames.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: dealer.serviceDisplayNames.take(3).map((service) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        service,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // 拨打电话
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        // 显示错误提示
        // Get.snackbar(
        //   '错误',
        //   '无法拨打电话：$phoneNumber',
        //   snackPosition: SnackPosition.BOTTOM,
        //   backgroundColor: Colors.red.shade100,
        //   colorText: Colors.red.shade800,
        // );
      }
    } catch (e) {
      // 显示错误提示
      // Get.snackbar(
      //   '错误',
      //   '拨打电话失败：$e',
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Colors.red.shade100,
      //   colorText: Colors.red.shade800,
      // );
    }
  }

  void _navigateToDetail(DealerItem dealer) {
    // Get.to(() => DealerDetailPage(dealer: dealer));
  }

}
