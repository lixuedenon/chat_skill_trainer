// lib/core/constants/scenario_data.dart (彻底重构 - 解决热重载内存泄漏)

import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

/// 🔥 训练场景数据配置 - 完全移除static const，改为异步JSON加载
class ScenarioData {
  // 🔥 关键修复：使用可控制的缓存，而非static const
  static Map<String, List<CombatScenario>>? _scenarioCache;
  static bool _isLoading = false;
  static String? _lastLoadError;

  /// 🔥 异步加载场景数据 - 从JSON文件读取，避免热重载内存累积
  static Future<Map<String, List<CombatScenario>>> loadScenarios() async {
    // 如果已经加载，直接返回缓存
    if (_scenarioCache != null) {
      return _scenarioCache!;
    }

    // 防止并发加载
    if (_isLoading) {
      // 等待加载完成
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 10));
      }
      return _scenarioCache ?? {};
    }

    _isLoading = true;
    _lastLoadError = null;

    try {
      print('🔄 开始从JSON加载场景数据...');

      // 🔥 从assets异步加载JSON - 这样热重载时不会重复分配内存
      final jsonString = await rootBundle.loadString('assets/data/scenarios.json');
      print('✅ JSON文件加载成功，大小: ${jsonString.length} 字符');

      // 解析JSON
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      print('✅ JSON解析成功，包含 ${jsonData.keys.length} 个类别');

      // 转换为Dart对象并缓存
      _scenarioCache = jsonData.map((categoryKey, scenarioList) {
        final List<CombatScenario> scenarios = (scenarioList as List)
            .map((item) => CombatScenario.fromJson(item as Map<String, dynamic>))
            .toList();

        print('✅ 加载类别 "$categoryKey": ${scenarios.length} 个场景');
        return MapEntry(categoryKey, scenarios);
      });

      print('🎉 所有场景数据加载完成!');
      return _scenarioCache!;

    } catch (e, stackTrace) {
      _lastLoadError = e.toString();
      print('❌ 场景数据加载失败: $e');
      print('📍 错误堆栈: $stackTrace');

      // 加载失败时返回空数据，避免应用崩溃
      _scenarioCache = <String, List<CombatScenario>>{};
      return _scenarioCache!;
    } finally {
      _isLoading = false;
    }
  }

  /// 🔥 强制重新加载数据（用于测试或内存优化）
  static Future<Map<String, List<CombatScenario>>> reloadScenarios() async {
    print('🔄 强制重新加载场景数据...');
    clearCache();
    return await loadScenarios();
  }

  /// 🔥 清理缓存 - 释放内存，解决热重载累积问题
  static void clearCache() {
    print('🧹 清理场景数据缓存...');
    _scenarioCache = null;
    _isLoading = false;
    _lastLoadError = null;
  }

  /// 获取缓存状态信息
  static Map<String, dynamic> getCacheInfo() {
    return {
      'isCached': _scenarioCache != null,
      'isLoading': _isLoading,
      'lastError': _lastLoadError,
      'totalScenarios': _scenarioCache?.values.fold<int>(0, (sum, list) => sum + list.length) ?? 0,
      'categories': _scenarioCache?.keys.toList() ?? [],
    };
  }

  /// 根据类别获取场景列表
  static Future<List<CombatScenario>> getCombatScenariosByCategory(String category) async {
    final scenarios = await loadScenarios();
    return scenarios[category] ?? [];
  }

  /// 根据标签获取场景列表
  static Future<List<CombatScenario>> getCombatScenariosByTag(String tag) async {
    final scenarios = await loadScenarios();
    final allScenarios = <CombatScenario>[];

    for (final scenarioList in scenarios.values) {
      allScenarios.addAll(scenarioList.where((scenario) => scenario.tags.contains(tag)));
    }

    return allScenarios;
  }

  /// 获取随机场景
  static Future<CombatScenario> getRandomCombatScenario() async {
    final scenarios = await loadScenarios();
    final allScenarios = <CombatScenario>[];

    for (final scenarioList in scenarios.values) {
      allScenarios.addAll(scenarioList);
    }

    if (allScenarios.isEmpty) {
      throw Exception('没有可用的训练场景');
    }

    final randomIndex = DateTime.now().millisecond % allScenarios.length;
    return allScenarios[randomIndex];
  }

  /// 获取所有可用的训练类别
  static Future<List<String>> getAvailableCategories() async {
    final scenarios = await loadScenarios();
    return scenarios.keys.toList();
  }

  /// 获取场景总数
  static Future<int> getTotalScenarioCount() async {
    final scenarios = await loadScenarios();
    return scenarios.values.fold<int>(0, (sum, list) => sum + list.length);
  }

  /// 获取某类别的场景数量
  static Future<int> getCategoryScenarioCount(String category) async {
    final scenarios = await loadScenarios();
    return scenarios[category]?.length ?? 0;
  }

  /// 🔥 获取训练模块信息 - 改为同步方法，因为这些是固定配置
  static List<TrainingModule> getTrainingModules() {
    return [
      const TrainingModule(
        id: 'anti_routine',
        name: '反套路专项',
        icon: '🎯',
        description: '识破并优雅应对各种测试',
        scenarios: ['探底测试', '情感绑架', '价值观试探'],
        difficulty: TrainingDifficulty.medium,
      ),
      const TrainingModule(
        id: 'workplace_crisis',
        name: '职场高危',
        icon: '💼',
        description: '职场关系的专业处理',
        scenarios: ['上级私下接触', '同事暧昧试探', '客户关系越界'],
        difficulty: TrainingDifficulty.hard,
      ),
      const TrainingModule(
        id: 'social_crisis',
        name: '聚会冷场处理',
        icon: '🎉',
        description: '社交场合的氛围调节',
        scenarios: ['聚会冷场救急', '群聊焦点争夺', '敏感话题转移'],
        difficulty: TrainingDifficulty.easy,
      ),
    ];
  }

  /// 🔥 根据ID获取特定场景
  static Future<CombatScenario?> getScenarioById(String scenarioId) async {
    final scenarios = await loadScenarios();

    for (final scenarioList in scenarios.values) {
      try {
        return scenarioList.firstWhere((scenario) => scenario.id == scenarioId);
      } catch (e) {
        // 继续查找
      }
    }

    return null;
  }
}

