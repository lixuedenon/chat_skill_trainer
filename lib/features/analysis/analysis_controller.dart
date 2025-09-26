// lib/features/analysis/analysis_controller.dart (修复版 - 迁移到HiveService)

import 'package:flutter/foundation.dart';
import '../../core/models/analysis_model.dart';
import '../../core/models/conversation_model.dart';
import '../../core/models/character_model.dart';
import '../../shared/services/hive_service.dart';  // 🔥 替代 StorageService

class AnalysisController extends ChangeNotifier {
  AnalysisReport? _currentReport;
  bool _isGenerating = false;
  String _errorMessage = '';
  bool _disposed = false;  // 🔥 添加销毁标志

  AnalysisReport? get currentReport => _currentReport;
  bool get isGenerating => _isGenerating;
  String get errorMessage => _errorMessage;

  Future<void> generateAnalysis({
    required ConversationModel conversation,
    required CharacterModel character,
  }) async {
    if (_disposed) return;

    _isGenerating = true;
    _errorMessage = '';
    _safeNotifyListeners();

    try {
      print('🔄 开始生成分析报告...');

      // 模拟分析过程
      await Future.delayed(const Duration(seconds: 2));

      final keyMoments = _analyzeKeyMoments(conversation.messages);
      final suggestions = _generateSuggestions(conversation, character);
      final strengths = _analyzeStrengths(conversation);
      final weaknesses = _analyzeWeaknesses(conversation);
      final finalScore = _calculateFinalScore(conversation);

      _currentReport = AnalysisReport.create(
        conversationId: conversation.id,
        userId: conversation.userId,
        finalScore: finalScore,
        keyMoments: keyMoments,
        suggestions: suggestions,
        strengths: strengths,
        weaknesses: weaknesses,
        nextTrainingFocus: _generateTrainingFocus(conversation, finalScore),
        overallAssessment: _generateOverallAssessment(conversation, finalScore),
      );

      // 🔥 使用HiveService保存分析报告
      await HiveService.saveAnalysisReport(_currentReport!);
      print('✅ 分析报告生成并保存成功: ${_currentReport!.id}');

    } catch (e) {
      print('❌ 分析生成失败: $e');
      _errorMessage = '分析生成失败: ${e.toString()}';
    } finally {
      if (!_disposed) {
        _isGenerating = false;
        _safeNotifyListeners();
      }
    }
  }

  /// 🔥 加载已有的分析报告
  Future<void> loadAnalysisReport(String reportId) async {
    if (_disposed) return;

    try {
      print('🔄 加载分析报告: $reportId');

      // 🔥 使用HiveService获取分析报告
      _currentReport = HiveService.getAnalysisReport(reportId);

      if (_currentReport == null) {
        throw Exception('分析报告不存在: $reportId');
      }

      print('✅ 分析报告加载成功: ${_currentReport!.finalScore}分');
      _safeNotifyListeners();

    } catch (e) {
      print('❌ 加载分析报告失败: $e');
      _errorMessage = '加载分析报告失败: ${e.toString()}';
      _safeNotifyListeners();
    }
  }

  /// 🔥 根据对话ID获取分析报告
  Future<void> loadAnalysisReportByConversation(String conversationId) async {
    if (_disposed) return;

    try {
      print('🔄 根据对话ID加载分析报告: $conversationId');

      // 🔥 使用HiveService查找对话对应的分析报告
      _currentReport = HiveService.getAnalysisReportByConversation(conversationId);

      if (_currentReport == null) {
        print('ℹ️ 该对话暂无分析报告: $conversationId');
      } else {
        print('✅ 找到分析报告: ${_currentReport!.finalScore}分');
      }

      _safeNotifyListeners();

    } catch (e) {
      print('❌ 查找分析报告失败: $e');
      _errorMessage = '查找分析报告失败: ${e.toString()}';
      _safeNotifyListeners();
    }
  }

  /// 🔥 获取用户的所有分析报告
  Future<List<AnalysisReport>> getUserAnalysisReports(String userId) async {
    if (_disposed) return [];

    try {
      print('🔄 获取用户分析报告: $userId');

      // 🔥 使用HiveService获取用户的分析报告
      final reports = await HiveService.getUserAnalysisReports(userId);

      print('✅ 找到${reports.length}份分析报告');
      return reports;

    } catch (e) {
      print('❌ 获取用户分析报告失败: $e');
      return [];
    }
  }

