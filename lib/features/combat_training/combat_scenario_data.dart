// lib/features/combat_training/combat_scenario_data.dart

/// 实战训练场景数据
class CombatScenarioData {
  /// 反套路专项训练场景
  static const List<CombatScenario> antiRoutineScenarios = [
    CombatScenario(
      id: 'routine_001',
      title: '探底测试',
      background: '你们约会几次了，她突然问这个问题，想要试探你的态度...',
      question: '你还有别的女性朋友吗？',
      options: [
        ScenarioOption(
          text: '没有，你是唯一的',
          isCorrect: false,
          explanation: '过度表态会显得缺乏社交价值，让对方产生压力',
        ),
        ScenarioOption(
          text: '有几个普通朋友',
          isCorrect: true,
          explanation: '诚实且有界限感，展现了正常的社交圈，增加自己的价值',
        ),
        ScenarioOption(
          text: '这重要吗？',
          isCorrect: false,
          explanation: '回避问题会让对方觉得你在隐瞒什么，产生不信任感',
        ),
      ],
      successMessage: '很好！诚实但有界限的回答最能建立健康关系',
      category: CombatCategory.antiRoutine,
    ),

    CombatScenario(
      id: 'routine_002',
      title: '时间投资测试',
      background: '她想要测试你对她的重视程度，看你是否会为了她改变计划...',
      question: '我知道你今晚有安排，但我突然很想见你',
      options: [
        ScenarioOption(
          text: '我马上取消安排过来找你',
          isCorrect: false,
          explanation: '过度迎合会让你失去独立性，降低自己的价值',
        ),
        ScenarioOption(
          text: '我现在有点忙，明天怎么样？',
          isCorrect: true,
          explanation: '坚持自己的边界，同时给出替代方案，展现成熟态度',
        ),
        ScenarioOption(
          text: '你怎么总是这样临时通知',
          isCorrect: false,
          explanation: '抱怨会破坏关系氛围，让对方感到被指责',
        ),
      ],
      successMessage: '优秀！保持自己的节奏是建立平等关系的关键',
      category: CombatCategory.antiRoutine,
    ),

    CombatScenario(
      id: 'routine_003',
      title: '价值观测试',
      background: '她想要了解你的价值观和原则，看你是否有主见...',
      question: '你觉得男生应该承担所有的约会费用吗？',
      options: [
        ScenarioOption(
          text: '当然，这是男生应该做的',
          isCorrect: false,
          explanation: '刻板印象会限制关系的平等发展',
        ),
        ScenarioOption(
          text: '我觉得可以轮流请客，这样更公平',
          isCorrect: true,
          explanation: '展现现代平等观念，有利于建立健康的伙伴关系',
        ),
        ScenarioOption(
          text: 'AA制最公平',
          isCorrect: false,
          explanation: '过于计较可能会让对方觉得你不够大方',
        ),
      ],
      successMessage: '很棒！平等的价值观是现代关系的基础',
      category: CombatCategory.antiRoutine,
    ),
  ];

  /// 危机处理专项训练场景
  static const List<CombatScenario> crisisHandlingScenarios = [
    CombatScenario(
      id: 'crisis_001',
      title: '说错话补救',
      background: '你刚才无意中说了句话，明显让她不高兴了，气氛变得尴尬...',
      question: '刚才那句话我说得不合适，我想...',
      options: [
        ScenarioOption(
          text: '算了，当我没说过',
          isCorrect: false,
          explanation: '回避问题只会让误会越来越深',
        ),
        ScenarioOption(
          text: '我真心向你道歉，我没想到会让你不舒服',
          isCorrect: true,
          explanation: '真诚道歉并承认错误，展现成熟和担当',
        ),
        ScenarioOption(
          text: '你也太敏感了吧',
          isCorrect: false,
          explanation: '指责对方会让问题更严重，破坏关系',
        ),
      ],
      successMessage: '很好！真诚的道歉能化解大部分误会',
      category: CombatCategory.crisisHandling,
    ),

    CombatScenario(
      id: 'crisis_002',
      title: '冷场破冰',
      background: '聊天突然陷入沉默，气氛有些尴尬，你需要打破僵局...',
      question: '(沉默了30秒)',
      options: [
        ScenarioOption(
          text: '怎么不说话了？',
          isCorrect: false,
          explanation: '指出尴尬只会让场面更尴尬',
        ),
        ScenarioOption(
          text: '刚才路过的那只小狗好可爱',
          isCorrect: true,
          explanation: '转移话题到轻松的事物上，自然破解尴尬',
        ),
        ScenarioOption(
          text: '继续保持沉默',
          isCorrect: false,
          explanation: '不采取行动会让尴尬持续下去',
        ),
      ],
      successMessage: '不错！转移话题是破解冷场的有效方法',
      category: CombatCategory.crisisHandling,
    ),
  ];

