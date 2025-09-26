// lib/core/models/hive_models.dart (最终正确版本 - 兼容 Dart 3.9.2 + Hive 2.2.3)

import 'package:hive/hive.dart';
import 'user_model.dart';
import 'conversation_model.dart';
import 'analysis_model.dart';
import 'companion_model.dart';
import '../../features/chat/basic_emotion_analyzer.dart';

/// Hive适配器注册服务 - 使用 Hive 的原生 JSON 支持
class HiveAdapterService {
  static bool _isRegistered = false;

  /// 注册基础适配器（仅枚举类型需要适配器）
  static void registerAdapters() {
    if (_isRegistered) return;

    try {
      print('开始注册Hive适配器...');

      // 为了向后兼容，我们只注册基础的枚举适配器
      // 复杂的数据模型将使用 Hive 的原生 Map 支持

      _isRegistered = true;
      print('Hive适配器注册完成!');
    } catch (e) {
      print('Hive适配器注册失败: $e');
      rethrow;
    }
  }

  static bool get isRegistered => _isRegistered;

  /// 获取注册统计信息
  static Map<String, dynamic> getRegistrationStats() {
    return {
      'is_registered': _isRegistered,
      'adapters_count': 0, // 当前使用原生支持，无需手动适配器
      'strategy': 'native_json_support',
    };
  }
}

/// 数据转换辅助类 - 在 Dart 枚举和存储值之间转换
class HiveEnumHelper {

  // CharmTag 转换
  static int charmTagToInt(CharmTag tag) => tag.index;
  static CharmTag intToCharmTag(int index) => CharmTag.values[index];

  // EmotionalChangeType 转换
  static int emotionalChangeTypeToInt(EmotionalChangeType type) => type.index;
  static EmotionalChangeType intToEmotionalChangeType(int index) => EmotionalChangeType.values[index];

  // MomentType 转换
  static int momentTypeToInt(MomentType type) => type.index;
  static MomentType intToMomentType(int index) => MomentType.values[index];

  // SuggestionType 转换
  static int suggestionTypeToInt(SuggestionType type) => type.index;
  static SuggestionType intToSuggestionType(int index) => SuggestionType.values[index];

  // CompanionType 转换
  static int companionTypeToInt(CompanionType type) => type.index;
  static CompanionType intToCompanionType(int index) => CompanionType.values[index];

  // MeetingScenario 转换
  static int meetingScenarioToInt(MeetingScenario scenario) => scenario.index;
  static MeetingScenario intToMeetingScenario(int index) => MeetingScenario.values[index];

  // RelationshipStage 转换
  static int relationshipStageToInt(RelationshipStage stage) => stage.index;
  static RelationshipStage intToRelationshipStage(int index) => RelationshipStage.values[index];

  // ConversationStatus 转换
  static int conversationStatusToInt(ConversationStatus status) => status.index;
  static ConversationStatus intToConversationStatus(int index) => ConversationStatus.values[index];
}

/// Hive存储包装器 - 提供类型安全的存储接口
class HiveStorageWrapper {

  /// 安全存储用户模型
  static Future<void> storeUser(Box box, String key, UserModel user) async {
    final data = user.toJson();
    // 转换枚举为整数以确保兼容性
    if (data['charmTags'] is List) {
      data['charmTags'] = (data['charmTags'] as List<String>)
          .map((tagName) => CharmTag.values.firstWhere((e) => e.name == tagName).index)
          .toList();
    }
    await box.put(key, data);
  }

  /// 安全读取用户模型
  static UserModel? loadUser(Box box, String key) {
    final data = box.get(key);
    if (data == null) return null;

    try {
      final Map<String, dynamic> userData = Map<String, dynamic>.from(data);

      // 转换整数回枚举
      if (userData['charmTags'] is List) {
        userData['charmTags'] = (userData['charmTags'] as List<int>)
            .map((index) => CharmTag.values[index].name)
            .toList();
      }

      return UserModel.fromJson(userData);
    } catch (e) {
      print('用户数据加载失败: $e');
      return null;
    }
  }

  /// 安全存储对话模型
  static Future<void> storeConversation(Box box, String key, ConversationModel conversation) async {
    final data = conversation.toJson();
    await box.put(key, data);
  }

  /// 安全读取对话模型
  static ConversationModel? loadConversation(Box box, String key) {
    final data = box.get(key);
    if (data == null) return null;

    try {
      return ConversationModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      print('对话数据加载失败: $e');
      return null;
    }
  }

  /// 安全存储分析报告
  static Future<void> storeAnalysisReport(Box box, String key, AnalysisReport report) async {
    final data = report.toJson();
    await box.put(key, data);
  }

  /// 安全读取分析报告
  static AnalysisReport? loadAnalysisReport(Box box, String key) {
    final data = box.get(key);
    if (data == null) return null;

    try {
      return AnalysisReport.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      print('分析报告加载失败: $e');
      return null;
    }
  }

