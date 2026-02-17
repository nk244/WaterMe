import '../models/plant.dart';
import '../models/log_entry.dart';

/// テストデータ生成用クラス
/// 実装コードから完全に分離されており、開発・テスト用途にのみ使用される
class TestDataGenerator {
  /// サンプル画像URLのリスト
  static List<String> getSampleImageUrls() {
    return [
      'https://images.unsplash.com/photo-1459156212016-c812468e2115?w=400',
      'https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?w=400',
      'https://images.unsplash.com/photo-1509587584298-0f3b3a3a1797?w=400',
      'https://images.unsplash.com/photo-1545241047-6083a3684587?w=400',
      'https://images.unsplash.com/photo-1512428813834-c702c7702b78?w=400',
      'https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=400',
      'https://images.unsplash.com/photo-1501004318641-b39e6451bec6?w=400',
      'https://images.unsplash.com/photo-1463936575829-25148e1db1b8?w=400',
      'https://images.unsplash.com/photo-1502472584811-0a2f2feb8968?w=400',
      'https://images.unsplash.com/photo-1520412099551-62b6bafeb5bb?w=400',
      'https://images.unsplash.com/photo-1509223197845-458d87c8f7f7?w=400',
      'https://images.unsplash.com/photo-1558603668-6570496b66f8?w=400',
      'https://images.unsplash.com/photo-1508919801845-fc2ae1bc2a28?w=400',
      'https://images.unsplash.com/photo-1470058869958-2a77ade41c02?w=400',
      'https://images.unsplash.com/photo-1525498128493-380d1990a112?w=400',
    ];
  }

