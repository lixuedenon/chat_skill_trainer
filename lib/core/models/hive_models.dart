// lib/core/models/hive_models.dart (最终修复版 - 解决Box API错误)

import 'package:hive_flutter/hive_flutter.dart';
import 'user_model.dart';
import 'conversation_model.dart';
import 'analysis_model.dart';
import 'companion_model.dart';

/// 🔥 Hive适配器注册和管理 - 修复版
///
/// 解决BinaryReader/BinaryWriter导入问题
/// 使用简化但兼容的适配器实现
class HiveModels {
  static bool _initialized = false;

  /// 初始化所有Hive适配器
  static Future<void> init() async {
    if (_initialized) return;

    try {
      print('🔄 初始化Hive适配器...');

      // 注册适配器（如果尚未注册）
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(UserModelAdapter());
      }

      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(UserStatsAdapter());
      }

      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(UserPreferencesAdapter());
      }

      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(ConversationModelAdapter());
      }

      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(MessageModelAdapter());
      }

      if (!Hive.isAdapterRegistered(5)) {
        Hive.registerAdapter(AnalysisReportAdapter());
      }

      if (!Hive.isAdapterRegistered(6)) {
        Hive.registerAdapter(KeyMomentAdapter());
      }

      if (!Hive.isAdapterRegistered(7)) {
        Hive.registerAdapter(CompanionModelAdapter());
      }

      if (!Hive.isAdapterRegistered(8)) {
        Hive.registerAdapter(MemoryFragmentAdapter());
      }

      _initialized = true;
      print('✅ Hive适配器初始化完成');
    } catch (e) {
      print('❌ Hive适配器初始化失败: $e');
      rethrow;
    }
  }

  /// 检查适配器是否已初始化
  static bool get isInitialized => _initialized;

  /// 获取所有已注册的适配器信息
  static Map<String, dynamic> getAdapterInfo() {
    return {
      'initialized': _initialized,
      'registeredAdapters': [
        if (Hive.isAdapterRegistered(0)) 'UserModel (0)',
        if (Hive.isAdapterRegistered(1)) 'UserStats (1)',
        if (Hive.isAdapterRegistered(2)) 'UserPreferences (2)',
        if (Hive.isAdapterRegistered(3)) 'ConversationModel (3)',
        if (Hive.isAdapterRegistered(4)) 'MessageModel (4)',
        if (Hive.isAdapterRegistered(5)) 'AnalysisReport (5)',
        if (Hive.isAdapterRegistered(6)) 'KeyMoment (6)',
        if (Hive.isAdapterRegistered(7)) 'CompanionModel (7)',
        if (Hive.isAdapterRegistered(8)) 'MemoryFragment (8)',
      ],
    };
  }
}

/// 🔥 用户模型适配器 - 简化实现
class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final json = Map<String, dynamic>.from(reader.readMap());
    return UserModel.fromJson(json);
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer.writeMap(obj.toJson());
  }
}

/// 🔥 用户统计适配器 - 简化实现
class UserStatsAdapter extends TypeAdapter<UserStats> {
  @override
  final int typeId = 1;

  @override
  UserStats read(BinaryReader reader) {
    final json = Map<String, dynamic>.from(reader.readMap());
    return UserStats.fromJson(json);
  }

  @override
  void write(BinaryWriter writer, UserStats obj) {
    writer.writeMap(obj.toJson());
  }
}

/// 🔥 用户偏好适配器 - 简化实现
class UserPreferencesAdapter extends TypeAdapter<UserPreferences> {
  @override
  final int typeId = 2;

  @override
  UserPreferences read(BinaryReader reader) {
    final json = Map<String, dynamic>.from(reader.readMap());
    return UserPreferences.fromJson(json);
  }

  @override
  void write(BinaryWriter writer, UserPreferences obj) {
    writer.writeMap(obj.toJson());
  }
}

/// 🔥 对话模型适配器 - 简化实现
class ConversationModelAdapter extends TypeAdapter<ConversationModel> {
  @override
  final int typeId = 3;

  @override
  ConversationModel read(BinaryReader reader) {
    final json = Map<String, dynamic>.from(reader.readMap());
    return ConversationModel.fromJson(json);
  }

  @override
  void write(BinaryWriter writer, ConversationModel obj) {
    writer.writeMap(obj.toJson());
  }
}

