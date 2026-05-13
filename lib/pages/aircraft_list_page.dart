import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/aircraft.dart';

class AircraftListPage extends StatefulWidget {
  const AircraftListPage({super.key});

  @override
  State<AircraftListPage> createState() => _AircraftListPageState();
}

class _AircraftListPageState extends State<AircraftListPage> {
  List<Aircraft> _aircrafts = [];
  bool _isLoading = true;

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
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAircraft(Aircraft aircraft) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除 "${aircraft.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await StorageService.deleteAircraft(aircraft.id);
      _loadAircrafts();
    }
  }

  void _showAircraftDetail(Aircraft aircraft) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(aircraft.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '创建时间: ${_formatDate(aircraft.createdAt)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '最后分析: ${_formatDate(aircraft.lastAnalyzed)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              ...aircraft.pidSettings.entries.map((entry) => 
                _buildPIDCard(entry.key, entry.value),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Widget _buildPIDCard(String axis, Map<String, int> pid) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              axis.toUpperCase(),
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
            fontSize: 12,
          ),
        ),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('飞机档案'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _aircrafts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_open,
                        size: 64,
                        color: Theme.of(context).disabledColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '暂无飞机档案',
                        style: TextStyle(
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '分析日志后保存到档案',
                        style: TextStyle(
                          color: Theme.of(context).disabledColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _aircrafts.length,
                  itemBuilder: (context, index) {
                    final aircraft = _aircrafts[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.flight),
                        ),
                        title: Text(aircraft.name),
                        subtitle: Text(
                          '最后分析: ${_formatDate(aircraft.lastAnalyzed)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deleteAircraft(aircraft),
                        ),
                        onTap: () => _showAircraftDetail(aircraft),
                      ),
                    );
                  },
                ),
    );
  }
}