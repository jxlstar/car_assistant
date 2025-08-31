import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DealersState {
  // 加载状态
  bool isLoading = false;
  
  // 错误信息
  String? errorMessage;
  
  // 代理商列表数据
  List<DealerItem> dealers = [];
  List<DealerItem> favoriteDealers = [];
  
  // 筛选条件
  String? selectedBrand;
  String? selectedCity;
  String? selectedService;
  
  // 搜索关键词
  String searchKeyword = '';
  
  // 收藏的代理商ID列表
  List<int> favoriteDealerIds = [];
  
  // 当前选中的标签页 (0: 位置, 1: 收藏)
  int currentTabIndex = 0;
  
  // Google Map
  GoogleMapController? mapController;
  Set<Marker> markers = {};

  DealersState();
}

// 代理商数据模型
class DealerItem {
  final int? id;
  final String? dealerCode;
  final String? dealerName;
  final String? brand;
  final String? dealerType;
  final String? contactPerson;
  final String? phone;
  final String? mobile;
  final String? email;
  final String? website;
  final String? country;
  final String? province;
  final String? city;
  final String? district;
  final String? address;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final int? locationAccuracy;
  final BusinessHours? businessHours;
  final List<String>? services;
  final List<String>? supportedBrands;
  final List<String>? specialties;
  final double? rating;
  final int? reviewCount;
  final int? responseTime;
  final double? satisfactionRate;
  final int? status;
  final bool? isVerified;
  final bool? isFeatured;
  final int? priorityLevel;
  final String? description;
  final List<String>? images;
  final List<String>? certificates;
  final List<String>? tags;
  final int? createdAt;
  final int? updatedAt;
  final int? lastActiveAt;
  final String? dealerTypeName;
  final String? statusName;
  final String? fullAddress;
  final bool? isFavorited;

  DealerItem({
    this.id,
    this.dealerCode,
    this.dealerName,
    this.brand,
    this.dealerType,
    this.contactPerson,
    this.phone,
    this.mobile,
    this.email,
    this.website,
    this.country,
    this.province,
    this.city,
    this.district,
    this.address,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.locationAccuracy,
    this.businessHours,
    this.services,
    this.supportedBrands,
    this.specialties,
    this.rating,
    this.reviewCount,
    this.responseTime,
    this.satisfactionRate,
    this.status,
    this.isVerified,
    this.isFeatured,
    this.priorityLevel,
    this.description,
    this.images,
    this.certificates,
    this.tags,
    this.createdAt,
    this.updatedAt,
    this.lastActiveAt,
    this.dealerTypeName,
    this.statusName,
    this.fullAddress,
    this.isFavorited,
  });

