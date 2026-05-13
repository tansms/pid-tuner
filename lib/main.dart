import 'package:flutter/material.dart';

void main() {
  runApp(const PIDTunerApp());
}

class PIDTunerApp extends StatelessWidget {
  const PIDTunerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PID调参助手',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _analyzed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PID调参助手'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PID调参助手',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '用于分析FPV穿越机黑盒日志',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _analyzed = true;
                        });
                      },
                      icon: const Icon(Icons.analytics),
                      label: const Text('模拟分析'),
                    ),
                  ],
                ),
              ),
            ),
            if (_analyzed) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '分析结果',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      const Text('超调分析：'),
                      const SizedBox(height: 8),
                      _buildResultRow('Roll', '12.5%', Colors.green),
                      _buildResultRow('Pitch', '8.3%', Colors.green),
                      _buildResultRow('Yaw', '5.2%', Colors.green),
                      const Divider(height: 24),
                      const Text('建议 PID 参数：'),
                      const SizedBox(height: 8),
                      _buildPIDRow('Roll', 37, 30, 40, 50),
                      _buildPIDRow('Pitch', 42, 32, 37, 52),
                      _buildPIDRow('Yaw', 45, 30, 33, 60),
                      const Divider(height: 24),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '调参口诀：\n机械先行，P 打基础，D 控过冲，\nFF 追跟随，I 保稳定，滤波最后动。',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String axis, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(axis),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPIDRow(String axis, int p, int i, int d, int ff) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              axis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text('P:$p  I:$i  D:$d  FF:$ff'),
          ),
        ],
      ),
    );
  }
}