  /// 高难度挑战场景
  static const List<CombatScenario> advancedChallengeScenarios = [
    CombatScenario(
      id: 'advanced_001',
      title: '傲娇女神',
      background: '她是公认的女神，平时很高冷，很少主动理人，今天却主动跟你说话...',
      question: '我听说你在公司表现不错呢',
      options: [
        ScenarioOption(
          text: '哪里哪里，我还差得远呢',
          isCorrect: false,
          explanation: '过度谦虚会让你显得不自信',
        ),
        ScenarioOption(
          text: '谢谢夸奖，我确实在努力提升自己',
          isCorrect: true,
          explanation: '自信但不骄傲的回应，展现了良好的心态',
        ),
        ScenarioOption(
          text: '天哪，你居然注意到我了！',
          isCorrect: false,
          explanation: '过度兴奋会暴露你的需求感，降低吸引力',
        ),
      ],
      successMessage: '优秀！面对高价值对象要保持自信和淡定',
      category: CombatCategory.advancedChallenge,
    ),

    CombatScenario(
      id: 'advanced_002',
      title: '职场权威',
      background: '她是你的上级，在工作中很严厉，但私下似乎对你有些不同的态度...',
      question: '你最近的工作让我刮目相看',
      options: [
        ScenarioOption(
          text: '谢谢领导栽培',
          isCorrect: false,
          explanation: '太正式的回应没有拉近距离',
        ),
        ScenarioOption(
          text: '谢谢认可，私下里你可以叫我名字',
          isCorrect: true,
          explanation: '感谢的同时适当拉近距离，但保持分寸',
        ),
        ScenarioOption(
          text: '那我们是不是可以...',
          isCorrect: false,
          explanation: '太急进可能会让对方感到压力',
        ),
      ],
      successMessage: '很好！职场关系需要更加谨慎和渐进',
      category: CombatCategory.advancedChallenge,
    ),
  ];

  /// 获取所有场景
  static List<CombatScenario> get allScenarios {
    return [
      ...antiRoutineScenarios,
      ...crisisHandlingScenarios,
      ...advancedChallengeScenarios,
    ];
  }

  /// 根据类别获取场景
  static List<CombatScenario> getScenariosByCategory(CombatCategory category) {
    return allScenarios.where((scenario) => scenario.category == category).toList();
  }

  /// 根据ID获取场景
  static CombatScenario? getScenarioById(String id) {
    try {
      return allScenarios.firstWhere((scenario) => scenario.id == id);
    } catch (e) {
      return null;
    }
  }
}

/// 训练类别枚举
enum CombatCategory {
  antiRoutine,        // 反套路
  crisisHandling,     // 危机处理
  advancedChallenge,  // 高难度挑战
}

/// 训练场景模型
class CombatScenario {
  final String id;                    // 场景ID
  final String title;                 // 场景标题
  final String background;            // 背景描述
  final String question;              // 问题/情境
  final List<ScenarioOption> options; // 选项列表
  final String successMessage;        // 成功提示
  final CombatCategory category;      // 场景类别

  const CombatScenario({
    required this.id,
    required this.title,
    required this.background,
    required this.question,
    required this.options,
    required this.successMessage,
    required this.category,
  });

  /// 获取正确选项
  ScenarioOption get correctOption {
    return options.firstWhere((option) => option.isCorrect);
  }

  /// 获取类别名称
  String get categoryName {
    switch (category) {
      case CombatCategory.antiRoutine:
        return '反套路专项';
      case CombatCategory.crisisHandling:
        return '危机处理';
      case CombatCategory.advancedChallenge:
        return '高难度挑战';
    }
  }
}

/// 场景选项模型
class ScenarioOption {
  final String text;         // 选项文本
  final bool isCorrect;      // 是否正确
  final String explanation;  // 解释说明

  const ScenarioOption({
    required this.text,
    required this.isCorrect,
    required this.explanation,
  });
}

/// 训练结果模型
class CombatResult {
  final String scenarioId;      // 场景ID
  final int selectedOptionIndex; // 选择的选项索引
  final bool isCorrect;         // 是否选择正确
  final DateTime completedAt;   // 完成时间

  const CombatResult({
    required this.scenarioId,
    required this.selectedOptionIndex,
    required this.isCorrect,
    required this.completedAt,
  });

  /// 从JSON创建对象
  factory CombatResult.fromJson(Map<String, dynamic> json) {
    return CombatResult(
      scenarioId: json['scenarioId'] ?? '',
      selectedOptionIndex: json['selectedOptionIndex'] ?? 0,
      isCorrect: json['isCorrect'] ?? false,
      completedAt: DateTime.parse(json['completedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'scenarioId': scenarioId,
      'selectedOptionIndex': selectedOptionIndex,
      'isCorrect': isCorrect,
      'completedAt': completedAt.toIso8601String(),
    };
  }
}