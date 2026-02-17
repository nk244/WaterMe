import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/plant_provider.dart';
import '../providers/settings_provider.dart';
import '../models/app_settings.dart';
import '../models/plant.dart';
import '../widgets/plant_image_widget.dart';
import 'add_plant_screen.dart';
import 'plant_detail_screen.dart';
import 'settings_screen.dart';

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
          // Sort order menu
          Consumer<SettingsProvider>(
            builder: (context, settingsForMenu, _) {
              return PopupMenuButton<PlantSortOrder>(
                icon: const Icon(Icons.sort),
                tooltip: '並び順',
                onSelected: (order) {
                  context.read<SettingsProvider>().setPlantSortOrder(order);
                },
                itemBuilder: (context) {
                  final currentOrder = settingsForMenu.plantSortOrder;
                  
                  return PlantSortOrder.values.map((order) {
                    return PopupMenuItem<PlantSortOrder>(
                      value: order,
                      child: Row(
                        children: [
                          Icon(
                            _getSortOrderIcon(order),
                            size: 20,
                            color: currentOrder == order 
                              ? Theme.of(context).colorScheme.primary
                              : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _getSortOrderName(order),
                              style: currentOrder == order
                                ? TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  )
                                : null,
                            ),
                          ),
                          if (currentOrder == order)
                            Icon(
                              Icons.check,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                        ],
                      ),
                    );
                  }).toList();
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
              final sortedPlants = plantProvider.getSortedPlants(
                settings.plantSortOrder,
                settings.customSortOrder,
              );
              
              // カード表示機能を無効化、リスト表示のみ
              final isCustomSort = settings.plantSortOrder == PlantSortOrder.custom;
              
              return isCustomSort 
                  ? _buildReorderableListView(context, sortedPlants, settings)
                  : _buildListView(sortedPlants);
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

  Widget _buildListView(List<Plant> plants) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: plants.length,
      itemBuilder: (context, index) {
        return _PlantListTile(plant: plants[index]);
      },
    );
  }

  Widget _buildReorderableListView(
    BuildContext context,
    List<Plant> plants,
    SettingsProvider settings,
  ) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: plants.length,
      onReorder: (oldIndex, newIndex) {
        _onReorder(context, plants, oldIndex, newIndex, settings);
      },
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(8),
              child: child,
            );
          },
          child: child,
        );
      },
      itemBuilder: (context, index) {
        final plant = plants[index];
        return Container(
          key: ValueKey(plant.id),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: _buildReorderableListTile(plant),
        );
      },
    );
  }

  Widget _buildReorderableListTile(Plant plant) {
    return Card(
      child: ListTile(
        leading: PlantImageWidget(plant: plant),
        title: Text(plant.name),
        subtitle: plant.variety != null ? Text(plant.variety!) : null,
        trailing: const Icon(Icons.drag_handle),
        onTap: () => _navigateToDetail(plant),
      ),
    );
  }

  void _onReorder(
    BuildContext context,
    List<Plant> plants,
    int oldIndex,
    int newIndex,
  SettingsProvider settings,
  ) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    final List<String> newOrder = plants.map((p) => p.id).toList();
    final plantId = newOrder.removeAt(oldIndex);
    newOrder.insert(newIndex, plantId);
    
    settings.setCustomSortOrder(newOrder);
  }

  void _navigateToDetail(Plant plant) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlantDetailScreen(plant: plant),
      ),
    );
  }

  String _getSortOrderName(PlantSortOrder order) {
    switch (order) {
      case PlantSortOrder.nameAsc:
        return '名前（あ→ん）';
      case PlantSortOrder.nameDesc:
        return '名前（ん→あ）';
      case PlantSortOrder.purchaseDateDesc:
        return '購入日が新しい順';
      case PlantSortOrder.purchaseDateAsc:
        return '購入日が古い順';
      case PlantSortOrder.custom:
        return 'カスタム（ドラッグで並び替え）';
    }
  }

  IconData _getSortOrderIcon(PlantSortOrder order) {
    switch (order) {
      case PlantSortOrder.nameAsc:
      case PlantSortOrder.nameDesc:
        return Icons.sort_by_alpha;
      case PlantSortOrder.purchaseDateDesc:
      case PlantSortOrder.purchaseDateAsc:
        return Icons.calendar_today;
      case PlantSortOrder.custom:
        return Icons.reorder;
    }
  }
}

class _PlantListTile extends StatelessWidget {
  final Plant plant;

  const _PlantListTile({required this.plant});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: PlantImageWidget(plant: plant),
        title: Text(plant.name),
        subtitle: plant.variety != null
            ? Text(plant.variety!)
            : null,
        onTap: () => _navigateToDetail(context, plant),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Plant plant) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlantDetailScreen(plant: plant),
      ),
    );
  }
}
