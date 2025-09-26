// lib/shared/services/storage_service.dart (修复版 - 解决导入问题)

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// 🔥 修复导入问题 - 使用相对路径导入模型
import '../../core/models/user_model.dart';
import '../../core/models/conversation_model.dart';
import '../../core/models/analysis_model.dart';
import '../../core/models/companion_model.dart';

/// 🔄 临时存储服务 - 解决编译问题，逐步被HiveService替代
///
/// ⚠️ 注意：这个服务是过渡期使用，最终会被废弃
/// 新功能请使用 HiveService
class StorageService {
  static SharedPreferences? _prefs;

  // 存储键名常量
  static const String _currentUserKey = 'current_user';
  static const String _conversationsKey = 'conversations';
  static const String _analysisReportsKey = 'analysis_reports';
  static const String _companionsKey = 'companions';
  static const String _appThemeKey = 'app_theme';
  static const String _firstLaunchKey = 'first_launch';

  /// 初始化存储服务
  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      print('✅ 临时存储服务初始化完成');
    } catch (e) {
      print('❌ 存储服务初始化失败: $e');
      rethrow;
    }
  }

  /// 确保已初始化
  static Future<void> _ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ========== 主题相关 ==========

  /// 获取应用主题
  static Future<String> getAppTheme() async {
    try {
      await _ensureInitialized();
      return _prefs!.getString(_appThemeKey) ?? 'young';
    } catch (e) {
      print('❌ 获取主题失败: $e');
      return 'young';
    }
  }

  /// 保存应用主题
  static Future<bool> saveAppTheme(String themeType) async {
    try {
      await _ensureInitialized();
      return await _prefs!.setString(_appThemeKey, themeType);
    } catch (e) {
      print('❌ 保存主题失败: $e');
      return false;
    }
  }

  // ========== 首次启动 ==========

  /// 检查是否首次启动
  static Future<bool> isFirstLaunch() async {
    try {
      await _ensureInitialized();
      return _prefs!.getBool(_firstLaunchKey) ?? true;
    } catch (e) {
      print('❌ 检查首次启动失败: $e');
      return true;
    }
  }

  /// 设置非首次启动
  static Future<bool> setNotFirstLaunch() async {
    try {
      await _ensureInitialized();
      return await _prefs!.setBool(_firstLaunchKey, false);
    } catch (e) {
      print('❌ 设置首次启动标志失败: $e');
      return false;
    }
  }

  // ========== 用户相关 ==========

  /// 获取当前用户
  static Future<UserModel?> getCurrentUser() async {
    try {
      await _ensureInitialized();
      final userJson = _prefs!.getString(_currentUserKey);
      if (userJson == null) return null;

      final userData = json.decode(userJson);
      return UserModel.fromJson(userData);
    } catch (e) {
      print('❌ 获取当前用户失败: $e');
      return null;
    }
  }

  /// 保存当前用户
  static Future<bool> saveCurrentUser(UserModel user) async {
    try {
      await _ensureInitialized();
      final userJson = json.encode(user.toJson());
      final result = await _prefs!.setString(_currentUserKey, userJson);
      if (result) {
        print('✅ 保存用户成功: ${user.username}');
      }
      return result;
    } catch (e) {
      print('❌ 保存用户失败: $e');
      return false;
    }
  }

  /// 更新当前用户
  static Future<bool> updateCurrentUser(UserModel user) async {
    return await saveCurrentUser(user);
  }

  /// 清除当前用户
  static Future<bool> clearCurrentUser() async {
    try {
      await _ensureInitialized();
      return await _prefs!.remove(_currentUserKey);
    } catch (e) {
      print('❌ 清除用户失败: $e');
      return false;
    }
  }

  // ========== 对话相关方法 ==========

  /// 获取所有对话
  static Future<List<ConversationModel>> getAllConversations() async {
    try {
      await _ensureInitialized();
      final conversationsJson = _prefs!.getString(_conversationsKey);
      if (conversationsJson == null) return [];

      final List<dynamic> conversationsList = json.decode(conversationsJson);
      return conversationsList
          .map((data) => ConversationModel.fromJson(data))
          .toList();
    } catch (e) {
      print('❌ 获取对话列表失败: $e');
      return [];
    }
  }

  /// 获取用户对话
  static Future<List<ConversationModel>> getUserConversations(String userId) async {
    try {
      final allConversations = await getAllConversations();
      return allConversations.where((conv) => conv.userId == userId).toList();
    } catch (e) {
      print('❌ 获取用户对话失败: $e');
      return [];
    }
  }

  /// 保存对话
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
      print('❌ 保存对话失败: $e');
      return false;
    }
  }

  /// 获取指定对话
  static Future<ConversationModel?> getConversation(String conversationId) async {
    try {
      final conversations = await getAllConversations();
      return conversations.firstWhere((conv) => conv.id == conversationId);
    } catch (e) {
      print('❌ 获取指定对话失败: $e');
      return null;
    }
  }

  /// 删除对话
  static Future<bool> deleteConversation(String conversationId) async {
    try {
      final conversations = await getAllConversations();
      final originalLength = conversations.length;
      conversations.removeWhere((conv) => conv.id == conversationId);

      if (conversations.length != originalLength) {
        await _ensureInitialized();
        final conversationsJson = json.encode(conversations.map((conv) => conv.toJson()).toList());
        return await _prefs!.setString(_conversationsKey, conversationsJson);
      }
      return false;
    } catch (e) {
      print('❌ 删除对话失败: $e');
      return false;
    }
  }

  // ========== 分析报告相关 ==========

  /// 获取所有分析报告
  static Future<List<AnalysisReport>> getAllAnalysisReports() async {
    try {
      await _ensureInitialized();
      final reportsJson = _prefs!.getString(_analysisReportsKey);
      if (reportsJson == null) return [];

      final List<dynamic> reportsList = json.decode(reportsJson);
      return reportsList
          .map((data) => AnalysisReport.fromJson(data))
          .toList();
    } catch (e) {
      print('❌ 获取分析报告失败: $e');
      return [];
    }
  }

  /// 保存分析报告
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
      print('❌ 保存分析报告失败: $e');
      return false;
    }
  }

  /// 获取用户分析报告
  static Future<List<AnalysisReport>> getUserAnalysisReports(String userId) async {
    try {
      final allReports = await getAllAnalysisReports();
      return allReports.where((report) => report.userId == userId).toList();
    } catch (e) {
      print('❌ 获取用户分析报告失败: $e');
      return [];
    }
  }

  /// 获取指定分析报告
  static Future<AnalysisReport?> getAnalysisReport(String reportId) async {
    try {
      final reports = await getAllAnalysisReports();
      return reports.firstWhere((report) => report.id == reportId);
    } catch (e) {
      print('❌ 获取指定分析报告失败: $e');
      return null;
    }
  }

  /// 根据对话ID获取分析报告
  static Future<AnalysisReport?> getAnalysisReportByConversation(String conversationId) async {
    try {
      final reports = await getAllAnalysisReports();
      return reports.firstWhere((report) => report.conversationId == conversationId);
    } catch (e) {
      print('❌ 根据对话获取分析报告失败: $e');
      return null;
    }
  }

  // ========== AI伴侣相关 ==========

  /// 获取AI伴侣列表
  static Future<List<CompanionModel>> getCompanions() async {
    try {
      await _ensureInitialized();
      final companionsJson = _prefs!.getString(_companionsKey);
      if (companionsJson == null) return [];

      final List<dynamic> companionsList = json.decode(companionsJson);
      return companionsList
          .map((data) => CompanionModel.fromJson(data))
          .toList();
    } catch (e) {
      print('❌ 获取AI伴侣列表失败: $e');
      return [];
    }
  }

  /// 保存AI伴侣
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
      print('❌ 保存AI伴侣失败: $e');
      return false;
    }
  }

  /// 获取指定AI伴侣
  static Future<CompanionModel?> getCompanion(String companionId) async {
    try {
      final companions = await getCompanions();
      return companions.firstWhere((comp) => comp.id == companionId);
    } catch (e) {
      print('❌ 获取指定AI伴侣失败: $e');
      return null;
    }
  }

  /// 🔥 删除AI伴侣 - 添加缺失的方法
  static Future<bool> deleteCompanion(String companionId) async {
    try {
      final companions = await getCompanions();
      final originalLength = companions.length;
      companions.removeWhere((comp) => comp.id == companionId);

      if (companions.length != originalLength) {
        await _ensureInitialized();
        final companionsJson = json.encode(companions.map((comp) => comp.toJson()).toList());
        final result = await _prefs!.setString(_companionsKey, companionsJson);
        if (result) {
          print('✅ 删除伴侣成功: $companionId');
        }
        return result;
      } else {
        print('⚠️ 未找到要删除的伴侣: $companionId');
        return false;
      }
    } catch (e) {
      print('❌ 删除伴侣失败: $e');
      return false;
    }
  }

  // ========== 通用数据存储方法 ==========

  /// 保存任意数据
  static Future<void> saveData(String key, dynamic data) async {
    try {
      await _ensureInitialized();
      final jsonStr = json.encode(data);
      await _prefs!.setString(key, jsonStr);
      print('✅ 保存数据成功: $key');
    } catch (e) {
      print('❌ 保存数据失败 [$key]: $e');
      rethrow;
    }
  }

  /// 获取任意数据
  static dynamic getData(String key) {
    try {
      if (_prefs == null) {
        print('⚠️ 存储服务未初始化，返回null: $key');
        return null;
      }

      final jsonStr = _prefs!.getString(key);
      if (jsonStr == null) return null;

      return json.decode(jsonStr);
    } catch (e) {
      print('❌ 获取数据失败 [$key]: $e');
      return null;
    }
  }

  /// 异步获取任意数据
  static Future<dynamic> getDataAsync(String key) async {
    try {
      await _ensureInitialized();
      final jsonStr = _prefs!.getString(key);
      if (jsonStr == null) return null;

      return json.decode(jsonStr);
    } catch (e) {
      print('❌ 异步获取数据失败 [$key]: $e');
      return null;
    }
  }

  /// 保存字符串
  static Future<void> setString(String key, String value) async {
    try {
      await _ensureInitialized();
      await _prefs!.setString(key, value);
    } catch (e) {
      print('❌ 保存字符串失败 [$key]: $e');
      rethrow;
    }
  }

  /// 获取字符串
  static Future<String?> getString(String key) async {
    try {
      await _ensureInitialized();
      return _prefs!.getString(key);
    } catch (e) {
      print('❌ 获取字符串失败 [$key]: $e');
      return null;
    }
  }

  /// 保存字符串列表
  static Future<void> setStringList(String key, List<String> value) async {
    try {
      await _ensureInitialized();
      await _prefs!.setStringList(key, value);
    } catch (e) {
      print('❌ 保存字符串列表失败 [$key]: $e');
      rethrow;
    }
  }

  /// 获取字符串列表
  static Future<List<String>?> getStringList(String key) async {
    try {
      await _ensureInitialized();
      return _prefs!.getStringList(key);
    } catch (e) {
      print('❌ 获取字符串列表失败 [$key]: $e');
      return null;
    }
  }

  /// 保存布尔值
  static Future<void> setBool(String key, bool value) async {
    try {
      await _ensureInitialized();
      await _prefs!.setBool(key, value);
    } catch (e) {
      print('❌ 保存布尔值失败 [$key]: $e');
      rethrow;
    }
  }

  /// 获取布尔值
  static Future<bool> getBool(String key, {bool defaultValue = false}) async {
    try {
      await _ensureInitialized();
      return _prefs!.getBool(key) ?? defaultValue;
    } catch (e) {
      print('❌ 获取布尔值失败 [$key]: $e');
      return defaultValue;
    }
  }

  /// 保存整数
  static Future<void> setInt(String key, int value) async {
    try {
      await _ensureInitialized();
      await _prefs!.setInt(key, value);
    } catch (e) {
      print('❌ 保存整数失败 [$key]: $e');
      rethrow;
    }
  }

  /// 获取整数
  static Future<int> getInt(String key, {int defaultValue = 0}) async {
    try {
      await _ensureInitialized();
      return _prefs!.getInt(key) ?? defaultValue;
    } catch (e) {
      print('❌ 获取整数失败 [$key]: $e');
      return defaultValue;
    }
  }

  /// 保存双精度浮点数
  static Future<void> setDouble(String key, double value) async {
    try {
      await _ensureInitialized();
      await _prefs!.setDouble(key, value);
    } catch (e) {
      print('❌ 保存双精度浮点数失败 [$key]: $e');
      rethrow;
    }
  }

  /// 获取双精度浮点数
  static Future<double> getDouble(String key, {double defaultValue = 0.0}) async {
    try {
      await _ensureInitialized();
      return _prefs!.getDouble(key) ?? defaultValue;
    } catch (e) {
      print('❌ 获取双精度浮点数失败 [$key]: $e');
      return defaultValue;
    }
  }

  /// 删除指定键
  static Future<bool> remove(String key) async {
    try {
      await _ensureInitialized();
      return await _prefs!.remove(key);
    } catch (e) {
      print('❌ 删除键失败 [$key]: $e');
      return false;
    }
  }

  /// 检查键是否存在
  static Future<bool> containsKey(String key) async {
    try {
      await _ensureInitialized();
      return _prefs!.containsKey(key);
    } catch (e) {
      print('❌ 检查键存在性失败 [$key]: $e');
      return false;
    }
  }

  /// 获取所有键
  static Future<Set<String>> getKeys() async {
    try {
      await _ensureInitialized();
      return _prefs!.getKeys();
    } catch (e) {
      print('❌ 获取所有键失败: $e');
      return <String>{};
    }
  }

  // ========== 清理方法 ==========

  /// 清空所有数据
  static Future<bool> clearAllData() async {
    try {
      await _ensureInitialized();
      return await _prefs!.clear();
    } catch (e) {
      print('❌ 清空所有数据失败: $e');
      return false;
    }
  }

  /// 🔥 获取存储统计信息
  static Future<Map<String, dynamic>> getStorageStats() async {
    try {
      await _ensureInitialized();

      final conversations = await getAllConversations();
      final reports = await getAllAnalysisReports();
      final companions = await getCompanions();
      final user = await getCurrentUser();

      // 计算存储大小（近似值）
      final allKeys = await getKeys();
      int approximateSize = 0;
      for (final key in allKeys) {
        final value = _prefs!.getString(key);
        if (value != null) {
          approximateSize += value.length;
        }
      }

      return {
        'userExists': user != null,
        'conversationsCount': conversations.length,
        'reportsCount': reports.length,
        'companionsCount': companions.length,
        'totalKeys': allKeys.length,
        'approximateSize': approximateSize,
        'approximateSizeKB': (approximateSize / 1024).toStringAsFixed(2),
        'storageService': 'SharedPreferences (临时)',
        'migrationStatus': '等待迁移到HiveService',
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('❌ 获取存储统计失败: $e');
      return {'error': e.toString()};
    }
  }

  /// 🔥 数据健康检查
  static Future<Map<String, dynamic>> performHealthCheck() async {
    final results = <String, dynamic>{};

    try {
      await _ensureInitialized();
      results['initialization'] = 'success';

      // 检查用户数据
      try {
        final user = await getCurrentUser();
        results['userData'] = user != null ? 'valid' : 'empty';
      } catch (e) {
        results['userData'] = 'error: $e';
      }

      // 检查对话数据
      try {
        final conversations = await getAllConversations();
        results['conversationsData'] = 'valid (${conversations.length} items)';
      } catch (e) {
        results['conversationsData'] = 'error: $e';
      }

      // 检查分析报告数据
      try {
        final reports = await getAllAnalysisReports();
        results['reportsData'] = 'valid (${reports.length} items)';
      } catch (e) {
        results['reportsData'] = 'error: $e';
      }

      // 检查AI伴侣数据
      try {
        final companions = await getCompanions();
        results['companionsData'] = 'valid (${companions.length} items)';
      } catch (e) {
        results['companionsData'] = 'error: $e';
      }

      results['overall'] = 'healthy';
    } catch (e) {
      results['initialization'] = 'failed: $e';
      results['overall'] = 'unhealthy';
    }

    return results;
  }

  /// 🔥 备份数据到JSON
  static Future<Map<String, dynamic>> backupAllData() async {
    try {
      final backup = <String, dynamic>{};

      backup['user'] = (await getCurrentUser())?.toJson();
      backup['conversations'] = (await getAllConversations()).map((c) => c.toJson()).toList();
      backup['reports'] = (await getAllAnalysisReports()).map((r) => r.toJson()).toList();
      backup['companions'] = (await getCompanions()).map((c) => c.toJson()).toList();
      backup['theme'] = await getAppTheme();
      backup['firstLaunch'] = await isFirstLaunch();
      backup['backupTime'] = DateTime.now().toIso8601String();
      backup['version'] = '1.0.0';

      print('✅ 数据备份完成');
      return backup;
    } catch (e) {
      print('❌ 数据备份失败: $e');
      return {'error': e.toString()};
    }
  }

  /// 🔥 清理过期数据
  static Future<Map<String, dynamic>> cleanupExpiredData({
    int maxConversations = 50,
    int maxReports = 30,
    int maxCompanions = 10,
    Duration expiredDuration = const Duration(days: 90),
  }) async {
    try {
      final results = <String, dynamic>{};
      final cutoffDate = DateTime.now().subtract(expiredDuration);

      // 清理对话
      final conversations = await getAllConversations();
      final oldConversationCount = conversations.length;
      conversations.removeWhere((conv) => conv.createdAt.isBefore(cutoffDate));
      if (conversations.length > maxConversations) {
        conversations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        conversations.removeRange(maxConversations, conversations.length);
      }

      if (conversations.length != oldConversationCount) {
        await _ensureInitialized();
        final conversationsJson = json.encode(conversations.map((conv) => conv.toJson()).toList());
        await _prefs!.setString(_conversationsKey, conversationsJson);
      }
      results['conversationsRemoved'] = oldConversationCount - conversations.length;

      // 清理报告
      final reports = await getAllAnalysisReports();
      final oldReportCount = reports.length;
      reports.removeWhere((report) => report.createdAt.isBefore(cutoffDate));
      if (reports.length > maxReports) {
        reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        reports.removeRange(maxReports, reports.length);
      }

      if (reports.length != oldReportCount) {
        await _ensureInitialized();
        final reportsJson = json.encode(reports.map((report) => report.toJson()).toList());
        await _prefs!.setString(_analysisReportsKey, reportsJson);
      }
      results['reportsRemoved'] = oldReportCount - reports.length;

      // 清理伴侣
      final companions = await getCompanions();
      final oldCompanionCount = companions.length;
      companions.removeWhere((comp) => comp.createdAt.isBefore(cutoffDate));
      if (companions.length > maxCompanions) {
        companions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        companions.removeRange(maxCompanions, companions.length);
      }

      if (companions.length != oldCompanionCount) {
        await _ensureInitialized();
        final companionsJson = json.encode(companions.map((comp) => comp.toJson()).toList());
        await _prefs!.setString(_companionsKey, companionsJson);
      }
      results['companionsRemoved'] = oldCompanionCount - companions.length;

      results['status'] = 'success';
      results['cleanupTime'] = DateTime.now().toIso8601String();

      print('✅ 过期数据清理完成');
      return results;
    } catch (e) {
      print('❌ 清理过期数据失败: $e');
      return {'error': e.toString()};
    }
  }

  @override
  String toString() {
    return 'StorageService(initialized: ${_prefs != null})';
  }
}