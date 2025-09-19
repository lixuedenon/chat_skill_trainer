// lib/shared/services/notification_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'storage_service.dart';

/// 通知服务
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _notificationsKey = 'app_notifications';
  static const String _settingsKey = 'notification_settings';

  List<AppNotification> _notifications = [];
  NotificationSettings _settings = const NotificationSettings();
  final List<VoidCallback> _listeners = [];

  /// 获取所有通知
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  /// 获取未读通知数量
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// 获取通知设置
  NotificationSettings get settings => _settings;

  /// 初始化通知服务
  static Future<void> init() async {
    await _instance._loadNotifications();
    await _instance._loadSettings();
  }

  /// 添加监听器
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// 移除监听器
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// 通知监听器
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  /// 显示通知
  Future<void> showNotification({
    required String title,
    required String content,
    NotificationType type = NotificationType.info,
    Map<String, dynamic>? data,
    Duration? expireAt,
  }) async {
    if (!_settings.enabled) return;

    // 检查类型是否启用
    if (!_isTypeEnabled(type)) return;

    final notification = AppNotification(
      id: 'notification_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      content: content,
      type: type,
      data: data ?? {},
      createdAt: DateTime.now(),
      expireAt: expireAt != null ? DateTime.now().add(expireAt) : null,
    );

    _notifications.insert(0, notification);

    // 限制通知数量
    if (_notifications.length > 100) {
      _notifications = _notifications.take(100).toList();
    }

    // 清理过期通知
    _cleanExpiredNotifications();

    await _saveNotifications();
    _notifyListeners();

    // 在开发模式下打印通知
    if (kDebugMode) {
      print('通知: $title - $content');
    }
  }

  /// 显示系统通知
  Future<void> showSystemNotification(String message) async {
    await showNotification(
      title: '系统消息',
      content: message,
      type: NotificationType.system,
    );
  }

  /// 显示成功通知
  Future<void> showSuccessNotification(String message) async {
    await showNotification(
      title: '操作成功',
      content: message,
      type: NotificationType.success,
    );
  }

  /// 显示错误通知
  Future<void> showErrorNotification(String message) async {
    await showNotification(
      title: '错误提示',
      content: message,
      type: NotificationType.error,
    );
  }

  /// 显示警告通知
  Future<void> showWarningNotification(String message) async {
    await showNotification(
      title: '警告',
      content: message,
      type: NotificationType.warning,
    );
  }

  /// 显示训练完成通知
  Future<void> showTrainingCompleteNotification({
    required String characterName,
    required int finalScore,
  }) async {
    await showNotification(
      title: '训练完成',
      content: '与$characterName的对话训练已完成，得分：$finalScore',
      type: NotificationType.training,
      data: {
        'characterName': characterName,
        'finalScore': finalScore,
      },
    );
  }

  /// 显示等级提升通知
  Future<void> showLevelUpNotification({
    required int newLevel,
    required String title,
  }) async {
    await showNotification(
      title: '等级提升！',
      content: '恭喜！你已升级到 Lv.$newLevel - $title',
      type: NotificationType.achievement,
      data: {
        'newLevel': newLevel,
        'title': title,
      },
    );
  }

  /// 显示AI伴侣相关通知
  Future<void> showCompanionNotification({
    required String companionName,
    required String message,
    CompanionNotificationType subType = CompanionNotificationType.general,
  }) async {
    String title;
    switch (subType) {
      case CompanionNotificationType.newMessage:
        title = '$companionName 发来消息';
        break;
      case CompanionNotificationType.stageChange:
        title = '关系进展';
        break;
      case CompanionNotificationType.farewell:
        title = '离别提醒';
        break;
      case CompanionNotificationType.general:
      default:
        title = companionName;
    }

    await showNotification(
      title: title,
      content: message,
      type: NotificationType.companion,
      data: {
        'companionName': companionName,
        'subType': subType.name,
      },
    );
  }

  /// 标记通知为已读
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index >= 0) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _saveNotifications();
      _notifyListeners();
    }
  }

  /// 标记所有通知为已读
  Future<void> markAllAsRead() async {
    bool hasChanges = false;
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        hasChanges = true;
      }
    }

    if (hasChanges) {
      await _saveNotifications();
      _notifyListeners();
    }
  }

  /// 删除通知
  Future<void> deleteNotification(String notificationId) async {
    final originalLength = _notifications.length;
    _notifications.removeWhere((n) => n.id == notificationId);

    if (_notifications.length != originalLength) {
      await _saveNotifications();
      _notifyListeners();
    }
  }

  /// 清空所有通知
  Future<void> clearAllNotifications() async {
    if (_notifications.isNotEmpty) {
      _notifications.clear();
      await _saveNotifications();
      _notifyListeners();
    }
  }

  /// 更新通知设置
  Future<void> updateSettings(NotificationSettings newSettings) async {
    _settings = newSettings;
    await _saveSettings();
    _notifyListeners();
  }

  /// 获取特定类型的通知
  List<AppNotification> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  /// 获取今天的通知
  List<AppNotification> getTodayNotifications() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    return _notifications.where((n) =>
      n.createdAt.isAfter(startOfDay) ||
      n.createdAt.isAtSameMomentAs(startOfDay)
    ).toList();
  }

  /// 检查是否有新的未读通知
  bool hasNewNotifications(DateTime since) {
    return _notifications.any((n) =>
      !n.isRead && n.createdAt.isAfter(since)
    );
  }

  /// 显示应用内通知横幅
  static void showInAppNotification(
    BuildContext context, {
    required String message,
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    final color = _getNotificationColor(type);
    final icon = _getNotificationIcon(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: onTap != null
            ? SnackBarAction(
                label: '查看',
                textColor: Colors.white,
                onPressed: onTap,
              )
            : null,
      ),
    );
  }

  // ============ 私有方法 ============

  Future<void> _loadNotifications() async {
    try {
      final data = await StorageService.getStringList(_notificationsKey);
      if (data != null) {
        _notifications = data
            .map((json) => AppNotification.fromJson(json))
            .toList();

        // 清理过期通知
        _cleanExpiredNotifications();
      }
    } catch (e) {
      if (kDebugMode) {
        print('加载通知失败: $e');
      }
      _notifications = [];
    }
  }

  Future<void> _saveNotifications() async {
    try {
      final data = _notifications.map((n) => n.toJson()).toList();
      await StorageService.setStringList(_notificationsKey, data);
    } catch (e) {
      if (kDebugMode) {
        print('保存通知失败: $e');
      }
    }
  }

  Future<void> _loadSettings() async {
    try {
      final data = await StorageService.getString(_settingsKey);
      if (data != null) {
        _settings = NotificationSettings.fromJson(data);
      }
    } catch (e) {
      if (kDebugMode) {
        print('加载通知设置失败: $e');
      }
      _settings = const NotificationSettings();
    }
  }

  Future<void> _saveSettings() async {
    try {
      await StorageService.setString(_settingsKey, _settings.toJson());
    } catch (e) {
      if (kDebugMode) {
        print('保存通知设置失败: $e');
      }
    }
  }

  void _cleanExpiredNotifications() {
    final now = DateTime.now();
    _notifications.removeWhere((n) =>
      n.expireAt != null && n.expireAt!.isBefore(now)
    );
  }

  bool _isTypeEnabled(NotificationType type) {
    switch (type) {
      case NotificationType.system:
        return _settings.enableSystem;
      case NotificationType.training:
        return _settings.enableTraining;
      case NotificationType.companion:
        return _settings.enableCompanion;
      case NotificationType.achievement:
        return _settings.enableAchievement;
      case NotificationType.reminder:
        return _settings.enableReminder;
      case NotificationType.success:
      case NotificationType.error:
      case NotificationType.warning:
      case NotificationType.info:
      default:
        return true; // 基础通知类型始终启用
    }
  }

  static Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Colors.green;
      case NotificationType.error:
        return Colors.red;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.achievement:
        return Colors.purple;
      case NotificationType.companion:
        return Colors.pink;
      case NotificationType.training:
        return Colors.blue;
      case NotificationType.system:
        return Colors.grey;
      case NotificationType.info:
      case NotificationType.reminder:
      default:
        return Colors.blue;
    }
  }

  static IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.achievement:
        return Icons.emoji_events;
      case NotificationType.companion:
        return Icons.favorite;
      case NotificationType.training:
        return Icons.school;
      case NotificationType.system:
        return Icons.settings;
      case NotificationType.reminder:
        return Icons.notifications;
      case NotificationType.info:
      default:
        return Icons.info;
    }
  }
}