/// 🔥 消息模型适配器 - 简化实现
class MessageModelAdapter extends TypeAdapter<MessageModel> {
  @override
  final int typeId = 4;

  @override
  MessageModel read(BinaryReader reader) {
    final json = Map<String, dynamic>.from(reader.readMap());
    return MessageModel.fromJson(json);
  }

  @override
  void write(BinaryWriter writer, MessageModel obj) {
    writer.writeMap(obj.toJson());
  }
}

/// 🔥 分析报告适配器 - 简化实现
class AnalysisReportAdapter extends TypeAdapter<AnalysisReport> {
  @override
  final int typeId = 5;

  @override
  AnalysisReport read(BinaryReader reader) {
    final json = Map<String, dynamic>.from(reader.readMap());
    return AnalysisReport.fromJson(json);
  }

  @override
  void write(BinaryWriter writer, AnalysisReport obj) {
    writer.writeMap(obj.toJson());
  }
}

/// 🔥 关键时刻适配器 - 简化实现
class KeyMomentAdapter extends TypeAdapter<KeyMoment> {
  @override
  final int typeId = 6;

  @override
  KeyMoment read(BinaryReader reader) {
    final json = Map<String, dynamic>.from(reader.readMap());
    return KeyMoment.fromJson(json);
  }

  @override
  void write(BinaryWriter writer, KeyMoment obj) {
    writer.writeMap(obj.toJson());
  }
}

/// 🔥 AI伴侣模型适配器 - 简化实现
class CompanionModelAdapter extends TypeAdapter<CompanionModel> {
  @override
  final int typeId = 7;

  @override
  CompanionModel read(BinaryReader reader) {
    final json = Map<String, dynamic>.from(reader.readMap());
    return CompanionModel.fromJson(json);
  }

  @override
  void write(BinaryWriter writer, CompanionModel obj) {
    writer.writeMap(obj.toJson());
  }
}

/// 🔥 记忆片段适配器 - 简化实现
class MemoryFragmentAdapter extends TypeAdapter<MemoryFragment> {
  @override
  final int typeId = 8;

  @override
  MemoryFragment read(BinaryReader reader) {
    final json = Map<String, dynamic>.from(reader.readMap());
    return MemoryFragment.fromJson(json);
  }

  @override
  void write(BinaryWriter writer, MemoryFragment obj) {
    writer.writeMap(obj.toJson());
  }
}

/// 🔥 Hive数据迁移和维护工具
class HiveMaintenanceUtils {

  /// 执行数据完整性检查
  static Future<Map<String, dynamic>> performIntegrityCheck() async {
    final results = <String, dynamic>{};

    try {
      // 检查用户数据Box
      if (Hive.isBoxOpen('users')) {
        final usersBox = Hive.box<UserModel>('users');
        results['usersBox'] = {
          'isOpen': true,
          'length': usersBox.length,
          'keys': usersBox.keys.take(10).toList(), // 🔥 修复：使用 box.keys 而不是 Hive.box.keys
        };
      } else {
        results['usersBox'] = {'isOpen': false};
      }

      // 检查对话数据Box
      if (Hive.isBoxOpen('conversations')) {
        final conversationsBox = Hive.box<ConversationModel>('conversations');
        results['conversationsBox'] = {
          'isOpen': true,
          'length': conversationsBox.length,
          'keys': conversationsBox.keys.take(10).toList(), // 🔥 修复：使用正确的API
        };
      } else {
        results['conversationsBox'] = {'isOpen': false};
      }

      // 检查分析报告Box
      if (Hive.isBoxOpen('analysis_reports')) {
        final reportsBox = Hive.box<AnalysisReport>('analysis_reports');
        results['reportsBox'] = {
          'isOpen': true,
          'length': reportsBox.length,
          'keys': reportsBox.keys.take(10).toList(),
        };
      } else {
        results['reportsBox'] = {'isOpen': false};
      }

      // 检查AI伴侣Box
      if (Hive.isBoxOpen('companions')) {
        final companionsBox = Hive.box<CompanionModel>('companions');
        results['companionsBox'] = {
          'isOpen': true,
          'length': companionsBox.length,
          'keys': companionsBox.keys.toList(),
        };
      } else {
        results['companionsBox'] = {'isOpen': false};
      }

      // 检查通用数据Box
      if (Hive.isBoxOpen('app_data')) {
        final appDataBox = Hive.box('app_data');
        results['appDataBox'] = {
          'isOpen': true,
          'length': appDataBox.length,
          'keys': appDataBox.keys.take(20).toList(),
        };
      } else {
        results['appDataBox'] = {'isOpen': false};
      }

      results['overall'] = 'healthy';
      results['checkTime'] = DateTime.now().toIso8601String();

    } catch (e) {
      results['overall'] = 'error';
      results['error'] = e.toString();
    }

    return results;
  }

