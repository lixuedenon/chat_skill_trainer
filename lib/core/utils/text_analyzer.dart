// lib/core/utils/text_analyzer.dart

import '../models/conversation_model.dart';

/// 文字分析工具类
class TextAnalyzer {
  /// 计算文字密度系数
  /// 根据字符数量返回不同的系数，用于计算有效轮数
  static double calculateDensityCoefficient(int characterCount) {
    if (characterCount <= 10) {
      return 0.5;  // 很短的消息，系数较低
    } else if (characterCount <= 25) {
      return 0.8;  // 中短消息，系数正常偏低
    } else if (characterCount <= 40) {
      return 1.0;  // 标准长度消息，系数为1
    } else if (characterCount <= 50) {
      return 1.2;  // 较长消息，系数较高
    } else {
      return 1.0;  // 超长消息截断后按标准计算
    }
  }

  /// 计算有效轮数
  /// 基于用户消息的密度系数计算实际对话效果
  static int calculateEffectiveRounds(List<MessageModel> messages) {
    double totalDensity = 0;
    int userMessageCount = 0;

    for (final message in messages) {
      if (message.isUser) {
        totalDensity += message.densityCoefficient;
        userMessageCount++;
      }
    }

    return totalDensity.round();
  }

  /// 分析用户消息质量
  /// 返回消息的质量分数 (0-10)
  static double analyzeMessageQuality(String message) {
    double score = 5.0; // 基础分数
    final length = message.length;

    // 长度评分
    if (length < 3) {
      score -= 2.0; // 太短扣分
    } else if (length >= 10 && length <= 40) {
      score += 1.0; // 适中长度加分
    } else if (length > 50) {
      score -= 1.0; // 过长扣分
    }

    // 问号加分（显示关心和兴趣）
    if (message.contains('?') || message.contains('？')) {
      score += 1.5;
    }

    // 情感词汇分析
    final positiveWords = ['喜欢', '开心', '有趣', '不错', '很好', '棒', '厉害'];
    final negativeWords = ['无聊', '烦', '算了', '随便', '不想', '没意思'];

    for (final word in positiveWords) {
      if (message.contains(word)) {
        score += 0.5;
        break;
      }
    }

    for (final word in negativeWords) {
      if (message.contains(word)) {
        score -= 1.0;
        break;
      }
    }

    // 赞美词汇加分
    final compliments = ['漂亮', '好看', '聪明', '有趣', '可爱', '温柔', '优雅', '厉害'];
    for (final compliment in compliments) {
      if (message.contains(compliment)) {
        score += 1.0;
        break;
      }
    }

    // 个人分享加分
    if (message.contains('我') && (message.contains('喜欢') || message.contains('觉得'))) {
      score += 0.5;
    }

    return score.clamp(0.0, 10.0);
  }

  /// 检测消息类型
  static MessageType detectMessageType(String message) {
    // 问题类型
    if (message.contains('?') || message.contains('？')) {
      return MessageType.question;
    }

    // 赞美类型
    final compliments = ['漂亮', '好看', '聪明', '有趣', '可爱', '温柔', '优雅'];
    for (final compliment in compliments) {
      if (message.contains(compliment)) {
        return MessageType.compliment;
      }
    }

    // 分享类型
    if (message.contains('我') && message.length > 15) {
      return MessageType.sharing;
    }

    // 简单回应
    if (message.length <= 5) {
      return MessageType.simple;
    }

    return MessageType.normal;
  }

  /// 提取消息中的关键词
  static List<String> extractKeywords(String message) {
    final keywords = <String>[];

    // 兴趣爱好关键词
    final hobbies = ['读书', '看书', '音乐', '电影', '旅行', '运动', '健身', '做饭', '摄影', '画画'];
    for (final hobby in hobbies) {
      if (message.contains(hobby)) {
        keywords.add(hobby);
      }
    }

    // 工作相关关键词
    final workWords = ['工作', '上班', '同事', '老板', '项目', '忙'];
    for (final word in workWords) {
      if (message.contains(word)) {
        keywords.add('工作');
        break;
      }
    }

    // 情感关键词
    final emotions = ['开心', '难过', '紧张', '兴奋', '累', '轻松'];
    for (final emotion in emotions) {
      if (message.contains(emotion)) {
        keywords.add('情感_$emotion');
      }
    }

    return keywords;
  }

