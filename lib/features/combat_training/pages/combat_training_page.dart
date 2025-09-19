// lib/features/combat_training/pages/combat_training_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../combat_controller.dart';
import '../../../core/constants/scenario_data.dart';
import '../../../core/models/user_model.dart';

class CombatTrainingPage extends StatelessWidget {
  final String scenario;
  final UserModel? user;

  const CombatTrainingPage({
    Key? key,
    required this.scenario,
    this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CombatController(user: user ?? UserModel.newUser(id: 'guest', username: 'Guest', email: '')),
      child: Consumer<CombatController>(
        builder: (context, controller, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_getScenarioTitle(scenario)),
              centerTitle: true,
            ),
            body: controller.currentScenario == null
                ? _buildLoadingScreen(context, controller, scenario)
                : _buildTrainingScreen(context, controller),
          );
        },
      ),
    );
  }

  Widget _buildLoadingScreen(BuildContext context, CombatController controller, String scenario) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          const Text('正在准备训练场景...'),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => controller.startTrainingSession(scenario),
            child: const Text('开始训练'),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingScreen(BuildContext context, CombatController controller) {
    final scenario = controller.currentScenario!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 进度指示器
          _buildProgressIndicator(controller),
          const SizedBox(height: 20),

          // 场景背景
          _buildScenarioBackground(scenario),
          const SizedBox(height: 20),

          // 问题
          _buildQuestion(scenario),
          const SizedBox(height: 20),

          // 选项
          _buildOptions(context, controller, scenario),
          const SizedBox(height: 20),

          // 结果显示
          if (controller.showResults) _buildResults(controller, scenario),

          // 操作按钮
          _buildActionButtons(context, controller),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(CombatController controller) {
    final session = controller.currentSession;
    if (session == null) return const SizedBox();

    final progress = session.currentScenarioIndex / session.scenarios.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('进度: ${session.currentScenarioIndex}/${session.scenarios.length}'),
            Text('正确率: ${(session.getAccuracy() * 100).toStringAsFixed(0)}%'),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: progress),
      ],
    );
  }

  Widget _buildScenarioBackground(CombatScenario scenario) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, size: 20),
                const SizedBox(width: 8),
                Text(
                  '场景背景',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              scenario.background,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion(CombatScenario scenario) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.chat_bubble_outline, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  '她说：',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              scenario.question,
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptions(BuildContext context, CombatController controller, CombatScenario scenario) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '你的回应：',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        ...scenario.options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildOptionCard(context, controller, index, option),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildOptionCard(BuildContext context, CombatController controller, int index, ScenarioOption option) {
    final isSelected = controller.selectedOptionIndex == index;
    final hasAnswered = controller.hasAnswered;

    Color? backgroundColor;
    Color? borderColor;
    IconData? icon;

    if (hasAnswered) {
      if (option.isCorrect) {
        backgroundColor = Colors.green.shade50;
        borderColor = Colors.green;
        icon = Icons.check_circle;
      } else if (isSelected && !option.isCorrect) {
        backgroundColor = Colors.red.shade50;
        borderColor = Colors.red;
        icon = Icons.cancel;
      }
    } else if (isSelected) {
      backgroundColor = Colors.blue.shade50;
      borderColor = Colors.blue;
    }

    return Card(
      color: backgroundColor,
      child: InkWell(
        onTap: hasAnswered ? null : () => controller.selectOption(index),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: borderColor != null ? Border.all(color: borderColor, width: 2) : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected || hasAnswered && option.isCorrect ? Colors.blue : Colors.grey.shade300,
                ),
                child: Center(
                  child: icon != null
                    ? Icon(icon, size: 16, color: Colors.white)
                    : Text(
                        String.fromCharCode(65 + index), // A, B, C
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  option.text,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults(CombatController controller, CombatScenario scenario) {
    final selectedOption = scenario.options[controller.selectedOptionIndex];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  selectedOption.isCorrect ? Icons.thumb_up : Icons.thumb_down,
                  color: selectedOption.isCorrect ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  selectedOption.isCorrect ? '回答正确！' : '需要改进',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: selectedOption.isCorrect ? Colors.green : Colors.red,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '反馈：${selectedOption.feedback}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '解析：',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    scenario.explanation,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, CombatController controller) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        children: [
          if (!controller.hasAnswered) ...[
            Expanded(
              child: ElevatedButton(
                onPressed: controller.selectedOptionIndex == -1
                  ? null
                  : () => controller.submitAnswer(),
                child: const Text('确认选择'),
              ),
            ),
          ] else ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('返回菜单'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => controller.nextScenario(),
                child: const Text('下一题'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getScenarioTitle(String scenario) {
    switch (scenario) {
      case 'anti_routine':
        return '反套路专项';
      case 'crisis_handling':
        return '危机处理专项';
      case 'high_difficulty':
        return '高难度挑战';
      default:
        return '实战训练';
    }
  }
}