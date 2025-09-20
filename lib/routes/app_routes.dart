// lib/routes/app_routes.dart (修复版)

import 'package:flutter/material.dart';
import '../features/home/pages/home_page.dart';
import '../features/auth/pages/login_page.dart';
import '../features/character_selection/pages/character_grid_page.dart';
import '../features/chat/pages/basic_chat_page.dart'; // 这个文件中的类名是 ChatPage
import '../features/ai_companion/pages/companion_selection_page.dart';
import '../features/ai_companion/pages/companion_chat_page.dart';
import '../features/combat_training/pages/combat_menu_page.dart';
import '../features/combat_training/pages/combat_training_page.dart';
import '../features/confession_predictor/pages/confession_analysis_page.dart';
import '../features/confession_predictor/pages/batch_upload_page.dart';
import '../features/real_chat_assistant/pages/real_chat_assistant_page.dart';
import '../features/anti_pua/pages/anti_pua_training_page.dart';
import '../features/analysis/pages/analysis_detail_page.dart';
import '../features/settings/pages/settings_page.dart';
import '../core/models/user_model.dart';
import '../core/models/character_model.dart';
import '../core/models/companion_model.dart';
import '../core/models/conversation_model.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String characterSelection = '/character_selection';
  static const String basicChat = '/basic_chat';
  static const String companionSelection = '/companion_selection';
  static const String companionChat = '/companion_chat';
  static const String combatMenu = '/combat_menu';
  static const String combatTraining = '/combat_training';
  static const String confessionAnalysis = '/confession_analysis';
  static const String batchUpload = '/batch_upload';
  static const String realChatAssistant = '/real_chat_assistant';
  static const String antiPuaTraining = '/anti_pua_training';
  static const String analysisDetail = '/analysis_detail';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => const HomePage(),
      login: (context) => const LoginPage(),
      settings: (context) => const SettingsPage(),
      companionSelection: (context) => const CompanionSelectionPage(),
      combatMenu: (context) => const CombatMenuPage(),
      batchUpload: (context) => const BatchUploadPage(),
      antiPuaTraining: (context) => const AntiPUATrainingPage(),
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case characterSelection:
        final args = settings.arguments as Map<String, dynamic>?;
        final user = args?['user'] as UserModel?;
        return MaterialPageRoute(
          builder: (context) => CharacterGridPage(currentUser: user!),
        );

      case basicChat:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null &&
            args['character'] != null &&
            args['user'] != null) {
          return MaterialPageRoute(
            builder: (context) => ChatPage(
              character: args['character'] as CharacterModel,
              currentUser: args['user'] as UserModel,
            ),
          );
        }
        return _errorRoute('缺少角色或用户信息');

      case companionChat:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null && args['companion'] != null) {
          return MaterialPageRoute(
            builder: (context) => CompanionChatPage(
              companion: args['companion'] as CompanionModel,
            ),
          );
        }
        return _errorRoute('缺少伴侣信息');

      case combatTraining:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null && args['scenario'] != null) {
          return MaterialPageRoute(
            builder: (context) => CombatTrainingPage(
              scenario: args['scenario'] as String,
              user: args['user'] as UserModel?,
            ),
          );
        }
        return _errorRoute('缺少训练场景信息');

      case confessionAnalysis:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => ConfessionAnalysisPage(
            analysisResult: args?['analysisResult'] as String?,
            chatData: args?['chatData'] as List<String>?,
          ),
        );

      case realChatAssistant:
        final args = settings.arguments as Map<String, dynamic>?;
        final user = args?['user'] as UserModel?;
        return MaterialPageRoute(
          builder: (context) => RealChatAssistantPage(user: user),
        );

      case analysisDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null &&
            args['conversation'] != null &&
            args['character'] != null &&
            args['user'] != null) {
          return MaterialPageRoute(
            builder: (context) => AnalysisDetailPage(
              conversation: args['conversation'] as ConversationModel,
              character: args['character'] as CharacterModel,
              user: args['user'] as UserModel,
            ),
          );
        }
        return _errorRoute('缺少对话信息');

      default:
        return _errorRoute('页面不存在');
    }
  }

  static Route<dynamic> _errorRoute([String? message]) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('页面未找到')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                message ?? '页面不存在',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  home,
                  (route) => false,
                ),
                child: const Text('返回首页'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}