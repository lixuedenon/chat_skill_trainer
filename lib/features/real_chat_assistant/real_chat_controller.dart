// lib/features/real_chat_assistant/real_chat_controller.dart

import 'package:flutter/foundation.dart';
import '../../core/models/user_model.dart';
import 'social_translator.dart';
import 'social_radar.dart';

/// 真人聊天助手控制器
class RealChatController extends ChangeNotifier {
  final UserModel? user;

  String _inputText = '';
  List<ChatSuggestion> _suggestions = [];
  SocialTranslation? _translation;
  SocialRadarAnalysis? _radarAnalysis;
  bool _isAnalyzing = false;
  bool _isScanning = false;
  bool _isGenerating = false;
  String _analysisHistory = '';

  // 用于页面显示的数据格式
  Map<String, dynamic> _translationResult = {};
  List<Map<String, dynamic>> _radarResults = [];
  List<Map<String, dynamic>> _replySuggestions = [];

  RealChatController({this.user});

  // Getters - 匹配页面中使用的属性名
  String get inputText => _inputText;
  List<ChatSuggestion> get suggestions => _suggestions;
  SocialTranslation? get translation => _translation;
  SocialRadarAnalysis? get radarAnalysis => _radarAnalysis;
  bool get isAnalyzing => _isAnalyzing;
  bool get isScanning => _isScanning;
  bool get isGenerating => _isGenerating;
  String get analysisHistory => _analysisHistory;

  // 页面使用的格式化数据
  Map<String, dynamic> get translationResult => _translationResult;
  List<Map<String, dynamic>> get radarResults => _radarResults;
  List<Map<String, dynamic>> get replySuggestions => _replySuggestions;

