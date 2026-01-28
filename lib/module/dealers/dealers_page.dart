import 'package:car_assistant/module/dealers/dealers_map_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/colors_util.dart';
import 'dealers_logic.dart';
import 'dealers_state.dart';

class DealersPage extends StatefulWidget {
  const DealersPage({super.key});

  @override
  State<DealersPage> createState() => _DealersPageState();
}

class _DealersPageState extends State<DealersPage> with SingleTickerProviderStateMixin {
  late final DealersLogic logic;
  late final DealersState state;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    logic = Get.put(DealersLogic());
    state = logic.state;
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (logic.state.currentTabIndex != _tabController.index) {
        logic.switchTab(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DealersLogic>(
      init: logic,
      builder: (logic) {
        _tabController.index = logic.state.currentTabIndex;
        return Scaffold(
          backgroundColor: ColorsUtil.hexColor('F1F5F8'),
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
                  hintText: 'Search Dealers...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 4),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
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
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildContent(logic), // Locations
              _buildContent(logic), // Favorites
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(DealersLogic logic) {
    final state = logic.state;
    final dealers = logic.currentDealers;

    if (state.isLoading && dealers.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.errorMessage != null && dealers.isEmpty) {
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
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

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
              state.currentTabIndex == 1 ? 'No favorite dealers' : 'No dealer data',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            if (state.currentTabIndex == 0) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => logic.refreshDealers(),
                child: const Text('Refresh'),
              ),
            ],
          ],
        ),
      );
    }

    final dealerList = ListView.builder(
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
    );

    Widget content;
    if (logic.state.currentTabIndex == 0) {
      // "位置" 标签页，包含地图和列表
      content = Column(
        children: [
          GestureDetector(
            onTap: () {
              if (logic.currentDealers.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DealersMapPage(dealers: logic.currentDealers),
                  ),
                );
              }
            },
            child: Container(
              height: 200,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: GoogleMap(
                key: const ValueKey('dealers_map'),
                initialCameraPosition: const CameraPosition(
                  target: LatLng(37.7749, -122.4194), // 默认位置
                  zoom: 12,
                ),
                markers: logic.state.markers,
                onMapCreated: (controller) {
                  logic.state.mapController = controller;
                  logic.updateMapCamera();
                },
                // 禁用双击放大
                zoomGesturesEnabled: false,
                scrollGesturesEnabled: false,
                tiltGesturesEnabled: false,
                rotateGesturesEnabled: false,
                // 禁用双击放大手势
                onTap: (_) {}, // 添加onTap来覆盖默认双击行为
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{},
                // 隐藏右下角定位按钮
                myLocationButtonEnabled: false,
                myLocationEnabled: false,
              ),
            ),
          ),
          Expanded(child: dealerList),
        ],
      );
    } else {
      // "收藏" 标签页，仅包含列表
      content = dealerList;
    }

    return RefreshIndicator(
      onRefresh: () => logic.refreshDealers(),
      child: content,
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
                                dealer.dealerName ?? '',
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
                                  'Verified',
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
                        dealer.phone!,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                  if (dealer.email != null) ...[
                    const SizedBox(width: 16),
                    const Icon(Icons.email, color: Colors.blue, size: 16),
                    const SizedBox(width: 4),
                    Flexible(
                      child: GestureDetector(
                        onTap: (){
                          _jumpToEmail(dealer.email!);
                        },
                        child: Text(
                          dealer.email!,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                            overflow: TextOverflow.ellipsis
                        ),
                      ),
                    ),
                  ],
                  if (dealer.website != null && dealer.website!.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: GestureDetector(
                        onTap: () => _launchURL(dealer.website!),
                        child: const Icon(Icons.language, color: Colors.blue, size: 16),
                      ),
                    ),
                  ],
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
      } else {}
    } catch (e) {}
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {}
    } catch (e) {}
  }
  Future<void> _jumpToEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not launch email client.'),
        ),
      );
    }
  }
/*
 Navigator.of(context).pop();
    // final body = _feedbackController.text;
    // final Uri emailLaunchUri = Uri(
    //   scheme: 'mailto',
    //   path: _email,
    //   query: 'subject=$_subject&body=$body',
    // );
    //
    // if (await canLaunchUrl(emailLaunchUri)) {
    //   await launchUrl(emailLaunchUri);
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Could not launch email client.'),
    //     ),
    //   );
    // }
 */

  void _navigateToDetail(DealerItem dealer) {
    // Get.to(() => DealerDetailPage(dealer: dealer));
  }
}
