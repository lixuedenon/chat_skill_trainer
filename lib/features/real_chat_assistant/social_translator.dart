// lib/features/real_chat_assistant/social_translator.dart

/// 社交翻译官 - 解读女生话语的隐含意思
class SocialTranslator {
  /// 翻译消息的隐含意思
  static Future<SocialTranslation> translateMessage(String message) async {
    // 模拟分析时间
    await Future.delayed(Duration(milliseconds: 800));

    final translation = _analyzeMessage(message);
    return translation;
  }

  /// 分析消息内容
  static SocialTranslation _analyzeMessage(String message) {
    final normalizedMessage = message.trim().toLowerCase();

    // 检查经典表达模式
    final classicPattern = _checkClassicPatterns(normalizedMessage);
    if (classicPattern != null) return classicPattern;

    // 分析情感状态
    final emotionalState = _detectEmotionalState(normalizedMessage);

    // 分析交流意图
    final communicationIntent = _detectCommunicationIntent(normalizedMessage);

    // 生成翻译结果
    return SocialTranslation(
      originalMessage: message,
      hiddenMeaning: _generateHiddenMeaning(normalizedMessage, emotionalState),
      emotionalState: emotionalState,
      communicationIntent: communicationIntent,
      confidence: _calculateConfidence(normalizedMessage),
      suggestedResponse: _generateSuggestedResponse(emotionalState, communicationIntent),
      warningLevel: _assessWarningLevel(emotionalState),
    );
  }

