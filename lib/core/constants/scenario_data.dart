// lib/core/constants/scenario_data.dart (重新设计版)

/// 训练场景数据配置
class ScenarioData {
  /// 实战训练营场景数据
  static const Map<String, List<CombatScenario>> combatScenarios = {
    'anti_routine': [
      CombatScenario(
        id: 'routine_001',
        title: '探底测试：女性朋友问题',
        category: '反套路专项',
        background: '你们约会几次了，气氛很好。她突然问了这个试探性问题，想要了解你的社交圈和态度...',
        question: '你还有别的女性朋友吗？',
        options: [
          ScenarioOption(
            text: '没有，你是唯一的',
            isCorrect: false,
            feedback: '过度表态显得缺乏社交价值，可能让对方产生压力。',
          ),
          ScenarioOption(
            text: '有几个普通朋友，大家关系都很正常',
            isCorrect: true,
            feedback: '诚实且有界限感，展现正常社交圈，增加自己的吸引力。',
          ),
          ScenarioOption(
            text: '这重要吗？我们聊点别的',
            isCorrect: false,
            feedback: '回避问题会让对方觉得你在隐瞒什么。',
          ),
        ],
        explanation: '面对试探性问题，诚实但有分寸的回答最有效。既展现了社交能力，又没有让对方感到威胁。',
        tags: ['测试性问题', '社交价值', '边界设定'],
      ),
      CombatScenario(
        id: 'routine_002',
        title: '情感绑架：时间投资测试',
        category: '反套路专项',
        background: '你今晚原本有其他安排，她突然说想见你，这是在测试你对她的重视程度...',
        question: '我知道你今晚有安排，但我突然很想见你',
        options: [
          ScenarioOption(
            text: '我马上取消安排过来找你',
            isCorrect: false,
            feedback: '过度迎合会失去独立性，降低自己的价值。',
          ),
          ScenarioOption(
            text: '我也想见你，但今天确实不方便，明天怎么样？',
            isCorrect: true,
            feedback: '既表达了想见的意愿，又坚持了自己的边界，展现成熟。',
          ),
          ScenarioOption(
            text: '你怎么总是这样临时通知',
            isCorrect: false,
            feedback: '抱怨会破坏关系氛围，让对方感到被责备。',
          ),
        ],
        explanation: '保持自己的计划和节奏是维护平等关系的关键，同时要表达关心。',
        tags: ['时间管理', '边界坚持', '关系平等'],
      ),
      CombatScenario(
        id: 'routine_003',
        title: '价值观试探：经济观念',
        category: '反套路专项',
        background: '约会进行到一半，在讨论买单时，她抛出了这个问题来了解你的价值观...',
        question: '你觉得约会应该谁买单？',
        options: [
          ScenarioOption(
            text: '当然应该我买单，这是绅士风度',
            isCorrect: false,
            feedback: '传统观念可能显得刻板，不利于平等关系发展。',
          ),
          ScenarioOption(
            text: '我觉得可以轮流请客，或者AA，看具体情况',
            isCorrect: true,
            feedback: '展现现代平等观念，有利于建立健康的伙伴关系。',
          ),
          ScenarioOption(
            text: '既然问了，那就AA制吧',
            isCorrect: false,
            feedback: '过于直接可能让对方觉得你计较或不够体贴。',
          ),
        ],
        explanation: '现代关系中，平等和灵活的经济观念更受欢迎，体现了对对方的尊重。',
        tags: ['价值观展示', '经济观念', '平等关系'],
      ),
    ],
    'workplace_crisis': [
      CombatScenario(
        id: 'workplace_001',
        title: '上级私下接触',
        category: '职场高危',
        background: '公司聚餐后，平时严肃的女上级单独找你聊天，氛围变得微妙...',
        question: '工作之外，我其实是个很随和的人',
        options: [
          ScenarioOption(
            text: '是的，您平时工作很辛苦',
            isCorrect: false,
            feedback: '太正式的称呼拉开了距离，错失拉近机会。',
          ),
          ScenarioOption(
            text: '能感觉到，私下的你更真实自然',
            isCorrect: true,
            feedback: '既认可了她的话，又自然地拉近了距离，但保持了分寸。',
          ),
          ScenarioOption(
            text: '那我们以后可以经常私下交流',
            isCorrect: false,
            feedback: '过于主动可能让对方感到压力，职场关系需要谨慎。',
          ),
        ],
        explanation: '职场关系转向私人接触需要格外谨慎，要渐进式发展，避免过急。',
        tags: ['职场关系', '边界把握', '渐进发展'],
      ),
      CombatScenario(
        id: 'workplace_002',
        title: '同事暧昧试探',
        category: '职场高危',
        background: '项目合作中，女同事开始有一些暧昧的举动和话语，你需要恰当回应...',
        question: '和你一起工作特别开心，感觉很有默契',
        options: [
          ScenarioOption(
            text: '我也是，我们很合拍',
            isCorrect: true,
            feedback: '既回应了好意，又保持在工作层面，安全且友善。',
          ),
          ScenarioOption(
            text: '是啊，也许我们可以发展点工作以外的关系',
            isCorrect: false,
            feedback: '在职场环境中过于直接可能造成不必要的风险。',
          ),
          ScenarioOption(
            text: '嗯，专业合作确实很重要',
            isCorrect: false,
            feedback: '过于冷淡可能让对方觉得被拒绝，影响工作关系。',
          ),
        ],
        explanation: '职场暧昧需要谨慎处理，既不要过于冷淡，也不要过于激进。',
        tags: ['职场暧昧', '风险控制', '关系平衡'],
      ),
      CombatScenario(
        id: 'workplace_003',
        title: '客户关系越界',
        category: '职场高危',
        background: '重要女客户在商务场合表现出超出工作范围的兴趣，需要专业处理...',
        question: '合作这么愉快，私下我们也可以做朋友',
        options: [
          ScenarioOption(
            text: '当然可以，我很愿意',
            isCorrect: false,
            feedback: '客户关系复杂，贸然答应可能带来职业风险。',
          ),
          ScenarioOption(
            text: '很荣幸，不过我习惯将工作和私生活分开',
            isCorrect: true,
            feedback: '礼貌地设定界限，既不得罪客户，又保护自己。',
          ),
          ScenarioOption(
            text: '这个...公司有相关规定',
            isCorrect: false,
            feedback: '推给公司规定显得不够诚恳，可能让客户不快。',
          ),
        ],
        explanation: '客户关系需要专业边界，礼貌但坚定地设定界限是最佳策略。',
        tags: ['客户关系', '职业边界', '风险管理'],
      ),
    ],
    'social_crisis': [
      CombatScenario(
        id: 'social_001',
        title: '聚会冷场救急',
        category: '聚会冷场处理',
        background: '朋友聚会时，大家正聊得热烈，突然话题断了，现场陷入尴尬的沉默...',
        question: '(全场沉默了30秒，气氛变得尴尬)',
        options: [
          ScenarioOption(
            text: '怎么突然都不说话了？',
            isCorrect: false,
            feedback: '直接指出尴尬只会让场面更加尴尬。',
          ),
          ScenarioOption(
            text: '刚才那首背景音乐不错，是什么歌？',
            isCorrect: true,
            feedback: '转移到中性话题，自然打破沉默，重新激活氛围。',
          ),
          ScenarioOption(
            text: '要不我们玩个游戏吧',
            isCorrect: false,
            feedback: '过于刻意的转场可能显得突兀。',
          ),
        ],
        explanation: '冷场时最好找一个在场的中性元素作为新话题，自然过渡。',
        tags: ['冷场处理', '话题转移', '氛围调节'],
      ),
      CombatScenario(
        id: 'social_002',
        title: '群聊焦点争夺',
        category: '聚会冷场处理',
        background: '在朋友聚会中，有人一直在讲自己的成功故事，垄断了谈话，你想适当参与...',
        question: '(某人已经连续讲了20分钟自己的工作成就)',
        options: [
          ScenarioOption(
            text: '哇，真厉害！我也有个类似的经历...',
            isCorrect: true,
            feedback: '先认可对方，再自然地分享，平衡话语权。',
          ),
          ScenarioOption(
            text: '让其他人也说说吧',
            isCorrect: false,
            feedback: '直接打断可能让对方感到不快。',
          ),
          ScenarioOption(
            text: '继续保持沉默',
            isCorrect: false,
            feedback: '错失参与机会，可能边缘化自己。',
          ),
        ],
        explanation: '在群体谈话中，通过认可他人再分享自己的方式最容易获得话语权。',
        tags: ['群体交流', '话语权', '社交技巧'],
      ),
      CombatScenario(
        id: 'social_003',
        title: '敏感话题转移',
        category: '聚会冷场处理',
        background: '聚会中有人提起了敏感的政治话题，现场气氛开始紧张，需要及时化解...',
        question: '(有人开始激烈讨论敏感政治话题，现场气氛紧张)',
        options: [
          ScenarioOption(
            text: '我们不要聊这些沉重的话题',
            isCorrect: false,
            feedback: '直接阻止可能让提话题的人感到被否定。',
          ),
          ScenarioOption(
            text: '说到这个，我想起今天看到一个有趣的新闻...',
            isCorrect: true,
            feedback: '承接话题但转向轻松方向，巧妙化解紧张。',
          ),
          ScenarioOption(
            text: '我觉得大家说得都有道理',
            isCorrect: false,
            feedback: '模糊表态可能让争论继续，没有有效转移话题。',
          ),
        ],
        explanation: '面对敏感话题，最好的策略是承接但转向，而不是直接阻止或参与争论。',
        tags: ['敏感话题', '危机化解', '气氛控制'],
      ),
      CombatScenario(
        id: 'social_004',
        title: '新人融入协助',
        category: '聚会冷场处理',
        background: '聚会中来了一个大家都不太熟悉的新人，TA显得有些拘谨，你想帮助TA融入...',
        question: '(新人站在角落，看起来有些格格不入)',
        options: [
          ScenarioOption(
            text: '直接走过去和新人聊天',
            isCorrect: false,
            feedback: '单独关注可能让新人感到被特殊化。',
          ),
          ScenarioOption(
            text: '把新人介绍给其他人，并找共同话题',
            isCorrect: true,
            feedback: '通过介绍和共同话题帮助新人自然融入群体。',
          ),
          ScenarioOption(
            text: '让新人自己慢慢适应',
            isCorrect: false,
            feedback: '缺乏主动帮助，错失展现社交能力的机会。',
          ),
        ],
        explanation: '帮助新人融入群体既展现了自己的社交能力，又营造了友好氛围。',
        tags: ['新人融入', '社交引导', '群体和谐'],
      ),
    ],
  };

