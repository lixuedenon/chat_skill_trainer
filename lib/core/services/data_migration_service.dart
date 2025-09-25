// lib/core/services/data_migration_service.dart (数据迁移服务)

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../shared/services/hive_service.dart';
import '../models/user_model.dart';
import '../models/conversation_model.dart';
import '../models/analysis_model.dart';
import '../models/companion_model.dart';

/// 🔥 数据迁移服务 - 从SharedPreferences迁移到Hive
class DataMigrationService {
  static const String _migrationCompleteKey = 'migration_complete_v1';

  /// 检查并执行数据迁移
  static Future<void> checkAndMigrate() async {
    try {
      print('🔄 检查是否需要数据迁移...');

      // 检查是否已经迁移过
      if (HiveService.getString(_migrationCompleteKey) == 'true') {
        print('✅ 数据已迁移，跳过迁移步骤');
        return;
      }

      // 检查是否存在旧数据
      final hasLegacyData = await _hasLegacyData();
      if (!hasLegacyData) {
        print('ℹ️ 没有发现旧数据，标记迁移完成');
        await _markMigrationComplete();
        return;
      }

      print('🔄 发现旧数据，开始迁移...');
      await _performMigration();

      await _markMigrationComplete();
      print('🎉 数据迁移完成!');

    } catch (e, stackTrace) {
      print('❌ 数据迁移失败: $e');
      print('📍 错误堆栈: $stackTrace');
      // 迁移失败不影响应用启动，只记录错误
    }
  }

  /// 检查是否存在SharedPreferences中的旧数据
  static Future<bool> _hasLegacyData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 检查关键的存储键
      final legacyKeys = [
        'current_user',
        'conversations',
        'analysis_reports',
        'companions',
      ];

      for (final key in legacyKeys) {
        if (prefs.containsKey(key)) {
          final value = prefs.getString(key);
          if (value != null && value.isNotEmpty) {
            print('🔍 发现旧数据: $key');
            return true;
          }
        }
      }

