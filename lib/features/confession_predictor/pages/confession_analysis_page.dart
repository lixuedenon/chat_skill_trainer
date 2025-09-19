// lib/features/confession_predictor/pages/confession_analysis_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../confession_service.dart';

class ConfessionAnalysisPage extends StatefulWidget {
  final String? analysisResult;
  final List<String>? chatData;

  const ConfessionAnalysisPage({
    Key? key,
    this.analysisResult,
    this.chatData,
  }) : super(key: key);

  @override
  State<ConfessionAnalysisPage> createState() => _ConfessionAnalysisPageState();
}

class _ConfessionAnalysisPageState extends State<ConfessionAnalysisPage> {
  late ConfessionService _confessionService;
  bool _isLoading = false;
  Map<String, dynamic> _detailedAnalysis = {};

  @override
  void initState() {
    super.initState();
    _confessionService = ConfessionService();
    if (widget.analysisResult != null) {
      _loadDetailedAnalysis();
    }
  }

  Future<void> _loadDetailedAnalysis() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final analysis = await _confessionService.generateDetailedAnalysis(
        widget.chatData ?? [],
      );
      setState(() {
        _detailedAnalysis = analysis;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('加载详细分析失败: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('告白成功率分析'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareAnalysis,
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        loadingMessage: '生成详细分析中...',
        child: _detailedAnalysis.isEmpty
            ? _buildEmptyState()
            : _buildAnalysisContent(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '暂无分析数据',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            '请先上传聊天记录进行分析',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSuccessRateCard(),
          const SizedBox(height: 16),
          _buildTimelineAnalysis(),
          const SizedBox(height: 16),
          _buildEmotionalTrends(),
          const SizedBox(height: 16),
          _buildKeyInsights(),
          const SizedBox(height: 16),
          _buildRecommendations(),
          const SizedBox(height: 16),
          _buildOptimalTiming(),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildSuccessRateCard() {
    final successRate = _detailedAnalysis['successRate'] ?? 0;
    final confidence = _detailedAnalysis['confidence'] ?? 'medium';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              '告白成功率预测',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: successRate / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getSuccessRateColor(successRate),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${successRate.toInt()}%',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getSuccessRateLabel(successRate),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getConfidenceColor(confidence).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getConfidenceColor(confidence).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.precision_manufacturing,
                    color: _getConfidenceColor(confidence),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '置信度: ${_getConfidenceLabel(confidence)}',
                    style: TextStyle(
                      color: _getConfidenceColor(confidence),
                      fontWeight: FontWeight.w500,
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

  Widget _buildTimelineAnalysis() {
    final timeline = _detailedAnalysis['timeline'] ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '关系发展时间线',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (timeline.isEmpty)
              const Center(
                child: Text('暂无时间线数据'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: timeline.length,
                itemBuilder: (context, index) {
                  final event = timeline[index];
                  return _buildTimelineItem(event, index == timeline.length - 1);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> event, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event['title'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                event['description'] ?? '',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionalTrends() {
    final emotions = _detailedAnalysis['emotionalTrends'] ?? {};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '情感趋势分析',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...emotions.entries.map((entry) => _buildEmotionItem(
              entry.key,
              entry.value.toDouble(),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionItem(String emotion, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(emotion),
              Text('${(value * 100).toInt()}%'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getEmotionColor(emotion),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyInsights() {
    final insights = _detailedAnalysis['keyInsights'] ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '关键洞察',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...insights.map<Widget>((insight) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.orange[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      insight.toString(),
                      style: const TextStyle(height: 1.4),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations() {
    final recommendations = _detailedAnalysis['recommendations'] ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '告白建议',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...recommendations.map<Widget>((rec) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.recommend,
                      color: Colors.blue[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rec.toString(),
                        style: TextStyle(
                          color: Colors.blue[700],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimalTiming() {
    final timing = _detailedAnalysis['optimalTiming'] ?? {};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '最佳告白时机',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTimingItem(
                    '建议时间',
                    timing['suggestedTime'] ?? '近期',
                    Icons.schedule,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimingItem(
                    '最佳场景',
                    timing['bestScenario'] ?? '私下聊天',
                    Icons.place,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Text(
                timing['reasoning'] ?? '基于当前分析，建议选择合适的时机表达心意',
                style: TextStyle(
                  color: Colors.green[700],
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimingItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _exportReport,
            icon: const Icon(Icons.download),
            label: const Text('导出分析报告'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _newAnalysis,
                child: const Text('重新分析'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: _getAdvice,
                child: const Text('获取建议'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getSuccessRateColor(double rate) {
    if (rate >= 70) return Colors.green;
    if (rate >= 50) return Colors.orange;
    return Colors.red;
  }

  String _getSuccessRateLabel(double rate) {
    if (rate >= 80) return '很有希望';
    if (rate >= 60) return '较有希望';
    if (rate >= 40) return '需要努力';
    return '建议等待';
  }

  Color _getConfidenceColor(String confidence) {
    switch (confidence) {
      case 'high': return Colors.green;
      case 'medium': return Colors.orange;
      case 'low': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getConfidenceLabel(String confidence) {
    switch (confidence) {
      case 'high': return '高';
      case 'medium': return '中';
      case 'low': return '低';
      default: return '未知';
    }
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case '喜欢': return Colors.pink;
      case '关心': return Colors.blue;
      case '信任': return Colors.green;
      case '兴趣': return Colors.purple;
      default: return Colors.grey;
    }
  }

  void _shareAnalysis() {
    // 分享分析结果
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('分享功能开发中')),
    );
  }

  void _exportReport() {
    // 导出报告
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('报告已保存到本地')),
    );
  }

  void _newAnalysis() {
    Navigator.of(context).pushReplacementNamed('/batch_upload');
  }

  void _getAdvice() {
    Navigator.of(context).pushNamed('/real_chat_assistant');
  }