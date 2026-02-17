import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/plant_provider.dart';
import '../providers/settings_provider.dart';
import '../models/app_settings.dart';
import '../models/plant.dart';
import 'add_plant_screen.dart';
import 'plant_detail_screen.dart';
import 'settings_screen.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class PlantListScreen extends StatefulWidget {
  const PlantListScreen({super.key});

  @override
  State<PlantListScreen> createState() => _PlantListScreenState();
}

class _PlantListScreenState extends State<PlantListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PlantProvider>().loadPlants();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WaterMe'),
        actions: [
          Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              return IconButton(
                icon: Icon(
                  settings.viewMode == ViewMode.card
                      ? Icons.view_list
                      : Icons.grid_view,
                ),
                onPressed: () {
                  settings.setViewMode(
                    settings.viewMode == ViewMode.card
                        ? ViewMode.list
                        : ViewMode.card,
                  );
                },
              );
            },
          ),
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

          if (plantProvider.plants.isEmpty) {
            return Center(
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
                    '植物が登録されていません',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '右下のボタンから植物を追加しましょう',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            );
          }

          return Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              return settings.viewMode == ViewMode.card
                  ? _buildCardView(plantProvider.plants)
                  : _buildListView(plantProvider.plants);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddPlantScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCardView(List<Plant> plants) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: plants.length,
      itemBuilder: (context, index) {
        return _PlantCard(plant: plants[index]);
      },
    );
  }

  Widget _buildListView(List<Plant> plants) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: plants.length,
      itemBuilder: (context, index) {
        return _PlantListTile(plant: plants[index]);
      },
    );
  }
}

class _PlantCard extends StatelessWidget {
  final Plant plant;

  const _PlantCard({required this.plant});

  @override
  Widget build(BuildContext context) {
    final bool needsWatering = plant.nextWateringDate != null &&
        plant.nextWateringDate!.isBefore(DateTime.now());

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PlantDetailScreen(plant: plant),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: plant.imagePath != null
                  ? (kIsWeb
                      ? Image.network(
                          plant.imagePath!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.eco,
                                size: 48,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            );
                          },
                        )
                      : File(plant.imagePath!).existsSync()
                          ? Image.file(
                              File(plant.imagePath!),
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.eco,
                                size: 48,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ))
                  : Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.eco,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (plant.variety != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      plant.variety!,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (plant.nextWateringDate != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.water_drop,
                          size: 16,
                          color: needsWatering
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _formatDate(plant.nextWateringDate!),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: needsWatering
                                  ? Theme.of(context).colorScheme.error
                                  : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
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
    if (difference < 0) return '${-difference}日前';
    return '$difference日後';
  }
}

class _PlantListTile extends StatelessWidget {
  final Plant plant;

  const _PlantListTile({required this.plant});

  @override
  Widget build(BuildContext context) {
    final bool needsWatering = plant.nextWateringDate != null &&
        plant.nextWateringDate!.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: plant.imagePath != null
            ? ClipRRect(
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
        title: Text(plant.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (plant.variety != null) Text(plant.variety!),
            if (plant.nextWateringDate != null)
              Row(
                children: [
                  Icon(
                    Icons.water_drop,
                    size: 14,
                    color: needsWatering
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(plant.nextWateringDate!),
                    style: TextStyle(
                      color: needsWatering
                          ? Theme.of(context).colorScheme.error
                          : null,
                    ),
                  ),
                ],
              ),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PlantDetailScreen(plant: plant),
            ),
          );
        },
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
    if (difference < 0) return '${-difference}日前';
    return '$difference日後';
  }
}
