// lib/routes/app_routes.dart

import 'package:flutter/material.dart';
import '../features/auth/pages/login_page.dart';
import '../features/character_selection/pages/character_grid_page.dart';
import '../features/chat/pages/chat_page.dart';
import '../features/analysis/pages/analysis_detail_page.dart';
import '../features/settings/pages/settings_page.dart';
import '../core/models/character_model.dart';
import '../core/models/conversation_model.dart';
import '../core/models/user_model.dart';

class AppRoutes {
  static const String login = '/login';
  static const String characterSelection = '/character_selection';
  static const String chat = '/chat';
  static const String analysis = '/analysis';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginPage(),
    characterSelection: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final user = args?['user'] as UserModel?;

      if (user == null) {
        return const LoginPage();
      }

      return CharacterGridPage(currentUser: user);
    },
    chat: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final character = args?['character'] as CharacterModel?;
      final user = args?['user'] as UserModel?;

      if (character == null || user == null) {
        return const LoginPage();
      }

      return ChatPage(character: character, currentUser: user);
    },
    analysis: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final conversation = args?['conversation'] as ConversationModel?;
      final character = args?['character'] as CharacterModel?;
      final user = args?['user'] as UserModel?;

      if (conversation == null || character == null || user == null) {
        return const LoginPage();
      }

      return AnalysisDetailPage(
        conversation: conversation,
        character: character,
        user: user,
      );
    },
    settings: (context) => const SettingsPage(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final builder = routes[settings.name];
    if (builder != null) {
      return MaterialPageRoute(
        builder: builder,
        settings: settings,
      );
    }

    // 404页面
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