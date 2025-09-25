// lib/shared/services/storage_service.dart (临时版本 - 先解决编译问题)

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/models/user_model.dart';
import '../../core/models/conversation_model.dart';
import '../../core/models/analysis_model.dart';
import '../../core/models/companion_model.dart';

/// 🔄 临时存储服务 - 先让项目运行起来，解决内存问题
class StorageService {
  static SharedPreferences? _prefs;

  // 存储键名常量
  static const String _currentUserKey = 'current_user';
  static const String _conversationsKey = 'conversations';
  static const String _analysisReportsKey = 'analysis_reports';
  static const String _companionsKey = 'companions';
  static const String _appThemeKey = 'app_theme';
  static const String _firstLaunchKey = 'first_launch';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    print('✅ 临时存储服务初始化完成');
  }

  static Future<void> _ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ========== 主题相关 ==========

  static Future<String> getAppTheme() async {
    await _ensureInitialized();
    return _prefs!.getString(_appThemeKey) ?? 'young';
  }

  static Future<bool> saveAppTheme(String themeType) async {
    await _ensureInitialized();
    return await _prefs!.setString(_appThemeKey, themeType);
  }

  // ========== 首次启动 ==========

  static Future<bool> isFirstLaunch() async {
    await _ensureInitialized();
    return _prefs!.getBool(_firstLaunchKey) ?? true;
  }

  static Future<bool> setNotFirstLaunch() async {
    await _ensureInitialized();
    return await _prefs!.setBool(_firstLaunchKey, false);
  }

  // ========== 用户相关 ==========

  static Future<UserModel?> getCurrentUser() async {
    await _ensureInitialized();
    final userJson = _prefs!.getString(_currentUserKey);
    if (userJson == null) return null;

    try {
      final userData = json.decode(userJson);
      return UserModel.fromJson(userData);
    } catch (e) {
      print('用户数据解析失败: $e');
      return null;
    }
  }

  static Future<bool> saveCurrentUser(UserModel user) async {
    await _ensureInitialized();
    try {
      final userJson = json.encode(user.toJson());
      return await _prefs!.setString(_currentUserKey, userJson);
    } catch (e) {
      print('保存用户数据失败: $e');
      return false;
    }
  }

  static Future<bool> updateCurrentUser(UserModel user) async {
    return await saveCurrentUser(user);
  }

  static Future<bool> clearCurrentUser() async {
    await _ensureInitialized();
    return await _prefs!.remove(_currentUserKey);
  }

  // ========== 🔥 简化的对话相关方法 - 减少内存占用 ==========

  static Future<List<ConversationModel>> getAllConversations() async {
    await _ensureInitialized();
    final conversationsJson = _prefs!.getString(_conversationsKey);
    if (conversationsJson == null) return [];

    try {
      final List<dynamic> conversationsList = json.decode(conversationsJson);
      return conversationsList
          .map((data) => ConversationModel.fromJson(data))
          .toList();
    } catch (e) {
      print('对话数据解析失败: $e');
      return [];
    }
  }

  static Future<List<ConversationModel>> getUserConversations(String userId) async {
    final allConversations = await getAllConversations();
    return allConversations.where((conv) => conv.userId == userId).toList();
  }

  // 🔥 优化：只保存必要的对话数据
  static Future<bool> saveConversation(ConversationModel conversation) async {
    try {
      final conversations = await getAllConversations();

      // 限制对话数量，防止数据过大
      const maxConversations = 50;

      final index = conversations.indexWhere((conv) => conv.id == conversation.id);
      if (index >= 0) {
        conversations[index] = conversation;
      } else {
        conversations.add(conversation);
        // 如果超过限制，删除最旧的对话
        if (conversations.length > maxConversations) {
          conversations.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          conversations.removeRange(0, conversations.length - maxConversations);
        }
      }

      await _ensureInitialized();
      final conversationsJson = json.encode(conversations.map((conv) => conv.toJson()).toList());
      return await _prefs!.setString(_conversationsKey, conversationsJson);
    } catch (e) {
      print('保存对话失败: $e');
      return false;
    }
  }

  static Future<ConversationModel?> getConversation(String conversationId) async {
    final conversations = await getAllConversations();
    try {
      return conversations.firstWhere((conv) => conv.id == conversationId);
    } catch (e) {
      return null;
    }
  }

  static Future<bool> deleteConversation(String conversationId) async {
    try {
      final conversations = await getAllConversations();
      conversations.removeWhere((conv) => conv.id == conversationId);

      await _ensureInitialized();
      final conversationsJson = json.encode(conversations.map((conv) => conv.toJson()).toList());
      return await _prefs!.setString(_conversationsKey, conversationsJson);
    } catch (e) {
      print('删除对话失败: $e');
      return false;
    }
  }

  // ========== 分析报告相关（简化） ==========

  static Future<List<AnalysisReport>> getAllAnalysisReports() async {
    await _ensureInitialized();
    final reportsJson = _prefs!.getString(_analysisReportsKey);
    if (reportsJson == null) return [];

    try {
      final List<dynamic> reportsList = json.decode(reportsJson);
      return reportsList
          .map((data) => AnalysisReport.fromJson(data))
          .toList();
    } catch (e) {
      print('分析报告解析失败: $e');
      return [];
    }
  }

  static Future<bool> saveAnalysisReport(AnalysisReport report) async {
    try {
      final reports = await getAllAnalysisReports();

      // 限制报告数量
      const maxReports = 30;

      final index = reports.indexWhere((r) => r.id == report.id);
      if (index >= 0) {
        reports[index] = report;
      } else {
        reports.add(report);
        if (reports.length > maxReports) {
          reports.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          reports.removeRange(0, reports.length - maxReports);
        }
      }

      await _ensureInitialized();
      final reportsJson = json.encode(reports.map((report) => report.toJson()).toList());
      return await _prefs!.setString(_analysisReportsKey, reportsJson);
    } catch (e) {
      print('保存分析报告失败: $e');
      return false;
    }
  }

  static Future<List<AnalysisReport>> getUserAnalysisReports(String userId) async {
    final allReports = await getAllAnalysisReports();
    return allReports.where((report) => report.userId == userId).toList();
  }

  static Future<AnalysisReport?> getAnalysisReport(String reportId) async {
    final reports = await getAllAnalysisReports();
    try {
      return reports.firstWhere((report) => report.id == reportId);
    } catch (e) {
      return null;
    }
  }

  static Future<AnalysisReport?> getAnalysisReportByConversation(String conversationId) async {
    final reports = await getAllAnalysisReports();
    try {
      return reports.firstWhere((report) => report.conversationId == conversationId);
    } catch (e) {
      return null;
    }
  }

  // ========== AI伴侣相关（简化） ==========

  static Future<List<CompanionModel>> getCompanions() async {
    await _ensureInitialized();
    final companionsJson = _prefs!.getString(_companionsKey);
    if (companionsJson == null) return [];

    try {
      final List<dynamic> companionsList = json.decode(companionsJson);
      return companionsList
          .map((data) => CompanionModel.fromJson(data))
          .toList();
    } catch (e) {
      print('伴侣数据解析失败: $e');
      return [];
    }
  }

  static Future<bool> saveCompanion(CompanionModel companion) async {
    try {
      final companions = await getCompanions();

      // 限制伴侣数量
      const maxCompanions = 10;

      final index = companions.indexWhere((comp) => comp.id == companion.id);
      if (index >= 0) {
        companions[index] = companion;
      } else {
        companions.add(companion);
        if (companions.length > maxCompanions) {
          companions.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          companions.removeRange(0, companions.length - maxCompanions);
        }
      }

      await _ensureInitialized();
      final companionsJson = json.encode(companions.map((comp) => comp.toJson()).toList());
      return await _prefs!.setString(_companionsKey, companionsJson);
    } catch (e) {
      print('保存伴侣失败: $e');
      return false;
    }
  }

  static Future<CompanionModel?> getCompanion(String companionId) async {
    final companions = await getCompanions();
    try {
      return companions.firstWhere((comp) => comp.id == companionId);
    } catch (e) {
      return null;
    }
  }

  // ========== 通用数据存储方法 ==========

  static Future<void> saveData(String key, dynamic data) async {
    await _ensureInitialized();
    final jsonStr = json.encode(data);
    await _prefs!.setString(key, jsonStr);
  }

  static Future<dynamic> getData(String key) async {
    await _ensureInitialized();
    final jsonStr = _prefs!.getString(key);
    if (jsonStr == null) return null;

    try {
      return json.decode(jsonStr);
    } catch (e) {
      return null;
    }
  }

  static Future<void> setString(String key, String value) async {
    await _ensureInitialized();
    await _prefs!.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    await _ensureInitialized();
    return _prefs!.getString(key);
  }

  // ========== 清理方法 ==========

  static Future<bool> clearAllData() async {
    await _ensureInitialized();
    return await _prefs!.clear();
  }
}