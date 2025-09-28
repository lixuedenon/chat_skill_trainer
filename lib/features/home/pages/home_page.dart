// lib/features/home/pages/home_page.dart (修复UI溢出问题)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../home_controller.dart';
import '../../../core/models/user_model.dart';
import '../../auth/auth_controller.dart';

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
    return Consumer<HomeController>(
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
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => _logout(context),
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
    );
  }

  Widget _buildUserInfoCard(UserModel? user) {
    if (user == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('正在加载用户信息...'),
              const SizedBox(height: 12),
              const CircularProgressIndicator(),
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
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    user.username.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
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
    // 🔥 调整：添加批量分析，移除实战训练营
    final coreModules = controller.availableModules.where((module) =>
      ['basic_chat', 'ai_companion', 'batch_chat_analyzer', 'anti_pua'].contains(module.id)
    ).toList();

    if (coreModules.isEmpty) {
      return Center(
        child: Text(
          '暂无可用的核心训练模块',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
        ),
      );
    }

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
    // 🔥 调整：添加实战训练营到智能辅助工具区域
    final assistantModules = controller.availableModules.where((module) =>
      ['combat_training', 'confession_predictor', 'real_chat_assistant'].contains(module.id)
    ).toList();

    print('🔍 智能辅助工具模块数量: ${assistantModules.length}');
    for (final module in assistantModules) {
      print('🔍 模块: ${module.name} - 解锁状态: ${module.isUnlocked}');
    }

    if (assistantModules.isEmpty) {
      return Center(
        child: Text(
          '暂无可用的智能辅助工具',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
        ),
      );
    }

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

  /// 🔥 修复：优化模块卡片布局，解决文字溢出问题
  Widget _buildModuleCard(TrainingModule module, HomeController controller) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: module.isUnlocked
          ? () => _onModuleTap(module, controller)
          : () => _showUnlockDialog(module),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔥 新增：为批量分析添加特殊标记
              if (module.id == 'batch_chat_analyzer')
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '🔥 核心功能',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              // 图标 - 减小尺寸给文字让出更多空间
              Text(
                module.icon,
                style: const TextStyle(fontSize: 28), // 从32减小到28
              ),
              const SizedBox(height: 6), // 从8减小到6

              // 🔥 修复：标题文字 - 增强约束
              Text(
                module.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14, // 明确设置字体大小
                  color: module.isUnlocked ? null : Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2), // 从4减小到2

              // 🔥 修复：描述文字 - 使用Flexible防止溢出
              Flexible(
                child: Text(
                  _getShortDescription(module), // 使用简化的描述
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11, // 从默认大小减小到11
                    height: 1.2, // 设置行高
                    color: module.isUnlocked ? Colors.grey[600] : Colors.grey[400],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // 锁定图标
              if (!module.isUnlocked)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.lock,
                    color: Colors.grey,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔥 新增：获取简化的描述文字，防止溢出
  String _getShortDescription(TrainingModule module) {
    // 为特定模块提供更简洁的描述
    switch (module.id) {
      case 'batch_chat_analyzer':
        return 'AI智能分析聊天记录';
      case 'basic_chat':
        return '与AI角色对话，提升沟通技巧';
      case 'ai_companion':
        return '长期AI伴侣养成，学习关系技巧';
      case 'anti_pua':
        return '识别并应对PUA技术';
      case 'combat_training':
        return '实战场景训练';
      case 'confession_predictor':
        return '告白成功率预测';
      case 'real_chat_assistant':
        return '真人聊天助手';
      default:
        // 如果原描述太长，进行截断
        if (module.description.length > 20) {
          return '${module.description.substring(0, 18)}...';
        }
        return module.description;
    }
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
    print('🔗 点击模块: ${module.name} (${module.id})');

    switch (module.id) {
      case 'basic_chat':
        print('🔗 导航到角色选择');
        Navigator.pushNamed(
          context,
          '/character_selection',
          arguments: {'user': controller.currentUser},
        );
        break;
      case 'ai_companion':
        print('🔗 导航到伴侣选择');
        Navigator.pushNamed(context, '/companion_selection');
        break;
      case 'batch_chat_analyzer': // 🔥 新增：批量分析导航
        print('🔗 导航到批量上传');
        Navigator.pushNamed(context, '/batch_upload');
        break;
      case 'combat_training':
        print('🔗 导航到实战训练营');
        Navigator.pushNamed(context, '/combat_menu');
        break;
      case 'anti_pua':
        print('🔗 导航到反PUA训练');
        Navigator.pushNamed(context, '/anti_pua_training');
        break;
      case 'confession_predictor':
        print('🔗 导航到告白预测');
        Navigator.pushNamed(context, '/confession_analysis');
        break;
      case 'real_chat_assistant':
        print('🔗 导航到聊天助手');
        Navigator.pushNamed(
          context,
          '/real_chat_assistant',
          arguments: {'user': controller.currentUser},
        );
        break;
      default:
        print('⚠️ 未知模块ID: ${module.id}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${module.name} 功能开发中...')),
        );
    }
  }

  void _showUnlockDialog(TrainingModule module) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${module.name} 暂未解锁'),
        content: Text(module.unlockDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final authController = Provider.of<AuthController>(context, listen: false);
              authController.logout();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}