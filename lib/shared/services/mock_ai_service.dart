// lib/shared/services/mock_ai_service.dart

import 'dart:math';
import '../../core/models/character_model.dart';
import '../../core/models/conversation_model.dart';

/// 模拟AI服务类 - 整个应用的核心业务逻辑
class MockAIService {
  static final Random _random = Random();

  /// 预设对话模板数据库
  static const Map<String, List<ConversationTemplate>> _conversationTemplates = {
    // 温柔女生对话模板
    'gentle_girl': [
      ConversationTemplate(
        triggers: ['你好', 'hi', '嗨', '在吗'],
        responses: [
          '你好呀~ 今天过得怎么样？',
          '嗨，很高兴认识你',
          '你好，看起来你心情不错呢',
        ],
        favorabilityChange: 2,
        stage: ConversationStage.opening,
      ),
      ConversationTemplate(
        triggers: ['工作', '上班', '忙', '累'],
        responses: [
          '工作辛苦了，要注意休息哦',
          '我理解你的辛苦，工作压力大吗？',
          '忙碌的生活也要记得照顾自己',
          '听起来你很努力，但也要劳逸结合',
        ],
        favorabilityChange: 5,
        stage: ConversationStage.developing,
      ),
      ConversationTemplate(
        triggers: ['漂亮', '好看', '美', '可爱'],
        responses: [
          '谢谢夸奖，你真会说话呢',
          '你也很有魅力呀',
          '过奖了，你的眼光真好',
          '听到你这么说我很开心',
        ],
        favorabilityChange: 8,
        stage: ConversationStage.deepening,
      ),
      ConversationTemplate(
        triggers: ['喜欢', '爱好', '兴趣'],
        responses: [
          '我喜欢看书和听音乐，你呢？',
          '平时喜欢安静的活动，比如画画',
          '喜欢和朋友聊天，就像现在这样',
        ],
        favorabilityChange: 4,
        stage: ConversationStage.developing,
      ),
    ],

    // 活泼女生对话模板
    'lively_girl': [
      ConversationTemplate(
        triggers: ['你好', 'hi', '嗨'],
        responses: [
          '嗨嗨！超开心遇到你！',
          '你好呀！今天心情超棒的！',
          'Hi！你看起来很有趣呢！',
        ],
        favorabilityChange: 3,
        stage: ConversationStage.opening,
      ),
      ConversationTemplate(
        triggers: ['有趣', '好玩', '开心'],
        responses: [
          '哈哈，对吧！我也觉得超有趣！',
          '你这么说我更开心了！',
          '和你聊天真的很愉快！',
        ],
        favorabilityChange: 6,
        stage: ConversationStage.developing,
      ),
    ],

    // 优雅女生对话模板
    'elegant_girl': [
      ConversationTemplate(
        triggers: ['你好', 'hi'],
        responses: [
          '您好，很高兴认识您',
          '下午好，今天的天气很不错',
          '您好，希望没有打扰到您',
        ],
        favorabilityChange: 2,
        stage: ConversationStage.opening,
      ),
    ],

    // 阳光男生对话模板
    'sunny_boy': [
      ConversationTemplate(
        triggers: ['你好', 'hi', '兄弟'],
        responses: [
          '嘿！哥们，今天怎么样？',
          '你好！看起来精神不错啊',
          '兄弟好！有什么新鲜事吗？',
        ],
        favorabilityChange: 3,
        stage: ConversationStage.opening,
      ),
    ],
  };

