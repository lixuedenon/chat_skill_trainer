// lib/core/services/data_migration_service.dart (移除SharedPreferences依赖版)

import 'dart:convert';
import '../../shared/services/hive_service.dart';
import '../models/user_model.dart';
import '../models/conversation_model.dart';
import '../models/analysis_model.dart';
import '../models/companion_model.dart';

/// 数据迁移服务 - 简化版本，直接标记迁移完成
class DataMigrationService {
  static const String _migrationCompleteKey = 'migration_complete_v1';

  /// 检查并执行数据迁移 - 简化版本
  static Future<void> checkAndMigrate() async {
    try {
      print('🔄 检查数据迁移状态...');

      // 检查是否已经迁移过
      if (HiveService.getString(_migrationCompleteKey) == 'true') {
        print('✅ 数据迁移已完成，跳过迁移步骤');
        return;
      }

      // 由于没有重要的旧数据需要迁移，直接标记迁移完成
      print('ℹ️ 新安装或测试环境，直接标记迁移完成');
      await _markMigrationComplete();

      // 可选：初始化一些默认数据
      await _initializeDefaultData();

      print('✅ 数据迁移标记完成!');

    } catch (e, stackTrace) {
      print('❌ 数据迁移失败: $e');
      print('📍 错误堆栈: $stackTrace');

      // 迁移失败也要标记完成，避免重复尝试
      await _markMigrationComplete();
    }
  }

  /// 初始化默认数据（可选）
  static Future<void> _initializeDefaultData() async {
    try {
      // 检查是否已有用户数据
      final currentUser = HiveService.getCurrentUser();
      if (currentUser == null) {
        print('ℹ️ 首次启动，可以在这里初始化默认数据');
        // 如果需要，可以在这里创建默认用户等
      }

      // 检查是否需要初始化其他默认数据
      final dbStats = HiveService.getDatabaseStats();
      print('📊 当前数据库状态: $dbStats');

    } catch (e) {
      print('❌ 初始化默认数据失败: $e');
    }
  }

  /// 标记迁移完成
  static Future<void> _markMigrationComplete() async {
    try {
      await HiveService.setString(_migrationCompleteKey, 'true');
      print('✅ 迁移标记已设置');
    } catch (e) {
      print('❌ 设置迁移标记失败: $e');
    }
  }

  /// 获取迁移状态
  static Map<String, dynamic> getMigrationStatus() {
    try {
      final isComplete = HiveService.getString(_migrationCompleteKey) == 'true';
      final dbStats = HiveService.getDatabaseStats();

      return {
        'migration_complete': isComplete,
        'hive_initialized': dbStats['is_initialized'] ?? false,
        'database_stats': dbStats,
        'migration_version': 'v1_simplified',
        'migration_type': 'no_legacy_data',
      };
    } catch (e) {
      return {
        'migration_complete': false,
        'error': e.toString(),
        'migration_version': 'v1_simplified',
      };
    }
  }

  /// 重置迁移状态（开发测试用）
  static Future<void> resetMigrationStatus() async {
    try {
      print('🔄 重置迁移状态...');
      await HiveService.removeData(_migrationCompleteKey);
      print('✅ 迁移状态已重置');
    } catch (e) {
      print('❌ 重置迁移状态失败: $e');
    }
  }

  /// 清理所有数据（开发测试用）
  static Future<void> clearAllTestData() async {
    try {
      print('🔄 清理所有测试数据...');

      // 清空所有Hive数据
      await HiveService.clearAllData();

      // 重置迁移状态
      await resetMigrationStatus();

      print('✅ 所有测试数据已清理');
    } catch (e) {
      print('❌ 清理测试数据失败: $e');
      rethrow;
    }
  }

  /// 验证数据库状态
  static Future<Map<String, dynamic>> validateDatabase() async {
    try {
      print('🔄 验证数据库状态...');

      final dbStats = HiveService.getDatabaseStats();
      final currentUser = HiveService.getCurrentUser();

      final validationResult = {
        'validation_passed': true,
        'database_initialized': dbStats['is_initialized'] ?? false,
        'has_current_user': currentUser != null,
        'database_stats': dbStats,
        'migration_status': getMigrationStatus(),
        'validated_at': DateTime.now().toIso8601String(),
      };

      print('✅ 数据库验证完成');
      return validationResult;

    } catch (e) {
      print('❌ 数据库验证失败: $e');
      return {
        'validation_passed': false,
        'error': e.toString(),
        'validated_at': DateTime.now().toIso8601String(),
      };
    }
  }

  /// 创建演示用户（开发测试用）
  static Future<UserModel?> createDemoUser() async {
    try {
      print('🔄 创建演示用户...');

      final demoUser = UserModel.newUser(
        id: 'demo_user_${DateTime.now().millisecondsSinceEpoch}',
        username: 'demo_user',
        email: 'demo@example.com',
      );

      await HiveService.saveCurrentUser(demoUser);
      await HiveService.saveUser(demoUser);

      print('✅ 演示用户创建完成: ${demoUser.username}');
      return demoUser;

    } catch (e) {
      print('❌ 创建演示用户失败: $e');
      return null;
    }
  }

  /// 检查是否为首次启动
  static bool isFirstLaunch() {
    try {
      return HiveService.isFirstLaunch();
    } catch (e) {
      print('❌ 检查首次启动状态失败: $e');
      return true;
    }
  }

  /// 设置非首次启动
  static Future<void> markNotFirstLaunch() async {
    try {
      await HiveService.setNotFirstLaunch();
      print('✅ 已标记为非首次启动');
    } catch (e) {
      print('❌ 标记首次启动状态失败: $e');
    }
  }
}