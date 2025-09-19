// lib/shared/services/storage_service.dart (完整版)

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/models/user_model.dart';
import '../../core/models/conversation_model.dart';
import '../../core/models/analysis_model.dart';
import '../../core/models/companion_model.dart';

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
      return null;
    }
  }

  static Future<bool> saveCurrentUser(UserModel user) async {
    await _ensureInitialized();
    final userJson = json.encode(user.toJson());
    return await _prefs!.setString(_currentUserKey, userJson);
  }

  static Future<bool> updateCurrentUser(UserModel user) async {
    return await saveCurrentUser(user);
  }

  static Future<bool> clearCurrentUser() async {
    await _ensureInitialized();
    return await _prefs!.remove(_currentUserKey);
  }

  // ========== 对话相关 ==========

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
      return [];
    }
  }

  static Future<List<ConversationModel>> getUserConversations(String userId) async {
    final allConversations = await getAllConversations();
    return allConversations.where((conv) => conv.userId == userId).toList();
  }

  static Future<bool> saveConversation(ConversationModel conversation) async {
    final conversations = await getAllConversations();

    // 查找并更新已存在的对话，或添加新对话
    final index = conversations.indexWhere((conv) => conv.id == conversation.id);
    if (index >= 0) {
      conversations[index] = conversation;
    } else {
      conversations.add(conversation);
    }

    await _ensureInitialized();
    final conversationsJson = json.encode(conversations.map((conv) => conv.toJson()).toList());
    return await _prefs!.setString(_conversationsKey, conversationsJson);
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
    final conversations = await getAllConversations();
    conversations.removeWhere((conv) => conv.id == conversationId);

    await _ensureInitialized();
    final conversationsJson = json.encode(conversations.map((conv) => conv.toJson()).toList());
    return await _prefs!.setString(_conversationsKey, conversationsJson);
  }

  // ========== 分析报告相关 ==========

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
      return [];
    }
  }

  static Future<List<AnalysisReport>> getUserAnalysisReports(String userId) async {
    final allReports = await getAllAnalysisReports();
    return allReports.where((report) => report.userId == userId).toList();
  }

  static Future<bool> saveAnalysisReport(AnalysisReport report) async {
    final reports = await getAllAnalysisReports();

    // 查找并更新已存在的报告，或添加新报告
    final index = reports.indexWhere((r) => r.id == report.id);
    if (index >= 0) {
      reports[index] = report;
    } else {
      reports.add(report);
    }

    await _ensureInitialized();
    final reportsJson = json.encode(reports.map((report) => report.toJson()).toList());
    return await _prefs!.setString(_analysisReportsKey, reportsJson);
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

  static Future<bool> deleteAnalysisReport(String reportId) async {
    final reports = await getAllAnalysisReports();
    reports.removeWhere((report) => report.id == reportId);

    await _ensureInitialized();
    final reportsJson = json.encode(reports.map((report) => report.toJson()).toList());
    return await _prefs!.setString(_analysisReportsKey, reportsJson);
  }

  // ========== AI伴侣相关 ==========

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
      return [];
    }
  }

  static Future<List<CompanionModel>> getUserCompanions(String userId) async {
    final allCompanions = await getCompanions();
    // 简化版本：返回所有伴侣（实际应用中可能需要根据用户ID过滤）
    return allCompanions;
  }

  static Future<bool> saveCompanion(CompanionModel companion) async {
    final companions = await getCompanions();

    // 查找并更新已存在的伴侣，或添加新伴侣
    final index = companions.indexWhere((comp) => comp.id == companion.id);
    if (index >= 0) {
      companions[index] = companion;
    } else {
      companions.add(companion);
    }

    await _ensureInitialized();
    final companionsJson = json.encode(companions.map((comp) => comp.toJson()).toList());
    return await _prefs!.setString(_companionsKey, companionsJson);
  }

  static Future<CompanionModel?> getCompanion(String companionId) async {
    final companions = await getCompanions();
    try {
      return companions.firstWhere((comp) => comp.id == companionId);
    } catch (e) {
      return null;
    }
  }

  static Future<bool> deleteCompanion(String companionId) async {
    final companions = await getCompanions();
    companions.removeWhere((comp) => comp.id == companionId);

    await _ensureInitialized();
    final companionsJson = json.encode(companions.map((comp) => comp.toJson()).toList());
    return await _prefs!.setString(_companionsKey, companionsJson);
  }

  // ========== 通用数据存储方法（用于伴侣记忆服务等） ==========

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

  static Future<bool> remove(String key) async {
    await _ensureInitialized();
    return await _prefs!.remove(key);
  }

  static Future<void> setString(String key, String value) async {
    await _ensureInitialized();
    await _prefs!.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    await _ensureInitialized();
    return _prefs!.getString(key);
  }

  static Future<void> setStringList(String key, List<String> value) async {
    await _ensureInitialized();
    await _prefs!.setStringList(key, value);
  }

  static Future<List<String>?> getStringList(String key) async {
    await _ensureInitialized();
    return _prefs!.getStringList(key);
  }

  // ========== 清理方法 ==========

  static Future<bool> clearAllData() async {
    await _ensureInitialized();
    return await _prefs!.clear();
  }

  static Future<bool> clearUserData(String userId) async {
    // 清理指定用户的所有数据
    final conversations = await getAllConversations();
    final reports = await getAllAnalysisReports();

    // 过滤掉该用户的数据
    final filteredConversations = conversations.where((conv) => conv.userId != userId).toList();
    final filteredReports = reports.where((report) => report.userId != userId).toList();

    await _ensureInitialized();

    // 保存过滤后的数据
    final conversationsJson = json.encode(filteredConversations.map((conv) => conv.toJson()).toList());
    final reportsJson = json.encode(filteredReports.map((report) => report.toJson()).toList());

    final success1 = await _prefs!.setString(_conversationsKey, conversationsJson);
    final success2 = await _prefs!.setString(_analysisReportsKey, reportsJson);

    return success1 && success2;
  }
}