  /// 🔥 删除分析报告
  Future<bool> deleteAnalysisReport(String reportId) async {
    if (_disposed) return false;

    try {
      print('🔄 删除分析报告: $reportId');

      // 🔥 使用HiveService删除分析报告
      await HiveService.deleteAnalysisReport(reportId);

      // 如果删除的是当前报告，清空当前状态
      if (_currentReport?.id == reportId) {
        _currentReport = null;
        _safeNotifyListeners();
      }

      print('✅ 分析报告删除成功');
      return true;

    } catch (e) {
      print('❌ 删除分析报告失败: $e');
      _errorMessage = '删除分析报告失败: ${e.toString()}';
      _safeNotifyListeners();
      return false;
    }
  }

  /// 🔥 获取分析统计信息
  Future<Map<String, dynamic>> getAnalysisStats(String userId) async {
    if (_disposed) return {};

    try {
      final reports = await getUserAnalysisReports(userId);

      if (reports.isEmpty) {
        return {
          'totalReports': 0,
          'averageScore': 0.0,
          'highestScore': 0,
          'improvementTrend': 0.0,
          'commonWeaknesses': <String>[],
          'strongestSkills': <String>[],
        };
      }

      // 计算基础统计
      final scores = reports.map((r) => r.finalScore).toList();
      final totalReports = reports.length;
      final averageScore = scores.fold<int>(0, (sum, score) => sum + score) / totalReports;
      final highestScore = scores.reduce((a, b) => a > b ? a : b);

      // 计算改进趋势（最近5份vs前面的平均分）
      double improvementTrend = 0.0;
      if (scores.length >= 10) {
        final recent = scores.sublist(scores.length - 5);
        final earlier = scores.sublist(0, scores.length - 5);
        final recentAvg = recent.fold<int>(0, (sum, score) => sum + score) / recent.length;
        final earlierAvg = earlier.fold<int>(0, (sum, score) => sum + score) / earlier.length;
        improvementTrend = recentAvg - earlierAvg;
      }

      // 统计常见弱点
      final allWeakAreas = <String>[];
      final allStrongSkills = <String>[];

      for (final report in reports) {
        allWeakAreas.addAll(report.weaknesses.weakAreas);
        allStrongSkills.addAll(report.strengths.topSkills);
      }

      // 找出出现频率最高的弱点和强项
      final weaknessFreq = <String, int>{};
      final strengthsFreq = <String, int>{};

      for (final weakness in allWeakAreas) {
        weaknessFreq[weakness] = (weaknessFreq[weakness] ?? 0) + 1;
      }

      for (final skill in allStrongSkills) {
        strengthsFreq[skill] = (strengthsFreq[skill] ?? 0) + 1;
      }

      final commonWeaknesses = weaknessFreq.entries
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value))
          ..take(3)
          .map((e) => e.key)
          .toList();