  /// 计算消息相似度
  /// 用于检测用户是否重复说类似的话
  static double calculateSimilarity(String message1, String message2) {
    if (message1 == message2) return 1.0;

    final words1 = message1.split('').where((char) => char != ' ').toList();
    final words2 = message2.split('').where((char) => char != ' ').toList();

    if (words1.isEmpty || words2.isEmpty) return 0.0;

    int commonChars = 0;
    for (final char in words1) {
      if (words2.contains(char)) {
        commonChars++;
      }
    }

    return commonChars / (words1.length + words2.length - commonChars);
  }

  /// 分析对话进展情况
  static ConversationProgress analyzeProgress(List<MessageModel> messages) {
    if (messages.length < 6) return ConversationProgress.opening;
    if (messages.length < 20) return ConversationProgress.developing;
    if (messages.length < 35) return ConversationProgress.deepening;
    return ConversationProgress.mature;
  }

  /// 检测是否包含敏感内容
  static bool containsSensitiveContent(String message) {
    final sensitiveWords = ['死', '自杀', '伤害', '血', '暴力'];
    return sensitiveWords.any((word) => message.contains(word));
  }

  /// 评估消息的情商指数
  static double calculateEQScore(String message, String context) {
    double eqScore = 5.0; // 基础分数

    // 共情加分
    final empathyWords = ['理解', '感受', '辛苦', '不容易', '支持'];
    for (final word in empathyWords) {
      if (message.contains(word)) {
        eqScore += 1.0;
        break;
      }
    }

    // 关怀加分
    final careWords = ['关心', '担心', '照顾', '注意', '小心'];
    for (final word in careWords) {
      if (message.contains(word)) {
        eqScore += 1.0;
        break;
      }
    }

    // 鼓励加分
    final encourageWords = ['加油', '相信', '一定可以', '没问题', '很棒'];
    for (final word in encourageWords) {
      if (message.contains(word)) {
        eqScore += 1.0;
        break;
      }
    }

    // 过于直接扣分
    if (message.length < 5 && !message.contains('?')) {
      eqScore -= 1.0;
    }

    return eqScore.clamp(0.0, 10.0);
  }

  /// 生成消息改进建议
  static String generateImprovementSuggestion(String original) {
    final length = original.length;
    final quality = analyzeMessageQuality(original);

    if (length < 5) {
      return '消息太短，试试加入更多细节或提问来延续话题';
    }

    if (quality < 4.0) {
      return '可以尝试表达更多关心或兴趣，让对话更有温度';
    }

    if (!original.contains('?') && !original.contains('？')) {
      return '适当提问可以让对话更有互动性';
    }

    return '很好的回应，继续保持这种沟通方式';
  }

  /// 检查消息是否过于频繁
  static bool isMessageTooFrequent(List<MessageModel> recentMessages, Duration timeWindow) {
    if (recentMessages.length < 3) return false;

    final now = DateTime.now();
    final recentCount = recentMessages.where((msg) =>
      msg.isUser && now.difference(msg.timestamp) < timeWindow
    ).length;

    return recentCount > 5; // 5分钟内超过5条消息视为过于频繁
  }
}

/// 消息类型枚举
enum MessageType {
  question,    // 问题
  compliment,  // 赞美
  sharing,     // 分享
  simple,      // 简单回应
  normal,      // 普通消息
}

/// 对话进展枚举
enum ConversationProgress {
  opening,     // 开场阶段
  developing,  // 发展阶段
  deepening,   // 深入阶段
  mature,      // 成熟阶段
}