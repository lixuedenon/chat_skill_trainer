// lib/main.dart (修复版 - 添加路由和认证系统)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/utils/theme_manager.dart';
import 'shared/services/storage_service.dart';
import 'features/auth/auth_controller.dart';
import 'routes/app_routes.dart';
import 'core/models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const ChatSkillTrainerApp());
}

class ChatSkillTrainerApp extends StatefulWidget {
  const ChatSkillTrainerApp({Key? key}) : super(key: key);

  @override
  State<ChatSkillTrainerApp> createState() => _ChatSkillTrainerAppState();
}

class _ChatSkillTrainerAppState extends State<ChatSkillTrainerApp> {
  AppThemeType _currentTheme = AppThemeType.young;
  late AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = AuthController();
    _loadTheme();
    _initializeAuth();
  }

  Future<void> _loadTheme() async {
    final themeString = await StorageService.getAppTheme();
    final themeType = _parseThemeType(themeString);
    if (mounted) {
      setState(() {
        _currentTheme = themeType;
        ThemeManager.setTheme(themeType);
      });
    }
  }

  Future<void> _initializeAuth() async {
    await _authController.initializeAuth();
  }

  AppThemeType _parseThemeType(String themeString) {
    switch (themeString) {
      case 'business': return AppThemeType.business;
      case 'cute': return AppThemeType.cute;
      default: return AppThemeType.young;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _authController,
      child: MaterialApp(
        title: '聊天技能训练师',
        debugShowCheckedModeBanner: false,
        theme: ThemeManager.getThemeData(_currentTheme, Brightness.light),
        darkTheme: ThemeManager.getThemeData(_currentTheme, Brightness.dark),
        themeMode: ThemeMode.system,
        routes: AppRoutes.routes,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: Consumer<AuthController>(
          builder: (context, auth, child) {
            if (auth.isLoggedIn && auth.currentUser != null) {
              return WelcomePage(currentUser: auth.currentUser!);
            } else {
              return const WelcomePage();
            }
          },
        ),
      ),
    );
  }
}

class WelcomePage extends StatelessWidget {
  final UserModel? currentUser;

  const WelcomePage({Key? key, this.currentUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('聊天技能训练师'),
        centerTitle: true,
        actions: [
          if (currentUser != null)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chat_bubble_outline,
                  size: 60,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                '欢迎使用聊天技能训练师',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '通过AI对话练习，提升你的社交沟通能力',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // 根据登录状态显示不同按钮
              if (currentUser != null) ...[
                Text(
                  '欢迎回来，${currentUser!.username}！',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '剩余对话次数：${currentUser!.credits}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      '/character_selection',
                      arguments: {'user': currentUser},
                    ),
                    child: const Text('开始聊天'),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => _logout(context),
                  child: const Text('退出登录'),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: const Text('开始体验'),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '体验账号：demo / 123456',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    final authController = Provider.of<AuthController>(context, listen: false);
    authController.logout();
  }
}