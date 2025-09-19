// lib/features/home/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../home_controller.dart';
import '../../../core/models/user_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeController>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeController(),
      child: Consumer<HomeController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('聊天技能训练师'),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () => Navigator.pushNamed(context, '/settings'),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 用户信息卡片
                  _buildUserInfoCard(controller.currentUser),
                  const SizedBox(height: 20),

                  // 核心训练模块
                  _buildSectionTitle('核心训练模块'),
                  const SizedBox(height: 12),
                  _buildCoreModules(controller),
                  const SizedBox(height: 20),

                  // 智能辅助工具
                  _buildSectionTitle('智能辅助工具'),
                  const SizedBox(height: 12),
                  _buildAssistantModules(controller),
                  const SizedBox(height: 20),

                  // 成长追踪
                  _buildSectionTitle('成长追踪'),
                  const SizedBox(height: 12),
                  _buildGrowthTracker(controller.currentUser),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserInfoCard(UserModel? user) {
    if (user == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('欢迎使用聊天技能训练师'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text('登录开始训练'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(user.username.substring(0, 1).toUpperCase()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text('${user.userLevel.title} - Lv.${user.userLevel.level}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Credits: ${user.credits}'),
                      Text('经验: ${user.userLevel.experience}/${user.userLevel.nextLevelExp}'),
                    ],
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: LinearProgressIndicator(
                    value: user.userLevel.progressPercentage,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCoreModules(HomeController controller) {
    final coreModules = controller.availableModules.where((module) =>
      ['basic_chat', 'ai_companion', 'combat_training', 'anti_pua'].contains(module.id)
    ).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: coreModules.length,
      itemBuilder: (context, index) {
        return _buildModuleCard(coreModules[index], controller);
      },
    );
  }

  Widget _buildAssistantModules(HomeController controller) {
    final assistantModules = controller.availableModules.where((module) =>
      ['confession_predictor', 'real_chat_assistant'].contains(module.id)
    ).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: assistantModules.length,
      itemBuilder: (context, index) {
        return _buildModuleCard(assistantModules[index], controller);
      },
    );
  }

  Widget _buildModuleCard(TrainingModule module, HomeController controller) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: module.isUnlocked
          ? () => _onModuleTap(module, controller)
          : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                module.icon,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 8),
              Text(
                module.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                module.description,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (!module.isUnlocked)
                const Icon(
                  Icons.lock,
                  color: Colors.grey,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrowthTracker(UserModel? user) {
    if (user == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up),
                const SizedBox(width: 8),
                Text(
                  '成长数据',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '对话次数',
                    '${user.stats.totalConversations}',
                    Icons.chat,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '平均好感度',
                    '${user.stats.averageFavorability.toStringAsFixed(1)}',
                    Icons.favorite,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '主导魅力',
                    user.charmTagNames.isNotEmpty ? user.charmTagNames.first : '待发现',
                    Icons.star,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '成功率',
                    '${(user.stats.successRate * 100).toStringAsFixed(0)}%',
                    Icons.military_tech,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  void _onModuleTap(TrainingModule module, HomeController controller) {
    switch (module.id) {
      case 'basic_chat':
        Navigator.pushNamed(
          context,
          '/character_selection',
          arguments: {'user': controller.currentUser},
        );
        break;
      case 'ai_companion':
        Navigator.pushNamed(context, '/companion_selection');
        break;
      case 'combat_training':
        Navigator.pushNamed(context, '/combat_menu');
        break;
      case 'anti_pua':
        Navigator.pushNamed(context, '/anti_pua_training');
        break;
      case 'confession_predictor':
        Navigator.pushNamed(context, '/confession_analysis');
        break;
      case 'real_chat_assistant':
        Navigator.pushNamed(context, '/real_chat_assistant');
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${module.name} 功能开发中...')),
        );
    }
  }
}