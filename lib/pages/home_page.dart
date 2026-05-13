import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/log_analyzer.dart';
import '../services/storage_service.dart';
import '../models/aircraft.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _filePath;
  AnalysisResult? _result;
  bool _isLoading = false;
  String? _error;
  List<Aircraft> _aircrafts = [];

  @override
  void initState() {
    super.initState();
    _loadAircrafts();
  }

  Future<void> _loadAircrafts() async {
    final aircrafts = await StorageService.getAircrafts();
    if (mounted) {
      setState(() {
        _aircrafts = aircrafts;
      });
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['bbl', 'txt', 'log'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _filePath = result.files.single.path;
          _result = null;
          _error = null;
        });
      }
    } catch (e) {
      setState(() {
        _error = '选择文件失败: $e';
      });
    }
  }

  Future<void> _analyze() async {
    if (_filePath == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final file = File(_filePath!);
      final bytes = await file.readAsBytes();
      final result = await LogAnalyzer.analyze(bytes);
      
      if (mounted) {
        setState(() {
          _result = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '分析失败: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _saveToAircraft() {
    if (_result == null) return;

    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('保存到档案'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '飞机名称',
            hintText: '例如: 穿越机 #1',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;

              final aircraft = Aircraft(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: name,
                pidSettings: _result!.recommendedPID,
                createdAt: DateTime.now(),
                lastAnalyzed: DateTime.now(),
              );

              await StorageService.saveAircraft(aircraft);
              if (mounted) {
                Navigator.pop(context);
                _loadAircrafts();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已保存到档案')),
                );
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PID调参助手'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 文件选择
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '选择日志文件',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _filePath ?? '未选择文件',
                            style: TextStyle(
                              color: _filePath != null 
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context).disabledColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _pickFile,
                          icon: const Icon(Icons.folder_open),
                          label: const Text('浏览'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _filePath != null && !_isLoading
                          ? _analyze
                          : null,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.analytics),
                      label: Text(_isLoading ? '分析中...' : '开始分析'),
                    ),
                  ],
                ),
              ),
            ),

            // 错误提示
            if (_error != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // 分析结果
            if (_result != null) ...[
              const SizedBox(height: 24),
              _buildResultCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '分析结果',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton.icon(
                  onPressed: _saveToAircraft,
                  icon: const Icon(Icons.save),
                  label: const Text('保存到档案'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 阶跃响应图表
            Text(
              '阶跃响应分析',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                      ),
                    ),
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      color: Colors.blue,
                      spots: _result!.stepResponsePoints,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Overshoot 数据
            _buildDataRow('Roll 超调', '${_result!.rollOvershoot.toStringAsFixed(1)}%'),
            _buildDataRow('Pitch 超调', '${_result!.pitchOvershoot.toStringAsFixed(1)}%'),
            _buildDataRow('Yaw 超调', '${_result!.yawOvershoot.toStringAsFixed(1)}%'),

            const Divider(height: 32),

            // 建议 PID
            Text(
              '建议 PID 参数',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            
            _buildPIDTable('Roll', _result!.recommendedPID['roll']!),
            const SizedBox(height: 12),
            _buildPIDTable('Pitch', _result!.recommendedPID['pitch']!),
            const SizedBox(height: 12),
            _buildPIDTable('Yaw', _result!.recommendedPID['yaw']!),

            const Divider(height: 32),

            // 调参建议
            Text(
              '调参建议',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_result!.recommendation),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPIDTable(String axis, Map<String, int> pid) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              axis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPIDValue('P', pid['P']!),
                _buildPIDValue('I', pid['I']!),
                _buildPIDValue('D', pid['D']!),
                _buildPIDValue('FF', pid['FF']!),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPIDValue(String label, int value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