  /// テスト用植物データの設定を取得
  static List<Map<String, dynamic>> getTestPlantConfigs(
    DateTime today,
    DateTime yesterday,
  ) {
    return [
      // 1. 今日が水やり予定日で、まだ水やりしていない植物（画像あり）
      {
        'name': 'モンステラ',
        'variety': 'デリシオーサ',
        'interval': 7,
        'location': 'ホームセンター',
        'nextWatering': today,
        'lastWatered': today.subtract(const Duration(days: 7)),
        'hasImage': true,
        'shouldWaterToday': false,
      },
      // 2. 今日が水やり予定日で、まだ水やりしていない植物
      {
        'name': 'ポトス',
        'variety': 'ゴールデン',
        'interval': 5,
        'location': '園芸店',
        'nextWatering': today,
        'lastWatered': today.subtract(const Duration(days: 5)),
        'hasImage': false,
        'shouldWaterToday': false,
      },
      // 3. 今日が水やり予定日で、すでに水やり済みの植物（画像あり）
      {
        'name': 'サンスベリア',
        'variety': 'ローレンティー',
        'interval': 14,
        'location': '雑貨店',
        'nextWatering': today.add(const Duration(days: 14)),
        'lastWatered': today,
        'hasImage': true,
        'shouldWaterToday': true,
      },
      // 4. 今日が水やり予定日で、すでに水やり済みの植物
      {
        'name': 'パキラ',
        'variety': 'スタンダード',
        'interval': 7,
        'location': 'ホームセンター',
        'nextWatering': today.add(const Duration(days: 7)),
        'lastWatered': today,
        'hasImage': false,
        'shouldWaterToday': true,
      },
      // 5. 前日が水やり予定日だったが、水やりしていない植物（期限切れ）
      {
        'name': 'ガジュマル',
        'variety': '多幸の木',
        'interval': 5,
        'location': '園芸店',
        'nextWatering': yesterday,
        'lastWatered': yesterday.subtract(const Duration(days: 5)),
        'hasImage': false,
        'shouldWaterToday': false,
      },
      // 6. 前日が水やり予定日だったが、水やりしていない植物（画像あり）
      {
        'name': 'アイビー',
        'variety': 'ヘデラ',
        'interval': 4,
        'location': '花屋',
        'nextWatering': yesterday,
        'lastWatered': yesterday.subtract(const Duration(days: 4)),
        'hasImage': true,
        'shouldWaterToday': false,
      },
      // 7. 明日が水やり予定日の植物
      {
        'name': 'シェフレラ',
        'variety': 'ホンコンカポック',
        'interval': 7,
        'location': 'ホームセンター',
        'nextWatering': today.add(const Duration(days: 1)),
        'lastWatered': today.subtract(const Duration(days: 6)),
        'hasImage': false,
        'shouldWaterToday': false,
      },
      // 8. 3日後が水やり予定日の植物
      {
        'name': 'ドラセナ',
        'variety': 'マッサンゲアナ',
        'interval': 7,
        'location': '園芸店',
        'nextWatering': today.add(const Duration(days: 3)),
        'lastWatered': today.subtract(const Duration(days: 4)),
        'hasImage': false,
        'shouldWaterToday': false,
      },
      // 9. 1週間後が水やり予定日の植物
      {
        'name': 'アロエベラ',
        'variety': 'キダチアロエ',
        'interval': 10,
        'location': '雑貨店',
        'nextWatering': today.add(const Duration(days: 7)),
        'lastWatered': today.subtract(const Duration(days: 3)),
        'hasImage': false,
        'shouldWaterToday': false,
      },
      // 10. 昨日水やりした植物
      {
        'name': 'クワズイモ',
        'variety': 'アロカシア',
        'interval': 5,
        'location': '花屋',
        'nextWatering': yesterday.add(const Duration(days: 5)),
        'lastWatered': yesterday,
        'hasImage': false,
        'shouldWaterToday': false,
      },
      // 11-20. アガベ系植物
      {
        'name': 'アガベ チタノタ',
        'variety': 'ブルー',
        'interval': 7,
        'location': '専門店',
        'nextWatering': today.add(const Duration(days: 2)),
        'lastWatered': today.subtract(const Duration(days: 5)),
        'hasImage': true,
        'shouldWaterToday': false,
      },
      {
        'name': 'アガベ チタノタ',
        'variety': 'ホワイトアイス',
        'interval': 6,
        'location': '専門店',
        'nextWatering': today,
        'lastWatered': today.subtract(const Duration(days: 6)),
        'hasImage': true,
        'shouldWaterToday': true,
      },
      {
        'name': 'アガベ オテロイ',
        'variety': 'FO-076',
        'interval': 8,
        'location': 'ネット購入',
        'nextWatering': today.add(const Duration(days: 3)),
        'lastWatered': today.subtract(const Duration(days: 5)),
        'hasImage': true,
        'shouldWaterToday': false,
      },
      {
        'name': 'アガベ パリー',
        'variety': 'トランカータ',
        'interval': 7,
        'location': '専門店',
        'nextWatering': yesterday,
        'lastWatered': yesterday.subtract(const Duration(days: 7)),
        'hasImage': true,
        'shouldWaterToday': true,
      },
      {
        'name': 'アガベ ユタエンシス',
        'variety': 'エボリスピナ',
        'interval': 9,
        'location': '専門店',
        'nextWatering': today.add(const Duration(days: 4)),
        'lastWatered': today.subtract(const Duration(days: 5)),
        'hasImage': true,
        'shouldWaterToday': false,
      },
      {
        'name': 'アガベ アメリカーナ',
        'variety': '王妃雷神',
        'interval': 6,
        'location': 'ホームセンター',
        'nextWatering': today.add(const Duration(days: 1)),
        'lastWatered': today.subtract(const Duration(days: 5)),
        'hasImage': true,
        'shouldWaterToday': false,
      },
      {
        'name': 'アガベ ポタトルム',
        'variety': '吉祥冠',
        'interval': 7,
        'location': '専門店',
        'nextWatering': today,
        'lastWatered': today.subtract(const Duration(days: 7)),
        'hasImage': true,
        'shouldWaterToday': true,
      },
      {
        'name': 'アガベ フィリフェラ',
        'variety': 'スプレム',
        'interval': 8,
        'location': 'ネット購入',
        'nextWatering': today.add(const Duration(days: 5)),
        'lastWatered': today.subtract(const Duration(days: 3)),
        'hasImage': true,
        'shouldWaterToday': false,
      },
      {
        'name': 'アガベ イシスメンシス',
        'variety': 'グリーン',
        'interval': 7,
        'location': '専門店',
        'nextWatering': yesterday,
        'lastWatered': yesterday.subtract(const Duration(days: 7)),
        'hasImage': true,
        'shouldWaterToday': true,
      },
      {
        'name': 'アガベ 笹の雪',
        'variety': 'A.victoriae-reginae',
        'interval': 8,
        'location': '専門店',
        'nextWatering': today.add(const Duration(days: 2)),
        'lastWatered': today.subtract(const Duration(days: 6)),
        'hasImage': true,
        'shouldWaterToday': false,
      },
    ];
  }

  /// 植物のテストデータを生成
  static List<Plant> generateTestPlants() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final sampleImages = getSampleImageUrls();
    final testPlantsData = getTestPlantConfigs(today, yesterday);
    final plants = <Plant>[];

