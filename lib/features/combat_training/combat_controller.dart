// lib/features/combat_training/combat_controller.dart

import 'package:flutter/foundation.dart';
import '../../core/constants/scenario_data.dart';
import '../../core/models/user_model.dart';
import '../../shared/services/storage_service.dart';
import '../../shared/services/billing_service.dart';

/// 实战训练营控制器
class CombatController extends ChangeNotifier {
  final UserModel initialUser;
  UserModel _currentUser;
  CombatScenario? _currentScenario;
  int _selectedOptionIndex = -1;
  bool _hasAnswered = false;
  bool _showResults = false;
  TrainingSession? _currentSession;

  CombatController({required UserModel user})
      : initialUser = user,
        _currentUser = user;

  // Getters
  UserModel get currentUser => _currentUser;
  CombatScenario? get currentScenario => _currentScenario;
  int get selectedOptionIndex => _selectedOptionIndex;
  bool get hasAnswered => _hasAnswered;
  bool get showResults => _showResults;
  TrainingSession? get currentSession => _currentSession;

  /// 开始训练会话
  Future<void> startTrainingSession(String category) async {
    try {
      final scenarios = ScenarioData.getCombatScenariosByCategory(category);
      if (scenarios.isEmpty) {
        throw Exception('该类别暂无训练场景');
      }

      _currentSession = TrainingSession(
        category: category,
        scenarios: scenarios,
        startTime: DateTime.now(),
      );

      // 开始第一个场景
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
      // 所有场景完成，结束会话
      await _completeSession();
      return;
    }

    _currentScenario = nextScenario;
    _selectedOptionIndex = -1;
    _hasAnswered = false;
    _showResults = false;
    notifyListeners();
  }

  /// 选择选项
  void selectOption(int index) {
    if (_hasAnswered || _currentScenario == null) return;

    _selectedOptionIndex = index;
    notifyListeners();
  }

  /// 提交答案
  Future<void> submitAnswer() async {
    if (_selectedOptionIndex == -1 || _currentScenario == null) return;

    try {
      // 扣除对话次数
      _currentUser = await BillingService.consumeCredits(_currentUser, 1);

      _hasAnswered = true;
      _showResults = true;

      // 记录答题结果
      final selectedOption = _currentScenario!.options[_selectedOptionIndex];
      _currentSession?.recordAnswer(
        scenarioId: _currentScenario!.id,
        selectedOption: _selectedOptionIndex,
        isCorrect: selectedOption.isCorrect,
      );

      notifyListeners();
    } catch (e) {
      throw Exception('提交答案失败: $e');
    }
  }

  /// 继续下一题
  Future<void> nextScenario() async {
    if (!_hasAnswered) return;
    await _loadNextScenario();
  }

  /// 完成训练会话
  Future<void> _completeSession() async {
    if (_currentSession == null) return;

    _currentSession!.completeSession();

    // 保存训练记录
    await _saveTrainingRecord();

    // 更新用户统计
    await _updateUserStats();

    notifyListeners();
  }

  /// 保存训练记录
  Future<void> _saveTrainingRecord() async {
    // 将训练记录保存到本地存储
    // 实际实现中可以扩展 StorageService 来支持训练记录
  }

  /// 更新用户统计
  Future<void> _updateUserStats() async {
    if (_currentSession == null) return;

    // 更新用户的训练统计数据
    // 这里可以扩展 UserModel 来包含训练相关的统计信息
  }

  /// 获取训练结果
  TrainingResult? getTrainingResult() {
    if (_currentSession == null || !_currentSession!.isCompleted) {
      return null;
    }

    return TrainingResult(
      category: _currentSession!.category,
      totalScenarios: _currentSession!.scenarios.length,
      correctAnswers: _currentSession!.getCorrectAnswerCount(),
      totalTime: _currentSession!.getTotalTimeInMinutes(),
      accuracy: _currentSession!.getAccuracy(),
    );
  }

  /// 重置控制器状态
  void reset() {
    _currentScenario = null;
    _selectedOptionIndex = -1;
    _hasAnswered = false;
    _showResults = false;
    _currentSession = null;
    notifyListeners();
  }
}

/// 训练会话
class TrainingSession {
  final String category;
  final List<CombatScenario> scenarios;
  final DateTime startTime;
  DateTime? endTime;
  int currentScenarioIndex = 0;
  final List<AnswerRecord> answers = [];

  TrainingSession({
    required this.category,
    required this.scenarios,
    required this.startTime,
  });

  bool get isCompleted => endTime != null;

  /// 获取下一个场景
  CombatScenario? getNextScenario() {
    if (currentScenarioIndex >= scenarios.length) return null;
    return scenarios[currentScenarioIndex++];
  }

  /// 记录答题结果
  void recordAnswer({
    required String scenarioId,
    required int selectedOption,
    required bool isCorrect,
  }) {
    answers.add(AnswerRecord(
      scenarioId: scenarioId,
      selectedOption: selectedOption,
      isCorrect: isCorrect,
      timestamp: DateTime.now(),
    ));
  }

  /// 完成会话
  void completeSession() {
    endTime = DateTime.now();
  }

  /// 获取正确答案数量
  int getCorrectAnswerCount() {
    return answers.where((answer) => answer.isCorrect).length;
  }

  /// 获取准确率
  double getAccuracy() {
    if (answers.isEmpty) return 0.0;
    return getCorrectAnswerCount() / answers.length;
  }

  /// 获取总用时（分钟）
  int getTotalTimeInMinutes() {
    if (endTime == null) return 0;
    return endTime!.difference(startTime).inMinutes;
  }
}

/// 答题记录
class AnswerRecord {
  final String scenarioId;
  final int selectedOption;
  final bool isCorrect;
  final DateTime timestamp;

  AnswerRecord({
    required this.scenarioId,
    required this.selectedOption,
    required this.isCorrect,
    required this.timestamp,
  });
}

/// 训练结果
class TrainingResult {
  final String category;
  final int totalScenarios;
  final int correctAnswers;
  final int totalTime;
  final double accuracy;

  TrainingResult({
    required this.category,
    required this.totalScenarios,
    required this.correctAnswers,
    required this.totalTime,
    required this.accuracy,
  });

  /// 获取等级评价
  String get gradeText {
    if (accuracy >= 0.9) return 'S级 - 优秀';
    if (accuracy >= 0.8) return 'A级 - 良好';
    if (accuracy >= 0.7) return 'B级 - 及格';
    if (accuracy >= 0.6) return 'C级 - 需要提高';
    return 'D级 - 需要更多练习';
  }

  /// 获取改进建议
  List<String> get improvementSuggestions {
    final suggestions = <String>[];

    if (accuracy < 0.7) {
      suggestions.add('建议多复习相关社交技巧理论');
      suggestions.add('可以重复练习错误的场景');
    }

    if (totalTime > 10) {
      suggestions.add('尝试提高反应速度，相信第一直觉');
    }

    if (correctAnswers < totalScenarios / 2) {
      suggestions.add('建议从基础对话训练开始练习');
    }

    return suggestions;
  }
}