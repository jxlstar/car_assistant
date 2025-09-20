import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationState {
  List<MessageItem> messages = [];
  int total = 0;
  int unreadCount = 0;
  int warningCount = 0;
  int infoCount = 0;
  int systemCount = 0;
  bool isLoading = false;
  String currentType = 'all';
  String currentStatus = 'all';
  int currentPage = 1;
}

class MessageItem {
  final String? id;
  final String? type; // warning, info, system
  final String? title;
  final String? content;
  final String? deviceId;
  final String? deviceName;
  final int? timestamp;
  final bool? isRead;
  final String? priority; // low, medium, high
  final bool? actionRequired;
  final String? actionUrl;

  MessageItem({
    this.id,
    this.type,
    this.title,
    this.content,
    this.deviceId,
    this.deviceName,
    this.timestamp,
    this.isRead,
    this.priority,
    this.actionRequired,
    this.actionUrl,
  });

  factory MessageItem.fromJson(Map<String, dynamic> json) {
    return MessageItem(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      content: json['content'],
      deviceId: json['device_id'],
      deviceName: json['device_name'],
      timestamp: json['timestamp'],
      isRead: json['is_read'] ?? false,
      priority: json['priority'],
      actionRequired: json['action_required'] ?? false,
      actionUrl: json['action_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'content': content,
      'device_id': deviceId,
      'device_name': deviceName,
      'timestamp': timestamp,
      'is_read': isRead,
      'priority': priority,
      'action_required': actionRequired,
      'action_url': actionUrl,
    };
  }

  // Get message type display name in English  // Changed from '获取消息类型的中文显示'
  String get typeDisplayName {
    switch (type) {
      case 'warning':
        return 'Warning';  // Changed from '警告'
      case 'info':
        return 'Info';  // Changed from '信息'
      case 'system':
        return 'System';  // Changed from '系统'
      default:
        return 'Unknown';  // Changed from '未知'
    }
  }

  // Get priority display name in English  // Changed from '获取优先级的中文显示'
  String get priorityDisplayName {
    switch (priority) {
      case 'high':
        return 'High';  // Changed from '高'
      case 'medium':
        return 'Medium';  // Changed from '中'
      case 'low':
        return 'Low';  // Changed from '低'
      default:
        return 'Normal';  // Changed from '普通'
    }
  }

  // Get message type icon
  IconData get typeIcon {
    switch (type) {
      case 'warning':
        return Icons.warning;
      case 'info':
        return Icons.info;
      case 'system':
        return Icons.settings;
      default:
        return Icons.message;
    }
  }

  // Format time display in English  // Changed from '格式化时间显示'
  String get formattedTime {
    if (timestamp == null) return '';
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp! * 1000);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';  // Changed from '天前'
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';  // Changed from '小时前'
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';  // Changed from '分钟前'
    } else {
      return 'Just now';  // Changed from '刚刚'
    }
  }
}