      final strongestSkills = strengthsFreq.entries
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value))
          ..take(3)
          .map((e) => e.key)
          .toList();

      return {
        'totalReports': totalReports,
        'averageScore': averageScore,
        'highestScore': highestScore,
        'improvementTrend': improvementTrend,
        'commonWeaknesses': commonWeaknesses,
        'strongestSkills': strongestSkills,
      };

    } catch (e) {
      print('❌ 获取分析统计失败: $e');
      return {};
    }
  }

  List<KeyMoment> _analyzeKeyMoments(List<MessageModel> messages) {
    final moments = <KeyMoment>[];

    for (int i = 0; i < messages.length; i += 2) {
      if (i + 1 < messages.length && messages[i].isUser) {
        final userMessage = messages[i];
        final aiMessage = messages[i + 1];

        // 分析这轮对话的关键点
        MomentType momentType = MomentType.mistake;
        String explanation = '';
        String improvedMessage = userMessage.content;
        int scoreChange = -2;

        // 简单的启发式分析
        if (userMessage.content.contains('？') || userMessage.content.contains('?')) {
          momentType = MomentType.perfectResponse;
          explanation = '主动提问显示了你的兴趣和参与度';
          scoreChange = 5;
        } else if (userMessage.content.length < 5) {
          momentType = MomentType.missedOpportunity;
          explanation = '回应过短，可能显得不够投入';
          improvedMessage = '${userMessage.content}，能告诉我更多吗？';
          scoreChange = -1;
        } else if (userMessage.content.length > 40) {
          momentType = MomentType.mistake;
          explanation = '消息过长可能让对方感到压力';
          scoreChange = -3;
        } else if (_hasPositiveWords(userMessage.content)) {
          momentType = MomentType.breakthrough;
          explanation = '积极的情感表达很有感染力';
          scoreChange = 3;
        }

        moments.add(KeyMoment(
          round: (i ~/ 2) + 1,
          originalMessage: userMessage.content,
          improvedMessage: improvedMessage,
          scoreChange: scoreChange,
          explanation: explanation,
          type: momentType,
          timestamp: userMessage.timestamp,
        ));
      }
    }

    // 返回最重要的5个关键时刻
    moments.sort((a, b) => b.scoreChange.abs().compareTo(a.scoreChange.abs()));
    return moments.take(5).toList();
  }

  bool _hasPositiveWords(String content) {
    const positiveWords = ['喜欢', '开心', '有趣', '温暖', '美好', '棒', '好', '不错', '赞'];
    return positiveWords.any((word) => content.contains(word));
  }

  List<Suggestion> _generateSuggestions(ConversationModel conversation, CharacterModel character) {
    final suggestions = <Suggestion>[];

    // 基于消息长度的建议
    final userMessages = conversation.messages.where((m) => m.isUser).toList();
    if (userMessages.isNotEmpty) {
      final avgLength = userMessages
          .map((m) => m.content.length)
          .fold<int>(0, (sum, length) => sum + length) / userMessages.length;

      if (avgLength < 10) {
        suggestions.add(const Suggestion(
          title: '增加表达丰富度',
          description: '你的回应偏短，尝试增加更多细节和感受分享',
          example: '不只说"好的"，可以说"好的，我也有类似的感受，特别是..."',
          type: SuggestionType.conversationSkills,
          priority: 4,
        ));
      }

      if (avgLength > 35) {
        suggestions.add(const Suggestion(
          title: '控制消息长度',
          description: '消息过长可能让对方感到压力，尝试分段表达',
          example: '将长段文字拆分成2-3条消息，让对话更自然',
          type: SuggestionType.conversationSkills,
          priority: 3,
        ));
      }
    }

    // 基于提问频率的建议
    final questionCount = userMessages
        .where((m) => m.content.contains('？') || m.content.contains('?'))
        .length;

    if (questionCount < userMessages.length * 0.2) {
      suggestions.add(const Suggestion(
        title: '增加提问频率',
        description: '适当的提问可以显示你对对方的关心和兴趣',
        example: '在陈述后加上"你觉得呢？"或"你有什么看法？"',
        type: SuggestionType.conversationSkills,
        priority: 4,
      ));
    }

    // 基于情感表达的建议
    final emotionalWords = ['感觉', '觉得', '想', '希望', '喜欢', '开心', '难过', '担心'];
    final emotionalCount = userMessages
        .where((m) => emotionalWords.any((word) => m.content.contains(word)))
        .length;

    if (emotionalCount < userMessages.length * 0.3) {
      suggestions.add(const Suggestion(
        title: '增强情感表达',
        description: '更多地分享你的感受和想法，让对话更有温度',
        example: '"听你这么说我很开心"替代简单的"是的"',
        type: SuggestionType.emotionalIntelligence,
        priority: 3,
      ));
    }

    // 基于角色特征的建议
    if (character.type == CharacterType.gentle) {
      suggestions.add(const Suggestion(
        title: '展现体贴一面',
        description: '对温柔型角色，展现你的关心和体贴更容易获得好感',
        example: '主动询问对方的感受："你累吗？需要休息一下吗？"',
        type: SuggestionType.emotionalIntelligence,
        priority: 4,
      ));
    } else if (character.type == CharacterType.lively) {
      suggestions.add(const Suggestion(
        title: '保持活跃互动',
        description: '活泼型角色喜欢有趣的对话，可以分享更多生活趣事',
        example: '分享有趣的经历或者提出好玩的话题',
        type: SuggestionType.conversationSkills,
        priority: 3,
      ));
    }

    // 确保至少有基础建议
    if (suggestions.isEmpty) {
      suggestions.add(const Suggestion(
        title: '保持自然对话',
        description: '继续保持现在的对话风格，尝试更多地分享个人想法',
        example: '在回应时加入自己的观点和感受',
        type: SuggestionType.conversationSkills,
        priority: 2,
      ));
    }

    return suggestions;
  }

  PersonalStrengths _analyzeStrengths(ConversationModel conversation) {
    final userMessages = conversation.messages.where((m) => m.isUser).toList();
    final skills = <String>[];
    final skillScores = <String, double>{};

    // 分析沟通能力
    final avgLength = userMessages.isNotEmpty
        ? userMessages.map((m) => m.content.length).fold<int>(0, (sum, length) => sum + length) / userMessages.length
        : 0.0;

    double communicationScore = 5.0;
    if (avgLength >= 15 && avgLength <= 30) {
      communicationScore = 8.0;
      skills.add('消息长度控制得当');
    }

    skillScores['沟通能力'] = communicationScore;

    // 分析提问能力
    final questionCount = userMessages.where((m) => m.content.contains('？') || m.content.contains('?')).length;
    final questionRatio = userMessages.isNotEmpty ? questionCount / userMessages.length : 0.0;

    double questioningScore = questionRatio * 10;
    if (questioningScore > 7.0) {
      skills.add('善于提问互动');
    }
    skillScores['提问技巧'] = questioningScore.clamp(0.0, 10.0);

    // 分析情感表达
    final emotionalWords = ['感觉', '觉得', '想', '希望', '喜欢', '开心'];
    final emotionalCount = userMessages.where((m) => emotionalWords.any((word) => m.content.contains(word))).length;
    final emotionalRatio = userMessages.isNotEmpty ? emotionalCount / userMessages.length : 0.0;

    double emotionalScore = emotionalRatio * 10;
    if (emotionalScore > 6.0) {
      skills.add('情感表达丰富');
    }
    skillScores['情感表达'] = emotionalScore.clamp(0.0, 10.0);

    // 分析积极性
    final positiveWords = ['好', '不错', '棒', '喜欢', '开心', '有趣'];
    final positiveCount = userMessages.where((m) => positiveWords.any((word) => m.content.contains(word))).length;
    final positiveRatio = userMessages.isNotEmpty ? positiveCount / userMessages.length : 0.0;

    double positivityScore = positiveRatio * 10;
    if (positivityScore > 5.0) {
      skills.add('积极正面思维');
    }
    skillScores['积极性'] = positivityScore.clamp(0.0, 10.0);

    // 确保有基本技能
    if (skills.isEmpty) {
      skills.add('基础对话能力');
    }

    return PersonalStrengths(
      topSkills: skills.take(3).toList(),
      skillScores: skillScores,
      dominantStyle: _determineDominantStyle(skillScores),
    );
  }

  String _determineDominantStyle(Map<String, double> skillScores) {
    if (skillScores['情感表达']! > 7.0) return '感性型';
    if (skillScores['提问技巧']! > 7.0) return '互动型';
    if (skillScores['积极性']! > 7.0) return '阳光型';
    if (skillScores['沟通能力']! > 7.0) return '平衡型';
    return '成长型';
  }

  PersonalWeaknesses _analyzeWeaknesses(ConversationModel conversation) {
    final userMessages = conversation.messages.where((m) => m.isUser).toList();
    final weakAreas = <String>[];
    final areaScores = <String, double>{};
    final improvementPlan = <String>[];

    // 分析消息长度问题
    if (userMessages.isNotEmpty) {
      final avgLength = userMessages.map((m) => m.content.length).fold<int>(0, (sum, length) => sum + length) / userMessages.length;

      if (avgLength < 10) {
        weakAreas.add('表达深度不足');
        areaScores['表达深度'] = 4.0;
        improvementPlan.add('尝试在回应中加入更多细节和个人感受');
      } else if (avgLength > 35) {
        weakAreas.add('表达过于冗长');
        areaScores['简洁性'] = 4.0;
        improvementPlan.add('学会用更简洁的语言表达重点');
      }
    }

    // 分析提问频率
    final questionCount = userMessages.where((m) => m.content.contains('？') || m.content.contains('?')).length;
    final questionRatio = userMessages.isNotEmpty ? questionCount / userMessages.length : 0.0;

    if (questionRatio < 0.2) {
      weakAreas.add('互动性不足');
      areaScores['互动技巧'] = 5.0;
      improvementPlan.add('增加开放性提问，如"你觉得呢？"');
    }

    // 分析情感表达
    final emotionalWords = ['感觉', '觉得', '想', '希望'];
    final emotionalCount = userMessages.where((m) => emotionalWords.any((word) => m.content.contains(word))).length;
    final emotionalRatio = userMessages.isNotEmpty ? emotionalCount / userMessages.length : 0.0;

    if (emotionalRatio < 0.2) {
      weakAreas.add('情感表达较少');
      areaScores['情感沟通'] = 5.5;
      improvementPlan.add('更多地分享个人感受和想法');
    }

    // 确保有基本分析
    if (weakAreas.isEmpty) {
      weakAreas.add('整体表现良好');
      areaScores['综合表现'] = 7.0;
      improvementPlan.add('保持现有水平，继续练习');
    }

    return PersonalWeaknesses(
      weakAreas: weakAreas,
      areaScores: areaScores,
      improvementPlan: improvementPlan,
    );
  }

  int _calculateFinalScore(ConversationModel conversation) {
    final baseScore = conversation.metrics.currentFavorability;
    final messageCount = conversation.messages.length;
    final userMessages = conversation.messages.where((m) => m.isUser).length;

    // 基础分数 = 好感度
    int finalScore = baseScore;

    // 消息数量奖励（鼓励更多互动）
    if (messageCount > 20) finalScore += 10;
    else if (messageCount > 10) finalScore += 5;

    // 用户参与度奖励
    if (userMessages >= messageCount * 0.45) finalScore += 5;

    // 消息质量分析
    final userMessageList = conversation.messages.where((m) => m.isUser).toList();
    if (userMessageList.isNotEmpty) {
      final avgLength = userMessageList.map((m) => m.content.length).fold<int>(0, (sum, length) => sum + length) / userMessageList.length;

      // 理想长度奖励
      if (avgLength >= 15 && avgLength <= 30) {
        finalScore += 5;
      }

      // 提问奖励
      final questionCount = userMessageList.where((m) => m.content.contains('？') || m.content.contains('?')).length;
      if (questionCount > userMessageList.length * 0.2) {
        finalScore += 5;
      }
    }

    return finalScore.clamp(0, 100);
  }

  List<String> _generateTrainingFocus(ConversationModel conversation, int finalScore) {
    final focus = <String>[];

    if (finalScore < 60) {
      focus.addAll(['基础对话技巧', '情感表达练习', '提问技巧训练']);
    } else if (finalScore < 80) {
      focus.addAll(['深度对话技巧', '话题延续能力', '情感共鸣技巧']);
    } else {
      focus.addAll(['高级社交技巧', '幽默感培养', '魅力提升训练']);
    }

    return focus.take(3).toList();
  }

  String _generateOverallAssessment(ConversationModel conversation, int finalScore) {
    if (finalScore >= 90) {
      return '表现卓越！你展现了出色的沟通技巧和情感智慧。继续保持这种水平，你在现实中的社交表现一定也会很出色。';
    } else if (finalScore >= 80) {
      return '表现优秀！你的沟通能力已经相当不错，在某些方面还有进一步提升的空间。多加练习，你会更加出色。';
    } else if (finalScore >= 60) {
      return '表现良好，已经掌握了基本的对话技巧。建议继续练习，特别是在情感表达和互动方面多下功夫。';
    } else if (finalScore >= 40) {
      return '有一定基础，但还需要更多练习。建议从基础的对话技巧开始，逐步提升自己的表达能力和互动技巧。';
    } else {
      return '需要更多练习来提升沟通效果。建议多进行基础对话训练，学习如何更好地表达自己和与他人互动。';
    }
  }

  void clearError() {
    if (_disposed) return;

    _errorMessage = '';
    _safeNotifyListeners();
  }

  void clearCurrentReport() {
    if (_disposed) return;

    _currentReport = null;
    _errorMessage = '';
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
    print('🔄 AnalysisController 销毁中...');
    _disposed = true;

    // 清理所有引用
    _currentReport = null;
    _errorMessage = '';
    _isGenerating = false;

    super.dispose();
    print('✅ AnalysisController 销毁完成');
  }
}