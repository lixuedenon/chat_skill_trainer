// lib/features/anti_pua/pages/anti_pua_training_page.dart (优化布局版)

import 'package:flutter/material.dart';

class AntiPUATrainingPage extends StatefulWidget {
  const AntiPUATrainingPage({Key? key}) : super(key: key);

  @override
  State<AntiPUATrainingPage> createState() => _AntiPUATrainingPageState();
}

class _AntiPUATrainingPageState extends State<AntiPUATrainingPage> {
  int _selectedAnswer = -1;
  bool _showFeedback = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('反PUA防护训练'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 主要内容区域
          Expanded(
            flex: 8, // 增加主内容区域的比例
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PUA话术警告区域 - 稍微压缩
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning, color: Colors.red[700], size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'PUA话术警告',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '他说：',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '"你是你家里我见过..."',
                              style: TextStyle(
                                color: Colors.red[800],
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '隐藏意图：',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '用"笑"来追过你懂，避过你懂不懂某人寄己',
                              style: TextStyle(
                                color: Colors.red[800],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 问题区域
                  Text(
                    '你可以这样回应：',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 选项区域 - 更紧凑的布局
                  ..._buildAnswerOptions(),

                  const SizedBox(height: 20),

                  // 反馈区域
                  if (_showFeedback) _buildFeedback(),
                ],
              ),
            ),
          ),

          // 底部按钮区域 - 固定高度，避免溢出
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('返回'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedAnswer != -1 ? _nextScenario : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('下一个场景'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAnswerOptions() {
    final options = [
      '完全不是你想的这样，想问什么就直说',
      '自正你觉不会另为对所做的司合',
      '如果你喜欢，我不会让你失望',
      '我们刚美的道感时能不一件',
    ];

    return options.asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value;
      final isSelected = _selectedAnswer == index;
      final isCorrect = index == 0; // 假设第一个是正确答案

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () => _selectAnswer(index),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? (_showFeedback
                        ? (isCorrect ? Colors.green : Colors.red)
                        : Theme.of(context).primaryColor)
                    : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: isSelected
                  ? (_showFeedback
                      ? (isCorrect
                          ? Colors.green[50]
                          : Colors.red[50])
                      : Theme.of(context).primaryColor.withOpacity(0.1))
                  : Colors.white,
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? (_showFeedback
                            ? (isCorrect ? Colors.green : Colors.red)
                            : Theme.of(context).primaryColor)
                        : Colors.grey[300],
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 15,
                      color: isSelected
                          ? (_showFeedback
                              ? (isCorrect ? Colors.green[800] : Colors.red[800])
                              : Theme.of(context).primaryColor)
                          : Colors.black87,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
                if (_showFeedback && isSelected)
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    color: isCorrect ? Colors.green : Colors.red,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildFeedback() {
    final isCorrect = _selectedAnswer == 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCorrect ? Colors.green[200]! : Colors.blue[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.lightbulb : Icons.info,
                color: isCorrect ? Colors.green[700] : Colors.blue[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? '学习要点' : '注意',
                style: TextStyle(
                  color: isCorrect ? Colors.green[700] : Colors.blue[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isCorrect
                ? '这是正确的应对方式！正确的表态更紧更加果断，不会让对方继续模糊和控制的机会，直截了当地向对方求证自己的猜测。'
                : '保护自己的权威过直接是完全正当的！',
            style: TextStyle(
              color: isCorrect ? Colors.green[800] : Colors.blue[800],
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _selectAnswer(int index) {
    setState(() {
      _selectedAnswer = index;
      _showFeedback = true;
    });
  }

  void _nextScenario() {
    // 进入下一个场景的逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('下一个场景功能开发中...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}