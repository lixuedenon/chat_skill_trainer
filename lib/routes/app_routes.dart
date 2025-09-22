// lib/routes/app_routes.dart (完整调试版)

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
      login: (context) {
        print('🟣 [Routes] 构建LoginPage');
        return const LoginPage();
      },
      settings: (context) {
        print('🟣 [Routes] 构建SettingsPage');
        return const SettingsPage();
      },
      batchUpload: (context) {
        print('🟣 [Routes] 构建BatchUploadPage');
        return const BatchUploadPage();
      },
      antiPuaTraining: (context) {
        print('🟣 [Routes] 构建AntiPUATrainingPage');
        return const AntiPUATrainingPage();
      },
      combatMenu: (context) {
        print('🟣 [Routes] 构建CombatMenuPage');
        return const CombatMenuPage();
      },
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    print('🟣 [Routes] onGenerateRoute 调用');
    print('🟣 [Routes] 路由名称: ${settings.name}');
    print('🟣 [Routes] 路由参数: ${settings.arguments}');

    switch (settings.name) {
      case home:
        print('🟣 [Routes] 生成HomePage路由');
        return MaterialPageRoute(
          builder: (context) {
            print('🟣 [Routes] 构建HomePage');
            return const HomePage();
          },
        );

      case characterSelection:
        print('🟣 [Routes] 生成CharacterSelection路由');
        final args = settings.arguments as Map<String, dynamic>?;
        print('🟣 [Routes] CharacterSelection参数: $args');
        final user = args?['user'] as UserModel?;
        if (user != null) {
          print('🟣 [Routes] User参数正确: ${user.username}');
          return MaterialPageRoute(
            builder: (context) => CharacterGridPage(currentUser: user),
          );
        }
        print('🔴 [Routes] CharacterSelection缺少用户参数');
        return _errorRoute('缺少用户信息');

      case basicChat:
        print('🟣 [Routes] 生成BasicChat路由');
        final args = settings.arguments as Map<String, dynamic>?;
        print('🟣 [Routes] BasicChat参数: $args');
        if (args != null &&
            args['character'] != null &&
            args['user'] != null) {
          final character = args['character'] as CharacterModel;
          final user = args['user'] as UserModel;
          print('🟣 [Routes] BasicChat参数正确 - Character: ${character.name}, User: ${user.username}');
          return MaterialPageRoute(
            builder: (context) => ChatPage(
              character: character,
              currentUser: user,
            ),
          );
        }
        print('🔴 [Routes] BasicChat缺少参数');
        return _errorRoute('缺少角色或用户信息');

      case companionSelection:
        print('🟣 [Routes] 生成CompanionSelection路由');
        return MaterialPageRoute(
          builder: (context) {
            print('🟣 [Routes] 构建CompanionSelectionPage');
            return const CompanionSelectionPage();
          },
        );

      case companionChat:
        print('🟣 [Routes] 生成CompanionChat路由');
        final args = settings.arguments as Map<String, dynamic>?;
        print('🟣 [Routes] CompanionChat参数: $args');
        print('🟣 [Routes] CompanionChat参数类型: ${args.runtimeType}');

        if (args != null) {
          print('🟣 [Routes] 参数不为空，检查companion字段');
          final companionData = args['companion'];
          print('🟣 [Routes] companion字段: $companionData');
          print('🟣 [Routes] companion字段类型: ${companionData.runtimeType}');

          if (companionData != null) {
            try {
              CompanionModel companion;
              if (companionData is CompanionModel) {
                companion = companionData;
                print('🟣 [Routes] companion参数类型正确: ${companion.name}');
              } else if (companionData is Map<String, dynamic>) {
                print('🟣 [Routes] companion是Map，尝试转换为CompanionModel');
                companion = CompanionModel.fromJson(companionData);
                print('🟣 [Routes] Map转换成功: ${companion.name}');
              } else {
                print('🔴 [Routes] companion参数类型错误: ${companionData.runtimeType}');
                return _errorRoute('伴侣参数类型错误');
              }

              print('🟣 [Routes] 准备构建CompanionChatPage');
              return MaterialPageRoute(
                builder: (context) {
                  print('🟣 [Routes] 开始构建CompanionChatPage - companion: ${companion.name}');
                  return CompanionChatPage(companion: companion);
                },
              );
            } catch (e) {
              print('🔴 [Routes] CompanionChat参数转换错误: $e');
              return _errorRoute('伴侣参数转换失败: $e');
            }
          }
        }
        print('🔴 [Routes] CompanionChat缺少伴侣参数');
        return _errorRoute('缺少伴侣信息');

      case combatTraining:
        print('🟣 [Routes] 生成CombatTraining路由');
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
        print('🟣 [Routes] 生成ConfessionAnalysis路由');
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => ConfessionAnalysisPage(
            analysisResult: args?['analysisResult'] as String?,
            chatData: args?['chatData'] as List<String>?,
          ),
        );

      case realChatAssistant:
        print('🟣 [Routes] 生成RealChatAssistant路由');
        final args = settings.arguments as Map<String, dynamic>?;
        final user = args?['user'] as UserModel?;
        return MaterialPageRoute(
          builder: (context) => RealChatAssistantPage(user: user),
        );

      case analysisDetail:
        print('🟣 [Routes] 生成AnalysisDetail路由');
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
        print('🔴 [Routes] 未知路由: ${settings.name}');
        return _errorRoute('页面不存在');
    }
  }

  static Route<dynamic> _errorRoute([String? message]) {
    print('🔴 [Routes] 生成错误路由: $message');
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
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  print('🟣 [Routes] 错误页面返回首页');
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    home,
                    (route) => false,
                  );
                },
                child: const Text('返回首页'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}