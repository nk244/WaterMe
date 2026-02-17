import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../models/plant.dart';
import '../models/log_entry.dart';
import '../providers/plant_provider.dart';
import '../services/database_service.dart';
import '../services/memory_storage_service.dart';
import 'add_plant_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class PlantDetailScreen extends StatefulWidget {
  final Plant plant;

  const PlantDetailScreen({super.key, required this.plant});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _db = kIsWeb ? null : DatabaseService();
  final _memory = kIsWeb ? MemoryStorageService() : null;
  
  List<LogEntry> _wateringLogs = [];
  List<LogEntry> _fertilizerLogs = [];
  List<LogEntry> _vitalizerLogs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadLogs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLogs() async {
    List<LogEntry> wateringLogs;
    List<LogEntry> fertilizerLogs;
    List<LogEntry> vitalizerLogs;
    
    if (kIsWeb) {
      wateringLogs = await _memory!.getLogsByPlantAndType(widget.plant.id, LogType.watering);
      fertilizerLogs = await _memory.getLogsByPlantAndType(widget.plant.id, LogType.fertilizer);
      vitalizerLogs = await _memory.getLogsByPlantAndType(widget.plant.id, LogType.vitalizer);
    } else {
      wateringLogs = await _db!.getLogsByPlantAndType(widget.plant.id, LogType.watering);
      fertilizerLogs = await _db.getLogsByPlantAndType(widget.plant.id, LogType.fertilizer);
      vitalizerLogs = await _db.getLogsByPlantAndType(widget.plant.id, LogType.vitalizer);
    }
    
    setState(() {
      _wateringLogs = wateringLogs;
      _fertilizerLogs = fertilizerLogs;
      _vitalizerLogs = vitalizerLogs;
    });
  }

  Future<void> _recordWatering() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _LogDialog(
        title: '水やりを記録',
        icon: Icons.water_drop,
      ),
    );

    if (result != null) {
      await context.read<PlantProvider>().recordWatering(
        widget.plant.id,
        result['date'] as DateTime,
        result['note'] as String?,
      );
      await _loadLogs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('水やりを記録しました')),
        );
      }
    }
  }

  Future<void> _deletePlant() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除の確認'),
        content: Text('「${widget.plant.name}」を削除してもよろしいですか？\nすべてのログとノートも削除されます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await context.read<PlantProvider>().deletePlant(widget.plant.id);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool needsWatering = widget.plant.nextWateringDate != null &&
        widget.plant.nextWateringDate!.isBefore(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plant.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddPlantScreen(plant: widget.plant),
                ),
              );
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deletePlant,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '情報'),
            Tab(text: '水やり'),
            Tab(text: '液肥'),
            Tab(text: '活力剤'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInfoTab(),
          _buildLogTab(_wateringLogs, LogType.watering),
          _buildLogTab(_fertilizerLogs, LogType.fertilizer),
          _buildLogTab(_vitalizerLogs, LogType.vitalizer),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _recordWatering,
        icon: const Icon(Icons.water_drop),
        label: const Text('水やり'),
        backgroundColor: needsWatering
            ? Theme.of(context).colorScheme.error
            : null,
      ),
    );
  }

  Widget _buildInfoTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (widget.plant.imagePath != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: kIsWeb
                ? Image.network(
                    widget.plant.imagePath!,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.broken_image,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      );
                    },
                  )
                : File(widget.plant.imagePath!).existsSync()
                    ? Image.file(
                        File(widget.plant.imagePath!),
                        height: 200,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 200,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.broken_image,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
          ),
        const SizedBox(height: 16),
        
        _InfoCard(
          title: '基本情報',
          children: [
            _InfoRow(label: '植物名', value: widget.plant.name),
            if (widget.plant.variety != null)
              _InfoRow(label: '品種名', value: widget.plant.variety!),
            if (widget.plant.purchaseDate != null)
              _InfoRow(
                label: '購入日',
                value: DateFormat('yyyy年MM月dd日').format(widget.plant.purchaseDate!),
              ),
            if (widget.plant.purchaseLocation != null)
              _InfoRow(label: '購入先', value: widget.plant.purchaseLocation!),
          ],
        ),
        const SizedBox(height: 16),
        
        _InfoCard(
          title: '水やり情報',
          children: [
            if (widget.plant.wateringIntervalDays != null)
              _InfoRow(
                label: '間隔',
                value: '${widget.plant.wateringIntervalDays}日ごと',
              ),
            if (widget.plant.nextWateringDate != null)
              _InfoRow(
                label: '次回予定',
                value: _formatDate(widget.plant.nextWateringDate!),
                valueColor: widget.plant.nextWateringDate!.isBefore(DateTime.now())
                    ? Theme.of(context).colorScheme.error
                    : null,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildLogTab(List<LogEntry> logs, LogType type) {
    if (logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconForLogType(type),
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'ログがありません',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: Icon(_getIconForLogType(type)),
            title: Text(DateFormat('yyyy年MM月dd日').format(log.date)),
            subtitle: log.note != null ? Text(log.note!) : null,
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                if (kIsWeb) {
                  await _memory!.deleteLog(log.id);
                } else {
                  await _db!.deleteLog(log.id);
                }
                await _loadLogs();
              },
            ),
          ),
        );
      },
    );
  }

  IconData _getIconForLogType(LogType type) {
    switch (type) {
      case LogType.watering:
        return Icons.water_drop;
      case LogType.fertilizer:
        return Icons.science;
      case LogType.vitalizer:
        return Icons.local_florist;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(date.year, date.month, date.day);
    final difference = targetDay.difference(today).inDays;

    if (difference == 0) return '今日';
    if (difference == -1) return '昨日';
    if (difference == 1) return '明日';
    if (difference < 0) return '${-difference}日前';
    return '$difference日後';
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogDialog extends StatefulWidget {
  final String title;
  final IconData icon;

  const _LogDialog({required this.title, required this.icon});

  @override
  State<_LogDialog> createState() => _LogDialogState();
}

class _LogDialogState extends State<_LogDialog> {
  DateTime _date = DateTime.now();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(widget.icon),
          const SizedBox(width: 8),
          Text(widget.title),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today),
            title: const Text('日付'),
            subtitle: Text(DateFormat('yyyy年MM月dd日').format(_date)),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() {
                  _date = date;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: '備考（任意）',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop({
              'date': _date,
              'note': _noteController.text.trim().isEmpty
                  ? null
                  : _noteController.text.trim(),
            });
          },
          child: const Text('記録'),
        ),
      ],
    );
  }
}
