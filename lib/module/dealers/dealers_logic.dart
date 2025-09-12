import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/network/api_service.dart';
import '../../core/utils/logger_util.dart';
import 'dealers_state.dart';

class DealersLogic extends GetxController {
  final DealersState state = DealersState();
  
  @override
  void onInit() {
    super.onInit();
    loadDealers();
    loadFavoriteDealers();
  }
  
  // 加载代理商列表
  Future<void> loadDealers({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        state.dealers.clear();
      }
      
      state.isLoading = true;
      state.errorMessage = null;
      update();
      
      final response = await ApiService.getDealerList();
      LoggerUtil.d('代理商数据加载: $response');
      
      if (response.success && response.data != null) {
        final responseData = response.data!;

        // 检查响应状态码
        if (responseData['code'] == 200) {
          final data = responseData['data'];

          // 解析代理商列表
          final dealersData = data['dealers'] as List<dynamic>? ?? [];
          final newDealers = dealersData.map((json) => DealerItem.fromJson(json)).toList();

          state.dealers = newDealers;
          _printDealersInfo();
          _updateMarkers();

          LoggerUtil.d('代理商数据加载成功: ${state.dealers.length}个代理商');
        } else {
          state.errorMessage = responseData['message'] ?? '加载代理商数据失败';
          LoggerUtil.e('代理商数据加载失败: ${responseData['message']}');
        }
      } else {
        state.errorMessage = response.message ?? '加载代理商数据失败';
        LoggerUtil.e('代理商数据加载失败: ${response.message}');
      }
    } catch (e) {
      state.errorMessage = '网络错误，请稍后重试';
      LoggerUtil.e('代理商数据加载异常: $e');
    } finally {
      state.isLoading = false;
      update();
    }
  }

  void _printDealersInfo() {
    LoggerUtil.d('--- All Dealers Info ---');
    for (final dealer in state.dealers) {
      LoggerUtil.d(
          'Name: ${dealer.dealerName}, Lat: ${dealer.latitude}, Lng: ${dealer.longitude}');
    }
    LoggerUtil.d('------------------------');
  }

  // 更新地图标记
  void _updateMarkers() {
    final markers = <Marker>{};
    for (final dealer in state.dealers) {
      if (dealer.latitude != null && dealer.longitude != null) {
        markers.add(
          Marker(
            markerId: MarkerId(dealer.id.toString()),
            position: LatLng(dealer.latitude!, dealer.longitude!),
            infoWindow: InfoWindow(
              title: dealer.dealerName,
              snippet: dealer.fullAddress,
            ),
          ),
        );
      }
    }
    state.markers = markers;

    // 更新地图相机以显示所有标记
    updateMapCamera();
  }

  void updateMapCamera() {
    if (state.markers.isEmpty || state.mapController == null) {
      return;
    }

    if (state.markers.length == 1) {
      // 如果只有一个标记，则将相机居中到该标记
      state.mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(state.markers.first.position, 14),
      );
    } else {
      // 如果有多个标记，则调整相机以适应所有标记
      final LatLngBounds bounds = _boundsFromMarkers(state.markers);
      state.mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50), // 50是内边距
      );
    }
  }

  LatLngBounds _boundsFromMarkers(Set<Marker> markers) {
    double? minLat, maxLat, minLng, maxLng;

    for (final marker in markers) {
      final lat = marker.position.latitude;
      final lng = marker.position.longitude;

      if (minLat == null || lat < minLat) minLat = lat;
      if (maxLat == null || lat > maxLat) maxLat = lat;
      if (minLng == null || lng < minLng) minLng = lng;
      if (maxLng == null || lng > maxLng) maxLng = lng;
    }

    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );
  }

  // 加载收藏的代理商列表
  Future<void> loadFavoriteDealers() async {
    try {
      state.isLoading = true;
      update();

      final response = await ApiService.getFavoriteDealers();
      LoggerUtil.d('收藏代理商数据加载: $response');
      
      if (response.success && response.data != null) {
        final responseData = response.data!;
        
        if (responseData['code'] == 200) {
          final data = responseData['data'];
          final favoritesData = data['favorites'] as List<dynamic>? ?? [];
          
          state.favoriteDealers = favoritesData.map((json) => DealerItem.fromJson(json['dealer'])).toList();
          
          // 更新收藏ID列表以用于UI（例如星标图标）
          state.favoriteDealerIds = state.favoriteDealers
              .map((dealer) => dealer.id)
              .where((id) => id != null)
              .cast<int>()
              .toList();
          
          LoggerUtil.d('收藏代理商加载成功: ${state.favoriteDealers.length}个');
        }
      }
    } catch (e) {
      LoggerUtil.e('加载收藏代理商异常: $e');
    } finally {
      state.isLoading = false;
      update();
    }
  }
  
  // 刷新数据
  Future<void> refreshDealers() async {
    if (state.currentTabIndex == 1) {
      await loadFavoriteDealers();
    } else {
      await loadDealers(isRefresh: true);
    }
  }
  
  // 搜索代理商
  void searchDealers(String keyword) {
    state.searchKeyword = keyword;
    loadDealers(isRefresh: true);
  }
  
  // 设置品牌筛选
  void setBrandFilter(String? brand) {
    state.selectedBrand = brand;
    loadDealers(isRefresh: true);
  }
  
  // 设置城市筛选
  void setCityFilter(String? city) {
    state.selectedCity = city;
    loadDealers(isRefresh: true);
  }
  
  // 设置服务类型筛选
  void setServiceFilter(String? service) {
    state.selectedService = service;
    loadDealers(isRefresh: true);
  }
  
  // 切换收藏状态
  Future<void> toggleFavorite(dynamic dealerId ,bool favorite) async {
    try {
      LoggerUtil.i('收藏&&取消收藏的数据=====$dealerId =====$favorite');
      // 调用API更新收藏状态
      final response = !favorite
          ? await ApiService.addDealerToFavorites(dealerId)
          : await ApiService.removeDealerFromFavorites(dealerId);
      
      if (response.success && response.data != null) {
        final responseData = response.data!;
        LoggerUtil.i('收藏&&取消收藏的数据=====$responseData');
        if (responseData['code'] == 200) {
          // 更新本地数据
          loadDealers(isRefresh: true);
          loadFavoriteDealers();
          Fluttertoast.showToast(msg: !favorite ? 'Added to favorites' : 'Removed from favorites');
        } else {
          Get.snackbar('Error', responseData['message'] ?? 'Operation failed');
        }
      } else {
        Get.snackbar('Error', response.message ?? 'Network error');
      }
    } catch (e) {
      LoggerUtil.e('更新收藏状态失败: $e');
      Get.snackbar('Error', 'Failed to update favorite status');
    }
  }
  
  // 获取代理商详情
  Future<DealerItem?> getDealerDetail(dynamic dealerId) async {
    try {
      final response = await ApiService.getDealerDetail(dealerId);
      LoggerUtil.d('代理商详情加载: $response');
      
      if (response.success && response.data != null) {
        final responseData = response.data!;
        
        if (responseData['code'] == 200) {
          final data = responseData['data'];
          return DealerItem.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      LoggerUtil.e('获取代理商详情失败: $e');
      return null;
    }
  }
  
  // 切换标签页
  void switchTab(int index) {
    if (state.currentTabIndex == index) return;
    state.currentTabIndex = index;
    
    // 如果切换到收藏标签页，重新加载收藏列表
    if (index == 1) {
      loadFavoriteDealers();
    }
    update();
  }
  
  // 获取收藏的代理商列表
  List<DealerItem> get favoriteDealers {
    return state.favoriteDealers;
  }
  
  // 获取当前显示的代理商列表
  List<DealerItem> get currentDealers {
    if (state.currentTabIndex == 1) {
      // 收藏标签页
      return state.favoriteDealers;
    } else {
      // 位置标签页
      return state.dealers;
    }
  }
  
  // 清除筛选条件
  void clearFilters() {
    state.selectedBrand = null;
    state.selectedCity = null;
    state.selectedService = null;
    state.searchKeyword = '';
    loadDealers(isRefresh: true);
  }
}