  /// 清理过期数据
  static Future<Map<String, dynamic>> cleanupExpiredData({
    Duration expiredDuration = const Duration(days: 90),
  }) async {
    final results = <String, dynamic>{};
    final cutoffDate = DateTime.now().subtract(expiredDuration);

    try {
      // 清理对话数据
      if (Hive.isBoxOpen('conversations')) {
        final conversationsBox = Hive.box<ConversationModel>('conversations');
        final keysToRemove = <dynamic>[];

        for (final key in conversationsBox.keys) { // 🔥 修复：使用正确的API
          final conversation = conversationsBox.get(key);
          if (conversation != null && conversation.createdAt.isBefore(cutoffDate)) {
            keysToRemove.add(key);
          }
        }

        await conversationsBox.deleteAll(keysToRemove);
        results['conversationsRemoved'] = keysToRemove.length;
      }

      // 清理分析报告
      if (Hive.isBoxOpen('analysis_reports')) {
        final reportsBox = Hive.box<AnalysisReport>('analysis_reports');
        final keysToRemove = <dynamic>[];

        for (final key in reportsBox.keys) {
          final report = reportsBox.get(key);
          if (report != null && report.createdAt.isBefore(cutoffDate)) {
            keysToRemove.add(key);
          }
        }

        await reportsBox.deleteAll(keysToRemove);
        results['reportsRemoved'] = keysToRemove.length;
      }

      // 清理AI伴侣数据
      if (Hive.isBoxOpen('companions')) {
        final companionsBox = Hive.box<CompanionModel>('companions');
        final keysToRemove = <dynamic>[];

        for (final key in companionsBox.keys) {
          final companion = companionsBox.get(key);
          if (companion != null && companion.createdAt.isBefore(cutoffDate)) {
            keysToRemove.add(key);
          }
        }

        await companionsBox.deleteAll(keysToRemove);
        results['companionsRemoved'] = keysToRemove.length;
      }

      results['status'] = 'success';
      results['cleanupTime'] = DateTime.now().toIso8601String();

    } catch (e) {
      results['status'] = 'error';
      results['error'] = e.toString();
    }

    return results;
  }

  /// 压缩和优化Hive数据库
  static Future<Map<String, dynamic>> compactDatabase() async {
    final results = <String, dynamic>{};

    try {
      final boxesToCompact = [
        'users',
        'conversations',
        'analysis_reports',
        'companions',
        'app_data'
      ];

      for (final boxName in boxesToCompact) {
        if (Hive.isBoxOpen(boxName)) {
          final box = Hive.box(boxName);
          await box.compact();
          results['${boxName}_compacted'] = true;
        } else {
          results['${boxName}_compacted'] = false;
        }
      }

      results['status'] = 'success';
      results['compactTime'] = DateTime.now().toIso8601String();

    } catch (e) {
      results['status'] = 'error';
      results['error'] = e.toString();
    }

    return results;
  }

