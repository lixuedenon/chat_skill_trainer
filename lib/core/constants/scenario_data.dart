// lib/core/constants/scenario_data.dart

/// 训练场景数据配置
class ScenarioData {
  /// 实战训练营场景数据
  static const Map<String, List<CombatScenario>> combatScenarios = {
    'anti_routine': [
      CombatScenario(
        id: 'routine_001',
        title: '你还有别的女性朋友吗？',
        category: '反套路专项',
        background: '你们约会几次了，气氛很好。她突然问了这个问题，这是典型的测试性问题...',
        question: '你还有别的女性朋友吗？',
        options: [
          ScenarioOption(
            text: '没有，你是唯一的',
            isCorrect: false,
            feedback: '这样回答显得虚假，容易让人不信任。',
          ),
          ScenarioOption(
            text: '有几个普通朋友',
            isCorrect: true,
            feedback: '诚实且有界限感，显示你的社交能力正常。',
          ),
          ScenarioOption(
            text: '这重要吗？',
            isCorrect: false,
            feedback: '回避问题会让对方觉得你在隐瞒什么。',
          ),
        ],
        explanation: '诚实但有界限感的回答最好。既不会显得你没有朋友（缺乏魅力），也不会让她感到威胁。',
        tags: ['测试性问题', '界限设定', '诚实沟通'],
      ),
      CombatScenario(
        id: 'routine_002',
        title: '你觉得我胖吗？',
        category: '反套路专项',
        background: '你们在餐厅约会，她点了沙拉，你点了牛排。她看着镜子突然问...',
        question: '你觉得我胖吗？',
        options: [
          ScenarioOption(
            text: '不胖啊，你很瘦',
            isCorrect: false,
            feedback: '太直接的否定，没有解决她的内心担忧。',
          ),
          ScenarioOption(
            text: '我觉得健康最重要',
            isCorrect: true,
            feedback: '转移焦点到健康，既没有直接评价外貌，又表达了关心。',
          ),
          ScenarioOption(
            text: '你在我心里最美',
            isCorrect: false,
            feedback: '太过甜腻，可能显得不真诚。',
          ),
        ],
        explanation: '女生问这种问题通常是在寻求安慰和认可，而不是真的要你评价她的身材。',
        tags: ['外貌焦虑', '情感支持', '巧妙回应'],
      ),
    ],
    'crisis_handling': [
      CombatScenario(
        id: 'crisis_001',
        title: '说错话快速补救',
        category: '危机处理专项',
        background: '你刚才说了一句话，从她的表情看出她不高兴了...',
        question: '刚才我的表达可能不太合适，让你不舒服了吗？',
        options: [
          ScenarioOption(
            text: '我不是那个意思，你误会了',
            isCorrect: false,
            feedback: '推卸责任，容易激化矛盾。',
          ),
          ScenarioOption(
            text: '对不起，我刚才的话确实不合适',
            isCorrect: true,
            feedback: '主动承认错误，显示成熟和担当。',
          ),
          ScenarioOption(
            text: '你怎么这么敏感？',
            isCorrect: false,
            feedback: '指责对方，会让情况更糟。',
          ),
        ],
        explanation: '说错话时，真诚道歉比解释更重要。承认错误显示你的成熟。',
        tags: ['道歉技巧', '责任担当', '危机化解'],
      ),
    ],
    'high_difficulty': [
      CombatScenario(
        id: 'difficult_001',
        title: '傲娇女神攻略',
        category: '高难度挑战',
        background: '她是公认的女神，性格有些高冷，很多人追求但都被拒绝了...',
        question: '我平时很忙的，不是什么人都有时间见面。',
        options: [
          ScenarioOption(
            text: '那我很荣幸能见到你',
            isCorrect: false,
            feedback: '过于谦卑，降低了自己的价值。',
          ),
          ScenarioOption(
            text: '我也是，能见面说明我们都很重视这次机会',
            isCorrect: true,
            feedback: '平等对待，既认可她的价值，也肯定自己的价值。',
          ),
          ScenarioOption(
            text: '那你今天怎么有时间？',
            isCorrect: false,
            feedback: '质疑她的话，可能引起不快。',
          ),
        ],
        explanation: '面对高价值女性，要保持自己的价值感，平等交流而不是卑微讨好。',
        tags: ['高价值对话', '自信展示', '平等交流'],
      ),
    ],
  };

  /// 反PUA训练场景数据
  static const Map<String, List<AntiPUAScenario>> antiPUAScenarios = {
    'recognition': [
      AntiPUAScenario(
        id: 'pua_001',
        title: '"你和别的女生不一样"',
        category: 'PUA话术识别',
        puaTactic: '你和别的女生不一样，你很特别。',
        hiddenIntent: '通过"特别"来让你产生优越感，降低防备心。',
        counterStrategies: [
          '谢谢夸奖，每个人都是独特的。',
          '是吗？具体哪里不一样呢？',
          '我确实很特别，这点我很清楚。',
        ],
        explanation: 'PUA常用"你很特别"来建立虚假的亲密感。正确的回应是保持理性，不被虚假的赞美迷惑。',
        warningLevel: PUAWarningLevel.medium,
      ),
      AntiPUAScenario(
        id: 'pua_002',
        title: '"如果你爱我就会..."',
        category: 'PUA话术识别',
        puaTactic: '如果你真的爱我，就会为我做这件事。',
        hiddenIntent: '通过道德绑架来操控你的行为。',
        counterStrategies: [
          '爱不是用来证明的，而是互相尊重的。',
          '真正爱我的人不会让我为难。',
          '我们可以理性讨论这个问题。',
        ],
        explanation: '这是典型的情感操控，用"爱"来绑架对方。健康的感情是相互尊重的。',
        warningLevel: PUAWarningLevel.high,
      ),
    ],
  };

  /// 根据类别获取场景列表
  static List<CombatScenario> getCombatScenariosByCategory(String category) {
    final allScenarios = <CombatScenario>[];
    for (final scenarios in combatScenarios.values) {
      allScenarios.addAll(scenarios.where((s) => s.category == category));
    }
    return allScenarios;
  }

  /// 根据标签获取场景列表
  static List<CombatScenario> getCombatScenariosByTag(String tag) {
    final allScenarios = <CombatScenario>[];
    for (final scenarios in combatScenarios.values) {
      allScenarios.addAll(scenarios.where((s) => s.tags.contains(tag)));
    }
    return allScenarios;
  }

  /// 获取随机场景
  static CombatScenario getRandomCombatScenario() {
    final allScenarios = <CombatScenario>[];
    for (final scenarios in combatScenarios.values) {
      allScenarios.addAll(scenarios);
    }
    return allScenarios[DateTime.now().millisecond % allScenarios.length];
  }
}

/// 实战训练场景模型
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
}

/// 场景选项模型
class ScenarioOption {
  final String text;
  final bool isCorrect;
  final String feedback;

  const ScenarioOption({
    required this.text,
    required this.isCorrect,
    required this.feedback,
  });
}

/// 反PUA训练场景模型
class AntiPUAScenario {
  final String id;
  final String title;
  final String category;
  final String puaTactic;
  final String hiddenIntent;
  final List<String> counterStrategies;
  final String explanation;
  final PUAWarningLevel warningLevel;

  const AntiPUAScenario({
    required this.id,
    required this.title,
    required this.category,
    required this.puaTactic,
    required this.hiddenIntent,
    required this.counterStrategies,
    required this.explanation,
    required this.warningLevel,
  });
}

/// PUA警告等级
enum PUAWarningLevel {
  low,    // 低危险性
  medium, // 中等危险性
  high,   // 高危险性
}