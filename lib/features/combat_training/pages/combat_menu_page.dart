// lib/features/combat_training/pages/combat_menu_page.dart

import 'package:flutter/material.dart';
import '../../../core/constants/scenario_data.dart';

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
            const Row(
              children: [
                Icon(Icons.military_tech, color: Colors.amber, size: 28),
                SizedBox(width: 12),
                Text(
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
              '专项技能训练，应对复杂社交场景',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              '✓ 真实场景模拟\n✓ 专业解析指导\n✓ 快速技能提升',
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
          icon: '📚',
          title: '反套路专项',
          description: '应对各种测试性问题',
          scenarios: [
            '"你还有别的女性朋友吗？"',
            '"你觉得我胖吗？"',
            '"随便，你决定就好"',
          ],
          category: 'anti_routine',
        ),
        const SizedBox(height: 12),
        _buildModuleCard(
          context,
          icon: '🆘',
          title: '危机处理专项',
          description: '化解尴尬，重建氛围',
          scenarios: [
            '说错话快速补救',
            '冷场破冰技巧',
            '敏感话题转移',
          ],
          category: 'crisis_handling',
        ),
        const SizedBox(height: 12),
        _buildModuleCard(
          context,
          icon: '🎯',
          title: '高难度挑战',
          description: '攻克复杂社交场景',
          scenarios: [
            '傲娇女神攻略',
            '职场权威沟通',
            '群聊焦点争夺',
          ],
          category: 'high_difficulty',
          isAdvanced: true,
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
    bool isAdvanced = false,
  }) {
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
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isAdvanced) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  '高级',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                '包含场景：',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              ...scenarios.map((scenario) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
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
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ],
          ),
        ),
      ),
    );
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
                  '训练记录',
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
                  child: _buildStatItem('完成场景', '0', Icons.check_circle),
                ),
                Expanded(
                  child: _buildStatItem('正确率', '0%', Icons.military_tech),
                ),
                Expanded(
                  child: _buildStatItem('等级', 'D级', Icons.star),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '💡 提示：完成更多训练可以解锁高级模块',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
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