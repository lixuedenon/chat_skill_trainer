// lib/features/combat_training/pages/combat_menu_page.dart (修复UI问题)

import 'package:flutter/material.dart';
import '../combat_scenario_data.dart';

class CombatMenuPage extends StatelessWidget {
  const CombatMenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('实战训练营'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 20),
            _buildTrainingModules(context),
            const SizedBox(height: 20),
            _buildProgressCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.military_tech, color: Colors.amber, size: 28),
                const SizedBox(width: 12),
                const Text(
                  '实战训练营',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '真实社交场景训练，提升应变能力',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              '• 反套路应对策略\n• 职场关系处理\n• 社交危机化解',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingModules(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '训练模块',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildModuleCard(
          context,
          icon: '🎯',
          title: '反套路专项',
          description: '识破并优雅应对各种测试',
          scenarios: [
            '探底测试：女性朋友问题',
            '情感绑架：时间投资测试',
            '价值观试探：经济观念',
          ],
          category: 'anti_routine',
          difficulty: '中级',
          difficultyColor: Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildModuleCard(
          context,
          icon: '💼',
          title: '职场高危',
          description: '职场关系的专业处理',
          scenarios: [
            '上级私下接触',
            '同事暧昧试探',
            '客户关系越界',
          ],
          category: 'workplace_crisis',
          difficulty: '高级',
          difficultyColor: Colors.red,
        ),
        const SizedBox(height: 12),
        _buildModuleCard(
          context,
          icon: '🎉',
          title: '聚会冷场处理',
          description: '社交场合的氛围调节',
          scenarios: [
            '聚会冷场救急',
            '群聊焦点争夺',
            '敏感话题转移',
            '新人融入协助',
          ],
          category: 'social_crisis',
          difficulty: '初级',
          difficultyColor: Colors.green,
        ),
      ],
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String description,
    required List<String> scenarios,
    required String category,
    required String difficulty,
    required Color difficultyColor,
  }) {
    // 🔥 修复：直接从本地数据获取场景数量，避免Future问题
    final scenarioCount = _getScenarioCountByCategory(category);

    return Card(
      child: InkWell(
        onTap: () => _navigateToTraining(context, category),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // 🔥 修复：使用Flexible防止标题溢出
                            Flexible(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: difficultyColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                difficulty,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: difficultyColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // 🔥 修复：防止描述文字溢出
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // 🔥 修复：确保右侧内容不溢出
                  Column(
                    children: [
                      Text(
                        '${scenarioCount}题',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                '训练场景：',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              // 🔥 修复：场景列表布局优化，防止溢出
              Column(
                children: scenarios.map((scenario) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.only(top: 6),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          scenario,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔥 新增：根据类别获取场景数量的本地方法
  int _getScenarioCountByCategory(String category) {
    switch (category) {
      case 'anti_routine':
        return CombatScenarioData.antiRoutineScenarios.length;
      case 'workplace_crisis':
      case 'crisis_handling':
        return CombatScenarioData.crisisHandlingScenarios.length;
      case 'social_crisis':
      case 'high_difficulty':
        return CombatScenarioData.advancedChallengeScenarios.length;
      default:
        return 0;
    }
  }

  Widget _buildProgressCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.trending_up, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  '训练统计',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('已完成', '0', Icons.check_circle),
                ),
                Expanded(
                  child: _buildStatItem('正确率', '0%', Icons.military_tech),
                ),
                Expanded(
                  child: _buildStatItem('当前等级', 'D级', Icons.star),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '训练建议',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• 建议从"聚会冷场处理"开始，难度较低\n• 每个模块建议完成70%以上再进入下一个\n• 职场高危模块需谨慎，建议有一定经验后练习',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  void _navigateToTraining(BuildContext context, String category) {
    Navigator.pushNamed(
      context,
      '/combat_training',
      arguments: {'scenario': category},
    );
  }
}