  /// 根据类别获取场景列表
  static List<CombatScenario> getCombatScenariosByCategory(String category) {
    return combatScenarios[category] ?? [];
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
    if (allScenarios.isEmpty) {
      throw Exception('没有可用的训练场景');
    }
    return allScenarios[DateTime.now().millisecond % allScenarios.length];
  }

  /// 获取所有可用的训练类别
  static List<String> getAvailableCategories() {
    return combatScenarios.keys.toList();
  }

  /// 获取场景总数
  static int getTotalScenarioCount() {
    int total = 0;
    for (final scenarios in combatScenarios.values) {
      total += scenarios.length;
    }
    return total;
  }

  /// 获取某类别的场景数量
  static int getCategoryScenarioCount(String category) {
    return combatScenarios[category]?.length ?? 0;
  }

  /// 获取训练模块信息
  static List<TrainingModule> getTrainingModules() {
    return [
      TrainingModule(
        id: 'anti_routine',
        name: '反套路专项',
        icon: '🎯',
        description: '识破并优雅应对各种测试',
        scenarios: [
          '探底测试：女性朋友问题',
          '情感绑架：时间投资测试',
          '价值观试探：经济观念',
        ],
        difficulty: TrainingDifficulty.medium,
      ),
      TrainingModule(
        id: 'workplace_crisis',
        name: '职场高危',
        icon: '💼',
        description: '职场关系的专业处理',
        scenarios: [
          '上级私下接触',
          '同事暧昧试探',
          '客户关系越界',
        ],
        difficulty: TrainingDifficulty.hard,
      ),
      TrainingModule(
        id: 'social_crisis',
        name: '聚会冷场处理',
        icon: '🎉',
        description: '社交场合的氛围调节',
        scenarios: [
          '聚会冷场救急',
          '群聊焦点争夺',
          '敏感话题转移',
          '新人融入协助',
        ],
        difficulty: TrainingDifficulty.easy,
      ),
    ];
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

/// 训练模块信息
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

/// 训练难度枚举
enum TrainingDifficulty {
  easy,    // 简单
  medium,  // 中等
  hard,    // 困难
}