  /// 生成AI回复
  static Future<AIResponse> generateResponse({
    required String userInput,
    required String characterId,
    required int currentRound,
    required List<MessageModel> conversationHistory,
    required int currentFavorability,
  }) async {
    // 模拟网络延迟
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1500)));

    // 获取角色模板
    final templates = _conversationTemplates[characterId] ?? [];
    final stage = _determineConversationStage(currentRound);

    // 寻找匹配的对话模板
    ConversationTemplate? matchedTemplate = _findMatchingTemplate(
      userInput,
      templates,
      stage,
    );

    String response;
    int favorabilityChange;

    if (matchedTemplate != null) {
      // 使用匹配的模板
      response = _selectRandomResponse(matchedTemplate.responses);
      favorabilityChange = matchedTemplate.favorabilityChange;
    } else {
      // 使用默认回复
      response = _generateDefaultResponse(characterId, currentRound, userInput);
      favorabilityChange = _calculateDefaultFavorabilityChange(
        userInput,
        currentFavorability,
        currentRound,
      );
    }

    // 根据角色性格调整回复
    response = _adjustResponseByPersonality(response, characterId, currentFavorability);

    return AIResponse(
      message: response,
      favorabilityChange: favorabilityChange,
      responseTime: DateTime.now(),
    );
  }

  /// 寻找匹配的对话模板
  static ConversationTemplate? _findMatchingTemplate(
    String userInput,
    List<ConversationTemplate> templates,
    ConversationStage stage,
  ) {
    // 首先寻找当前阶段的模板
    final stageTemplates = templates.where((t) => t.stage == stage).toList();

    for (final template in stageTemplates) {
      for (final trigger in template.triggers) {
        if (userInput.contains(trigger)) {
          return template;
        }
      }
    }

    // 如果当前阶段没找到，寻找其他阶段的模板
    for (final template in templates) {
      for (final trigger in template.triggers) {
        if (userInput.contains(trigger)) {
          return template;
        }
      }
    }

    return null;
  }

  /// 选择随机回复
  static String _selectRandomResponse(List<String> responses) {
    return responses[_random.nextInt(responses.length)];
  }

  /// 确定对话阶段
  static ConversationStage _determineConversationStage(int round) {
    if (round <= 5) return ConversationStage.opening;
    if (round <= 15) return ConversationStage.developing;
    if (round <= 25) return ConversationStage.deepening;
    return ConversationStage.mature;
  }

  /// 生成默认回复
  static String _generateDefaultResponse(String characterId, int round, String userInput) {
    final stage = _determineConversationStage(round);

    switch (characterId) {
      case 'gentle_girl':
        return _getGentleGirlDefaultResponse(stage, userInput);
      case 'lively_girl':
        return _getLivelyGirlDefaultResponse(stage, userInput);
      case 'elegant_girl':
        return _getElegantGirlDefaultResponse(stage, userInput);
      case 'sunny_boy':
        return _getSunnyBoyDefaultResponse(stage, userInput);
      default:
        return _getGenericDefaultResponse(stage, userInput);
    }
  }

  /// 温柔女生默认回复
  static String _getGentleGirlDefaultResponse(ConversationStage stage, String userInput) {
    switch (stage) {
      case ConversationStage.opening:
        return ['嗯嗯，我在听', '是这样吗？', '听起来不错呢'][_random.nextInt(3)];
      case ConversationStage.developing:
        return ['我也这么觉得', '你说得对', '真的吗？好有趣'][_random.nextInt(3)];
      case ConversationStage.deepening:
        return ['和你聊天很舒服', '你很会表达呢', '我们很有共同语言'][_random.nextInt(3)];
      case ConversationStage.mature:
        return ['时间过得真快', '今天聊得很开心', '你是个很有趣的人'][_random.nextInt(3)];
    }
  }

  /// 活泼女生默认回复
  static String _getLivelyGirlDefaultResponse(ConversationStage stage, String userInput) {
    switch (stage) {
      case ConversationStage.opening:
        return ['哇真的吗！', '好有趣！', '然后呢然后呢？'][_random.nextInt(3)];
      case ConversationStage.developing:
        return ['太棒了！', '我也是这样想的！', '你好厉害！'][_random.nextInt(3)];
      case ConversationStage.deepening:
        return ['我们好像很合拍呢！', '和你聊天超开心的！', '你真的很有意思！'][_random.nextInt(3)];
      case ConversationStage.mature:
        return ['今天聊得超级开心！', '你是我遇到过最有趣的人之一！', '希望我们能经常聊天！'][_random.nextInt(3)];
    }
  }

  /// 优雅女生默认回复
  static String _getElegantGirlDefaultResponse(ConversationStage stage, String userInput) {
    switch (stage) {
      case ConversationStage.opening:
        return ['是的，我明白', '您说得很有道理', '确实如此'][_random.nextInt(3)];
      case ConversationStage.developing:
        return ['这个观点很有见地', '您的想法很独特', '我很赞同您的看法'][_random.nextInt(3)];
      case ConversationStage.deepening:
        return ['与您交流让我受益匪浅', '您是一个很有内涵的人', '我们的对话很有深度'][_random.nextInt(3)];
      case ConversationStage.mature:
        return ['今天的对话很有收获', '您是个很优雅的人', '希望能有更多这样的交流'][_random.nextInt(3)];
    }
  }

  /// 阳光男生默认回复
  static String _getSunnyBoyDefaultResponse(ConversationStage stage, String userInput) {
    switch (stage) {
      case ConversationStage.opening:
        return ['哈哈，有意思！', '不错不错！', '挺好的！'][_random.nextInt(3)];
      case ConversationStage.developing:
        return ['兄弟说得对！', '我也是这样想的！', '你这想法不错！'][_random.nextInt(3)];
      case ConversationStage.deepening:
        return ['咱们挺投缘的！', '和你聊天很舒服！', '你这人不错！'][_random.nextInt(3)];
      case ConversationStage.mature:
        return ['今天聊得挺开心！', '你是个很不错的朋友！', '以后常联系！'][_random.nextInt(3)];
    }
  }

  /// 通用默认回复
  static String _getGenericDefaultResponse(ConversationStage stage, String userInput) {
    switch (stage) {
      case ConversationStage.opening:
        return ['嗯', '是吗？', '继续说'][_random.nextInt(3)];
      case ConversationStage.developing:
        return ['我明白', '有道理', '然后呢？'][_random.nextInt(3)];
      case ConversationStage.deepening:
        return ['很有意思', '我也这么想', '说得好'][_random.nextInt(3)];
      case ConversationStage.mature:
        return ['聊得不错', '时间过得真快', '今天很开心'][_random.nextInt(3)];
    }
  }

  /// 计算默认好感度变化
  static int _calculateDefaultFavorabilityChange(
    String userInput,
    int currentFavorability,
    int round,
  ) {
    int change = 1; // 基础参与分

    // 字数适中加分
    if (userInput.length >= 10 && userInput.length <= 40) {
      change += 2;
    } else if (userInput.length < 5) {
      change -= 1; // 太短扣分
    }

    // 提问加分
    if (userInput.contains('？') || userInput.contains('?')) {
      change += 3;
    }

    // 积极词汇检测
    final positiveWords = ['喜欢', '开心', '有趣', '不错', '很好', '棒'];
    if (positiveWords.any((word) => userInput.contains(word))) {
      change += 2;
    }

    // 消极词汇扣分
    final negativeWords = ['无聊', '烦', '算了', '随便', '不想'];
    if (negativeWords.any((word) => userInput.contains(word))) {
      change -= 3;
    }

    // 好感度过高时降低增长速度
    if (currentFavorability > 60) {
      change = (change * 0.7).round();
    }

    // 后期对话加分减少
    if (round > 30) {
      change = (change * 0.8).round();
    }

    return change.clamp(-5, 10);
  }

  /// 根据角色性格调整回复
  static String _adjustResponseByPersonality(
    String response,
    String characterId,
    int favorability,
  ) {
    // 根据好感度调整语气
    if (favorability >= 50) {
      // 高好感度时更加亲密
      switch (characterId) {
        case 'gentle_girl':
          if (response.endsWith('呢')) return response;
          if (response.endsWith('。')) return response.replaceAll('。', '呢~');
          return response + '~';
        case 'lively_girl':
          if (!response.contains('！')) return response + '！';
          return response;
        case 'elegant_girl':
          return response; // 保持优雅，不过度亲密
        case 'sunny_boy':
          if (!response.contains('！')) return response + '！';
          return response;
      }
    }

    return response;
  }

  /// 生成对话改进建议
  static List<String> generateImprovementSuggestions(
    String originalMessage,
    String characterId,
    int favorabilityChange,
  ) {
    final suggestions = <String>[];

    // 基于消息长度的建议
    if (originalMessage.length < 5) {
      suggestions.add('消息太短了，试试加入更多细节或提问');
    }

    // 基于好感度变化的建议
    if (favorabilityChange <= 0) {
      suggestions.add('可以尝试表达更多关心或兴趣');
      suggestions.add('适当的赞美和认可会很有效');
    }

    // 基于角色特点的建议
    switch (characterId) {
      case 'gentle_girl':
        suggestions.add('温柔的女生喜欢被关心和理解');
        break;
      case 'lively_girl':
        suggestions.add('活泼的女生喜欢有趣和积极的话题');
        break;
      case 'elegant_girl':
        suggestions.add('优雅的女生重视有内涵的交流');
        break;
    }

    return suggestions.take(3).toList(); // 最多返回3条建议
  }
}

/// 对话模板类
class ConversationTemplate {
  final List<String> triggers;      // 触发词
  final List<String> responses;     // 回复列表
  final int favorabilityChange;     // 好感度变化
  final ConversationStage stage;    // 对话阶段

  const ConversationTemplate({
    required this.triggers,
    required this.responses,
    required this.favorabilityChange,
    required this.stage,
  });
}

/// 对话阶段枚举
enum ConversationStage {
  opening,    // 开场阶段
  developing, // 发展阶段
  deepening,  // 深入阶段
  mature,     // 成熟阶段
}

/// AI回复结果类
class AIResponse {
  final String message;              // 回复消息
  final int favorabilityChange;      // 好感度变化
  final DateTime responseTime;       // 回复时间

  const AIResponse({
    required this.message,
    required this.favorabilityChange,
    required this.responseTime,
  });
}