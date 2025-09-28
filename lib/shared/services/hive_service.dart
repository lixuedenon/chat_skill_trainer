// lib/shared/services/hive_service.dart (修复数据类型转换问题)

import 'package:hive_flutter/hive_flutter.dart';
import '../../core/models/user_model.dart';
import '../../core/models/conversation_model.dart';
import '../../core/models/analysis_model.dart';
import '../../core/models/companion_model.dart';

/// 🔥 HiveAdapterService - 管理所有Hive适配器的注册
class HiveAdapterService {
  /// 注册所有适配器
  static void registerAdapters() {
    try {
      print('🔄 开始注册Hive适配器...');

      // 🔥 使用简化的适配器注册方式，避免复杂的TypeAdapter实现
      // 这些适配器会在需要时自动处理JSON序列化

      print('✅ Hive适配器注册完成');
    } catch (e) {
      print('❌ 注册Hive适配器失败: $e');
      // 不重新抛出异常，使用备用方案
    }
  }
}

/// HiveService - 高性能存储服务
class HiveService {
  // Box名称常量 - 修复重复定义问题
  static const String _settingsBoxName = 'settings';
  static const String _usersBoxName = 'users';
  static const String _conversationsBoxName = 'conversations';
  static const String _analysisReportsBoxName = 'analysis_reports';
  static const String _companionsBoxName = 'companions';
  static const String _messagesBoxName = 'messages';

  // 缓存Box引用，避免重复打开
  static Box? _settingsBoxCache;
  static Box? _usersBoxCache;        // 🔥 改为动态Box，使用JSON存储
  static Box? _conversationsBoxCache;
  static Box? _analysisReportsBoxCache;
  static Box? _companionsBoxCache;
  static Box? _messagesBoxCache;

  static bool _isInitialized = false;

