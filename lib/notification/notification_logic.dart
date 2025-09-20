import 'package:car_assistant/core/network/api_service.dart';
import 'package:car_assistant/core/utils/logger_util.dart';
import 'package:get/get.dart';
import 'notification_state.dart';

class NotificationLogic extends GetxController {
  final NotificationState state = NotificationState();

  @override
  void onInit() {
    super.onInit();
    fetchMessageList();
  }

  // Get message list  // Changed from '获取消息列表'
  Future<void> fetchMessageList({
    String? type,
    String? status,
    bool refresh = false,
  }) async {
    if (refresh) {
      state.currentPage = 1;
      state.messages.clear();
    }

    state.isLoading = true;
    update();

    try {
      final response = await ApiService.getMessageList(
        type: type ?? state.currentType,
        status: status ?? state.currentStatus,
        page: state.currentPage,
        pageSize: 20,
      );

      LoggerUtil.i('Message list response: $response');  // Changed from '消息列表响应'

      if (response.success && response.data != null) {
        final data = response.data!['data'];
        final messageList = (data['messages'] as List)
            .map((item) => MessageItem.fromJson(item))
            .toList();

        if (refresh) {
          state.messages = messageList;
        } else {
          state.messages.addAll(messageList);
        }

        state.total = data['total'] ?? 0;
        state.unreadCount = data['unread_count'] ?? 0;
        state.warningCount = data['warning_count'] ?? 0;
        state.infoCount = data['info_count'] ?? 0;
        state.systemCount = data['system_count'] ?? 0;

        if (type != null) state.currentType = type;
        if (status != null) state.currentStatus = status;
      } else {
        LoggerUtil.e('Failed to get message list: ${response.message}');  // Changed from '获取消息列表失败'
      }
    } catch (e) {
      LoggerUtil.e('Get message list exception: $e');  // Changed from '获取消息列表异常'
    } finally {
      state.isLoading = false;
      update();
    }
  }

  // Load more messages  // Changed from '加载更多消息'
  Future<void> loadMoreMessages() async {
    if (state.isLoading) return;
    
    state.currentPage++;
    await fetchMessageList();
  }

  // Mark message as read  // Changed from '标记消息为已读'
  Future<void> markAsRead(String messageId) async {
    try {
      final response = await ApiService.markMessageAsRead(messageId);
      if (response.success) {
        // Update local status  // Changed from '更新本地状态'
        final index = state.messages.indexWhere((msg) => msg.id == messageId);
        if (index != -1) {
          final message = state.messages[index];
          state.messages[index] = MessageItem(
            id: message.id,
            type: message.type,
            title: message.title,
            content: message.content,
            deviceId: message.deviceId,
            deviceName: message.deviceName,
            timestamp: message.timestamp,
            isRead: true,
            priority: message.priority,
            actionRequired: message.actionRequired,
            actionUrl: message.actionUrl,
          );
          state.unreadCount = (state.unreadCount - 1).clamp(0, state.total);
          update();
        }
      }
    } catch (e) {
      LoggerUtil.e('Mark message as read failed: $e');  // Changed from '标记消息已读失败'
    }
  }

  // Filter messages by type  // Changed from '按类型筛选消息'
  void filterByType(String type) {
    state.currentType = type;
    fetchMessageList(type: type, refresh: true);
  }

  // Filter messages by status  // Changed from '按状态筛选消息'
  void filterByStatus(String status) {
    state.currentStatus = status;
    fetchMessageList(status: status, refresh: true);
  }

  // Refresh message list  // Changed from '刷新消息列表'
  Future<void> refreshMessages() async {
    await fetchMessageList(refresh: true);
  }

  // Get warning type messages  // Changed from '获取警告类型的消息'
  List<MessageItem> get warningMessages {
    return state.messages.where((msg) => msg.type == 'warning').toList();
  }

  // Get info type messages  // Changed from '获取信息类型的消息'
  List<MessageItem> get infoMessages {
    return state.messages.where((msg) => msg.type == 'info').toList();
  }

  // Get system type messages  // Changed from '获取系统类型的消息'
  List<MessageItem> get systemMessages {
    return state.messages.where((msg) => msg.type == 'system').toList();
  }

  // Get unread messages  // Changed from '获取未读消息'
  List<MessageItem> get unreadMessages {
    return state.messages.where((msg) => msg.isRead == false).toList();
  }
}