import 'package:get/get.dart';
import '../../core/network/api_service.dart';
import '../../core/utils/logger_util.dart';
import 'resources_state.dart';

class ResourcesLogic extends GetxController {
  final ResourcesState state = ResourcesState();
  
  @override
  void onInit() {
    super.onInit();
    loadAllResources();
  }
  
  // 加载所有资源数据
  Future<void> loadAllResources() async {
    try {
      state.isLoading = true;
      state.errorMessage = null;
      update();
      
      final response = await ApiService.getResourceBrands();
      LoggerUtil.d('资源数据加载: $response');
      
      if (response.success && response.data != null) {
        final data = response.data!['data'];
        
        // 解析所有数据，添加空值检查
        final brandsData = data['brands'] as List<dynamic>? ?? [];
        final deviceTypesData = data['device_types'] as List<dynamic>? ?? [];
        final modelsData = data['models'] as List<dynamic>? ?? [];
        
        state.allBrands = brandsData.map((json) => ResourceItem.fromJson(json)).toList();
        state.allDeviceTypes = deviceTypesData.map((json) => ResourceItem.fromJson(json)).toList();
        state.allModels = modelsData.map((json) => ResourceItem.fromJson(json)).toList();
        
        // 显示品牌列表（一级）
        showBrands();
        
        LoggerUtil.d('资源数据加载成功: ${state.allBrands.length}个品牌, ${state.allDeviceTypes.length}个设备类型, ${state.allModels.length}个型号');
      } else {
        state.errorMessage = response.message ?? '加载资源数据失败';
        LoggerUtil.e('资源数据加载失败: ${response.message}');
      }
    } catch (e) {
      state.errorMessage = '网络错误，请稍后重试';
      LoggerUtil.e('资源数据加载异常: $e');
    } finally {
      state.isLoading = false;
      update();
    }
  }
  
  // 显示品牌列表（一级）
  void showBrands() {
    state.currentLevel = 1;
    state.currentItems = state.allBrands;
    state.breadcrumbs.clear();
    state.currentBrandId = null;
    state.currentBrandName = null;
    state.currentDeviceTypeId = null;
    state.currentDeviceTypeName = null;
    update();
  }
  
  // 显示设备类型列表（二级）
  void showDeviceTypes(int? brandId, String? brandName) {
    if (brandId == null || brandName == null) return;
    
    state.currentLevel = 2;
    state.currentBrandId = brandId;
    state.currentBrandName = brandName;
    
    // 通过parent_id过滤device_types，添加空值检查
    state.secondData = state.allDeviceTypes
        .where((item) => item.parentId == brandId)
        .toList();
    
    // 更新面包屑导航
    state.breadcrumbs = [
      BreadcrumbItem(title: brandName, level: 1, id: brandId),
    ];

    update();
  }

  // 显示型号列表（三级）
  void showModels(int? deviceTypeId, String? deviceTypeName) {
    if (deviceTypeId == null || deviceTypeName == null) return;

    state.currentLevel = 3;
    state.currentDeviceTypeId = deviceTypeId;
    state.currentDeviceTypeName = deviceTypeName;

    // 通过parent_id过滤models，添加空值检查
    state.threeData = state.allModels
        .where((item) => item.parentId == deviceTypeId)
        .toList();

    // 更新面包屑导航
    state.breadcrumbs = [
      BreadcrumbItem(title: state.currentBrandName, level: 1, id: state.currentBrandId),
      BreadcrumbItem(title: deviceTypeName, level: 2, id: deviceTypeId, isSelected: true),
    ];

    update();
  }

  // 显示详情页（四级）
  void showDetail(ResourceItem item) {
    // 导航到详情页，传递item数据
    Get.toNamed('/resource_detail', arguments: item);
  }

  // 面包屑导航点击
  void onBreadcrumbTap(BreadcrumbItem item) {
    if (item.level == 1) {
      // 返回品牌列表
      showBrands();
    } else if (item.level == 2 && state.currentBrandId != null) {
      // 返回设备类型列表
      showDeviceTypes(state.currentBrandId, state.currentBrandName);
    }
  }

  // 刷新当前页面数据
  Future<void> refreshCurrentData() async {
    await loadAllResources();
  }

  // 获取当前页面标题
  String get currentPageTitle {
    switch (state.currentLevel) {
      case 1:
        return 'Resources';
      case 2:
        return state.currentBrandName ?? 'Device Types';
      case 3:
        return state.currentDeviceTypeName ?? 'Models';
      default:
        return 'Resources';
    }
  }
}