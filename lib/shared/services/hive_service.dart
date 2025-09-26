// lib/shared/services/hive_service.dart (完整修复版 - 解决Box重复定义问题)

import 'package:hive_flutter/hive_flutter.dart';
import '../../core/models/user_model.dart';
import '../../core/models/conversation_model.dart';
import '../../core/models/analysis_model.dart';
import '../../core/models/companion_model.dart';
import '../../core/models/hive_models.dart';

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
  static Box<UserModel>? _usersBoxCache;
  static Box<ConversationModel>? _conversationsBoxCache;
  static Box<AnalysisReport>? _analysisReportsBoxCache;
  static Box<CompanionModel>? _companionsBoxCache;
  static Box? _messagesBoxCache;

  static bool _isInitialized = false;

  /// 初始化Hive
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      print('开始初始化Hive数据库...');

      await Hive.initFlutter();
      print('Hive Flutter 初始化完成');

      HiveAdapterService.registerAdapters();
      print('Hive适配器注册完成');

      await _openAllBoxes();
      print('所有数据库Box打开完成');

      _isInitialized = true;
      print('Hive数据库初始化成功!');

    } catch (e, stackTrace) {
      print('Hive初始化失败: $e');
      print('错误堆栈: $stackTrace');
      rethrow;
    }
  }

  /// 打开所有Box
  static Future<void> _openAllBoxes() async {
    try {
      final futures = [
        Hive.openBox(_settingsBoxName),
        Hive.openBox<UserModel>(_usersBoxName),
        Hive.openBox<ConversationModel>(_conversationsBoxName),
        Hive.openBox<AnalysisReport>(_analysisReportsBoxName),
        Hive.openBox<CompanionModel>(_companionsBoxName),
        Hive.openBox(_messagesBoxName),
      ];

      final boxes = await Future.wait(futures);

      _settingsBoxCache = boxes[0];
      _usersBoxCache = boxes[1] as Box<UserModel>;
      _conversationsBoxCache = boxes[2] as Box<ConversationModel>;
      _analysisReportsBoxCache = boxes[3] as Box<AnalysisReport>;
      _companionsBoxCache = boxes[4] as Box<CompanionModel>;
      _messagesBoxCache = boxes[5];

      print('已打开 ${boxes.length} 个数据库Box');
    } catch (e) {
      print('打开Box失败: $e');
      rethrow;
    }
  }

  /// 获取设置Box
  static Box get settingsBox {
    return _settingsBoxCache ??= Hive.box(_settingsBoxName);
  }

  /// 获取用户Box
  static Box<UserModel> get usersBox {
    return _usersBoxCache ??= Hive.box<UserModel>(_usersBoxName);
  }

  /// 获取对话Box
  static Box<ConversationModel> get conversationsBox {
    return _conversationsBoxCache ??= Hive.box<ConversationModel>(_conversationsBoxName);
  }

  /// 获取分析报告Box
  static Box<AnalysisReport> get analysisReportsBox {
    return _analysisReportsBoxCache ??= Hive.box<AnalysisReport>(_analysisReportsBoxName);
  }

  /// 获取伴侣Box
  static Box<CompanionModel> get companionsBox {
    return _companionsBoxCache ??= Hive.box<CompanionModel>(_companionsBoxName);
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

  // ========== 用户相关 ==========

  static UserModel? getCurrentUser() {
    return usersBox.get('current_user');
  }

  static Future<void> saveCurrentUser(UserModel user) async {
    await usersBox.put('current_user', user);
    print('用户数据已保存: ${user.username}');
  }

  static Future<void> updateCurrentUser(UserModel user) async {
    await saveCurrentUser(user);
  }

  static Future<void> clearCurrentUser() async {
    await usersBox.delete('current_user');
    print('当前用户数据已清除');
  }

  static Future<void> saveUser(UserModel user) async {
    await usersBox.put(user.id, user);
  }

  static UserModel? getUser(String userId) {
    return usersBox.get(userId);
  }

  // ========== 对话相关 ==========

  static Future<void> saveConversation(ConversationModel conversation) async {
    await conversationsBox.put(conversation.id, conversation);
    print('对话已保存: ${conversation.id}');
  }

  static ConversationModel? getConversation(String conversationId) {
    return conversationsBox.get(conversationId);
  }

  static Future<List<ConversationModel>> getUserConversations(String userId) async {
    try {
      final allConversations = conversationsBox.values;
      final userConversations = allConversations
          .where((conversation) => conversation.userId == userId)
          .toList();

      print('获取用户对话: $userId, 共${userConversations.length}条');
      return userConversations;
    } catch (e) {
      print('获取用户对话失败: $e');
      return [];
    }
  }

  static List<ConversationModel> getAllConversations() {
    return conversationsBox.values.toList();
  }

  static Future<void> deleteConversation(String conversationId) async {
    await conversationsBox.delete(conversationId);
    print('对话已删除: $conversationId');
  }

  static int getConversationCount() {
    return conversationsBox.length;
  }

  static int getUserConversationCount(String userId) {
    return conversationsBox.values
        .where((conversation) => conversation.userId == userId)
        .length;
  }

  // ========== 分析报告相关 ==========

  static Future<void> saveAnalysisReport(AnalysisReport report) async {
    await analysisReportsBox.put(report.id, report);
    print('分析报告已保存: ${report.id}');
  }

  static AnalysisReport? getAnalysisReport(String reportId) {
    return analysisReportsBox.get(reportId);
  }

  static AnalysisReport? getAnalysisReportByConversation(String conversationId) {
    try {
      return analysisReportsBox.values
          .firstWhere((report) => report.conversationId == conversationId);
    } catch (e) {
      return null;
    }
  }

  static Future<List<AnalysisReport>> getUserAnalysisReports(String userId) async {
    try {
      final userReports = analysisReportsBox.values
          .where((report) => report.userId == userId)
          .toList();

      print('获取用户分析报告: $userId, 共${userReports.length}份');
      return userReports;
    } catch (e) {
      print('获取用户分析报告失败: $e');
      return [];
    }
  }

  static List<AnalysisReport> getAllAnalysisReports() {
    return analysisReportsBox.values.toList();
  }

  static Future<void> deleteAnalysisReport(String reportId) async {
    await analysisReportsBox.delete(reportId);
    print('分析报告已删除: $reportId');
  }

  // ========== AI伴侣相关 ==========

  static Future<void> saveCompanion(CompanionModel companion) async {
    await companionsBox.put(companion.id, companion);
    print('AI伴侣已保存: ${companion.name} (${companion.id})');
  }

  static CompanionModel? getCompanion(String companionId) {
    return companionsBox.get(companionId);
  }

  static List<CompanionModel> getCompanions() {
    return companionsBox.values.toList();
  }

  static Future<List<CompanionModel>> getUserCompanions(String userId) async {
    return getCompanions();
  }

  static Future<void> deleteCompanion(String companionId) async {
    await companionsBox.delete(companionId);
    await messagesBox.delete('companion_messages_$companionId');
    print('AI伴侣已删除: $companionId');
  }

  // ========== AI伴侣消息存储 ==========

  static Future<void> saveCompanionMessages(String companionId, List<MessageModel> messages) async {
    final key = 'companion_messages_$companionId';
    final messagesData = messages.map((m) => m.toJson()).toList();
    await messagesBox.put(key, messagesData);
    print('伴侣消息已保存: $companionId, 共${messages.length}条消息');
  }

  static Future<List<MessageModel>> loadCompanionMessages(String companionId) async {
    final key = 'companion_messages_$companionId';
    try {
      final data = messagesBox.get(key);
      if (data == null) return [];

      final List<dynamic> messagesData = data;
      final messages = messagesData
          .map((item) => MessageModel.fromJson(item as Map<String, dynamic>))
          .toList();

      print('伴侣消息已加载: $companionId, 共${messages.length}条消息');
      return messages;
    } catch (e) {
      print('加载伴侣消息失败: $e');
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
      print('开始压缩数据库...');

      await Future.wait([
        usersBox.compact(),
        conversationsBox.compact(),
        analysisReportsBox.compact(),
        companionsBox.compact(),
        messagesBox.compact(),
      ]);

      print('数据库压缩完成');
    } catch (e) {
      print('数据库压缩失败: $e');
    }
  }

  static Future<void> clearUserData(String userId) async {
    try {
      print('开始清理用户数据: $userId');

      final userConversations = await getUserConversations(userId);
      for (final conversation in userConversations) {
        await deleteConversation(conversation.id);
      }

      final userReports = await getUserAnalysisReports(userId);
      for (final report in userReports) {
        await deleteAnalysisReport(report.id);
      }

      await usersBox.delete(userId);

      print('用户数据清理完成: $userId');
    } catch (e) {
      print('清理用户数据失败: $e');
    }
  }

  static Future<void> clearAllData() async {
    try {
      print('开始清空所有数据...');

      await Future.wait([
        usersBox.clear(),
        conversationsBox.clear(),
        analysisReportsBox.clear(),
        companionsBox.clear(),
        messagesBox.clear(),
      ]);

      print('所有数据已清空');
    } catch (e) {
      print('清空数据失败: $e');
    }
  }

  static Future<void> close() async {
    try {
      print('开始关闭Hive数据库...');

      await Hive.close();

      _settingsBoxCache = null;
      _usersBoxCache = null;
      _conversationsBoxCache = null;
      _analysisReportsBoxCache = null;
      _companionsBoxCache = null;
      _messagesBoxCache = null;

      _isInitialized = false;
      print('Hive数据库已关闭');
    } catch (e) {
      print('关闭数据库失败: $e');
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

  // ========== 导出用户数据 ==========

  static Future<Map<String, dynamic>> exportUserData(String userId) async {
    try {
      print('开始导出用户数据: $userId');

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

      print('用户数据导出完成: ${exportData.keys.length}个数据类型');
      return exportData;
    } catch (e) {
      print('导出用户数据失败: $e');
      return {};
    }
  }

  static Future<bool> importUserData(Map<String, dynamic> importData) async {
    try {
      print('开始导入用户数据...');

      if (importData['user'] != null) {
        final user = UserModel.fromJson(importData['user']);
        await saveUser(user);
      }

      if (importData['conversations'] != null) {
        final conversations = (importData['conversations'] as List)
            .map((data) => ConversationModel.fromJson(data))
            .toList();

        for (final conversation in conversations) {
          await saveConversation(conversation);
        }
      }

      if (importData['analysis_reports'] != null) {
        final reports = (importData['analysis_reports'] as List)
            .map((data) => AnalysisReport.fromJson(data))
            .toList();

        for (final report in reports) {
          await saveAnalysisReport(report);
        }
      }

      if (importData['companions'] != null) {
        final companions = (importData['companions'] as List)
            .map((data) => CompanionModel.fromJson(data))
            .toList();

        for (final companion in companions) {
          await saveCompanion(companion);
        }
      }

      print('用户数据导入完成');
      return true;
    } catch (e) {
      print('导入用户数据失败: $e');
      return false;
    }
  }
}