    int imageIndex = 0;
    for (int i = 0; i < testPlantsData.length; i++) {
      final plantData = testPlantsData[i];
      final purchaseDate = now.subtract(Duration(days: 60 + i * 10));
      final hasImage = plantData['hasImage'] as bool;

      final plant = Plant(
        id: 'test_plant_$i',
        name: plantData['name'] as String,
        variety: plantData['variety'] as String,
        purchaseDate: purchaseDate,
        purchaseLocation: plantData['location'] as String,
        imagePath: hasImage ? sampleImages[imageIndex++ % sampleImages.length] : null,
        wateringIntervalDays: plantData['interval'] as int,
        createdAt: purchaseDate,
        updatedAt: now,
      );

      plants.add(plant);
    }

    return plants;
  }

  /// ログエントリーのテストデータを生成
  static List<LogEntry> generateTestLogs(List<Plant> plants) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final testPlantsData = getTestPlantConfigs(today, yesterday);
    final logs = <LogEntry>[];

    for (int i = 0; i < plants.length; i++) {
      final plant = plants[i];
      final plantData = testPlantsData[i];

      // 過去のログを生成
      final lastWateredDate = plantData['lastWatered'] as DateTime;
      DateTime logDate = plant.purchaseDate ?? now.subtract(const Duration(days: 60));

      while (logDate.isBefore(lastWateredDate) || logDate.isAtSameMomentAs(lastWateredDate)) {
        // 定期的な水やりログを生成
        if (logDate.isAtSameMomentAs(lastWateredDate) ||
            (logDate.day % (plantData['interval'] as int) == 0)) {
          logs.add(LogEntry(
            id: 'log_${plant.id}_water_${logDate.millisecondsSinceEpoch}',
            plantId: plant.id,
            type: LogType.watering,
            date: logDate,
            note: _getRandomNote(LogType.watering),
            createdAt: logDate,
            updatedAt: logDate,
          ));
        }

        logDate = logDate.add(const Duration(days: 1));
        if (logDate.isAfter(now)) break;
      }

      // 今日水やり済みの場合は、今日の記録を追加
      if (plantData['shouldWaterToday'] as bool) {
        logs.add(LogEntry(
          id: 'log_${plant.id}_water_today',
          plantId: plant.id,
          type: LogType.watering,
          date: today,
          note: '今日の水やり',
          createdAt: now,
          updatedAt: now,
        ));
      }

      // いくつかの植物に肥料と活力剤の記録を追加
      if (i % 3 == 0) {
        final fertDate = today.subtract(Duration(days: 14 + i));
        logs.add(LogEntry(
          id: 'log_${plant.id}_fertilizer_${fertDate.millisecondsSinceEpoch}',
          plantId: plant.id,
          type: LogType.fertilizer,
          date: fertDate,
          note: _getRandomNote(LogType.fertilizer),
          createdAt: fertDate,
          updatedAt: fertDate,
        ));
      }

      if (i % 4 == 0) {
        final vitalDate = today.subtract(Duration(days: 7 + i));
        logs.add(LogEntry(
          id: 'log_${plant.id}_vitalizer_${vitalDate.millisecondsSinceEpoch}',
          plantId: plant.id,
          type: LogType.vitalizer,
          date: vitalDate,
          note: _getRandomNote(LogType.vitalizer),
          createdAt: vitalDate,
          updatedAt: vitalDate,
        ));
      }
    }

    return logs;
  }

  /// ランダムなメモを生成（内部使用）
  static String _getRandomNote(LogType type) {
    switch (type) {
      case LogType.watering:
        final notes = [
          'たっぷり水やり',
          '霧吹きで葉水も実施',
          '底面給水',
          '土の表面が乾いていた',
          '葉がしおれ気味だった',
        ];
        return notes[DateTime.now().millisecondsSinceEpoch % notes.length];
      case LogType.fertilizer:
        final notes = [
          'ハイポネックス使用',
          '規定倍率で希釈',
          '有機肥料を追加',
          '肥料を2000倍に希釈',
          '成長期なので多めに',
        ];
        return notes[DateTime.now().millisecondsSinceEpoch % notes.length];
      case LogType.vitalizer:
        final notes = [
          'メネデール使用',
          '植え替え後のケア',
          '根の活性化',
          'リキダス使用',
          '葉の艶出し',
        ];
        return notes[DateTime.now().millisecondsSinceEpoch % notes.length];
    }
  }
}
