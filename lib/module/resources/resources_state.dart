import 'package:get/get.dart';

class ResourcesState {
  // 加载状态
  bool isLoading = false;
  
  // 错误信息
  String? errorMessage;
  
  // 当前层级 (1: 品牌, 2: 分类, 3: 型号)
  int currentLevel = 1;
  
  // 面包屑导航数据
  List<BreadcrumbItem> breadcrumbs = [];
  
  // 原始数据（从API获取的完整数据）
  List<ResourceItem> allBrands = [];
  List<ResourceItem> allDeviceTypes = [];
  List<ResourceItem> allModels = [];

  List<ResourceItem> secondData = [];
  List<ResourceItem> threeData = [];

  // 当前显示的数据
  List<ResourceItem> currentItems = [];

  // 当前选中的ID
  int? currentBrandId;
  String? currentBrandName;
  int? currentDeviceTypeId;
  String? currentDeviceTypeName;

  ResourcesState();
}

// 面包屑导航项
class BreadcrumbItem {
  final String? title;
  final bool? isSelected;
  final int? id;
  final int? level;

  BreadcrumbItem({
    this.title,
    this.isSelected = false,
    this.id,
    this.level,
  });
}

// 统一的资源项数据模型
class ResourceItem {
  final int? id;
  final String? name;
  final String? code;
  final int? parentId;
  final int? level;
  final String? path;
  final String? imageUrl;
  final String? description;
  final int? sortOrder;
  final int? status;
  final int? createdAt;
  final int? updatedAt;
  final int? deviceCount;
  final List<dynamic>? maintenanceManuals;
  final List<dynamic>? operationManuals;

  ResourceItem({
    this.id,
    this.name,
    this.code,
    this.parentId,
    this.level,
    this.path,
    this.imageUrl,
    this.description,
    this.sortOrder,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.deviceCount,
    this.maintenanceManuals,
    this.operationManuals,
  });

  factory ResourceItem.fromJson(Map<String, dynamic> json) {
    return ResourceItem(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      parentId: json['parent_id'],
      level: json['level'],
      path: json['path'],
      imageUrl: json['image_url'],
      description: json['description'],
      sortOrder: json['sort_order'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deviceCount: json['device_count'],
      maintenanceManuals: json['maintenance_manuals'],
      operationManuals: json['operation_manuals']
    );
  }
}