// lib/features/combat_training/combat_controller.dart (修复版 - 迁移到HiveService)

import 'package:flutter/foundation.dart';
import '../../core/constants/scenario_data.dart';
import '../../core/models/user_model.dart';
import '../../shared/services/hive_service.dart';  // 🔥 替代 StorageService
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
  bool _disposed = false;  // 🔥 添加销毁标志

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
    if (_disposed) return;

    try {
      print('🔄 开始训练会话: $category');

      // 🔥 使用异步方法获取场景数据
      final scenarios = await ScenarioData.getCombatScenariosByCategory(category);
      if (scenarios.isEmpty) {
        throw Exception('该类别暂无训练场景: $category');
      }

      _currentSession = TrainingSession(
        category: category,
        scenarios: scenarios,
        startTime: DateTime.now(),
      );

      print('✅ 训练会话创建成功，共${scenarios.length}个场景');

      // 开始第一个场景
      await _loadNextScenario();
    } catch (e) {
      print('❌ 开始训练失败: $e');
      throw Exception('开始训练失败: $e');
    }
  }

  /// 加载下一个场景
  Future<void> _loadNextScenario() async {
    if (_currentSession == null || _disposed) return;

    try {
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

      print('📖 加载场景: ${nextScenario.title}');
      _safeNotifyListeners();
    } catch (e) {
      print('❌ 加载场景失败: $e');
      throw Exception('加载场景失败: $e');
    }
  }

  /// 选择选项
  void selectOption(int index) {
    if (_hasAnswered || _currentScenario == null || _disposed) return;

    _selectedOptionIndex = index;
    print('🎯 选择选项: $index');
    _safeNotifyListeners();
  }

  /// 提交答案
  Future<void> submitAnswer() async {
    if (_selectedOptionIndex == -1 || _currentScenario == null || _disposed) return;

    try {
      print('🔄 提交答案，选项: $_selectedOptionIndex');

      // 扣除对话次数
      _currentUser = await BillingService.consumeCredits(_currentUser, 1);

      // 🔥 更新用户数据到HiveService
      await HiveService.saveCurrentUser(_currentUser);
      print('✅ 用户积分更新成功，剩余: ${_currentUser.credits}');

      _hasAnswered = true;
      _showResults = true;

      // 记录答题结果
      final selectedOption = _currentScenario!.options[_selectedOptionIndex];
      _currentSession?.recordAnswer(
        scenarioId: _currentScenario!.id,
        selectedOption: _selectedOptionIndex,
        isCorrect: selectedOption.isCorrect,
      );

      print('📝 答题结果已记录: ${selectedOption.isCorrect ? '正确' : '错误'}');
      _safeNotifyListeners();
    } catch (e) {
      print('❌ 提交答案失败: $e');
      throw Exception('提交答案失败: $e');
    }
  }

  /// 继续下一题
  Future<void> nextScenario() async {
    if (!_hasAnswered || _disposed) return;
    await _loadNextScenario();
  }

  /// 完成训练会话
  Future<void> _completeSession() async {
    if (_currentSession == null || _disposed) return;

    try {
      print('🔄 完成训练会话...');

      _currentSession!.completeSession();

      // 保存训练记录
      await _saveTrainingRecord();

      // 更新用户统计
      await _updateUserStats();

      print('🎉 训练会话完成! 共答对${_currentSession!.getCorrectAnswerCount()}/${_currentSession!.scenarios.length}题');
      _safeNotifyListeners();
    } catch (e) {
      print('❌ 完成训练会话失败: $e');
    }
  }

  /// 保存训练记录
  Future<void> _saveTrainingRecord() async {
    if (_currentSession == null) return;

    try {
      // 🔥 将训练记录保存到HiveService
      final trainingRecord = {
        'id': 'training_${DateTime.now().millisecondsSinceEpoch}',
        'userId': _currentUser.id,
        'category': _currentSession!.category,
        'startTime': _currentSession!.startTime.toIso8601String(),
        'endTime': _currentSession!.endTime?.toIso8601String(),
        'totalScenarios': _currentSession!.scenarios.length,
        'correctAnswers': _currentSession!.getCorrectAnswerCount(),
        'accuracy': _currentSession!.getAccuracy(),
        'answers': _currentSession!.answers.map((answer) => {
          'scenarioId': answer.scenarioId,
          'selectedOption': answer.selectedOption,
          'isCorrect': answer.isCorrect,
          'timestamp': answer.timestamp.toIso8601String(),
        }).toList(),
      };

      // 保存到通用数据存储
      final trainingKey = 'combat_training_${_currentUser.id}';
      final existingRecords = HiveService.getData(trainingKey) as List<dynamic>? ?? [];
      existingRecords.add(trainingRecord);

      // 保留最近20条记录
      if (existingRecords.length > 20) {
        existingRecords.removeRange(0, existingRecords.length - 20);
      }

      await HiveService.saveData(trainingKey, existingRecords);
      print('✅ 训练记录保存成功');
    } catch (e) {
      print('❌ 保存训练记录失败: $e');
    }
  }

  /// 更新用户统计
  Future<void> _updateUserStats() async {
    if (_currentSession == null || _disposed) return;

    try {
      // 🔥 更新用户统计数据
      final correctAnswers = _currentSession!.getCorrectAnswerCount();
      final totalScenarios = _currentSession!.scenarios.length;

      // 创建新的统计数据
      final updatedStats = _currentUser.stats.copyWith(
        totalConversations: _currentUser.stats.totalConversations + 1,
        successfulConversations: _currentUser.stats.successfulConversations +
            (correctAnswers >= totalScenarios * 0.8 ? 1 : 0), // 80%正确率算成功
        totalRounds: _currentUser.stats.totalRounds + totalScenarios,
      );

      // 更新用户信息
      _currentUser = _currentUser.copyWith(stats: updatedStats);

      // 🔥 保存到HiveService
      await HiveService.saveCurrentUser(_currentUser);
      await HiveService.saveUser(_currentUser);

      print('✅ 用户统计更新成功');
    } catch (e) {
      print('❌ 更新用户统计失败: $e');
    }
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

  /// 🔥 获取历史训练记录
  Future<List<Map<String, dynamic>>> getTrainingHistory() async {
    if (_disposed) return [];

    try {
      final trainingKey = 'combat_training_${_currentUser.id}';
      final records = HiveService.getData(trainingKey) as List<dynamic>? ?? [];

      return records.map((record) => Map<String, dynamic>.from(record)).toList();
    } catch (e) {
      print('❌ 获取训练历史失败: $e');
      return [];
    }
  }

  /// 🔥 获取用户在特定类别的表现统计
  Future<Map<String, dynamic>> getCategoryStats(String category) async {
    if (_disposed) return {};

    try {
      final history = await getTrainingHistory();
      final categoryRecords = history.where((record) => record['category'] == category).toList();

      if (categoryRecords.isEmpty) {
        return {
          'category': category,
          'totalSessions': 0,
          'averageAccuracy': 0.0,
          'bestAccuracy': 0.0,
          'totalTime': 0,
          'improvement': 0.0,
        };
      }

      final totalSessions = categoryRecords.length;
      final accuracies = categoryRecords.map((r) => r['accuracy'] as double).toList();
      final totalTime = categoryRecords.fold<int>(0, (sum, r) => sum + (r['totalTime'] as int? ?? 0));

      final averageAccuracy = accuracies.fold<double>(0, (sum, acc) => sum + acc) / accuracies.length;
      final bestAccuracy = accuracies.reduce((a, b) => a > b ? a : b);

      // 计算改进趋势（最近3次vs前面的平均值）
      double improvement = 0.0;
      if (accuracies.length >= 6) {
        final recent = accuracies.sublist(accuracies.length - 3);
        final earlier = accuracies.sublist(0, accuracies.length - 3);
        final recentAvg = recent.fold<double>(0, (sum, acc) => sum + acc) / recent.length;
        final earlierAvg = earlier.fold<double>(0, (sum, acc) => sum + acc) / earlier.length;
        improvement = recentAvg - earlierAvg;
      }

      return {
        'category': category,
        'totalSessions': totalSessions,
        'averageAccuracy': averageAccuracy,
        'bestAccuracy': bestAccuracy,
        'totalTime': totalTime,
        'improvement': improvement,
      };
    } catch (e) {
      print('❌ 获取类别统计失败: $e');
      return {};
    }
  }

  /// 重置控制器状态
  void reset() {
    if (_disposed) return;

    _currentScenario = null;
    _selectedOptionIndex = -1;
    _hasAnswered = false;
    _showResults = false;
    _currentSession = null;
    _safeNotifyListeners();
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
    print('🔄 CombatController 销毁中...');
    _disposed = true;

    // 如果训练进行中，先完成保存
    if (_currentSession != null && !_currentSession!.isCompleted) {
      _currentSession!.completeSession();
      _saveTrainingRecord().catchError((e) {
        print('❌ 销毁时保存训练记录失败: $e');
      });
    }

    // 清理所有引用
    _currentScenario = null;
    _currentSession = null;
    _selectedOptionIndex = -1;
    _hasAnswered = false;
    _showResults = false;

    super.dispose();
    print('✅ CombatController 销毁完成');
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