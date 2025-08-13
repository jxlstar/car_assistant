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

  // 获取消息类型的中文显示
  String get typeDisplayName {
    switch (type) {
      case 'warning':
        return '警告';
      case 'info':
        return '信息';
      case 'system':
        return '系统';
      default:
        return '未知';
    }
  }

  // 获取优先级的中文显示
  String get priorityDisplayName {
    switch (priority) {
      case 'high':
        return '高';
      case 'medium':
        return '中';
      case 'low':
        return '低';
      default:
        return '普通';
    }
  }

  // 获取消息类型图标
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

  // 格式化时间显示
  String get formattedTime {
    if (timestamp == null) return '';
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp! * 1000);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}