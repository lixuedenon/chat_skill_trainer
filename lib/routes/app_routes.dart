// lib/routes/app_routes.dart

import 'package:flutter/material.dart';
import '../features/home/pages/home_page.dart';
import '../features/auth/pages/login_page.dart';
import '../features/character_selection/pages/character_grid_page.dart';
import '../features/chat/pages/basic_chat_page.dart';
import '../features/ai_companion/pages/companion_selection_page.dart';
import '../features/ai_companion/pages/companion_chat_page.dart';
import '../features/combat_training/pages/combat_menu_page.dart';
import '../features/combat_training/pages/combat_training_page.dart';
import '../features/confession_predictor/pages/confession_analysis_page.dart';
import '../features/real_chat_assistant/pages/real_chat_assistant_page.dart';
import '../features/anti_pua/pages/anti_pua_training_page.dart';
import '../features/analysis/pages/analysis_detail_page.dart';
import '../features/settings/pages/settings_page.dart';

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
  static const String realChatAssistant = '/real_chat_assistant';
  static const String antiPuaTraining = '/anti_pua_training';
  static const String analysisDetail = '/analysis_detail';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => const HomePage(),
      login: (context) => const LoginPage(),
      characterSelection: (context) => const CharacterGridPage(currentUser: null), // 需要传入实际用户
      // 其他路由需要根据实际参数进行调整
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case basicChat:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null && args['character'] != null && args['user'] != null) {
          return MaterialPageRoute(
            builder: (context) => BasicChatPage(
              character: args['character'],
              currentUser: args['user'],
            ),
          );
        }
        return _errorRoute();

      case companionChat:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null && args['companion'] != null) {
          return MaterialPageRoute(
            builder: (context) => CompanionChatPage(
              companion: args['companion'],
            ),
          );
        }
        return _errorRoute();

      case combatTraining:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null && args['scenario'] != null) {
          return MaterialPageRoute(
            builder: (context) => CombatTrainingPage(
              scenario: args['scenario'],
            ),
          );
        }
        return _errorRoute();

      case analysisDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null && args['conversation'] != null) {
          return MaterialPageRoute(
            builder: (context) => AnalysisDetailPage(
              conversation: args['conversation'],
            ),
          );
        }
        return _errorRoute();

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('页面未找到')),
        body: const Center(
          child: Text('页面不存在'),
        ),
      ),
    );
  }
}