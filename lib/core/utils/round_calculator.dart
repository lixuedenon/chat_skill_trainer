// lib/core/utils/round_calculator.dart

import '../models/conversation_model.dart';

/// 轮数状态枚举
enum RoundStatus {
  early,      // 初期阶段
  perfect,    // 完美区间
  acceptable, // 可接受区间
  warning,    // 警告区间
  forcedEnd,  // 强制结束
}

/// 轮数计算工具类
class RoundCalculator {
  // 常量定义
  static const int PERFECT_ZONE_START = 15;    // 完美区间开始
  static const int PERFECT_ZONE_END = 25;      // 完美区间结束
  static const int ACCEPTABLE_ZONE_END = 35;   // 可接受区间结束
  static const int WARNING_ZONE_END = 45;      // 警告区间结束
  static const int MAX_ROUNDS = 45;            // 最大轮数

  /// 获取当前轮数状态
  static RoundStatus getRoundStatus(int effectiveRounds) {
    if (effectiveRounds < PERFECT_ZONE_START) {
      return RoundStatus.early;
    } else if (effectiveRounds <= PERFECT_ZONE_END) {
      return RoundStatus.perfect;
    } else if (effectiveRounds <= ACCEPTABLE_ZONE_END) {
      return RoundStatus.acceptable;
    } else if (effectiveRounds < MAX_ROUNDS) {
      return RoundStatus.warning;
    } else {
      return RoundStatus.forcedEnd;
    }
  }

  /// 获取状态对应的提示消息
  static String getStatusMessage(RoundStatus status) {
    switch (status) {
      case RoundStatus.early:
        return ''; // 初期不显示提示
      case RoundStatus.perfect:
        return '💡 聊天氛围很好！可以考虑在高潮时优雅结束，给对方留下好印象';
      case RoundStatus.acceptable:
        return '⚠️ 建议寻找合适的话题收尾点，避免聊到无话可说的尴尬';
      case RoundStatus.warning:
        return '🚨 强烈建议结束对话！过长的聊天会消耗彼此的新鲜感';
      case RoundStatus.forcedEnd:
        return '❌ 已达到最大轮数，系统将协助你优雅地结束这次对话';
    }
  }

  /// 获取详细的轮数提示信息
  static String getDetailedMessage(int effectiveRounds, RoundStatus status) {
    switch (status) {
      case RoundStatus.early:
        return '对话刚刚开始，慢慢建立好感度吧';
      case RoundStatus.perfect:
        return '现在是结束对话的黄金时机($effectiveRounds轮)，适度的意犹未尽会让人更想了解你';
      case RoundStatus.acceptable:
        return '对话已经比较深入($effectiveRounds轮)，可以开始考虑如何优雅地结束了';
      case RoundStatus.warning:
        return '对话时间过长($effectiveRounds轮)，建议立即寻找合适的结束点，避免透支好感度';
      case RoundStatus.forcedEnd:
        return '对话必须结束了，长时间聊天会让人感到疲劳，影响下次交流的期待';
    }
  }

  /// 获取状态对应的颜色代码
  static String getStatusColor(RoundStatus status) {
    switch (status) {
      case RoundStatus.early:
        return '#4CAF50'; // 绿色
      case RoundStatus.perfect:
        return '#2196F3'; // 蓝色
      case RoundStatus.acceptable:
        return '#FF9800'; // 橙色
      case RoundStatus.warning:
        return '#F44336'; // 红色
      case RoundStatus.forcedEnd:
        return '#9C27B0'; // 紫色
    }
  }

  /// 计算进度百分比 (0.0 - 1.0)
  static double calculateProgress(int effectiveRounds) {
    return (effectiveRounds / MAX_ROUNDS).clamp(0.0, 1.0);
  }

  /// 获取建议的结束话术
  static List<String> getEndingSuggestions(RoundStatus status, int favorability) {
    switch (status) {
      case RoundStatus.perfect:
        if (favorability >= 40) {
          return [
            '我们聊得很投机，不过我要去忙了，期待下次继续这个话题',
            '时间过得真快，我还有些事情要处理，今天聊得很开心',
            '很高兴认识你，我先去忙工作了，有时间再聊',
          ];
        } else {
          return [
            '聊得很愉快，不过时间不早了，我要去休息了',
            '今天的对话让我很舒服，我先去做其他事情了',
            '很开心能和你聊天，我要去忙了，再见',
          ];
        }
      case RoundStatus.acceptable:
        return [
          '时间过得真快，我还有些事情要处理，今天聊得很开心',
          '看时间不早了，我们今天就先聊到这里吧',
          '很高兴和你聊天，我要去忙其他事情了，回头见',
        ];
      case RoundStatus.warning:
        return [
          '聊了这么久，我有点累了，我们休息一下吧',
          '时间真的很晚了，我要去休息了，晚安',
          '今天聊得很多，我需要整理一下思绪，先这样吧',
        ];
      case RoundStatus.forcedEnd:
        return [
          '今天聊了很多内容，我需要时间消化一下，我们改天再聊',
          '感觉聊得有点累了，我要去休息了，谢谢你的陪伴',
          '时间真的太晚了，我必须要去睡觉了，晚安',
        ];
      default:
        return ['再见'];
    }
  }

