// lib/features/home/home_controller.dart (修复版 - 迁移到HiveService + 调整模块解锁条件)

import 'package:flutter/foundation.dart';
import '../../core/models/user_model.dart';
import '../../shared/services/hive_service.dart';  // 🔥 替代 StorageService

/// 主页控制器 - 管理模块化主页的状态
class HomeController extends ChangeNotifier {
  UserModel? _currentUser;
  List<TrainingModule> _modules = [];
  bool _isLoading = false;
  bool _disposed = false;  // 🔥 添加销毁标志

  // Getters
  UserModel? get currentUser => _currentUser;
  List<TrainingModule> get modules => _modules;
  List<TrainingModule> get availableModules =>
      _modules.where((module) => module.isUnlocked).toList();
  bool get isLoading => _isLoading;

  /// 初始化主页数据
  Future<void> initialize() async {
    if (_disposed) return;

    _isLoading = true;
    _safeNotifyListeners();

    try {
      print('🔄 初始化主页数据...');

      // 🔥 使用HiveService加载用户数据
      _currentUser = HiveService.getCurrentUser();
      print('✅ 用户数据加载完成: ${_currentUser?.username ?? '未登录'}');

      // 初始化训练模块
      _initializeModules();
      print('✅ 训练模块初始化完成，共${_modules.length}个模块');

    } catch (e) {
      print('❌ 初始化主页失败: $e');
      if (kDebugMode) {
        print('初始化主页失败: $e');
      }
    } finally {
      if (!_disposed) {
        _isLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  /// 更新用户信息
  void updateUser(UserModel user) {
    if (_disposed) return;

    print('🔄 更新用户信息: ${user.username}');
    _currentUser = user;
    _initializeModules(); // 重新初始化模块（检查解锁状态）
    _safeNotifyListeners();
    print('✅ 用户信息更新完成');
  }

  /// 导航到指定模块
  Future<void> navigateToModule(String moduleId) async {
    if (_disposed) return;

    try {
      final module = _modules.firstWhere(
        (m) => m.id == moduleId,
        orElse: () => throw Exception('模块未找到: $moduleId'),
      );

      if (!module.isUnlocked) {
        throw Exception('模块未解锁: ${module.name}');
      }

      print('🔄 导航到模块: ${module.name}');
      // 具体的导航逻辑将在各模块实现
      await module.launch();
      print('✅ 模块启动成功: ${module.name}');

    } catch (e) {
      print('❌ 导航到模块失败: $e');
      rethrow;
    }
  }

  /// 🔥 获取模块统计信息
  Future<Map<String, dynamic>> getModuleStats() async {
    if (_disposed) return {};

    try {
      final totalModules = _modules.length;
      final unlockedModules = availableModules.length;
      final completionRate = totalModules > 0 ? unlockedModules / totalModules : 0.0;

      // 按类别分组
      final modulesByCategory = <String, List<TrainingModule>>{};
      for (final module in _modules) {
        final category = module.category;
        if (!modulesByCategory.containsKey(category)) {
          modulesByCategory[category] = [];
        }
        modulesByCategory[category]!.add(module);
      }

      return {
        'totalModules': totalModules,
        'unlockedModules': unlockedModules,
        'lockedModules': totalModules - unlockedModules,
        'completionRate': completionRate,
        'modulesByCategory': modulesByCategory.map(
          (key, value) => MapEntry(key, {
            'total': value.length,
            'unlocked': value.where((m) => m.isUnlocked).length,
          })
        ),
        'recommendedModules': _getRecommendedModules().map((m) => m.id).toList(),
      };
    } catch (e) {
      print('❌ 获取模块统计失败: $e');
      return {};
    }
  }

  /// 🔥 获取推荐模块
  List<TrainingModule> _getRecommendedModules() {
    if (_currentUser == null) return [];

    final recommended = <TrainingModule>[];
    final userLevel = _currentUser!.userLevel.level;
    final credits = _currentUser!.credits;

    // 基于用户等级推荐
    if (userLevel <= 2) {
      // 新手推荐
      recommended.addAll(_modules.where((m) =>
        m.id == 'basic_chat' || m.id == 'anti_pua'
      ));
    } else if (userLevel <= 5) {
      // 进阶推荐
      recommended.addAll(_modules.where((m) =>
        m.id == 'ai_companion' || m.id == 'batch_chat_analyzer'
      ));
    } else {
      // 高级推荐
      recommended.addAll(_modules.where((m) =>
        m.id == 'real_chat_assistant' || m.id == 'confession_predictor'
      ));
    }

    // 只返回已解锁的模块
    return recommended.where((m) => m.isUnlocked).take(3).toList();
  }

  /// 🔥 刷新用户数据
  Future<void> refreshUserData() async {
    if (_disposed) return;

    try {
      print('🔄 刷新用户数据...');

      // 🔥 从HiveService重新加载用户数据
      _currentUser = HiveService.getCurrentUser();

      if (_currentUser != null) {
        _initializeModules();
        _safeNotifyListeners();
        print('✅ 用户数据刷新完成');
      } else {
        print('⚠️ 未找到用户数据');
      }
    } catch (e) {
      print('❌ 刷新用户数据失败: $e');
    }
  }

  /// 初始化训练模块
  void _initializeModules() {
    _modules = [
      BasicChatModule(_currentUser),
      AICompanionModule(_currentUser),
      BatchChatAnalyzerModule(_currentUser), // 🔥 批量聊天记录分析模块
      AntiPUAModule(_currentUser),
      CombatTrainingModule(_currentUser), // 实战训练营
      ConfessionPredictorModule(_currentUser),
      RealChatAssistantModule(_currentUser),
    ];
  }

  /// 🔥 安全的通知监听器方法
  void _safeNotifyListeners() {
    if (!_disposed && hasListeners) {
      notifyListeners();
    }
  }

  /// 🔥 重写dispose方法，确保资源释放
  @override
  void dispose() {
    print('🔄 HomeController 销毁中...');
    _disposed = true;

    // 清理所有引用
    _currentUser = null;
    _modules.clear();
    _isLoading = false;

    super.dispose();
    print('✅ HomeController 销毁完成');
  }
}

/// 训练模块基类
abstract class TrainingModule {
  final UserModel? user;

  TrainingModule(this.user);

  String get id;
  String get name;
  String get icon;
  String get description;
  String get category;  // 🔥 新增：模块类别
  bool get isUnlocked;
  int get requiredLevel => 1;  // 🔥 新增：所需等级
  int get requiredCredits => 0;  // 🔥 新增：所需积分

  Future<void> launch();

  /// 🔥 获取解锁状态描述
  String get unlockDescription {
    if (isUnlocked) return '已解锁';

    final reasons = <String>[];
    if (user == null) reasons.add('需要登录');
    if (user != null && user!.userLevel.level < requiredLevel) {
      reasons.add('需要等级 $requiredLevel');
    }
    if (user != null && user!.credits < requiredCredits) {
      reasons.add('需要 $requiredCredits 积分');
    }

    return reasons.isNotEmpty ? reasons.join('，') : '条件不足';
  }
}

/// 基础对话训练模块
class BasicChatModule extends TrainingModule {
  BasicChatModule(UserModel? user) : super(user);

  @override
  String get id => 'basic_chat';

  @override
  String get name => '基础对话训练';

  @override
  String get icon => '💬';

  @override
  String get description => '与AI角色对话练习，提升沟通技巧';

  @override
  String get category => '基础训练';

  @override
  bool get isUnlocked => true; // 基础功能始终解锁

  @override
  Future<void> launch() async {
    // 导航到角色选择页面
    print('启动基础对话训练模块');
  }
}

/// AI伴侣养成模块
class AICompanionModule extends TrainingModule {
  AICompanionModule(UserModel? user) : super(user);

  @override
  String get id => 'ai_companion';

  @override
  String get name => 'AI伴侣养成';

  @override
  String get icon => '💕';

  @override
  String get description => '长期AI伴侣养成，学习关系维护技巧';

  @override
  String get category => '高级训练';

  @override
  int get requiredCredits => 50;

  @override
  bool get isUnlocked => user != null && user!.credits >= requiredCredits;

  @override
  Future<void> launch() async {
    print('启动AI伴侣养成模块');
  }
}

/// 🔥 批量聊天记录分析模块
class BatchChatAnalyzerModule extends TrainingModule {
  BatchChatAnalyzerModule(UserModel? user) : super(user);

  @override
  String get id => 'batch_chat_analyzer';

  @override
  String get name => '聊天记录分析';

  @override
  String get icon => '📊';

  @override
  String get description => '上传聊天记录，AI智能分析告白成功率';

  @override
  String get category => '智能分析';

  @override
  bool get isUnlocked => true; // 核心功能，免费开放

  @override
  Future<void> launch() async {
    print('启动聊天记录分析模块');
  }
}

/// 反PUA防护模块
class AntiPUAModule extends TrainingModule {
  AntiPUAModule(UserModel? user) : super(user);

  @override
  String get id => 'anti_pua';

  @override
  String get name => '反PUA防护';

  @override
  String get icon => '🛡️';

  @override
  String get description => '识别和应对各种PUA话术';

  @override
  String get category => '安全防护';

  @override
  bool get isUnlocked => true; // 免费功能

  @override
  Future<void> launch() async {
    print('启动反PUA防护模块');
  }
}

/// 实战训练营模块
class CombatTrainingModule extends TrainingModule {
  CombatTrainingModule(UserModel? user) : super(user);

  @override
  String get id => 'combat_training';

  @override
  String get name => '实战训练营';

  @override
  String get icon => '🎪';

  @override
  String get description => '专项技能训练，应对复杂社交场景';

  @override
  String get category => '技能训练';

  @override
  bool get isUnlocked => true; // 🔥 修改：免费开放，不需要登录

  @override
  Future<void> launch() async {
    print('启动实战训练营模块');
  }
}

/// 告白成功率预测模块
class ConfessionPredictorModule extends TrainingModule {
  ConfessionPredictorModule(UserModel? user) : super(user);

  @override
  String get id => 'confession_predictor';

  @override
  String get name => '告白成功率预测';

  @override
  String get icon => '💘';

  @override
  String get description => '分析对话数据，预测告白成功率';

  @override
  String get category => '智能分析';

  @override
  int get requiredLevel => 1; // 🔥 修改：降低等级要求从3到1

  @override
  bool get isUnlocked => true; // 🔥 修改：免费开放，不需要对话次数条件

  @override
  Future<void> launch() async {
    print('启动告白成功率预测模块');
  }
}

/// 真人聊天助手模块
class RealChatAssistantModule extends TrainingModule {
  RealChatAssistantModule(UserModel? user) : super(user);

  @override
  String get id => 'real_chat_assistant';

  @override
  String get name => '真人聊天助手';

  @override
  String get icon => '📱';

  @override
  String get description => '现实聊天指导，社交翻译官';

  @override
  String get category => '智能助手';

  @override
  int get requiredLevel => 1; // 🔥 修改：降低等级要求从5到1

  @override
  bool get isUnlocked => true; // 🔥 修改：免费开放，不需要VIP条件

  @override
  Future<void> launch() async {
    print('启动真人聊天助手模块');
  }
}