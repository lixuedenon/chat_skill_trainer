// lib/features/confession_predictor/pages/batch_upload_page.dart

import 'package:flutter/material.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../batch_chat_analyzer.dart';
import '../confession_service.dart';

class BatchUploadPage extends StatefulWidget {
  const BatchUploadPage({Key? key}) : super(key: key);

  @override
  State<BatchUploadPage> createState() => _BatchUploadPageState();
}

class _BatchUploadPageState extends State<BatchUploadPage> {
  final TextEditingController _chatController = TextEditingController();
  final List<String> _uploadedChats = [];
  bool _isAnalyzing = false;
  String _analysisResult = '';

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('批量聊天记录上传'),
        centerTitle: true,
      ),
      body: LoadingOverlay(
        isLoading: _isAnalyzing,
        loadingMessage: '正在分析聊天记录...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildUploadSection(),
              const SizedBox(height: 24),
              if (_uploadedChats.isNotEmpty) ...[
                _buildUploadedChats(),
                const SizedBox(height: 24),
              ],
              _buildAnalyzeButton(),
              const SizedBox(height: 24),
              if (_analysisResult.isNotEmpty) _buildAnalysisResult(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '批量聊天记录分析',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          '上传你们的聊天记录，AI将分析对话模式、情感变化和关系发展趋势，为你的告白提供数据支持。',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.privacy_tip, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '隐私保护：所有聊天记录仅用于分析，不会被保存或泄露',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '上传聊天记录',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          '请复制粘贴聊天记录，每次可上传一段对话',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _chatController,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: '粘贴聊天记录...\n\n例如：\n你：今天天气不错\nTA：是啊，很适合出去走走\n你：要不我们一起去公园？',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _uploadedChats.length < 10 ? _addChat : null,
                icon: const Icon(Icons.add),
                label: Text('添加对话 (${_uploadedChats.length}/10)'),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: _chatController.text.isNotEmpty ? _clearInput : null,
              child: const Text('清空'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUploadedChats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '已上传对话 (${_uploadedChats.length}段)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _uploadedChats.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text('${index + 1}'),
                ),
                title: Text(
                  '对话片段 ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  _uploadedChats[index].length > 50
                      ? '${_uploadedChats[index].substring(0, 50)}...'
                      : _uploadedChats[index],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeChat(index),
                ),
                onTap: () => _showChatDetail(index),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnalyzeButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _uploadedChats.isNotEmpty && !_isAnalyzing
            ? _startAnalysis
            : null,
        icon: const Icon(Icons.analytics),
        label: const Text('开始分析'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildAnalysisResult() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '分析结果',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '综合分析报告',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _analysisResult,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _viewDetailedAnalysis,
                child: const Text('查看详细分析'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _addChat() {
    final chatText = _chatController.text.trim();
    if (chatText.isNotEmpty && _uploadedChats.length < 10) {
      setState(() {
        _uploadedChats.add(chatText);
        _chatController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('对话已添加'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _clearInput() {
    _chatController.clear();
  }

  void _removeChat(int index) {
    setState(() {
      _uploadedChats.removeAt(index);
    });
  }

  void _showChatDetail(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('对话片段 ${index + 1}'),
        content: SingleChildScrollView(
          child: Text(_uploadedChats[index]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _removeChat(index);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Future<void> _startAnalysis() async {
    setState(() {
      _isAnalyzing = true;
      _analysisResult = '';
    });

    try {
      // 模拟分析过程
      await Future.delayed(const Duration(seconds: 3));

      // 生成模拟分析结果
      final result = '''
基于${_uploadedChats.length}段聊天记录的分析：

📊 对话质量评分：76/100
💬 互动频率：中等偏上
😊 情感倾向：积极友好
🎯 话题匹配度：72%

关键发现：
• 对方回复速度较快，显示出兴趣
• 话题延续性良好，愿意深入交流
• 偶尔主动分享，表现出信任感
• 语气较为轻松，关系发展健康

建议：
• 可以尝试更深入的话题交流
• 适当增加一些个人感受的分享
• 选择合适时机表达更多关心

告白成功率预测：68%
最佳时机：继续培养感情2-3周后
      ''';

      setState(() {
        _analysisResult = result;
      });
    } catch (e) {
      setState(() {
        _analysisResult = '分析失败：${e.toString()}';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('分析失败: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  void _viewDetailedAnalysis() {
    Navigator.of(context).pushNamed(
      '/confession_analysis',
      arguments: {
        'analysisResult': _analysisResult,
        'chatData': _uploadedChats,
      },
    );
  }
}