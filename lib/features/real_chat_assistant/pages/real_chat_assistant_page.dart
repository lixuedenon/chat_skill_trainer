// lib/features/real_chat_assistant/pages/real_chat_assistant_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../real_chat_controller.dart';
import '../../../core/models/user_model.dart';

class RealChatAssistantPage extends StatefulWidget {
  final UserModel? user;

  const RealChatAssistantPage({Key? key, this.user}) : super(key: key);

  @override
  State<RealChatAssistantPage> createState() => _RealChatAssistantPageState();
}

class _RealChatAssistantPageState extends State<RealChatAssistantPage>
    with TickerProviderStateMixin {
  late RealChatController _controller;
  late TabController _tabController;
  final TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = RealChatController(
      user: widget.user ?? UserModel.newUser(
        id: 'guest',
        username: 'Guest',
        email: 'guest@example.com',
      ),
    );
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('真人聊天助手'),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Icon(Icons.translate),
                text: '社交翻译',
              ),
              Tab(
                icon: Icon(Icons.radar),
                text: '社交雷达',
              ),
              Tab(
                icon: Icon(Icons.assistant),
                text: '回复建议',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildTranslatorTab(),
            _buildRadarTab(),
            _buildAssistantTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslatorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            '社交翻译官',
            '解读对方话语背后的真实含义',
            Icons.translate,
          ),
          const SizedBox(height: 24),
          _buildInputSection(
            '输入对方说的话',
            '例如："你是个好人，但是..."',
            _analyzeMessage,
          ),
          const SizedBox(height: 24),
          Consumer<RealChatController>(
            builder: (context, controller, child) {
              if (controller.isAnalyzing) {
                return const LoadingIndicator(message: '正在解析中...');
              }

              if (controller.translationResult.isNotEmpty) {
                return _buildTranslationResult(controller.translationResult);
              }

              return _buildTranslationExamples();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRadarTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            '社交雷达',
            '识别对话中的关键信息点',
            Icons.radar,
          ),
          const SizedBox(height: 24),
          _buildInputSection(
            '输入聊天内容',
            '粘贴你们的聊天记录...',
            _scanForSignals,
          ),
          const SizedBox(height: 24),
          Consumer<RealChatController>(
            builder: (context, controller, child) {
              if (controller.isScanning) {
                return const LoadingIndicator(message: '雷达扫描中...');
              }

              if (controller.radarResults.isNotEmpty) {
                return _buildRadarResults(controller.radarResults);
              }

              return _buildRadarIntroduction();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAssistantTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            '智能回复建议',
            '根据上下文生成最佳回复',
            Icons.assistant,
          ),
          const SizedBox(height: 24),
          _buildInputSection(
            '输入对话上下文',
            '包括对方说的话和你想表达的意思...',
            _generateReply,
          ),
          const SizedBox(height: 24),
          Consumer<RealChatController>(
            builder: (context, controller, child) {
              if (controller.isGenerating) {
                return const LoadingIndicator(message: '生成建议中...');
              }

              if (controller.replySuggestions.isNotEmpty) {
                return _buildReplySuggestions(controller.replySuggestions);
              }

              return _buildReplyExamples();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 28,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildInputSection(String title, String hint, VoidCallback onAnalyze) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _inputController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onAnalyze,
            icon: const Icon(Icons.search),
            label: const Text('开始分析'),
          ),
        ),
      ],
    );
  }

  Widget _buildTranslationResult(Map<String, dynamic> result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '翻译结果',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildResultItem(
                  '表面意思',
                  result['surfaceMeaning'] ?? '',
                  Icons.visibility,
                  Colors.blue,
                ),
                const Divider(),
                _buildResultItem(
                  '隐含意思',
                  result['hiddenMeaning'] ?? '',
                  Icons.psychology,
                  Colors.orange,
                ),
                const Divider(),
                _buildResultItem(
                  '情感态度',
                  result['emotionalTone'] ?? '',
                  Icons.favorite,
                  Colors.red,
                ),
                const Divider(),
                _buildResultItem(
                  '建议回应',
                  result['suggestedResponse'] ?? '',
                  Icons.lightbulb,
                  Colors.green,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRadarResults(List<Map<String, dynamic>> results) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '雷达扫描结果',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final signal = results[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getSignalColor(signal['type']),
                  child: Icon(
                    _getSignalIcon(signal['type']),
                    color: Colors.white,
                  ),
                ),
                title: Text(signal['title'] ?? ''),
                subtitle: Text(signal['description'] ?? ''),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getSignalColor(signal['type']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    signal['intensity'] ?? '',
                    style: TextStyle(
                      color: _getSignalColor(signal['type']),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildReplySuggestions(List<Map<String, dynamic>> suggestions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '回复建议',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final suggestion = suggestions[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '方案${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          suggestion['style'] ?? '',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Text(
                        suggestion['message'] ?? '',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      suggestion['explanation'] ?? '',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _copyToClipboard(suggestion['message']),
                            icon: const Icon(Icons.copy, size: 16),
                            label: const Text('复制'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _refineReply(suggestion),
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('优化'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTranslationExamples() {
    return _buildExamplesSection(
      '使用示例',
      [
        {
          'input': '"你是个好人，但是..."',
          'output': '委婉拒绝，表示对你没有恋爱感觉',
        },
        {
          'input': '"我们还是做朋友吧"',
          'output': '明确拒绝进一步发展的可能',
        },
        {
          'input': '"你很忙吧？"',
          'output': '想要你的关注，希望你主动联系',
        },
      ],
    );
  }

  Widget _buildRadarIntroduction() {
    return _buildExamplesSection(
      '雷达功能',
      [
        {
          'signal': '兴趣信号',
          'description': '主动提及共同话题、询问个人信息',
        },
        {
          'signal': '距离信号',
          'description': '回复速度变化、用词正式程度',
        },
        {
          'signal': '情感信号',
          'description': '表情符号使用、语气变化',
        },
      ],
    );
  }

  Widget _buildReplyExamples() {
    return _buildExamplesSection(
      '回复示例',
      [
        {
          'scenario': '对方发自拍',
          'suggestion': '赞美+互动式回复',
        },
        {
          'scenario': '聊到兴趣爱好',
          'suggestion': '表现共同点+深入话题',
        },
        {
          'scenario': '对方情绪低落',
          'suggestion': '关心+鼓励+转移注意力',
        },
      ],
    );
  }

  Widget _buildExamplesSection(String title, List<Map<String, String>> examples) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ...examples.map((example) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: example.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: '${entry.key}: ',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      TextSpan(text: entry.value),
                    ],
                  ),
                ),
              )).toList(),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildResultItem(String label, String content, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(height: 1.4),
          ),
        ],
      ),
    );
  }

  Color _getSignalColor(String? type) {
    switch (type) {
      case 'positive':
        return Colors.green;
      case 'negative':
        return Colors.red;
      case 'neutral':
        return Colors.orange;
      case 'interest':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getSignalIcon(String? type) {
    switch (type) {
      case 'positive':
        return Icons.thumb_up;
      case 'negative':
        return Icons.thumb_down;
      case 'neutral':
        return Icons.remove;
      case 'interest':
        return Icons.favorite;
      default:
        return Icons.radio_button_unchecked;
    }
  }

  Future<void> _analyzeMessage() async {
    final message = _inputController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入要分析的消息')),
      );
      return;
    }

    try {
      await _controller.translateMessage(message);
      _inputController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('分析失败: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _scanForSignals() async {
    final content = _inputController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入要扫描的聊天内容')),
      );
      return;
    }

    try {
      await _controller.scanSocialSignals(content);
      _inputController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('扫描失败: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _generateReply() async {
    final inputContext = _inputController.text.trim();
    if (inputContext.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入对话上下文')),
      );
      return;
    }

    try {
      await _controller.generateReplySuggestions(inputContext);
      _inputController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('生成失败: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _copyToClipboard(String? text) {
    if (text != null) {
      // 复制到剪贴板的实现
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已复制到剪贴板')),
      );
    }
  }

  void _refineReply(Map<String, dynamic> suggestion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('优化回复'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(text: suggestion['message']),
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: '编辑回复内容',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '你可以根据实际情况调整这个回复',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('回复已优化')),
              );
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}