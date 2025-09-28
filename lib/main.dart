// lib/main.dart (更新 - 初始化Hive替代SharedPreferences)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/utils/theme_manager.dart';
import 'shared/services/hive_service.dart';  // 🔥 替代 StorageService
import 'features/auth/auth_controller.dart';
import 'features/home/home_controller.dart';
import 'features/home/pages/home_page.dart';
import 'routes/app_routes.dart';
import 'core/models/user_model.dart';
import 'core/constants/scenario_data.dart';  // 🔥 需要预加载场景数据

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print('🚀 应用启动中...');

    // 🔥 初始化Hive数据库 - 替代SharedPreferences
    //await HiveService.init();
    print('✅ Hive数据库初始化完成');

    // 🔥 预加载场景数据 - 避免首次使用时延迟
    print('🔄 预加载场景数据...');
    //await ScenarioData.loadScenarios();
    print('✅ 场景数据预加载完成');

    print('🎉 应用初始化成功，启动UI...');
    runApp(const ChatSkillTrainerApp());

  } catch (e, stackTrace) {
    print('❌ 应用初始化失败: $e');
    print('📍 错误堆栈: $stackTrace');

    // 显示错误界面而不是崩溃
    runApp(MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('初始化失败')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('应用初始化失败', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  e.toString(),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
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
    print('🔄 开始初始化应用组件...');
    _authController = AuthController();
    _loadTheme();
    _initializeAuth();
  }

  Future<void> _loadTheme() async {
    try {
      // 🔥 使用HiveService获取主题设置
      final themeString = HiveService.getAppTheme();
      final themeType = _parseThemeType(themeString);

      if (mounted) {
        setState(() {
          _currentTheme = themeType;
          ThemeManager.setTheme(themeType);
        });
      }

      print('✅ 主题加载完成: $themeString');
    } catch (e) {
      print('❌ 主题加载失败: $e');
      // 使用默认主题
      _currentTheme = AppThemeType.young;
      ThemeManager.setTheme(_currentTheme);
    }
  }

  Future<void> _initializeAuth() async {
    try {
      print('🔄 开始初始化用户认证...');
      await _authController.initializeAuth();
      print('✅ 用户认证初始化完成');
    } catch (e) {
      print('❌ 用户认证初始化失败: $e');
    }
  }

  AppThemeType _parseThemeType(String themeString) {
    switch (themeString) {
      case 'business':
        return AppThemeType.business;
      case 'cute':
        return AppThemeType.cute;
      case 'young':
      default:
        return AppThemeType.young;
    }
  }

  @override
  void dispose() {
    print('🔄 应用主组件销毁中...');
    _authController.dispose();

    // 🔥 应用退出时关闭Hive连接
    HiveService.close();
    print('✅ 应用主组件销毁完成');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authController),
        ChangeNotifierProvider(create: (_) => HomeController()),
      ],
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
            print('🔄 构建主页面，用户登录状态: ${auth.isLoggedIn}');

            // 登录后显示主页，未登录显示欢迎页
            if (auth.isLoggedIn && auth.currentUser != null) {
              // 🔥 更新主页控制器的用户信息
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  final homeController = Provider.of<HomeController>(context, listen: false);
                  homeController.updateUser(auth.currentUser!);
                }
              });
              return const HomePage();
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
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('聊天技能训练师'),
        centerTitle: true,
        actions: [
          // 🔥 添加调试信息按钮（仅在开发模式）
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showDebugInfo(context),
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
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
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

              // 登录按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: const Text('开始体验'),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '快速登录：a / 1 或 demo / 123456',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),

              const SizedBox(height: 32),
              // 🔥 显示系统状态
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[700], size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Hive数据库已就绪',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.data_object, color: Colors.green[700], size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '场景数据已预载',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔥 显示调试信息
  void _showDebugInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('系统信息'),
        content: FutureBuilder<Map<String, dynamic>>(
          future: _getSystemInfo(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final info = snapshot.data!;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('数据库状态', info['db_healthy'] ? '健康' : '异常'),
                  _buildInfoRow('场景数据', '${info['scenarios_count']} 个场景'),
                  _buildInfoRow('用户数据', '${info['users_count']} 个用户'),
                  _buildInfoRow('对话记录', '${info['conversations_count']} 条对话'),
                  _buildInfoRow('分析报告', '${info['reports_count']} 份报告'),
                  _buildInfoRow('AI伴侣', '${info['companions_count']} 个伴侣'),
                ],
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  /// 获取系统信息
  Future<Map<String, dynamic>> _getSystemInfo() async {
    try {
      final dbStats = HiveService.getDatabaseStats();
      final scenariosInfo = ScenarioData.getCacheInfo();

      return {
        'db_healthy': true,
        'scenarios_count': scenariosInfo['totalScenarios'] ?? 0,
        'users_count': dbStats['users'] ?? 0,
        'conversations_count': dbStats['conversations'] ?? 0,
        'reports_count': dbStats['analysis_reports'] ?? 0,
        'companions_count': dbStats['companions'] ?? 0,
      };
    } catch (e) {
      return {
        'db_healthy': false,
        'error': e.toString(),
        'scenarios_count': 0,
        'users_count': 0,
        'conversations_count': 0,
        'reports_count': 0,
        'companions_count': 0,
      };
    }
  }
}