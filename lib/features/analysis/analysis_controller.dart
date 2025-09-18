// lib/features/analysis/analysis_controller.dart

import 'package:flutter/foundation.dart';
import '../../core/models/analysis_model.dart';
import '../../core/models/conversation_model.dart';
import '../../core/models/character_model.dart';
import '../../shared/services/storage_service.dart';

class AnalysisController extends ChangeNotifier {
  AnalysisReport? _currentReport;
  bool _isGenerating = false;
  String _errorMessage = '';

  AnalysisReport? get currentReport => _currentReport;
  bool get isGenerating => _isGenerating;
  String get errorMessage => _errorMessage;

  Future<void> generateAnalysis({
    required ConversationModel conversation,
    required CharacterModel character,
  }) async {
    _isGenerating = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2)); // 模拟分析

      final keyMoments = _analyzeKeyMoments(conversation.messages);
      final suggestions = _generateSuggestions(conversation, character);
      final strengths = _analyzeStrengths(conversation);
      final weaknesses = _analyzeWeaknesses(conversation);

      _currentReport = AnalysisReport.create(
        conversationId: conversation.id,
        userId: conversation.userId,
        finalScore: _calculateFinalScore(conversation),
        keyMoments: keyMoments,
        suggestions: suggestions,
        strengths: strengths,
        weaknesses: weaknesses,
        nextTrainingFocus: ['提升开场技巧', '增强话题延续能力'],
        overallAssessment: _generateOverallAssessment(conversation),
      );

      // 保存分析报告
      await StorageService.saveAnalysisReport(_currentReport!);
    } catch (e) {
      _errorMessage = '分析生成失败: ${e.toString()}';
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  List<KeyMoment> _analyzeKeyMoments(List<MessageModel> messages) {
    final moments = <KeyMoment>[];
    for (int i = 0; i < messages.length; i += 2) {
      if (i + 1 < messages.length && messages[i].isUser) {
        moments.add(KeyMoment(
          round: (i ~/ 2) + 1,
          originalMessage: messages[i].content,
          improvedMessage: '${messages[i].content}，你觉得呢？',
          scoreChange: 5,
          explanation: '加入提问可以增加互动性',
          type: MomentType.missedOpportunity,
          timestamp: messages[i].timestamp,
        ));
      }
    }
    return moments.take(5).toList();
  }

  List<Suggestion> _generateSuggestions(ConversationModel conversation, CharacterModel character) {
    return [
      const Suggestion(
        title: '增加提问频率',
        description: '适当的提问可以显示你对对方的关心和兴趣',
        example: '在陈述后加上"你觉得呢？"或"你有什么看法？"',
        type: SuggestionType.conversationSkills,
        priority: 4,
      ),
      const Suggestion(
        title: '提升情感表达',
        description: '更多表达个人感受，让对话更有温度',
        example: '"听你这么说我很开心"替代简单的"是的"',
        type: SuggestionType.emotionalIntelligence,
        priority: 3,
      ),
    ];
  }

  PersonalStrengths _analyzeStrengths(ConversationModel conversation) {
    return const PersonalStrengths(
      topSkills: ['积极回应', '话题延续'],
      skillScores: {'沟通能力': 7.5, '共情能力': 6.8, '表达能力': 7.2},
      dominantStyle: '友善型',
    );
  }

  PersonalWeaknesses _analyzeWeaknesses(ConversationModel conversation) {
    return const PersonalWeaknesses(
      weakAreas: ['提问技巧', '深度话题'],
      areaScores: {'提问频率': 5.2, '话题深度': 6.1},
      improvementPlan: ['增加开放性提问', '分享更多个人观点'],
    );
  }

  int _calculateFinalScore(ConversationModel conversation) {
    final baseScore = conversation.metrics.currentFavorability;
    final messageCount = conversation.messages.length;
    final bonus = messageCount > 20 ? 10 : 0;
    return (baseScore + bonus).clamp(0, 100);
  }

  String _generateOverallAssessment(ConversationModel conversation) {
    final score = _calculateFinalScore(conversation);
    if (score >= 80) return '表现优秀！你展现了很好的沟通技巧。';
    if (score >= 60) return '表现良好，还有进步空间。';
    return '需要更多练习来提升沟通效果。';
  }
}