  /// 翻译消息（社交翻译功能）
  Future<void> translateMessage(String message) async {
    if (message.trim().isEmpty) return;

    _isAnalyzing = true;
    _inputText = message;
    notifyListeners();

    try {
      // 社交翻译官：解读隐含意思
      _translation = await SocialTranslator.translateMessage(message);

      // 转换为页面显示格式
      _translationResult = {
        'surfaceMeaning': '字面意思：$message',
        'hiddenMeaning': _translation!.hiddenMeaning,
        'emotionalTone': '${_translation!.emotionalState.emoji} ${_translation!.emotionalState.displayName}',
        'suggestedResponse': _translation!.suggestedResponse,
      };

      // 更新历史记录
      _updateAnalysisHistory('翻译: $message');

    } catch (e) {
      debugPrint('翻译消息失败: $e');
      _translationResult = {
        'surfaceMeaning': message,
        'hiddenMeaning': '分析失败，请重试',
        'emotionalTone': '无法识别',
        'suggestedResponse': '建议直接回应',
      };
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  /// 扫描社交信号（社交雷达功能）
  Future<void> scanSocialSignals(String content) async {
    if (content.trim().isEmpty) return;

    _isScanning = true;
    notifyListeners();

    try {
      // 社交雷达：识别关键信息
      _radarAnalysis = await SocialRadar.analyzeMessage(content);

      // 转换为页面显示格式
      _radarResults = [];

      // 添加机会信号
      for (final opportunity in _radarAnalysis!.opportunities) {
        _radarResults.add({
          'type': 'positive',
          'title': _getOpportunityTitle(opportunity.type),
          'description': opportunity.explanation,
          'intensity': _getPriorityText(opportunity.priority),
        });
      }

      // 添加警告信号
      for (final warning in _radarAnalysis!.warnings) {
        _radarResults.add({
          'type': 'negative',
          'title': _getWarningTitle(warning.type),
          'description': warning.explanation,
          'intensity': _getSeverityText(warning.severity),
        });
      }

      // 添加关键信息
      for (final info in _radarAnalysis!.keyInformation) {
        _radarResults.add({
          'type': 'neutral',
          'title': _getInfoTitle(info.type),
          'description': '发现：${info.content}',
          'intensity': _getImportanceText(info.importance),
        });
      }

      // 更新历史记录
      _updateAnalysisHistory('雷达扫描: ${content.substring(0, 20)}...');

    } catch (e) {
      debugPrint('扫描信号失败: $e');
      _radarResults = [{
        'type': 'neutral',
        'title': '扫描失败',
        'description': '无法分析内容，请检查输入',
        'intensity': '低',
      }];
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  /// 生成回复建议
  Future<void> generateReplySuggestions(String context) async {
    if (context.trim().isEmpty) return;

    _isGenerating = true;
    notifyListeners();

    try {
      // 生成建议
      _suggestions = await _generateReplySuggestions(context);

      // 转换为页面显示格式
      _replySuggestions = _suggestions.map((suggestion) => {
        'style': suggestion.type.displayName,
        'message': suggestion.text,
        'explanation': suggestion.explanation,
        'confidence': suggestion.confidence,
      }).toList();

      // 更新历史记录
      _updateAnalysisHistory('生成建议: ${context.substring(0, 20)}...');

    } catch (e) {
      debugPrint('生成建议失败: $e');
      _replySuggestions = [{
        'style': '通用',
        'message': '谢谢你的分享，我很认同你的看法',
        'explanation': '安全的通用回复',
        'confidence': 0.5,
      }];
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  /// 分析对方消息（原有方法，保持兼容性）
  Future<void> analyzeMessage(String message) async {
    await translateMessage(message);
  }

  /// 生成回复建议
  Future<List<ChatSuggestion>> _generateReplySuggestions(String message) async {
    final suggestions = <ChatSuggestion>[];

    // 基于翻译结果生成建议
    if (_translation != null) {
      suggestions.addAll(_generateBasedOnTranslation(_translation!));
    }

    // 基于雷达分析生成建议
    if (_radarAnalysis != null) {
      suggestions.addAll(_generateBasedOnRadar(_radarAnalysis!));
    }

    // 通用建议
    suggestions.addAll(_generateGenericSuggestions(message));

    // 去重并排序
    return _deduplicateAndSort(suggestions);
  }

  /// 基于翻译结果生成建议
  List<ChatSuggestion> _generateBasedOnTranslation(SocialTranslation translation) {
    final suggestions = <ChatSuggestion>[];

    switch (translation.emotionalState) {
      case EmotionalState.seeking_attention:
        suggestions.add(ChatSuggestion(
          text: '我注意到了，告诉我更多吧',
          type: SuggestionType.caring,
          confidence: 0.9,
          explanation: '她在寻求关注，给予积极回应',
        ));
        break;
      case EmotionalState.testing:
        suggestions.add(ChatSuggestion(
          text: '我理解你的想法，让我们开诚布公地聊聊',
          type: SuggestionType.honest,
          confidence: 0.85,
          explanation: '这是测试，诚实回应最好',
        ));
        break;
      case EmotionalState.upset:
        suggestions.add(ChatSuggestion(
          text: '我能感受到你的心情，需要我陪陪你吗？',
          type: SuggestionType.supportive,
          confidence: 0.9,
          explanation: '她情绪不好，提供情感支持',
        ));
        break;
      default:
        break;
    }

    return suggestions;
  }

  /// 基于雷达分析生成建议
  List<ChatSuggestion> _generateBasedOnRadar(SocialRadarAnalysis radar) {
    final suggestions = <ChatSuggestion>[];

    for (final opportunity in radar.opportunities) {
      switch (opportunity.type) {
        case OpportunityType.show_care:
          suggestions.add(ChatSuggestion(
            text: '${opportunity.suggestedResponse}，你还好吗？',
            type: SuggestionType.caring,
            confidence: 0.8,
            explanation: opportunity.explanation,
          ));
          break;
        case OpportunityType.ask_question:
          suggestions.add(ChatSuggestion(
            text: opportunity.suggestedResponse,
            type: SuggestionType.engaging,
            confidence: 0.75,
            explanation: opportunity.explanation,
          ));
          break;
        case OpportunityType.share_experience:
          suggestions.add(ChatSuggestion(
            text: opportunity.suggestedResponse,
            type: SuggestionType.sharing,
            confidence: 0.7,
            explanation: opportunity.explanation,
          ));
          break;
        default:
          break;
      }
    }

    return suggestions;
  }

  /// 生成通用建议
  List<ChatSuggestion> _generateGenericSuggestions(String message) {
    final suggestions = <ChatSuggestion>[];

    // 如果包含问号，生成回答建议
    if (message.contains('?') || message.contains('？')) {
      suggestions.add(ChatSuggestion(
        text: '让我想想...[根据具体问题回答]',
        type: SuggestionType.thoughtful,
        confidence: 0.6,
        explanation: '对问题进行思考后回答',
      ));
    }

    // 如果提到负面情绪，生成安慰建议
    final negativeWords = ['累', '烦', '难过', '生气', '郁闷'];
    if (negativeWords.any((word) => message.contains(word))) {
      suggestions.add(ChatSuggestion(
        text: '辛苦了，需要我做些什么吗？',
        type: SuggestionType.supportive,
        confidence: 0.8,
        explanation: '对方情绪不好，提供支持',
      ));
    }

    // 默认建议
    suggestions.add(ChatSuggestion(
      text: '我明白你的意思，让我们继续聊聊这个话题',
      type: SuggestionType.engaging,
      confidence: 0.5,
      explanation: '保持对话继续的通用回复',
    ));

    return suggestions;
  }

  /// 去重并排序建议
  List<ChatSuggestion> _deduplicateAndSort(List<ChatSuggestion> suggestions) {
    // 按置信度排序，取前5个
    suggestions.sort((a, b) => b.confidence.compareTo(a.confidence));
    return suggestions.take(5).toList();
  }

  /// 更新分析历史
  void _updateAnalysisHistory(String message) {
    final timestamp = DateTime.now().toString().substring(11, 16);
    _analysisHistory += '[$timestamp] $message\n';

    // 保持历史记录在合理长度
    final lines = _analysisHistory.split('\n');
    if (lines.length > 20) {
      _analysisHistory = lines.sublist(lines.length - 20).join('\n');
    }
  }

  /// 辅助方法：获取机会标题
  String _getOpportunityTitle(OpportunityType type) {
    switch (type) {
      case OpportunityType.show_care:
        return '关心机会';
      case OpportunityType.ask_question:
        return '提问机会';
      case OpportunityType.share_experience:
        return '分享机会';
      case OpportunityType.emotional_support:
        return '情感支持机会';
      case OpportunityType.future_plan:
        return '未来计划机会';
    }
  }

  String _getWarningTitle(WarningType type) {
    switch (type) {
      case WarningType.cold_response:
        return '冷淡回应';
      case WarningType.impatient:
        return '不耐烦信号';
      case WarningType.keeping_distance:
        return '保持距离';
    }
  }

  String _getInfoTitle(InfoType type) {
    switch (type) {
      case InfoType.time:
        return '时间信息';
      case InfoType.location:
        return '地点信息';
      case InfoType.people:
        return '人物信息';
      case InfoType.activity:
        return '活动信息';
    }
  }

  String _getPriorityText(OpportunityPriority priority) {
    switch (priority) {
      case OpportunityPriority.high:
        return '高';
      case OpportunityPriority.medium:
        return '中';
      case OpportunityPriority.low:
        return '低';
    }
  }

  String _getSeverityText(WarningSeverity severity) {
    switch (severity) {
      case WarningSeverity.high:
        return '高风险';
      case WarningSeverity.medium:
        return '中风险';
      case WarningSeverity.low:
        return '低风险';
    }
  }

  String _getImportanceText(ImportanceLevel importance) {
    switch (importance) {
      case ImportanceLevel.high:
        return '重要';
      case ImportanceLevel.medium:
        return '一般';
      case ImportanceLevel.low:
        return '次要';
    }
  }

  /// 清空输入和结果
  void clearInput() {
    _inputText = '';
    _suggestions.clear();
    _translation = null;
    _radarAnalysis = null;
    _translationResult.clear();
    _radarResults.clear();
    _replySuggestions.clear();
    notifyListeners();
  }

  /// 清空历史记录
  void clearHistory() {
    _analysisHistory = '';
    notifyListeners();
  }

  /// 获取使用统计
  Map<String, dynamic> getUsageStats() {
    final lines = _analysisHistory.split('\n');
    return {
      'totalAnalyses': lines.where((line) => line.isNotEmpty).length,
      'todayAnalyses': lines.where((line) {
        final today = DateTime.now().toString().substring(0, 10);
        return line.contains(today);
      }).length,
    };
  }
}

/// 聊天建议
class ChatSuggestion {
  final String text;              // 建议文本
  final SuggestionType type;      // 建议类型
  final double confidence;        // 置信度
  final String explanation;       // 解释说明

  const ChatSuggestion({
    required this.text,
    required this.type,
    required this.confidence,
    required this.explanation,
  });
}

/// 建议类型
enum SuggestionType {
  caring,         // 关心型
  honest,         // 诚实型
  supportive,     // 支持型
  engaging,       // 互动型
  sharing,        // 分享型
  thoughtful,     // 深思型
  playful,        // 俏皮型
  romantic,       // 浪漫型
}

extension SuggestionTypeExtension on SuggestionType {
  String get displayName {
    switch (this) {
      case SuggestionType.caring:
        return '关心型';
      case SuggestionType.honest:
        return '诚实型';
      case SuggestionType.supportive:
        return '支持型';
      case SuggestionType.engaging:
        return '互动型';
      case SuggestionType.sharing:
        return '分享型';
      case SuggestionType.thoughtful:
        return '深思型';
      case SuggestionType.playful:
        return '俏皮型';
      case SuggestionType.romantic:
        return '浪漫型';
    }
  }

  String get icon {
    switch (this) {
      case SuggestionType.caring:
        return '💝';
      case SuggestionType.honest:
        return '💯';
      case SuggestionType.supportive:
        return '🤝';
      case SuggestionType.engaging:
        return '💬';
      case SuggestionType.sharing:
        return '🎯';
      case SuggestionType.thoughtful:
        return '🤔';
      case SuggestionType.playful:
        return '😄';
      case SuggestionType.romantic:
        return '💕';
    }
  }
}