/// 通知类型枚举
enum NotificationType {
  info,        // 信息
  success,     // 成功
  error,       // 错误
  warning,     // 警告
  system,      // 系统
  training,    // 训练相关
  companion,   // AI伴侣相关
  achievement, // 成就
  reminder,    // 提醒
}

/// AI伴侣通知子类型
enum CompanionNotificationType {
  general,     // 一般消息
  newMessage,  // 新消息
  stageChange, // 关系阶段变化
  farewell,    // 离别相关
}

/// 应用通知模型
class AppNotification {
  final String id;
  final String title;
  final String content;
  final NotificationType type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final DateTime? expireAt;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.data,
    required this.createdAt,
    this.expireAt,
    this.isRead = false,
  });

  /// 从JSON创建通知
  factory AppNotification.fromJson(String jsonStr) {
    final json = Map<String, dynamic>.from(
      // 这里应该解析JSON字符串，暂时简化处理
      {'id': '', 'title': '', 'content': '', 'type': 'info', 'data': {}, 'createdAt': DateTime.now().toIso8601String()},
    );

    return AppNotification(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.info,
      ),
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      expireAt: json['expireAt'] != null ? DateTime.parse(json['expireAt']) : null,
      isRead: json['isRead'] ?? false,
    );
  }

  /// 转换为JSON
  String toJson() {
    final json = {
      'id': id,
      'title': title,
      'content': content,
      'type': type.name,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'expireAt': expireAt?.toIso8601String(),
      'isRead': isRead,
    };
    // 这里应该序列化为JSON字符串，暂时简化处理
    return json.toString();
  }

  /// 复制通知并修改部分属性
  AppNotification copyWith({
    String? id,
    String? title,
    String? content,
    NotificationType? type,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    DateTime? expireAt,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      expireAt: expireAt ?? this.expireAt,
      isRead: isRead ?? this.isRead,
    );
  }

  /// 检查是否已过期
  bool get isExpired {
    return expireAt != null && DateTime.now().isAfter(expireAt!);
  }

  /// 获取相对时间字符串
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}天前';
    } else {
      return '${createdAt.month}/${createdAt.day}';
    }
  }
}