  factory DealerItem.fromJson(Map<String, dynamic> json) {
    return DealerItem(
      id: json['id'],
      dealerCode: json['dealer_code'],
      dealerName: json['dealer_name'],
      brand: json['brand'],
      dealerType: json['dealer_type'],
      contactPerson: json['contact_person'],
      phone: json['phone'],
      mobile: json['mobile'],
      email: json['email'],
      website: json['website'],
      country: json['country'],
      province: json['province'],
      city: json['city'],
      district: json['district'],
      address: json['address'],
      postalCode: json['postal_code'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      locationAccuracy: json['location_accuracy'],
      businessHours: json['business_hours'] != null 
          ? BusinessHours.fromJson(json['business_hours']) 
          : null,
      services: _parseStringList(json['services']),
      supportedBrands: _parseStringList(json['supported_brands']),
      specialties: _parseStringList(json['specialties']),
      rating: json['rating']?.toDouble(),
      reviewCount: json['review_count'],
      responseTime: json['response_time'],
      satisfactionRate: json['satisfaction_rate']?.toDouble(),
      status: json['status'],
      isVerified: json['is_verified'] == 1,
      isFeatured: json['is_featured'] == 1,
      priorityLevel: json['priority_level'],
      description: json['description'],
      images: _parseStringList(json['images']),
      certificates: _parseStringList(json['certificates']),
      tags: _parseStringList(json['tags']),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      lastActiveAt: json['last_active_at'],
      dealerTypeName: json['dealer_type_name'],
      statusName: json['status_name'],
      fullAddress: json['full_address'],
      isFavorited: json['is_favorited'] ?? false,
    );
  }

  static List<String>? _parseStringList(dynamic data) {
    if (data == null) return null;
    if (data is List) {
      return data.map((item) => item.toString()).toList();
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dealer_code': dealerCode,
      'dealer_name': dealerName,
      'brand': brand,
      'dealer_type': dealerType,
      'contact_person': contactPerson,
      'phone': phone,
      'mobile': mobile,
      'email': email,
      'website': website,
      'country': country,
      'province': province,
      'city': city,
      'district': district,
      'address': address,
      'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'location_accuracy': locationAccuracy,
      'business_hours': businessHours?.toJson(),
      'services': services,
      'supported_brands': supportedBrands,
      'specialties': specialties,
      'rating': rating,
      'review_count': reviewCount,
      'response_time': responseTime,
      'satisfaction_rate': satisfactionRate,
      'status': status,
      'is_verified': isVerified == true ? 1 : 0,
      'is_featured': isFeatured == true ? 1 : 0,
      'priority_level': priorityLevel,
      'description': description,
      'images': images,
      'certificates': certificates,
      'tags': tags,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'last_active_at': lastActiveAt,
      'dealer_type_name': dealerTypeName,
      'status_name': statusName,
      'full_address': fullAddress,
      'is_favorited': isFavorited,
    };
  }

  // 获取服务类型的显示名称
  List<String> get serviceDisplayNames {
    if (services == null) return [];
    const serviceMap = {
      'sales': 'sales',
      'maintenance': 'maintenance',
      'parts': 'parts',
      'rental': 'rental',
      'training': 'training',
    };
    return services!.map((service) => serviceMap[service] ?? service).toList();
  }

  // 获取专业领域的显示名称
  List<String> get specialtyDisplayNames {
    if (specialties == null) return [];
    const specialtyMap = {
      'excavators': 'excavators',
      'wheel_loaders': 'wheel Loaders',
      'motor_graders': 'motor Graders',
      'compactors': 'compactors',
    };
    return specialties!.map((specialty) => specialtyMap[specialty] ?? specialty).toList();
  }
}

// 营业时间模型
class BusinessHours {
  final String? monday;
  final String? tuesday;
  final String? wednesday;
  final String? thursday;
  final String? friday;
  final String? saturday;
  final String? sunday;

  BusinessHours({
    this.monday,
    this.tuesday,
    this.wednesday,
    this.thursday,
    this.friday,
    this.saturday,
    this.sunday,
  });

  factory BusinessHours.fromJson(Map<String, dynamic> json) {
    return BusinessHours(
      monday: json['monday'],
      tuesday: json['tuesday'],
      wednesday: json['wednesday'],
      thursday: json['thursday'],
      friday: json['friday'],
      saturday: json['saturday'],
      sunday: json['sunday'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monday': monday,
      'tuesday': tuesday,
      'wednesday': wednesday,
      'thursday': thursday,
      'friday': friday,
      'saturday': saturday,
      'sunday': sunday,
    };
  }

  // 获取今天的营业时间
  String? getTodayHours() {
    final now = DateTime.now();
    switch (now.weekday) {
      case 1: return monday;
      case 2: return tuesday;
      case 3: return wednesday;
      case 4: return thursday;
      case 5: return friday;
      case 6: return saturday;
      case 7: return sunday;
      default: return null;
    }
  }

  // 获取所有营业时间
  List<MapEntry<String, String>> getAllHours() {
    final days = [
      MapEntry('周一', monday ?? ''),
      MapEntry('周二', tuesday ?? ''),
      MapEntry('周三', wednesday ?? ''),
      MapEntry('周四', thursday ?? ''),
      MapEntry('周五', friday ?? ''),
      MapEntry('周六', saturday ?? ''),
      MapEntry('周日', sunday ?? ''),
    ];
    return days.where((entry) => entry.value.isNotEmpty).toList();
  }
}