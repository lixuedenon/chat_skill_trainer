// lib/features/anti_pua/anti_pua_controller.dart

import 'package:flutter/foundation.dart';
import '../../core/models/user_model.dart';
import 'anti_pua_scenarios.dart';

/// 反PUA训练控制器
class AntiPUAController extends ChangeNotifier {
  final UserModel user;
  AntiPUAScenario? _currentScenario;
  int _selectedStrategyIndex = -1;
  bool _hasAnswered = false;
  bool _showResults = false;
  AntiPUASession? _currentSession;

  AntiPUAController({required this.user});

  // Getters
  AntiPUAScenario? get currentScenario => _currentScenario;
  int get selectedStrategyIndex => _selectedStrategyIndex;
  bool get hasAnswered => _hasAnswered;
  bool get showResults => _showResults;
  AntiPUASession? get currentSession => _currentSession;

  /// 开始反PUA训练
  Future<void> startTraining(String category) async {
    try {
      final scenarios = ScenarioService.getAntiPUAScenarios(category);
      if (scenarios.isEmpty) {
        throw Exception('该类别暂无训练场景');
      }

      _currentSession = AntiPUASession(
        category: category,
        scenarios: scenarios,
        startTime: DateTime.now(),
      );

      await _loadNextScenario();
    } catch (e) {
      throw Exception('开始训练失败: $e');
    }
  }

  /// 加载下一个场景
  Future<void> _loadNextScenario() async {
    if (_currentSession == null) return;

    final nextScenario = _currentSession!.getNextScenario();
    if (nextScenario == null) {
      await _completeSession();
      return;
    }

    _currentScenario = nextScenario;
    _selectedStrategyIndex = -1;
    _hasAnswered = false;
    _showResults = false;
    notifyListeners();
  }

  /// 选择应对策略
  void selectStrategy(int index) {
    if (_hasAnswered) return;
    _selectedStrategyIndex = index;
    notifyListeners();
  }

  /// 提交选择
  Future<void> submitAnswer() async {
    if (_selectedStrategyIndex == -1 || _currentScenario == null) return;

    _hasAnswered = true;
    _showResults = true;

    // 记录选择
    _currentSession?.recordAnswer(
      scenarioId: _currentScenario!.id,
      selectedStrategy: _selectedStrategyIndex,
    );

    notifyListeners();
  }

  /// 继续下一个场景
  Future<void> nextScenario() async {
    if (!_hasAnswered) return;
    await _loadNextScenario();
  }

  /// 完成训练会话
  Future<void> _completeSession() async {
    _currentSession?.completeSession();
    notifyListeners();
  }

  /// 获取训练结果
  AntiPUAResult? getTrainingResult() {
    if (_currentSession == null || !_currentSession!.isCompleted) {
      return null;
    }

    return AntiPUAResult(
      category: _currentSession!.category,
      totalScenarios: _currentSession!.scenarios.length,
      completedScenarios: _currentSession!.answers.length,
      totalTime: _currentSession!.getTotalTimeInMinutes(),
      masteredScenarios: _currentSession!.scenarios.length, // 所有场景都算掌握，因为是学习性质
    );
  }

  /// 获取所有可用的训练分类
  static List<AntiPUACategoryInfo> getAvailableCategories() {
    return [
      const AntiPUACategoryInfo(
        id: 'recognition',
        name: 'PUA话术识别',
        description: '学会识别常见的PUA套路和话术',
        icon: '🔍',
        scenarios: [
          '"你和别的女生不一样"',
          '"如果你爱我就会..."',
          '"我从来没遇到过像你这样的人"',
        ],
      ),
      const AntiPUACategoryInfo(
        id: 'counter_strategies',
        name: '反击策略训练',
        description: '掌握高情商的反击和应对方法',
        icon: '⚔️',
        scenarios: [
          '优雅拒绝技巧',
          '界限设定方法',
          '情绪操控识别',
        ],
      ),
      const AntiPUACategoryInfo(
        id: 'self_protection',
        name: '自我保护技能',
        description: '学会保护自己的情感和心理健康',
        icon: '🛡️',
        scenarios: [
          '及时抽身技巧',
          '寻求支持方法',
          '心理建设强化',
        ],
      ),
    ];
  }

  /// 重置控制器
  void reset() {
    _currentScenario = null;
    _selectedStrategyIndex = -1;
    _hasAnswered = false;
    _showResults = false;
    _currentSession = null;
    notifyListeners();
  }
}

/// 反PUA训练会话
class AntiPUASession {
  final String category;
  final List<AntiPUAScenario> scenarios;
  final DateTime startTime;
  DateTime? endTime;
  int currentScenarioIndex = 0;
  final List<AntiPUAAnswer> answers = [];

  AntiPUASession({
    required this.category,
    required this.scenarios,
    required this.startTime,
  });

  bool get isCompleted => endTime != null;

  AntiPUAScenario? getNextScenario() {
    if (currentScenarioIndex >= scenarios.length) return null;
    return scenarios[currentScenarioIndex++];
  }

  void recordAnswer({
    required String scenarioId,
    required int selectedStrategy,
  }) {
    answers.add(AntiPUAAnswer(
      scenarioId: scenarioId,
      selectedStrategy: selectedStrategy,
      timestamp: DateTime.now(),
    ));
  }

  void completeSession() {
    endTime = DateTime.now();
  }

  int getTotalTimeInMinutes() {
    if (endTime == null) return 0;
    return endTime!.difference(startTime).inMinutes;
  }
}

/// 反PUA答题记录
class AntiPUAAnswer {
  final String scenarioId;
  final int selectedStrategy;
  final DateTime timestamp;

  const AntiPUAAnswer({
    required this.scenarioId,
    required this.selectedStrategy,
    required this.timestamp,
  });
}

/// 反PUA训练结果
class AntiPUAResult {
  final String category;
  final int totalScenarios;
  final int completedScenarios;
  final int totalTime;
  final int masteredScenarios;

  const AntiPUAResult({
    required this.category,
    required this.totalScenarios,
    required this.completedScenarios,
    required this.totalTime,
    required this.masteredScenarios,
  });

  double get completionRate =>
      totalScenarios > 0 ? completedScenarios / totalScenarios : 0.0;

  String get completionGrade {
    if (completionRate >= 1.0) return 'S级 - 全部掌握';
    if (completionRate >= 0.8) return 'A级 - 大部分掌握';
    if (completionRate >= 0.6) return 'B级 - 基本掌握';
    return 'C级 - 需要继续练习';
  }

  List<String> get achievements {
    final achievements = <String>[];

    if (completedScenarios >= totalScenarios) {
      achievements.add('完美学员 - 完成所有场景');
    }

    if (totalTime <= 10) {
      achievements.add('快速学习者 - 10分钟内完成');
    }

    if (masteredScenarios >= totalScenarios) {
      achievements.add('防护专家 - 掌握所有技巧');
    }

    return achievements;
  }
}

/// 反PUA分类信息
class AntiPUACategoryInfo {
  final String id;
  final String name;
  final String description;
  final String icon;
  final List<String> scenarios;

  const AntiPUACategoryInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.scenarios,
  });
}