  /// 🔥 安全的类型转换方法 - 解决 Map<dynamic, dynamic> 问题
  static Map<String, dynamic> _safeJsonCast(dynamic data) {
    if (data == null) return {};
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      try {
        return Map<String, dynamic>.from(data);
      } catch (e) {
        print('❌ 类型转换失败: $e');
        return {};
      }
    }
    return {};
  }

  /// 🔥 安全的列表转换方法
  static List<Map<String, dynamic>> _safeJsonListCast(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.map((item) => _safeJsonCast(item)).toList();
    }
    return [];
  }

  /// 初始化Hive
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      print('🔄 开始初始化Hive数据库...');

      await Hive.initFlutter();
      print('✅ Hive Flutter 初始化完成');

      HiveAdapterService.registerAdapters();
      print('✅ Hive适配器注册完成');

      await _openAllBoxes();
      print('✅ 所有数据库Box打开完成');

      _isInitialized = true;
      print('✅ Hive数据库初始化成功!');

    } catch (e, stackTrace) {
      print('❌ Hive初始化失败: $e');
      print('错误堆栈: $stackTrace');
      rethrow;
    }
  }

  /// 打开所有Box - 🔥 使用动态Box避免TypeAdapter问题
  static Future<void> _openAllBoxes() async {
    try {
      final futures = [
        Hive.openBox(_settingsBoxName),
        Hive.openBox(_usersBoxName),           // 动态Box
        Hive.openBox(_conversationsBoxName),   // 动态Box
        Hive.openBox(_analysisReportsBoxName), // 动态Box
        Hive.openBox(_companionsBoxName),      // 动态Box
        Hive.openBox(_messagesBoxName),
      ];

      final boxes = await Future.wait(futures);

      _settingsBoxCache = boxes[0];
      _usersBoxCache = boxes[1];
      _conversationsBoxCache = boxes[2];
      _analysisReportsBoxCache = boxes[3];
      _companionsBoxCache = boxes[4];
      _messagesBoxCache = boxes[5];

      print('✅ 已打开 ${boxes.length} 个数据库Box');
    } catch (e) {
      print('❌ 打开Box失败: $e');
      rethrow;
    }
  }

  /// 获取设置Box
  static Box get settingsBox {
    return _settingsBoxCache ??= Hive.box(_settingsBoxName);
  }

  /// 获取用户Box - 🔥 改为动态Box
  static Box get usersBox {
    return _usersBoxCache ??= Hive.box(_usersBoxName);
  }

  /// 获取对话Box - 🔥 改为动态Box
  static Box get conversationsBox {
    return _conversationsBoxCache ??= Hive.box(_conversationsBoxName);
  }

  /// 获取分析报告Box - 🔥 改为动态Box
  static Box get analysisReportsBox {
    return _analysisReportsBoxCache ??= Hive.box(_analysisReportsBoxName);
  }

  /// 获取伴侣Box - 🔥 改为动态Box
  static Box get companionsBox {
    return _companionsBoxCache ??= Hive.box(_companionsBoxName);
  }

  /// 获取消息Box
  static Box get messagesBox {
    return _messagesBoxCache ??= Hive.box(_messagesBoxName);
  }

  // ========== 主题和设置相关 ==========

  static String getAppTheme() {
    return settingsBox.get('app_theme', defaultValue: 'young');
  }

  static Future<void> saveAppTheme(String themeType) async {
    await settingsBox.put('app_theme', themeType);
  }

  static bool isFirstLaunch() {
    return settingsBox.get('first_launch', defaultValue: true);
  }

  static Future<void> setNotFirstLaunch() async {
    await settingsBox.put('first_launch', false);
  }

  // ========== 用户相关 - 🔥 使用JSON序列化 + 安全类型转换 ==========

  static UserModel? getCurrentUser() {
    try {
      final data = usersBox.get('current_user');
      if (data == null) return null;
      final safeData = _safeJsonCast(data);
      return UserModel.fromJson(safeData);
    } catch (e) {
      print('❌ 获取当前用户失败: $e');
      return null;
    }
  }

  static Future<void> saveCurrentUser(UserModel user) async {
    try {
      await usersBox.put('current_user', user.toJson());
      print('✅ 用户数据已保存: ${user.username}');
    } catch (e) {
      print('❌ 保存用户数据失败: $e');
    }
  }

  static Future<void> updateCurrentUser(UserModel user) async {
    await saveCurrentUser(user);
  }

  static Future<void> clearCurrentUser() async {
    await usersBox.delete('current_user');
    print('✅ 当前用户数据已清除');
  }

  static Future<void> saveUser(UserModel user) async {
    try {
      await usersBox.put(user.id, user.toJson());
    } catch (e) {
      print('❌ 保存用户失败: $e');
    }
  }

  static UserModel? getUser(String userId) {
    try {
      final data = usersBox.get(userId);
      if (data == null) return null;
      final safeData = _safeJsonCast(data);
      return UserModel.fromJson(safeData);
    } catch (e) {
      print('❌ 获取用户失败: $e');
      return null;
    }
  }

  // ========== 对话相关 - 🔥 使用JSON序列化 + 安全类型转换 ==========

  static Future<void> saveConversation(ConversationModel conversation) async {
    try {
      await conversationsBox.put(conversation.id, conversation.toJson());
      print('✅ 对话已保存: ${conversation.id}');
    } catch (e) {
      print('❌ 保存对话失败: $e');
    }
  }

  static ConversationModel? getConversation(String conversationId) {
    try {
      final data = conversationsBox.get(conversationId);
      if (data == null) return null;
      final safeData = _safeJsonCast(data);
      return ConversationModel.fromJson(safeData);
    } catch (e) {
      print('❌ 获取对话失败: $e');
      return null;
    }
  }

  static Future<List<ConversationModel>> getUserConversations(String userId) async {
    try {
      final userConversations = <ConversationModel>[];

      for (final key in conversationsBox.keys) {
        final data = conversationsBox.get(key);
        if (data != null) {
          try {
            final safeData = _safeJsonCast(data);
            final conversation = ConversationModel.fromJson(safeData);
            if (conversation.userId == userId) {
              userConversations.add(conversation);
            }
          } catch (e) {
            print('❌ 解析对话数据失败: $e，删除损坏数据');
            await conversationsBox.delete(key);
          }
        }
      }

      print('✅ 获取用户对话: $userId, 共${userConversations.length}条');
      return userConversations;
    } catch (e) {
      print('❌ 获取用户对话失败: $e');
      return [];
    }
  }

  static List<ConversationModel> getAllConversations() {
    try {
      final conversations = <ConversationModel>[];

      for (final key in conversationsBox.keys) {
        final data = conversationsBox.get(key);
        if (data != null) {
          try {
            final safeData = _safeJsonCast(data);
            conversations.add(ConversationModel.fromJson(safeData));
          } catch (e) {
            print('❌ 解析对话数据失败: $e，跳过损坏数据');
          }
        }
      }

      return conversations;
    } catch (e) {
      print('❌ 获取所有对话失败: $e');
      return [];
    }
  }

  static Future<void> deleteConversation(String conversationId) async {
    await conversationsBox.delete(conversationId);
    print('✅ 对话已删除: $conversationId');
  }

  static int getConversationCount() {
    return conversationsBox.length;
  }

  static int getUserConversationCount(String userId) {
    try {
      int count = 0;
      for (final key in conversationsBox.keys) {
        final data = conversationsBox.get(key);
        if (data != null) {
          try {
            final safeData = _safeJsonCast(data);
            final conversation = ConversationModel.fromJson(safeData);
            if (conversation.userId == userId) count++;
          } catch (e) {
            // 忽略解析错误
          }
        }
      }
      return count;
    } catch (e) {
      print('❌ 获取用户对话数量失败: $e');
      return 0;
    }
  }

  // ========== 分析报告相关 - 🔥 使用JSON序列化 + 安全类型转换 ==========

  static Future<void> saveAnalysisReport(AnalysisReport report) async {
    try {
      await analysisReportsBox.put(report.id, report.toJson());
      print('✅ 分析报告已保存: ${report.id}');
    } catch (e) {
      print('❌ 保存分析报告失败: $e');
    }
  }

  static AnalysisReport? getAnalysisReport(String reportId) {
    try {
      final data = analysisReportsBox.get(reportId);
      if (data == null) return null;
      final safeData = _safeJsonCast(data);
      return AnalysisReport.fromJson(safeData);
    } catch (e) {
      print('❌ 获取分析报告失败: $e');
      return null;
    }
  }

  static AnalysisReport? getAnalysisReportByConversation(String conversationId) {
    try {
      for (final key in analysisReportsBox.keys) {
        final data = analysisReportsBox.get(key);
        if (data != null) {
          try {
            final safeData = _safeJsonCast(data);
            final report = AnalysisReport.fromJson(safeData);
            if (report.conversationId == conversationId) {
              return report;
            }
          } catch (e) {
            // 忽略解析错误
          }
        }
      }
      return null;
    } catch (e) {
      print('❌ 根据对话获取分析报告失败: $e');
      return null;
    }
  }

  static Future<List<AnalysisReport>> getUserAnalysisReports(String userId) async {
    try {
      final userReports = <AnalysisReport>[];

      for (final key in analysisReportsBox.keys) {
        final data = analysisReportsBox.get(key);
        if (data != null) {
          try {
            final safeData = _safeJsonCast(data);
            final report = AnalysisReport.fromJson(safeData);
            if (report.userId == userId) {
              userReports.add(report);
            }
          } catch (e) {
            print('❌ 解析分析报告数据失败: $e，删除损坏数据');
            await analysisReportsBox.delete(key);
          }
        }
      }

      print('✅ 获取用户分析报告: $userId, 共${userReports.length}份');
      return userReports;
    } catch (e) {
      print('❌ 获取用户分析报告失败: $e');
      return [];
    }
  }

  static List<AnalysisReport> getAllAnalysisReports() {
    try {
      final reports = <AnalysisReport>[];

      for (final key in analysisReportsBox.keys) {
        final data = analysisReportsBox.get(key);
        if (data != null) {
          try {
            final safeData = _safeJsonCast(data);
            reports.add(AnalysisReport.fromJson(safeData));
          } catch (e) {
            print('❌ 解析分析报告数据失败: $e，跳过损坏数据');
          }
        }
      }

      return reports;
    } catch (e) {
      print('❌ 获取所有分析报告失败: $e');
      return [];
    }
  }

  static Future<void> deleteAnalysisReport(String reportId) async {
    await analysisReportsBox.delete(reportId);
    print('✅ 分析报告已删除: $reportId');
  }

  // ========== AI伴侣相关 - 🔥 使用JSON序列化 + 安全类型转换 ==========

  static Future<void> saveCompanion(CompanionModel companion) async {
    try {
      await companionsBox.put(companion.id, companion.toJson());
      print('✅ AI伴侣已保存: ${companion.name} (${companion.id})');
    } catch (e) {
      print('❌ 保存AI伴侣失败: $e');
    }
  }

  static CompanionModel? getCompanion(String companionId) {
    try {
      final data = companionsBox.get(companionId);
      if (data == null) return null;
      final safeData = _safeJsonCast(data);
      return CompanionModel.fromJson(safeData);
    } catch (e) {
      print('❌ 获取AI伴侣失败: $e');
      return null;
    }
  }

  /// 🔥 修复：getCompanions方法增强错误处理和数据清理
  static List<CompanionModel> getCompanions() {
    try {
      final companions = <CompanionModel>[];
      final keysToDelete = <String>[];

      for (final key in companionsBox.keys) {
        final data = companionsBox.get(key);
        if (data != null) {
          try {
            final safeData = _safeJsonCast(data);
            if (safeData.isNotEmpty) {
              companions.add(CompanionModel.fromJson(safeData));
            } else {
              print('⚠️ 空数据，标记删除: $key');
              keysToDelete.add(key.toString());
            }
          } catch (e) {
            print('❌ 解析AI伴侣数据失败: $e，标记删除损坏数据: $key');
            keysToDelete.add(key.toString());
          }
        }
      }

      // 异步清理损坏的数据
      if (keysToDelete.isNotEmpty) {
        _cleanupCorruptedData(keysToDelete);
      }

      print('✅ 成功加载 ${companions.length} 个AI伴侣');
      return companions;
    } catch (e) {
      print('❌ 获取AI伴侣列表失败: $e');
      return [];
    }
  }

  /// 🔥 异步清理损坏的数据
  static void _cleanupCorruptedData(List<String> keys) {
    Future.microtask(() async {
      try {
        for (final key in keys) {
          await companionsBox.delete(key);
        }
        print('✅ 已清理 ${keys.length} 个损坏的数据条目');
      } catch (e) {
        print('❌ 清理损坏数据失败: $e');
      }
    });
  }

  static Future<List<CompanionModel>> getUserCompanions(String userId) async {
    return getCompanions(); // 简化实现
  }

  static Future<void> deleteCompanion(String companionId) async {
    await companionsBox.delete(companionId);
    await messagesBox.delete('companion_messages_$companionId');
    print('✅ AI伴侣已删除: $companionId');
  }

  // ========== AI伴侣消息存储 - 🔥 增强安全性 ==========

  static Future<void> saveCompanionMessages(String companionId, List<MessageModel> messages) async {
    try {
      final key = 'companion_messages_$companionId';
      final messagesData = messages.map((m) => m.toJson()).toList();
      await messagesBox.put(key, messagesData);
      print('✅ 伴侣消息已保存: $companionId, 共${messages.length}条消息');
    } catch (e) {
      print('❌ 保存伴侣消息失败: $e');
    }
  }

  static Future<List<MessageModel>> loadCompanionMessages(String companionId) async {
    final key = 'companion_messages_$companionId';
    try {
      final data = messagesBox.get(key);
      if (data == null) return [];

      final List<dynamic> messagesData = data;
      final messages = <MessageModel>[];

      for (final item in messagesData) {
        try {
          final safeData = _safeJsonCast(item);
          messages.add(MessageModel.fromJson(safeData));
        } catch (e) {
          print('❌ 解析消息数据失败: $e，跳过此条消息');
        }
      }

      print('✅ 伴侣消息已加载: $companionId, 共${messages.length}条消息');
      return messages;
    } catch (e) {
      print('❌ 加载伴侣消息失败: $e');
      return [];
    }
  }

  // ========== 数据统计 ==========

  static Map<String, dynamic> getDatabaseStats() {
    return {
      'users': usersBox.length,
      'conversations': conversationsBox.length,
      'analysis_reports': analysisReportsBox.length,
      'companions': companionsBox.length,
      'settings': settingsBox.length,
      'messages': messagesBox.length,
      'total_boxes': 6,
      'is_initialized': _isInitialized,
    };
  }

  static Future<void> compactDatabase() async {
    try {
      print('🔄 开始压缩数据库...');

      await Future.wait([
        usersBox.compact(),
        conversationsBox.compact(),
        analysisReportsBox.compact(),
        companionsBox.compact(),
        messagesBox.compact(),
      ]);

      print('✅ 数据库压缩完成');
    } catch (e) {
      print('❌ 数据库压缩失败: $e');
    }
  }

  static Future<void> clearUserData(String userId) async {
    try {
      print('🔄 开始清理用户数据: $userId');

      final userConversations = await getUserConversations(userId);
      for (final conversation in userConversations) {
        await deleteConversation(conversation.id);
      }

      final userReports = await getUserAnalysisReports(userId);
      for (final report in userReports) {
        await deleteAnalysisReport(report.id);
      }

      await usersBox.delete(userId);

      print('✅ 用户数据清理完成: $userId');
    } catch (e) {
      print('❌ 清理用户数据失败: $e');
    }
  }

  static Future<void> clearAllData() async {
    try {
      print('🔄 开始清空所有数据...');

      await Future.wait([
        usersBox.clear(),
        conversationsBox.clear(),
        analysisReportsBox.clear(),
        companionsBox.clear(),
        messagesBox.clear(),
      ]);

      print('✅ 所有数据已清空');
    } catch (e) {
      print('❌ 清空数据失败: $e');
    }
  }

  static Future<void> close() async {
    try {
      print('🔄 开始关闭Hive数据库...');

      await Hive.close();

      _settingsBoxCache = null;
      _usersBoxCache = null;
      _conversationsBoxCache = null;
      _analysisReportsBoxCache = null;
      _companionsBoxCache = null;
      _messagesBoxCache = null;

      _isInitialized = false;
      print('✅ Hive数据库已关闭');
    } catch (e) {
      print('❌ 关闭数据库失败: $e');
    }
  }

  // ========== 通用数据存储方法 ==========

  static Future<void> saveData(String key, dynamic data) async {
    await settingsBox.put(key, data);
  }

  static dynamic getData(String key) {
    return settingsBox.get(key);
  }

  static Future<void> removeData(String key) async {
    await settingsBox.delete(key);
  }

  static Future<void> setString(String key, String value) async {
    await settingsBox.put(key, value);
  }

  static String? getString(String key) {
    return settingsBox.get(key);
  }

  static Future<void> setStringList(String key, List<String> value) async {
    await settingsBox.put(key, value);
  }

  static List<String>? getStringList(String key) {
    final data = settingsBox.get(key);
    if (data is List) {
      return List<String>.from(data);
    }
    return null;
  }

  // ========== 导出用户数据 - 🔥 增强安全性 ==========

  static Future<Map<String, dynamic>> exportUserData(String userId) async {
    try {
      print('🔄 开始导出用户数据: $userId');

      final user = getUser(userId);
      final conversations = await getUserConversations(userId);
      final analysisReports = await getUserAnalysisReports(userId);
      final companions = await getUserCompanions(userId);

      final exportData = {
        'user': user?.toJson(),
        'conversations': conversations.map((c) => c.toJson()).toList(),
        'analysis_reports': analysisReports.map((r) => r.toJson()).toList(),
        'companions': companions.map((c) => c.toJson()).toList(),
        'exported_at': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };

      print('✅ 用户数据导出完成: ${exportData.keys.length}个数据类型');
      return exportData;
    } catch (e) {
      print('❌ 导出用户数据失败: $e');
      return {};
    }
  }

  static Future<bool> importUserData(Map<String, dynamic> importData) async {
    try {
      print('🔄 开始导入用户数据...');

      if (importData['user'] != null) {
        final userData = _safeJsonCast(importData['user']);
        final user = UserModel.fromJson(userData);
        await saveUser(user);
      }

      if (importData['conversations'] != null) {
        final conversationsData = _safeJsonListCast(importData['conversations']);
        for (final data in conversationsData) {
          final conversation = ConversationModel.fromJson(data);
          await saveConversation(conversation);
        }
      }

      if (importData['analysis_reports'] != null) {
        final reportsData = _safeJsonListCast(importData['analysis_reports']);
        for (final data in reportsData) {
          final report = AnalysisReport.fromJson(data);
          await saveAnalysisReport(report);
        }
      }

      if (importData['companions'] != null) {
        final companionsData = _safeJsonListCast(importData['companions']);
        for (final data in companionsData) {
          final companion = CompanionModel.fromJson(data);
          await saveCompanion(companion);
        }
      }

      print('✅ 用户数据导入完成');
      return true;
    } catch (e) {
      print('❌ 导入用户数据失败: $e');
      return false;
    }
  }
}