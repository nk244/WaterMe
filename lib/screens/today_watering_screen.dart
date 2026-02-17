import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import '../providers/plant_provider.dart';
import '../providers/settings_provider.dart';
import '../models/plant.dart';
import '../services/database_service.dart';
import '../services/memory_storage_service.dart';
import '../models/log_entry.dart';
import 'plant_detail_screen.dart';
import 'settings_screen.dart';

class TodayWateringScreen extends StatefulWidget {
  const TodayWateringScreen({super.key});

  @override
  State<TodayWateringScreen> createState() => _TodayWateringScreenState();
}

class _TodayWateringScreenState extends State<TodayWateringScreen> {
  DateTime _selectedDate = DateTime.now();
  Map<String, bool> _wateredToday = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  @override
  void didUpdateWidget(TodayWateringScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _refreshData();
  }

  Future<void> _refreshData() async {
    await context.read<PlantProvider>().loadPlants();
    await _loadTodayWaterings();
  }

  Future<void> _loadTodayWaterings() async {
    final selectedDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final startOfDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    final endOfDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day, 23, 59, 59);

    final plants = context.read<PlantProvider>().plants;
    final wateredToday = <String, bool>{};

    for (var plant in plants) {
      List<LogEntry> logs;
      if (kIsWeb) {
        logs = await MemoryStorageService().getLogsByPlantAndType(
          plant.id,
          LogType.watering,
        );
      } else {
        logs = await DatabaseService().getLogsByPlantAndType(
          plant.id,
          LogType.watering,
        );
      }

      // Check if watered on selected date
      final selectedDateLogs = logs.where((log) =>
          log.date.isAfter(startOfDay.subtract(const Duration(seconds: 1))) && 
          log.date.isBefore(endOfDay.add(const Duration(seconds: 1))));
      wateredToday[plant.id] = selectedDateLogs.isNotEmpty;
    }

    if (mounted) {
      setState(() {
        _wateredToday = wateredToday;
      });
    }
  }

  List<Plant> _getPlantsForDate(List<Plant> plants) {
    final selectedDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final today = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);
    
    // Show plants that need watering on or before the selected date
    return plants.where((plant) {
      if (plant.nextWateringDate == null) return false;
      final nextDay = DateTime(
        plant.nextWateringDate!.year,
        plant.nextWateringDate!.month,
        plant.nextWateringDate!.day,
      );
      
      // For today, show all plants that need watering today or are overdue
      if (selectedDay.isAtSameMomentAs(todayDay)) {
        return !nextDay.isAfter(selectedDay);
      }
      
      // For other dates, show plants scheduled for that specific date
      return nextDay.isAtSameMomentAs(selectedDay) || nextDay.isBefore(selectedDay);
    }).toList()
      ..sort((a, b) => a.nextWateringDate!.compareTo(b.nextWateringDate!));
  }

  Future<void> _quickWater(Plant plant) async {
    await context.read<PlantProvider>().recordWatering(
      plant.id,
      _selectedDate,
      null,
    );
    
    // Reload both plants and watering status
    await context.read<PlantProvider>().loadPlants();
    await _loadTodayWaterings();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${plant.name}に水やりしました'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final isToday = _selectedDate.year == today.year &&
        _selectedDate.month == today.month &&
        _selectedDate.day == today.day;

    return Scaffold(
      appBar: AppBar(
        title: const Text('水やり管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<PlantProvider>(
        builder: (context, plantProvider, _) {
          if (plantProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final plantsForDate = _getPlantsForDate(plantProvider.plants);
          
          // Calculate plants that need watering today (not overdue from past)
          final selectedDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
          final needsWatering = plantsForDate.where((p) {
            final nextDay = DateTime(
              p.nextWateringDate!.year,
              p.nextWateringDate!.month,
              p.nextWateringDate!.day,
            );
            return nextDay.isAtSameMomentAs(selectedDay);
          }).length;

          final wateredCount = isToday
              ? plantsForDate.where((p) => _wateredToday[p.id] ?? false).length
              : 0;

          return Column(
            children: [
              // Date selector
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        setState(() {
                          _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                        });
                        _loadTodayWaterings();
                      },
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() {
                              _selectedDate = date;
                            });
                            _loadTodayWaterings();
                          }
                        },
                        child: Column(
                          children: [
                            Text(
                              isToday ? '今日' : _formatDate(_selectedDate),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              DateFormat('yyyy年M月d日').format(_selectedDate),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        setState(() {
                          _selectedDate = _selectedDate.add(const Duration(days: 1));
                        });
                        _loadTodayWaterings();
                      },
                    ),
                  ],
                ),
              ),

              // Summary
              if (isToday && needsWatering > 0)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.water_drop,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '今日は$needsWatering件の水やりが必要です（$wateredCount件完了）',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),

              // Plant list
              Expanded(
                child: plantsForDate.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.eco_outlined,
                              size: 64,
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isToday ? '今日は水やりの予定がありません' : 'この日は水やりの予定がありません',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: plantsForDate.length,
                        itemBuilder: (context, index) {
                          final plant = plantsForDate[index];
                          final isWatered = _wateredToday[plant.id] ?? false;
                          final selectedDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
                          final nextDay = DateTime(
                            plant.nextWateringDate!.year,
                            plant.nextWateringDate!.month,
                            plant.nextWateringDate!.day,
                          );
                          final isOverdue = nextDay.isBefore(selectedDay);

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            child: ListTile(
                              leading: Stack(
                                children: [
                                  _buildPlantImage(plant),
                                  if (isWatered)
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.check,
                                          size: 16,
                                          color: Theme.of(context).colorScheme.onPrimary,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              title: Text(
                                plant.name,
                                style: TextStyle(
                                  decoration: isWatered ? TextDecoration.lineThrough : null,
                                  color: isWatered
                                      ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                                      : null,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (plant.variety != null) Text(plant.variety!),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.water_drop,
                                        size: 14,
                                        color: isOverdue
                                            ? Theme.of(context).colorScheme.error
                                            : Theme.of(context).colorScheme.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatDateDifference(plant.nextWateringDate!),
                                        style: TextStyle(
                                          color: isOverdue
                                              ? Theme.of(context).colorScheme.error
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: isToday && !isWatered
                                  ? IconButton(
                                      icon: const Icon(Icons.water_drop),
                                      color: Theme.of(context).colorScheme.primary,
                                      onPressed: () => _quickWater(plant),
                                    )
                                  : null,
                              onTap: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => PlantDetailScreen(plant: plant),
                                  ),
                                );
                                if (mounted) {
                                  await context.read<PlantProvider>().loadPlants();
                                  await _loadTodayWaterings();
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlantImage(Plant plant) {
    if (plant.imagePath == null) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.eco,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: kIsWeb
          ? Image.network(
              plant.imagePath!,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.eco,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            )
          : File(plant.imagePath!).existsSync()
              ? Image.file(
                  File(plant.imagePath!),
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.eco,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(date.year, date.month, date.day);
    final difference = targetDay.difference(today).inDays;

    if (difference == 0) return '今日';
    if (difference == -1) return '昨日';
    if (difference == 1) return '明日';
    return DateFormat('M月d日').format(date);
  }

  String _formatDateDifference(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(date.year, date.month, date.day);
    final difference = targetDay.difference(today).inDays;

    if (difference == 0) return '今日';
    if (difference == -1) return '昨日（期限切れ）';
    if (difference == 1) return '明日';
    if (difference < 0) return '${-difference}日前（期限切れ）';
    return '$difference日後';
  }
}