/// 🔥 实战训练场景模型 - 添加完整的JSON序列化支持
class CombatScenario {
  final String id;
  final String title;
  final String category;
  final String background;
  final String question;
  final List<ScenarioOption> options;
  final String explanation;
  final List<String> tags;

  const CombatScenario({
    required this.id,
    required this.title,
    required this.category,
    required this.background,
    required this.question,
    required this.options,
    required this.explanation,
    required this.tags,
  });

  /// 🔥 从JSON创建场景对象 - 关键方法
  factory CombatScenario.fromJson(Map<String, dynamic> json) {
    try {
      return CombatScenario(
        id: json['id'] as String,
        title: json['title'] as String,
        category: json['category'] as String,
        background: json['background'] as String,
        question: json['question'] as String,
        options: (json['options'] as List)
            .map((item) => ScenarioOption.fromJson(item as Map<String, dynamic>))
            .toList(),
        explanation: json['explanation'] as String,
        tags: List<String>.from(json['tags'] as List),
      );
    } catch (e) {
      throw FormatException('场景数据格式错误: $e', json.toString());
    }
  }

  /// 转换为JSON格式
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'background': background,
      'question': question,
      'options': options.map((option) => option.toJson()).toList(),
      'explanation': explanation,
      'tags': tags,
    };
  }

  @override
  String toString() {
    return 'CombatScenario(id: $id, title: $title, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CombatScenario && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 🔥 场景选项模型 - 添加完整的JSON序列化支持
class ScenarioOption {
  final String text;
  final bool isCorrect;
  final String feedback;

  const ScenarioOption({
    required this.text,
    required this.isCorrect,
    required this.feedback,
  });

  /// 🔥 从JSON创建选项对象
  factory ScenarioOption.fromJson(Map<String, dynamic> json) {
    try {
      return ScenarioOption(
        text: json['text'] as String,
        isCorrect: json['isCorrect'] as bool,
        feedback: json['feedback'] as String,
      );
    } catch (e) {
      throw FormatException('选项数据格式错误: $e', json.toString());
    }
  }

  /// 转换为JSON格式
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isCorrect': isCorrect,
      'feedback': feedback,
    };
  }

  @override
  String toString() {
    return 'ScenarioOption(text: $text, isCorrect: $isCorrect)';
  }
}

/// 训练模块信息 - 保持不变
class TrainingModule {
  final String id;
  final String name;
  final String icon;
  final String description;
  final List<String> scenarios;
  final TrainingDifficulty difficulty;

  const TrainingModule({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.scenarios,
    required this.difficulty,
  });
}

/// 训练难度枚举 - 保持不变
enum TrainingDifficulty {
  easy,    // 简单
  medium,  // 中等
  hard,    // 困难
}