  /// 备份所有Hive数据到Map
  static Future<Map<String, dynamic>> backupAllData() async {
    final backup = <String, dynamic>{};

    try {
      // 备份用户数据
      if (Hive.isBoxOpen('users')) {
        final usersBox = Hive.box<UserModel>('users');
        backup['users'] = <dynamic, dynamic>{};
        for (final key in usersBox.keys) {
          final user = usersBox.get(key);
          if (user != null) {
            backup['users'][key] = user.toJson();
          }
        }
      }

      // 备份对话数据
      if (Hive.isBoxOpen('conversations')) {
        final conversationsBox = Hive.box<ConversationModel>('conversations');
        backup['conversations'] = <dynamic, dynamic>{};
        for (final key in conversationsBox.keys) {
          final conversation = conversationsBox.get(key);
          if (conversation != null) {
            backup['conversations'][key] = conversation.toJson();
          }
        }
      }

      // 备份分析报告
      if (Hive.isBoxOpen('analysis_reports')) {
        final reportsBox = Hive.box<AnalysisReport>('analysis_reports');
        backup['analysis_reports'] = <dynamic, dynamic>{};
        for (final key in reportsBox.keys) {
          final report = reportsBox.get(key);
          if (report != null) {
            backup['analysis_reports'][key] = report.toJson();
          }
        }
      }

      // 备份AI伴侣数据
      if (Hive.isBoxOpen('companions')) {
        final companionsBox = Hive.box<CompanionModel>('companions');
        backup['companions'] = <dynamic, dynamic>{};
        for (final key in companionsBox.keys) {
          final companion = companionsBox.get(key);
          if (companion != null) {
            backup['companions'][key] = companion.toJson();
          }
        }
      }

      // 备份通用数据
      if (Hive.isBoxOpen('app_data')) {
        final appDataBox = Hive.box('app_data');
        backup['app_data'] = <dynamic, dynamic>{};
        for (final key in appDataBox.keys) {
          final value = appDataBox.get(key);
          if (value != null) {
            backup['app_data'][key] = value;
          }
        }
      }

      backup['backupTime'] = DateTime.now().toIso8601String();
      backup['version'] = '2.0.0';

    } catch (e) {
      backup['error'] = e.toString();
    }

    return backup;
  }

  /// 从备份数据恢复
  static Future<bool> restoreFromBackup(Map<String, dynamic> backup) async {
    try {
      // 恢复用户数据
      if (backup.containsKey('users') && backup['users'] is Map) {
        final usersBox = await Hive.openBox<UserModel>('users');
        final usersData = Map<String, dynamic>.from(backup['users']);

        for (final entry in usersData.entries) {
          final user = UserModel.fromJson(Map<String, dynamic>.from(entry.value));
          await usersBox.put(entry.key, user);
        }
      }

      // 恢复对话数据
      if (backup.containsKey('conversations') && backup['conversations'] is Map) {
        final conversationsBox = await Hive.openBox<ConversationModel>('conversations');
        final conversationsData = Map<String, dynamic>.from(backup['conversations']);

        for (final entry in conversationsData.entries) {
          final conversation = ConversationModel.fromJson(Map<String, dynamic>.from(entry.value));
          await conversationsBox.put(entry.key, conversation);
        }
      }

      // 恢复分析报告
      if (backup.containsKey('analysis_reports') && backup['analysis_reports'] is Map) {
        final reportsBox = await Hive.openBox<AnalysisReport>('analysis_reports');
        final reportsData = Map<String, dynamic>.from(backup['analysis_reports']);

        for (final entry in reportsData.entries) {
          final report = AnalysisReport.fromJson(Map<String, dynamic>.from(entry.value));
          await reportsBox.put(entry.key, report);
        }
      }

      // 恢复AI伴侣数据
      if (backup.containsKey('companions') && backup['companions'] is Map) {
        final companionsBox = await Hive.openBox<CompanionModel>('companions');
        final companionsData = Map<String, dynamic>.from(backup['companions']);

        for (final entry in companionsData.entries) {
          final companion = CompanionModel.fromJson(Map<String, dynamic>.from(entry.value));
          await companionsBox.put(entry.key, companion);
        }
      }

      // 恢复通用数据
      if (backup.containsKey('app_data') && backup['app_data'] is Map) {
        final appDataBox = await Hive.openBox('app_data');
        final appData = Map<String, dynamic>.from(backup['app_data']);

        for (final entry in appData.entries) {
          await appDataBox.put(entry.key, entry.value);
        }
      }

      print('✅ 数据恢复完成');
      return true;
    } catch (e) {
      print('❌ 数据恢复失败: $e');
      return false;
    }
  }

