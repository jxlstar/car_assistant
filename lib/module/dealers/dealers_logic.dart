import 'package:get/get.dart';
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
  
  // 加载收藏的代理商列表
  Future<void> loadFavoriteDealers() async {
    try {
      final response = await ApiService.getFavoriteDealers();
      LoggerUtil.d('收藏代理商数据加载: $response');
      
      if (response.success && response.data != null) {
        final responseData = response.data!;
        
        if (responseData['code'] == 200) {
          final data = responseData['data'];
          final favoritesData = data['favorites'] as List<dynamic>? ?? [];
          
          // 更新收藏ID列表
          state.favoriteDealerIds = favoritesData
              .map((item) => item['id'])
              .where((id) => id != null)
              .cast<int>()
              .toList();
          
          LoggerUtil.d('收藏代理商加载成功: ${state.favoriteDealerIds.length}个');
        }
      }
    } catch (e) {
      LoggerUtil.e('加载收藏代理商异常: $e');
    }
  }
  
  // 刷新数据
  Future<void> refreshDealers() async {
    await loadDealers(isRefresh: true);
    if (state.currentTabIndex == 1) {
      await loadFavoriteDealers();
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
          Get.snackbar(
            '成功',
            !favorite ? '已添加到收藏' : '已取消收藏',
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          Get.snackbar('错误', responseData['message'] ?? '操作失败');
        }
      } else {
        Get.snackbar('错误', response.message ?? '网络错误');
      }
    } catch (e) {
      LoggerUtil.e('更新收藏状态失败: $e');
      Get.snackbar('错误', '更新收藏状态失败');
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
    state.currentTabIndex = index;
    update();
    
    // 如果切换到收藏标签页，重新加载收藏列表
    if (index == 1) {
      loadFavoriteDealers();
    }
  }
  
  // 获取收藏的代理商列表
  List<DealerItem> get favoriteDealers {
    return state.dealers.where((dealer) => 
        state.favoriteDealerIds.contains(dealer.id)).toList();
  }
  
  // 获取当前显示的代理商列表
  List<DealerItem> get currentDealers {
    if (state.currentTabIndex == 1) {
      // 收藏标签页
      return favoriteDealers;
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