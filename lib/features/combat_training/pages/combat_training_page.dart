// lib/features/combat_training/pages/combat_training_page.dart (自动开始版)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../combat_controller.dart';
import '../../../core/constants/scenario_data.dart';
import '../../../core/models/user_model.dart';

class CombatTrainingPage extends StatefulWidget {
  final String scenario;
  final UserModel? user;

  const CombatTrainingPage({
    Key? key,
    required this.scenario,
    this.user,
  }) : super(key: key);

  @override
  State<CombatTrainingPage> createState() => _CombatTrainingPageState();
}

class _CombatTrainingPageState extends State<CombatTrainingPage> {
  late CombatController _controller;
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    print('🔴 [CombatTraining] initState - scenario: ${widget.scenario}');
    _initializeTraining();
  }

  Future<void> _initializeTraining() async {
    try {
      print('🔴 [CombatTraining] 开始初始化训练');

      // 创建控制器
      _controller = CombatController(
        user: widget.user ?? UserModel.newUser(
          id: 'guest',
          username: 'Guest',
          email: ''
        )
      );

      print('🔴 [CombatTraining] Controller创建成功');

      // 自动开始训练会话
      await _controller.startTrainingSession(widget.scenario);
      print('🔴 [CombatTraining] 训练会话开始成功');

      setState(() {
        _isInitialized = true;
      });

    } catch (e) {
      print('🔴 [CombatTraining] 初始化失败: $e');
      setState(() {
        _error = e.toString();
        _isInitialized = true; // 设置为true以显示错误界面
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🔴 [CombatTraining] build - initialized: $_isInitialized, error: $_error');

    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_getScenarioTitle(widget.scenario)),
          centerTitle: true,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('正在准备训练场景...'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_getScenarioTitle(widget.scenario)),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('加载失败: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isInitialized = false;
                    _error = null;
                  });
                  _initializeTraining();
                },
                child: const Text('重试'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('返回菜单'),
              ),
            ],
          ),
        ),
      );
    }

    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<CombatController>(
        builder: (context, controller, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_getScenarioTitle(widget.scenario)),
              centerTitle: true,
            ),
            body: controller.currentScenario == null
                ? _buildNoScenarioScreen(context)
                : _buildTrainingScreen(context, controller),
          );
        },
      ),
    );
  }

  Widget _buildNoScenarioScreen(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning, size: 64, color: Colors.orange),
          const SizedBox(height: 16),
          const Text('没有找到训练场景'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('返回菜单'),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingScreen(BuildContext context, CombatController controller) {
    final scenario = controller.currentScenario!;
    print('🔴 [CombatTraining] 构建训练界面 - scenario: ${scenario.title}');

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

    final progress = (session.currentScenarioIndex - 1) / session.scenarios.length;
    final currentIndex = session.currentScenarioIndex - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('进度: ${currentIndex + 1}/${session.scenarios.length}'),
            Text('正确率: ${(session.getAccuracy() * 100).toStringAsFixed(0)}%'),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: progress.clamp(0.0, 1.0)),
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
            const Row(
              children: [
                Icon(Icons.info_outline, size: 20),
                SizedBox(width: 8),
                Text(
                  '场景背景',
                  style: TextStyle(
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
            const Row(
              children: [
                Icon(Icons.chat_bubble_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text(
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
                  color: isSelected || (hasAnswered && option.isCorrect)
                      ? (option.isCorrect ? Colors.green : Colors.red)
                      : Colors.grey.shade300,
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
      case 'workplace_crisis':
        return '职场高危';
      case 'high_difficulty':
      case 'social_crisis':
        return '聚会冷场处理';
      default:
        return '实战训练';
    }
  }

  @override
  void dispose() {
    if (_isInitialized && _error == null) {
      _controller.dispose();
    }
    super.dispose();
  }
}