  /// 获取数据库统计信息
  static Future<Map<String, dynamic>> getDatabaseStats() async {
    final stats = <String, dynamic>{};

    try {
      final boxNames = ['users', 'conversations', 'analysis_reports', 'companions', 'app_data'];

      for (final boxName in boxNames) {
        if (Hive.isBoxOpen(boxName)) {
          final box = Hive.box(boxName);
          stats[boxName] = {
            'isOpen': true,
            'length': box.length,
            'isEmpty': box.isEmpty,
            'isNotEmpty': box.isNotEmpty,
            'keys': box.keys.length, // 🔥 修复：使用正确的API
          };
        } else {
          stats[boxName] = {
            'isOpen': false,
            'length': 0,
            'isEmpty': true,
            'isNotEmpty': false,
            'keys': 0,
          };
        }
      }

      // 计算总体统计
      final totalItems = stats.values
          .where((stat) => stat is Map && stat['isOpen'] == true)
          .map((stat) => stat['length'] as int)
          .fold(0, (sum, length) => sum + length);

      stats['summary'] = {
        'totalItems': totalItems,
        'openBoxes': stats.values.where((stat) => stat is Map && stat['isOpen'] == true).length,
        'totalBoxes': boxNames.length,
        'adaptersRegistered': HiveModels.isInitialized,
        'statsTime': DateTime.now().toIso8601String(),
      };

    } catch (e) {
      stats['error'] = e.toString();
    }

    return stats;
  }
}

/// 🔥 Hive异常处理和恢复工具
class HiveErrorHandler {

  /// 处理Hive相关异常
  static Future<Map<String, dynamic>> handleHiveError(Object error, StackTrace stackTrace) async {
    final errorInfo = <String, dynamic>{};

    try {
      errorInfo['errorType'] = error.runtimeType.toString();
      errorInfo['errorMessage'] = error.toString();
      errorInfo['timestamp'] = DateTime.now().toIso8601String();

      // 根据错误类型提供不同的处理建议
      if (error.toString().contains('type adapter')) {
        errorInfo['suggestion'] = '请检查TypeAdapter是否正确注册';
        errorInfo['action'] = 'registerAdapters';
      } else if (error.toString().contains('box')) {
        errorInfo['suggestion'] = '请检查Box是否正确打开';
        errorInfo['action'] = 'reopenBoxes';
      } else if (error.toString().contains('corrupted')) {
        errorInfo['suggestion'] = '数据库可能已损坏，建议重新初始化';
        errorInfo['action'] = 'reinitializeDatabase';
      } else {
        errorInfo['suggestion'] = '未知错误，建议查看完整日志';
        errorInfo['action'] = 'investigateError';
      }

      // 记录堆栈跟踪（简化版）
      final stackLines = stackTrace.toString().split('\n');
      errorInfo['stackTrace'] = stackLines.take(5).toList();

      // 尝试获取当前状态
      errorInfo['hiveStatus'] = await _getHiveStatus();

    } catch (e) {
      errorInfo['handlerError'] = e.toString();
    }

    return errorInfo;
  }

  /// 获取Hive当前状态
  static Future<Map<String, dynamic>> _getHiveStatus() async {
    try {
      // 🔥 修复：获取所有已打开的Box名称
      final openBoxNames = <String>[];
      final boxNames = ['users', 'conversations', 'analysis_reports', 'companions', 'app_data'];

      for (final name in boxNames) {
        if (Hive.isBoxOpen(name)) {
          openBoxNames.add(name);
        }
      }

      return {
        'adaptersInitialized': HiveModels.isInitialized,
        'adapterInfo': HiveModels.getAdapterInfo(),
        'openBoxes': openBoxNames,
      };
    } catch (e) {
      return {'statusError': e.toString()};
    }
  }

  /// 尝试修复常见的Hive问题
  static Future<bool> attemptRepair() async {
    try {
      print('🔄 尝试修复Hive问题...');

      // 重新初始化适配器
      await HiveModels.init();

      // 检查并重新打开必需的boxes
      final requiredBoxes = ['users', 'conversations', 'analysis_reports', 'companions', 'app_data'];

      for (final boxName in requiredBoxes) {
        if (!Hive.isBoxOpen(boxName)) {
          try {
            await Hive.openBox(boxName);
            print('✅ 重新打开Box: $boxName');
          } catch (e) {
            print('❌ 打开Box失败 [$boxName]: $e');
          }
        }
      }

      print('✅ Hive修复尝试完成');
      return true;
    } catch (e) {
      print('❌ Hive修复失败: $e');
      return false;
    }
  }
}