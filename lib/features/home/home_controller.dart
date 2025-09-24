// lib/features/home/home_controller.dart

import 'package:flutter/foundation.dart';
import '../../core/models/user_model.dart';
import '../../shared/services/storage_service.dart';

/// 主页控制器 - 管理模块化主页的状态
class HomeController extends ChangeNotifier {
  UserModel? _currentUser;
  List<TrainingModule> _modules = [];
  bool _isLoading = false;

  // Getters
  UserModel? get currentUser => _currentUser;
  List<TrainingModule> get modules => _modules;
  List<TrainingModule> get availableModules =>
      _modules.where((module) => module.isUnlocked).toList();
  bool get isLoading => _isLoading;

  /// 初始化主页数据
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 加载用户数据
      _currentUser = await StorageService.getCurrentUser();

      // 初始化训练模块
      _initializeModules();

    } catch (e) {
      debugPrint('初始化主页失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 更新用户信息
  void updateUser(UserModel user) {
    _currentUser = user;
    _initializeModules(); // 重新初始化模块（检查解锁状态）
    notifyListeners();
  }

  /// 导航到指定模块
  Future<void> navigateToModule(String moduleId) async {
    final module = _modules.firstWhere(
      (m) => m.id == moduleId,
      orElse: () => throw Exception('模块未找到: $moduleId'),
    );

    if (!module.isUnlocked) {
      throw Exception('模块未解锁');
    }

    // 具体的导航逻辑将在各模块实现
    await module.launch();
  }

  /// 初始化训练模块
  void _initializeModules() {
    _modules = [
      BasicChatModule(_currentUser),
      AICompanionModule(_currentUser),
      BatchChatAnalyzerModule(_currentUser), // 🔥 新增：批量聊天记录分析模块
      AntiPUAModule(_currentUser),
      CombatTrainingModule(_currentUser), // 移至智能辅助工具区域
      ConfessionPredictorModule(_currentUser),
      RealChatAssistantModule(_currentUser),
    ];
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
  bool get isUnlocked;

  Future<void> launch();
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
  bool get isUnlocked => true; // 基础功能始终解锁

  @override
  Future<void> launch() async {
    // 导航到角色选择页面
    // Navigator.pushNamed(context, '/character_selection', arguments: {'user': user});
  }
}

/// AI养成模块
class AICompanionModule extends TrainingModule {
  AICompanionModule(UserModel? user) : super(user);

  @override
  String get id => 'ai_companion';

  @override
  String get name => 'AI女友养成';

  @override
  String get icon => '💕';

  @override
  String get description => '长期AI伴侣养成，学习关系维护技巧';

  @override
  bool get isUnlocked => user?.credits != null && user!.credits > 50; // 需要50个credits

  @override
  Future<void> launch() async {
    // 导航到养成对象选择页面
    // Navigator.pushNamed(context, '/companion_selection');
  }
}

/// 🔥 新增：批量聊天记录分析模块
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
  bool get isUnlocked => true; // 核心功能，免费开放

  @override
  Future<void> launch() async {
    // 直接导航到批量上传页面，不需要传递用户参数
    // Navigator.pushNamed(context, '/batch_upload');
  }
}

/// 反PUA模块
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
  bool get isUnlocked => true; // 免费功能

  @override
  Future<void> launch() async {
    // Navigator.pushNamed(context, '/anti_pua_training');
  }
}

/// 实战训练营模块（移至智能辅助工具区域）
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
  bool get isUnlocked => user != null; // 需要登录

  @override
  Future<void> launch() async {
    // 导航到训练营菜单
    // Navigator.pushNamed(context, '/combat_menu');
  }
}

/// 告白预测模块
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
  bool get isUnlocked => user?.stats.totalConversations != null &&
                         user!.stats.totalConversations >= 5; // 需要至少5次对话

  @override
  Future<void> launch() async {
    // Navigator.pushNamed(context, '/confession_analysis');
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
  bool get isUnlocked => user?.isVipUser == true; // VIP功能

  @override
  Future<void> launch() async {
    // Navigator.pushNamed(context, '/real_chat_assistant');
  }
}