  /// 计算推荐的用户轮数上限（基于用户习惯）
  static int calculateRecommendedLimit(List<MessageModel> messages) {
    if (messages.isEmpty) return MAX_ROUNDS;

    // 计算用户的平均字数
    final userMessages = messages.where((msg) => msg.isUser).toList();
    if (userMessages.isEmpty) return MAX_ROUNDS;

    final averageChars = userMessages
        .map((msg) => msg.characterCount)
        .reduce((a, b) => a + b) / userMessages.length;

    // 根据平均字数调整轮数限制
    if (averageChars <= 10) {
      return (MAX_ROUNDS * 1.5).round(); // 简短消息允许更多轮数
    } else if (averageChars <= 25) {
      return MAX_ROUNDS;
    } else if (averageChars <= 40) {
      return (MAX_ROUNDS * 0.8).round();
    } else {
      return (MAX_ROUNDS * 0.7).round(); // 长消息建议更少轮数
    }
  }

  /// 检查是否应该显示提示
  static bool shouldShowPrompt(int effectiveRounds, RoundStatus lastStatus) {
    final currentStatus = getRoundStatus(effectiveRounds);

    // 状态发生变化时显示提示
    if (currentStatus != lastStatus) {
      return currentStatus != RoundStatus.early;
    }

    // 在关键节点重复提醒
    if (currentStatus == RoundStatus.warning && effectiveRounds % 5 == 0) {
      return true;
    }

    return false;
  }

  /// 获取轮数阶段描述
  static String getPhaseDescription(int effectiveRounds) {
    if (effectiveRounds < 5) {
      return '破冰阶段';
    } else if (effectiveRounds < 15) {
      return '建立联系';
    } else if (effectiveRounds < 25) {
      return '深入了解';
    } else if (effectiveRounds < 35) {
      return '关系发展';
    } else {
      return '维持热度';
    }
  }

  /// 分析对话节奏
  static ConversationPace analyzeConversationPace(List<MessageModel> messages) {
    if (messages.length < 4) return ConversationPace.normal;

    final intervals = <Duration>[];
    for (int i = 1; i < messages.length; i++) {
      if (messages[i].isUser == messages[i-1].isUser) continue;
      intervals.add(messages[i].timestamp.difference(messages[i-1].timestamp));
    }

    if (intervals.isEmpty) return ConversationPace.normal;

    final averageSeconds = intervals
        .map((d) => d.inSeconds)
        .reduce((a, b) => a + b) / intervals.length;

    if (averageSeconds < 30) {
      return ConversationPace.fast;
    } else if (averageSeconds > 300) { // 5分钟
      return ConversationPace.slow;
    } else {
      return ConversationPace.normal;
    }
  }

  /// 获取节奏建议
  static String getPaceAdvice(ConversationPace pace) {
    switch (pace) {
      case ConversationPace.fast:
        return '对话节奏有点快，可以适当放慢，给彼此思考的时间';
      case ConversationPace.slow:
        return '回复间隔较长，如果对方在线，可以尝试更积极的互动';
      case ConversationPace.normal:
        return '对话节奏很好，继续保持';
    }
  }

  /// 预测最佳结束轮数
  static int predictOptimalEndingRound(int currentFavorability, int favorabilityTrend) {
    // 基础最佳轮数
    int baseOptimal = 20;

    // 根据好感度调整
    if (currentFavorability >= 50) {
      baseOptimal = 25; // 高好感度可以稍微延长
    } else if (currentFavorability < 30) {
      baseOptimal = 15; // 低好感度应该早点结束
    }

    // 根据趋势调整
    if (favorabilityTrend > 0) {
      baseOptimal += 5; // 上升趋势可以继续
    } else if (favorabilityTrend < -5) {
      baseOptimal -= 5; // 下降趋势应该及时止损
    }

    return baseOptimal.clamp(10, 30);
  }

  /// 获取轮数统计信息
  static RoundStatistics getStatistics(List<MessageModel> messages) {
    final userMessages = messages.where((msg) => msg.isUser).toList();
    final aiMessages = messages.where((msg) => !msg.isUser).toList();

    return RoundStatistics(
      totalMessages: messages.length,
      userMessages: userMessages.length,
      aiMessages: aiMessages.length,
      averageUserMessageLength: userMessages.isEmpty ? 0.0 :
        userMessages.map((m) => m.characterCount).reduce((a, b) => a + b) / userMessages.length,
      longestMessage: messages.isEmpty ? 0 :
        messages.map((m) => m.characterCount).reduce((a, b) => a > b ? a : b),
      shortestMessage: messages.isEmpty ? 0 :
        messages.map((m) => m.characterCount).reduce((a, b) => a < b ? a : b),
    );
  }
}

/// 对话节奏枚举
enum ConversationPace {
  fast,    // 快节奏
  normal,  // 正常节奏
  slow,    // 慢节奏
}

/// 轮数统计信息
class RoundStatistics {
  final int totalMessages;           // 总消息数
  final int userMessages;           // 用户消息数
  final int aiMessages;             // AI消息数
  final double averageUserMessageLength; // 用户平均消息长度
  final int longestMessage;         // 最长消息字数
  final int shortestMessage;        // 最短消息字数

  const RoundStatistics({
    required this.totalMessages,
    required this.userMessages,
    required this.aiMessages,
    required this.averageUserMessageLength,
    required this.longestMessage,
    required this.shortestMessage,
  });

  /// 获取用户消息比例
  double get userMessageRatio {
    if (totalMessages == 0) return 0.0;
    return userMessages / totalMessages;
  }

  /// 获取消息长度评价
  String get lengthAssessment {
    if (averageUserMessageLength < 10) {
      return '消息偏短，可以尝试表达更多内容';
    } else if (averageUserMessageLength > 40) {
      return '消息较长，注意保持简洁';
    } else {
      return '消息长度适中';
    }
  }
}