/// 通知设置模型
class NotificationSettings {
  final bool enabled;           // 总开关
  final bool enableSystem;      // 系统通知
  final bool enableTraining;    // 训练通知
  final bool enableCompanion;   // AI伴侣通知
  final bool enableAchievement; // 成就通知
  final bool enableReminder;    // 提醒通知
  final bool enableSound;       // 声音提醒
  final bool enableVibration;   // 震动提醒
  final String quietStartTime;  // 免打扰开始时间
  final String quietEndTime;    // 免打扰结束时间

  const NotificationSettings({
    this.enabled = true,
    this.enableSystem = true,
    this.enableTraining = true,
    this.enableCompanion = true,
    this.enableAchievement = true,
    this.enableReminder = true,
    this.enableSound = true,
    this.enableVibration = true,
    this.quietStartTime = '22:00',
    this.quietEndTime = '08:00',
  });

  /// 从JSON创建设置
  factory NotificationSettings.fromJson(String jsonStr) {
    // 这里应该解析JSON字符串，暂时简化处理
    return const NotificationSettings();
  }

  /// 转换为JSON
  String toJson() {
    final json = {
      'enabled': enabled,
      'enableSystem': enableSystem,
      'enableTraining': enableTraining,
      'enableCompanion': enableCompanion,
      'enableAchievement': enableAchievement,
      'enableReminder': enableReminder,
      'enableSound': enableSound,
      'enableVibration': enableVibration,
      'quietStartTime': quietStartTime,
      'quietEndTime': quietEndTime,
    };
    // 这里应该序列化为JSON字符串，暂时简化处理
    return json.toString();
  }

  /// 复制设置并修改部分属性
  NotificationSettings copyWith({
    bool? enabled,
    bool? enableSystem,
    bool? enableTraining,
    bool? enableCompanion,
    bool? enableAchievement,
    bool? enableReminder,
    bool? enableSound,
    bool? enableVibration,
    String? quietStartTime,
    String? quietEndTime,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      enableSystem: enableSystem ?? this.enableSystem,
      enableTraining: enableTraining ?? this.enableTraining,
      enableCompanion: enableCompanion ?? this.enableCompanion,
      enableAchievement: enableAchievement ?? this.enableAchievement,
      enableReminder: enableReminder ?? this.enableReminder,
      enableSound: enableSound ?? this.enableSound,
      enableVibration: enableVibration ?? this.enableVibration,
      quietStartTime: quietStartTime ?? this.quietStartTime,
      quietEndTime: quietEndTime ?? this.quietEndTime,
    );
  }

  /// 检查当前是否在免打扰时间
  bool get isInQuietTime {
    final now = TimeOfDay.now();
    final start = _parseTime(quietStartTime);
    final end = _parseTime(quietEndTime);

    if (start.hour < end.hour) {
      // 正常时间段
      return now.hour >= start.hour && now.hour < end.hour;
    } else {
      // 跨天时间段
      return now.hour >= start.hour || now.hour < end.hour;
    }
  }

  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}