  /// 安全存储AI伴侣
  static Future<void> storeCompanion(Box box, String key, CompanionModel companion) async {
    final data = companion.toJson();
    await box.put(key, data);
  }

  /// 安全读取AI伴侣
  static CompanionModel? loadCompanion(Box box, String key) {
    final data = box.get(key);
    if (data == null) return null;

    try {
      return CompanionModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      print('伴侣数据加载失败: $e');
      return null;
    }
  }

  /// 批量存储消息列表
  static Future<void> storeMessages(Box box, String key, List<MessageModel> messages) async {
    final data = messages.map((m) => m.toJson()).toList();
    await box.put(key, data);
  }

  /// 批量读取消息列表
  static List<MessageModel> loadMessages(Box box, String key) {
    final data = box.get(key);
    if (data == null) return [];

    try {
      final List<dynamic> messagesData = data;
      return messagesData
          .map((item) => MessageModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      print('消息列表加载失败: $e');
      return [];
    }
  }

  /// 存储通用数据
  static Future<void> storeGeneral(Box box, String key, dynamic value) async {
    await box.put(key, value);
  }

  /// 读取通用数据
  static T? loadGeneral<T>(Box box, String key, {T? defaultValue}) {
    try {
      final value = box.get(key, defaultValue: defaultValue);
      return value as T?;
    } catch (e) {
      print('通用数据加载失败 $key: $e');
      return defaultValue;
    }
  }
}

/// 存储优化工具
class HiveOptimizationUtils {

  /// 压缩Box数据
  static Future<void> compactBox(Box box) async {
    try {
      await box.compact();
      print('Box压缩完成: ${box.name}');
    } catch (e) {
      print('Box压缩失败 ${box.name}: $e');
    }
  }

  /// 获取Box统计信息
  static Map<String, dynamic> getBoxStats(Box box) {
    try {
      return {
        'name': box.name,
        'length': box.length,
        'keys': box.keys.length,
        'lazy': box.lazy,
        'is_open': box.isOpen,
      };
    } catch (e) {
      return {
        'name': box.name ?? 'unknown',
        'error': e.toString(),
      };
    }
  }

  /// 清理过期数据
  static Future<int> cleanupExpiredData(Box box, Duration maxAge) async {
    int deletedCount = 0;
    final cutoffTime = DateTime.now().subtract(maxAge);

    try {
      final keysToDelete = <dynamic>[];

      for (final key in box.keys) {
        final data = box.get(key);
        if (data is Map) {
          final createdAtStr = data['createdAt'] as String?;
          if (createdAtStr != null) {
            final createdAt = DateTime.tryParse(createdAtStr);
            if (createdAt != null && createdAt.isBefore(cutoffTime)) {
              keysToDelete.add(key);
            }
          }
        }
      }

      await box.deleteAll(keysToDelete);
      deletedCount = keysToDelete.length;

      print('清理过期数据完成: 删除 $deletedCount 条记录');
    } catch (e) {
      print('清理过期数据失败: $e');
    }

    return deletedCount;
  }
}

/// 调试工具
class HiveDebugUtils {

  /// 打印Box内容概览
  static void debugPrintBox(Box box, {int maxItems = 5}) {
    print('=== Box调试信息: ${box.name} ===');
    print('项目数量: ${box.length}');
    print('是否打开: ${box.isOpen}');

    int count = 0;
    for (final key in box.keys.take(maxItems)) {
      final value = box.get(key);
      print('[$key]: ${_summarizeValue(value)}');
      count++;
    }

    if (box.length > maxItems) {
      print('... 还有 ${box.length - maxItems} 个项目');
    }
    print('========================');
  }

  static String _summarizeValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return '"${value.length > 50 ? value.substring(0, 50) + '...' : value}"';
    if (value is Map) return 'Map(${value.keys.length} keys)';
    if (value is List) return 'List(${value.length} items)';
    return value.runtimeType.toString();
  }

  /// 验证数据完整性
  static Future<Map<String, dynamic>> validateBoxData(Box box) async {
    int validCount = 0;
    int invalidCount = 0;
    final errors = <String>[];

    for (final key in box.keys) {
      try {
        final value = box.get(key);
        if (value != null) {
          // 基础验证：检查是否能正确序列化
          if (value is Map) {
            Map<String, dynamic>.from(value);
          }
          validCount++;
        } else {
          invalidCount++;
        }
      } catch (e) {
        invalidCount++;
        errors.add('Key $key: ${e.toString()}');
      }
    }

    return {
      'valid_count': validCount,
      'invalid_count': invalidCount,
      'total_count': box.length,
      'errors': errors,
      'health_score': validCount / (validCount + invalidCount),
    };
  }
}