  /// 检查经典表达模式
  static SocialTranslation? _checkClassicPatterns(String message) {
    final patterns = {
      '你忙就不用陪我了': SocialTranslation(
        originalMessage: message,
        hiddenMeaning: '我希望你说"再忙也要陪你"，我需要你的关心和重视',
        emotionalState: EmotionalState.seeking_attention,
        communicationIntent: CommunicationIntent.testing_care,
        confidence: 0.95,
        suggestedResponse: '再忙也要陪你，你对我很重要',
        warningLevel: WarningLevel.medium,
      ),

      '你决定就好': SocialTranslation(
        originalMessage: message,
        hiddenMeaning: '我有自己的想法，但希望你能猜出来或主动询问我的意见',
        emotionalState: EmotionalState.testing,
        communicationIntent: CommunicationIntent.indirect_communication,
        confidence: 0.9,
        suggestedResponse: '我想听听你的想法，你比较倾向于哪个？',
        warningLevel: WarningLevel.low,
      ),

      '没事': SocialTranslation(
        originalMessage: message,
        hiddenMeaning: '明显有事，但我希望你能主动关心和询问',
        emotionalState: EmotionalState.upset,
        communicationIntent: CommunicationIntent.seeking_comfort,
        confidence: 0.85,
        suggestedResponse: '我感觉你好像有什么心事，愿意和我说说吗？',
        warningLevel: WarningLevel.high,
      ),

      '都可以': SocialTranslation(
        originalMessage: message,
        hiddenMeaning: '我其实有偏好，但不想直接说出来，希望你了解我',
        emotionalState: EmotionalState.testing,
        communicationIntent: CommunicationIntent.testing_understanding,
        confidence: 0.8,
        suggestedResponse: '我想选个你会喜欢的，平时你更偏向哪种？',
        warningLevel: WarningLevel.low,
      ),
    };

    for (final entry in patterns.entries) {
      if (message.contains(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }

  /// 检测情感状态
  static EmotionalState _detectEmotionalState(String message) {
    // 寻求关注的信号
    if (message.contains('忙') || message.contains('不用') || message.contains('算了')) {
      return EmotionalState.seeking_attention;
    }

    // 测试性信号
    if (message.contains('你觉得') || message.contains('你说') || message.contains('决定')) {
      return EmotionalState.testing;
    }

    // 不高兴信号
    if (message.contains('没事') || message.contains('没什么') || message.contains('无所谓')) {
      return EmotionalState.upset;
    }

    // 撒娇信号
    if (message.contains('人家') || message.contains('嘛') || message.contains('~')) {
      return EmotionalState.playful;
    }

    return EmotionalState.neutral;
  }

  /// 检测交流意图
  static CommunicationIntent _detectCommunicationIntent(String message) {
    if (message.contains('?') || message.contains('？')) {
      return CommunicationIntent.seeking_information;
    }

    if (message.contains('忙') || message.contains('累')) {
      return CommunicationIntent.seeking_comfort;
    }

    if (message.contains('你') && (message.contains('觉得') || message.contains('想'))) {
      return CommunicationIntent.testing_understanding;
    }

    return CommunicationIntent.general_chat;
  }

  /// 生成隐含意思
  static String _generateHiddenMeaning(String message, EmotionalState state) {
    switch (state) {
      case EmotionalState.seeking_attention:
        return '希望得到更多关注和重视，想要感受到被在意';
      case EmotionalState.testing:
        return '在测试你是否了解她，或者是否真的关心她的想法';
      case EmotionalState.upset:
        return '心情不好，需要安慰和理解，但不想直接表达';
      case EmotionalState.playful:
        return '心情不错，可能在撒娇或者想要更亲密的互动';
      case EmotionalState.neutral:
        return '表面意思，没有特别的隐含信息';
    }
  }

  /// 计算置信度
  static double _calculateConfidence(String message) {
    double confidence = 0.5; // 基础置信度

    // 长度因素
    if (message.length < 10) confidence += 0.2; // 短消息通常有隐含意思

    // 关键词因素
    final keyWords = ['没事', '随便', '都可以', '不用', '算了'];
    for (final word in keyWords) {
      if (message.contains(word)) {
        confidence += 0.3;
        break;
      }
    }

    // 标点符号
    if (!message.contains('!') && !message.contains('！')) {
      confidence += 0.1; // 平淡语气通常有隐含意思
    }

    return confidence.clamp(0.0, 1.0);
  }

  /// 生成建议回复
  static String _generateSuggestedResponse(EmotionalState state, CommunicationIntent intent) {
    switch (state) {
      case EmotionalState.seeking_attention:
        return '我很在意你的感受，告诉我你在想什么好吗？';
      case EmotionalState.testing:
        return '我想了解你真正的想法，你的意见对我很重要';
      case EmotionalState.upset:
        return '我感觉你可能有些不开心，需要我陪陪你吗？';
      case EmotionalState.playful:
        return '你这样说话真可爱，我很喜欢和你聊天';
      case EmotionalState.neutral:
        return '继续保持自然的对话就好';
    }
  }

  /// 评估警告等级
  static WarningLevel _assessWarningLevel(EmotionalState state) {
    switch (state) {
      case EmotionalState.upset:
        return WarningLevel.high; // 需要立即关注
      case EmotionalState.seeking_attention:
      case EmotionalState.testing:
        return WarningLevel.medium; // 需要谨慎回应
      case EmotionalState.playful:
      case EmotionalState.neutral:
        return WarningLevel.low; // 正常交流
    }
  }
}

/// 社交翻译结果
class SocialTranslation {
  final String originalMessage;        // 原始消息
  final String hiddenMeaning;         // 隐含意思
  final EmotionalState emotionalState; // 情感状态
  final CommunicationIntent communicationIntent; // 交流意图
  final double confidence;             // 置信度
  final String suggestedResponse;      // 建议回复
  final WarningLevel warningLevel;     // 警告等级

  const SocialTranslation({
    required this.originalMessage,
    required this.hiddenMeaning,
    required this.emotionalState,
    required this.communicationIntent,
    required this.confidence,
    required this.suggestedResponse,
    required this.warningLevel,
  });
}

/// 情感状态
enum EmotionalState {
  seeking_attention,  // 寻求关注
  testing,           // 测试
  upset,            // 不高兴
  playful,          // 撒娇/俏皮
  neutral,          // 中性
}

/// 交流意图
enum CommunicationIntent {
  testing_care,              // 测试关心程度
  testing_understanding,     // 测试理解程度
  seeking_comfort,          // 寻求安慰
  seeking_information,      // 寻求信息
  indirect_communication,   // 间接交流
  general_chat,            // 一般聊天
}

/// 警告等级
enum WarningLevel {
  low,     // 低风险
  medium,  // 中等风险
  high,    // 高风险
}

extension EmotionalStateExtension on EmotionalState {
  String get displayName {
    switch (this) {
      case EmotionalState.seeking_attention:
        return '寻求关注';
      case EmotionalState.testing:
        return '测试态度';
      case EmotionalState.upset:
        return '心情不好';
      case EmotionalState.playful:
        return '撒娇俏皮';
      case EmotionalState.neutral:
        return '正常交流';
    }
  }

  String get emoji {
    switch (this) {
      case EmotionalState.seeking_attention:
        return '🥺';
      case EmotionalState.testing:
        return '🤔';
      case EmotionalState.upset:
        return '😔';
      case EmotionalState.playful:
        return '😊';
      case EmotionalState.neutral:
        return '😐';
    }
  }
}