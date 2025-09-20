// lib/features/anti_pua/anti_pua_scenarios.dart

/// 反PUA场景数据模型
class AntiPUAScenario {
  final String id;
  final String category;
  final String puaTactic;           // PUA话术
  final String hiddenIntent;        // 隐藏意图
  final List<String> counterStrategies; // 应对策略选项
  final int bestStrategyIndex;      // 最佳策略索引
  final String explanation;         // 解释说明

  const AntiPUAScenario({
    required this.id,
    required this.category,
    required this.puaTactic,
    required this.hiddenIntent,
    required this.counterStrategies,
    required this.bestStrategyIndex,
    required this.explanation,
  });

  /// 从JSON创建对象
  factory AntiPUAScenario.fromJson(Map<String, dynamic> json) {
    return AntiPUAScenario(
      id: json['id'] ?? '',
      category: json['category'] ?? '',
      puaTactic: json['puaTactic'] ?? '',
      hiddenIntent: json['hiddenIntent'] ?? '',
      counterStrategies: List<String>.from(json['counterStrategies'] ?? []),
      bestStrategyIndex: json['bestStrategyIndex'] ?? 0,
      explanation: json['explanation'] ?? '',
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'puaTactic': puaTactic,
      'hiddenIntent': hiddenIntent,
      'counterStrategies': counterStrategies,
      'bestStrategyIndex': bestStrategyIndex,
      'explanation': explanation,
    };
  }
}

/// 反PUA场景数据库
class AntiPUAScenariosData {
  static const Map<String, List<AntiPUAScenario>> scenarios = {
    'recognition': [
      AntiPUAScenario(
        id: 'recog_001',
        category: 'recognition',
        puaTactic: '你和别的女生不一样',
        hiddenIntent: '通过制造"特别感"来降低你的判断力，让你觉得自己被特殊对待',
        counterStrategies: [
          '谢谢夸奖，但我觉得每个人都有自己的特点',
          '哦，是吗？你认识很多女生吗？',
          '这话你对每个女生都说过吧',
          '我也觉得我很特别，所以我的标准也很高',
        ],
        bestStrategyIndex: 3,
        explanation: '这是典型的PUA"特殊化"话术。最好的应对方式是保持自信，不被虚假的"特殊感"迷惑，同时暗示你有自己的标准和判断。',
      ),
      AntiPUAScenario(
        id: 'recog_002',
        category: 'recognition',
        puaTactic: '如果你爱我就会...',
        hiddenIntent: '用"爱"来道德绑架，强迫你做不愿意的事情',
        counterStrategies: [
          '爱不是用来证明的，是用来感受的',
          '真正的爱不会强迫对方做任何事',
          '如果你爱我，就不会让我为难',
          '我们对爱的理解可能不一样',
        ],
        bestStrategyIndex: 1,
        explanation: '这是道德绑架式PUA。真正的爱是尊重和理解，不是强迫和要求。坚定地拒绝这种逻辑很重要。',
      ),
      AntiPUAScenario(
        id: 'recog_003',
        category: 'recognition',
        puaTactic: '我从来没遇到过像你这样的人',
        hiddenIntent: '制造虚假的稀缺感和特殊感，让你产生"错过就没有了"的焦虑',
        counterStrategies: [
          '那你应该多出去走走，见见世面',
          '谢谢，但我不觉得自己有多特别',
          '是吗？那你以前遇到的都是什么样的？',
          '我也是第一次遇到用这种话术的人',
        ],
        bestStrategyIndex: 3,
        explanation: '这种话术试图制造虚假的稀缺感。最好的应对是保持理性，甚至可以幽默地指出对方的套路。',
      ),
    ],
    'counter_strategies': [
      AntiPUAScenario(
        id: 'counter_001',
        category: 'counter_strategies',
        puaTactic: '你这样想说明你还不够成熟',
        hiddenIntent: '用"成熟"标签来贬低你的判断，让你自我怀疑',
        counterStrategies: [
          '成熟不是盲目接受，而是独立思考',
          '每个人对成熟的定义不同',
          '我觉得质疑不合理的事情才是成熟的表现',
          '那请你告诉我什么是成熟？',
        ],
        bestStrategyIndex: 2,
        explanation: '用"成熟"来压制异议是常见手段。真正的成熟包括独立思考和坚持原则的能力。',
      ),
      AntiPUAScenario(
        id: 'counter_002',
        category: 'counter_strategies',
        puaTactic: '你想太多了，我是为了你好',
        hiddenIntent: '否定你的感受和判断，同时包装成关心你的样子',
        counterStrategies: [
          '谢谢关心，但我的感受是真实的',
          '什么对我好，我自己会判断',
          '为我好的话应该尊重我的想法',
          '我没有想太多，我只是在保护自己',
        ],
        bestStrategyIndex: 3,
        explanation: '"你想太多"是典型的情感操控话术，目的是让你自我怀疑。坚持相信自己的感受很重要。',
      ),
    ],
    'self_protection': [
      AntiPUAScenario(
        id: 'protect_001',
        category: 'self_protection',
        puaTactic: '我为你付出这么多，你就这样对我？',
        hiddenIntent: '用"付出"来情感绑架，让你产生愧疚感',
        counterStrategies: [
          '付出应该是自愿的，不是交换的筹码',
          '我没有要求你付出，这是你的选择',
          '真正的付出不求回报',
          '那你的付出是有条件的吗？',
        ],
        bestStrategyIndex: 0,
        explanation: '真正的付出是无条件的，不应该成为要求回报的理由。拒绝情感绑架，保护自己的情感边界。',
      ),
      AntiPUAScenario(
        id: 'protect_002',
        category: 'self_protection',
        puaTactic: '其他人都不会像我这样对你',
        hiddenIntent: '制造稀缺感和依赖感，让你觉得离开就找不到更好的',
        counterStrategies: [
          '我相信世界上有很多善良的人',
          '我不需要别人来定义我的价值',
          '那是因为我值得更好的对待',
          '我宁愿一个人也不要将就',
        ],
        bestStrategyIndex: 2,
        explanation: '这种话术试图降低你的自我价值感。要相信自己值得被好好对待，不要被虚假的稀缺感绑架。',
      ),
    ],
  };

  /// 根据类别获取场景列表
  static List<AntiPUAScenario> getScenariosByCategory(String category) {
    return scenarios[category] ?? [];
  }

  /// 获取所有场景
  static List<AntiPUAScenario> getAllScenarios() {
    return scenarios.values.expand((list) => list).toList();
  }

  /// 根据ID获取特定场景
  static AntiPUAScenario? getScenarioById(String id) {
    for (final categoryScenarios in scenarios.values) {
      for (final scenario in categoryScenarios) {
        if (scenario.id == id) return scenario;
      }
    }
    return null;
  }

  /// 获取随机场景
  static AntiPUAScenario? getRandomScenario([String? category]) {
    final targetScenarios = category != null
        ? getScenariosByCategory(category)
        : getAllScenarios();

    if (targetScenarios.isEmpty) return null;

    final randomIndex = DateTime.now().millisecondsSinceEpoch % targetScenarios.length;
    return targetScenarios[randomIndex];
  }
}

/// 场景服务类（为了兼容现有的控制器代码）
class ScenarioService {
  static List<AntiPUAScenario> getAntiPUAScenarios(String category) {
    return AntiPUAScenariosData.getScenariosByCategory(category);
  }
}