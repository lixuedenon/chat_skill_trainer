// lib/core/constants/app_constants.dart
class AppConstants {
  static const String appName = 'ChatSkillTrainer';
  static const String appVersion = '1.0.0';

  static const int maxMessageLength = 50;
  static const int maxConversationRounds = 45;
  static const int initialFavorability = 10;
  static const int maxFavorability = 100;

  static const String currentUserKey = 'current_user';
  static const String conversationsKey = 'conversations';
  static const String appThemeKey = 'app_theme';

  static const String networkError = '网络连接失败';
  static const String serverError = '服务器错误';
  static const String insufficientCreditsError = '对话次数不足';
}