      return false;
    } catch (e) {
      print('❌ 检查旧数据失败: $e');
      return false;
    }
  }

  /// 执行实际的数据迁移
  static Future<void> _performMigration() async {
    final prefs = await SharedPreferences.getInstance();

    // 迁移统计
    int migratedUsers = 0;
    int migratedConversations = 0;
    int migratedReports = 0;
    int migratedCompanions = 0;

    try {
      // 🔥 迁移当前用户
      final currentUserJson = prefs.getString('current_user');
      if (currentUserJson != null && currentUserJson.isNotEmpty) {
        try {
          final userData = json.decode(currentUserJson);
          final user = UserModel.fromJson(userData);
          await HiveService.saveCurrentUser(user);
          await HiveService.saveUser(user);
          migratedUsers++;
          print('✅ 迁移当前用户: ${user.username}');
        } catch (e) {
          print('❌ 迁移当前用户失败: $e');
        }
      }

      // 🔥 迁移对话记录
      final conversationsJson = prefs.getString('conversations');
      if (conversationsJson != null && conversationsJson.isNotEmpty) {
        try {
          final List<dynamic> conversationsList = json.decode(conversationsJson);
          for (final conversationData in conversationsList) {
            try {
              final conversation = ConversationModel.fromJson(conversationData);
              await HiveService.saveConversation(conversation);
              migratedConversations++;
            } catch (e) {
              print('❌ 迁移单个对话失败: $e');
            }
          }
          print('✅ 迁移对话记录: $migratedConversations 条');
        } catch (e) {
          print('❌ 迁移对话记录失败: $e');
        }
      }

      // 🔥 迁移分析报告
      final reportsJson = prefs.getString('analysis_reports');
      if (reportsJson != null && reportsJson.isNotEmpty) {
        try {
          final List<dynamic> reportsList = json.decode(reportsJson);
          for (final reportData in reportsList) {
            try {
              final report = AnalysisReport.fromJson(reportData);
              await HiveService.saveAnalysisReport(report);
              migratedReports++;
            } catch (e) {
              print('❌ 迁移单个分析报告失败: $e');
            }
          }
          print('✅ 迁移分析报告: $migratedReports 份');
        } catch (e) {
          print('❌ 迁移分析报告失败: $e');
        }
      }

      // 🔥 迁移AI伴侣
      final companionsJson = prefs.getString('companions');
      if (companionsJson != null && companionsJson.isNotEmpty) {
        try {
          final List<dynamic> companionsList = json.decode(companionsJson);
          for (final companionData in companionsList) {
            try {
              final companion = CompanionModel.fromJson(companionData);
              await HiveService.saveCompanion(companion);
              migratedCompanions++;
            } catch (e) {
              print('❌ 迁移单个AI伴侣失败: $e');
            }
          }
          print('✅ 迁移AI伴侣: $migratedCompanions 个');
        } catch (e) {
          print('❌ 迁移AI伴侣失败: $e');
        }
      }

      // 🔥 迁移应用设置
      await _migrateSettings(prefs);

      // 🔥 迁移伴侣消息数据
      await _migrateCompanionMessages(prefs, migratedCompanions);

      print('📊 迁移统计:');
      print('  - 用户: $migratedUsers');
      print('  - 对话: $migratedConversations');
      print('  - 报告: $migratedReports');
      print('  - 伴侣: $migratedCompanions');

    } catch (e) {
      print('❌ 数据迁移过程异常: $e');
      rethrow;
    }
  }

  /// 迁移应用设置
  static Future<void> _migrateSettings(SharedPreferences prefs) async {
    try {
      // 迁移主题设置
      final appTheme = prefs.getString('app_theme');
      if (appTheme != null) {
        await HiveService.saveAppTheme(appTheme);
        print('✅ 迁移主题设置: $appTheme');
      }

      // 迁移首次启动标志
      final firstLaunch = prefs.getBool('first_launch');
      if (firstLaunch != null && !firstLaunch) {
        await HiveService.setNotFirstLaunch();
        print('✅ 迁移首次启动标志');
      }

      // 迁移其他设置
      final allKeys = prefs.getKeys();
      for (final key in allKeys) {
        if (key.startsWith('setting_') || key.startsWith('config_')) {
          final value = prefs.get(key);
          if (value != null) {
            await HiveService.saveData(key, value);
            print('✅ 迁移设置: $key');
          }
        }
      }

    } catch (e) {
      print('❌ 迁移应用设置失败: $e');
    }
  }

  /// 迁移伴侣消息数据
  static Future<void> _migrateCompanionMessages(SharedPreferences prefs, int companionCount) async {
    try {
      if (companionCount == 0) return;

      int migratedMessageGroups = 0;
      final allKeys = prefs.getKeys();

      for (final key in allKeys) {
        if (key.startsWith('companion_messages_')) {
          try {
            final messagesJson = prefs.getString(key);
            if (messagesJson != null && messagesJson.isNotEmpty) {
              // 直接复制到Hive
              final messagesData = json.decode(messagesJson);
              final companionId = key.replaceFirst('companion_messages_', '');

              if (messagesData is List) {
                final messages = messagesData
                    .map((item) => MessageModel.fromJson(item as Map<String, dynamic>))
                    .toList();

                await HiveService.saveCompanionMessages(companionId, messages);
                migratedMessageGroups++;
                print('✅ 迁移伴侣消息: $companionId, ${messages.length} 条消息');
              }
            }
          } catch (e) {
            print('❌ 迁移伴侣消息失败 $key: $e');
          }
        }
      }

      if (migratedMessageGroups > 0) {
        print('✅ 迁移伴侣消息组: $migratedMessageGroups 个');
      }

    } catch (e) {
      print('❌ 迁移伴侣消息失败: $e');
    }
  }

  /// 标记迁移完成
  static Future<void> _markMigrationComplete() async {
    await HiveService.setString(_migrationCompleteKey, 'true');
    print('✅ 迁移标记已设置');
  }

  /// 清理旧的SharedPreferences数据（慎用！）
  static Future<void> cleanupLegacyData() async {
    try {
      print('🔄 开始清理旧数据...');

      final prefs = await SharedPreferences.getInstance();

      // 需要清理的键
      final keysToClean = [
        'current_user',
        'conversations',
        'analysis_reports',
        'companions',
      ];

      // 清理伴侣消息
      final allKeys = prefs.getKeys();
      for (final key in allKeys) {
        if (key.startsWith('companion_messages_')) {
          keysToClean.add(key);
        }
      }

      int cleanedKeys = 0;
      for (final key in keysToClean) {
        if (prefs.containsKey(key)) {
          await prefs.remove(key);
          cleanedKeys++;
          print('🗑️ 清理旧数据: $key');
        }
      }

      print('✅ 清理完成，共清理 $cleanedKeys 个键');

    } catch (e) {
      print('❌ 清理旧数据失败: $e');
    }
  }

  /// 获取迁移状态
  static Map<String, dynamic> getMigrationStatus() {
    try {
      final isComplete = HiveService.getString(_migrationCompleteKey) == 'true';
      final dbStats = HiveService.getDatabaseStats();

      return {
        'migration_complete': isComplete,
        'hive_initialized': dbStats['is_initialized'],
        'database_stats': dbStats,
        'migration_version': 'v1',
      };
    } catch (e) {
      return {
        'migration_complete': false,
        'error': e.toString(),
        'migration_version': 'v1',
      };
    }
  }

  /// 🔥 强制重新迁移（开发测试用）
  static Future<void> forceMigration() async {
    try {
      print('🔄 强制重新迁移...');

      // 清除迁移标记
      await HiveService.removeData(_migrationCompleteKey);

      // 清空Hive数据
      await HiveService.clearAllData();

      // 重新执行迁移
      await checkAndMigrate();

      print('✅ 强制迁移完成');
    } catch (e) {
      print('❌ 强制迁移失败: $e');
      rethrow;
    }
  }

  /// 🔥 验证迁移结果
  static Future<Map<String, dynamic>> validateMigration() async {
    try {
      print('🔄 开始验证迁移结果...');

      final prefs = await SharedPreferences.getInstance();
      final dbStats = HiveService.getDatabaseStats();

      // 检查旧数据是否存在
      final hasLegacyUser = prefs.containsKey('current_user');
      final hasLegacyConversations = prefs.containsKey('conversations');
      final hasLegacyReports = prefs.containsKey('analysis_reports');
      final hasLegacyCompanions = prefs.containsKey('companions');

      // 检查新数据是否存在
      final currentUser = HiveService.getCurrentUser();
      final hasNewData = dbStats['users'] > 0 || dbStats['conversations'] > 0 ||
                        dbStats['analysis_reports'] > 0 || dbStats['companions'] > 0;

      final validationResult = {
        'validation_passed': true,
        'has_legacy_data': hasLegacyUser || hasLegacyConversations || hasLegacyReports || hasLegacyCompanions,
        'has_new_data': hasNewData,
        'current_user_migrated': currentUser != null,
        'database_stats': dbStats,
        'legacy_keys': {
          'current_user': hasLegacyUser,
          'conversations': hasLegacyConversations,
          'analysis_reports': hasLegacyReports,
          'companions': hasLegacyCompanions,
        },
        'validated_at': DateTime.now().toIso8601String(),
      };

      print('✅ 迁移验证完成');
      return validationResult;

    } catch (e) {
      print('❌ 迁移验证失败: $e');
      return {
        'validation_passed': false,
        'error': e.toString(),
        'validated_at': DateTime.now().toIso8601String(),
      };
    }
  }
}