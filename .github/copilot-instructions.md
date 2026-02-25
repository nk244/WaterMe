# GitHub Copilot Instructions — WaterMe

## 基本ルール

- **応答は必ず日本語で行うこと。**
- コード中のコメントも日本語で書くこと。
- ファイル名・変数名・クラス名などの識別子は英語のままでよい。

---

## プロジェクト概要

**WaterMe** は Flutter 製の植物水やり管理アプリ。  
植物ごとの水やりスケジュール管理、水やり履歴記録、ノート機能、プッシュ通知リマインダーを提供する。

- **パッケージ名**: `water_me`
- **対応プラットフォーム**: Android / iOS / Web
- **Flutter SDK**: `^3.11.0`
- **状態管理**: Provider パターン (`provider: ^6.1.1`)

---

## ディレクトリ構成

```
lib/
├── main.dart                  # エントリポイント
├── models/                    # データモデル
│   ├── app_settings.dart      # アプリ設定 (テーマ・通知設定)
│   ├── plant.dart             # 植物モデル
│   ├── log_entry.dart         # 水やりログエントリ
│   ├── note.dart              # ノートモデル
│   └── daily_log_status.dart  # 日別ログステータス
├── providers/                 # 状態管理 (Provider)
│   ├── plant_provider.dart    # 植物データ管理
│   ├── note_provider.dart     # ノートデータ管理
│   └── settings_provider.dart # アプリ設定管理
├── screens/                   # 画面
│   ├── home_screen.dart       # ホーム (タブ管理)
│   ├── plant_list_screen.dart # 植物一覧
│   ├── plant_detail_screen.dart # 植物詳細
│   ├── add_plant_screen.dart  # 植物追加・編集
│   ├── today_watering_screen.dart # 水やりログ (日付別・過去/未来対応)
│   ├── notes_list_screen.dart # ノート一覧 (検索・絞り込み対応)
│   ├── note_detail_screen.dart # ノート詳細
│   ├── add_edit_note_screen.dart # ノート追加・編集
│   ├── image_crop_screen.dart # 画像トリミング
│   └── settings_screen.dart   # 設定
├── services/                  # サービス層
│   ├── database_service.dart  # SQLite (sqflite) 操作 (モバイル)
│   ├── web_storage_service.dart # SharedPreferences によるデータ永続化 (Web)
│   ├── memory_storage_service.dart # インメモリストレージ (Web 開発用)
│   ├── export_service.dart    # JSON エクスポート/インポート
│   ├── settings_service.dart  # 設定の永続化 (SharedPreferences)
│   ├── notification_service.dart # ローカル通知 (flutter_local_notifications)
│   └── log_service.dart       # 水やりログ操作
├── theme/
│   └── app_themes.dart        # テーマ定義 (AppTheme enum)
├── utils/                     # ユーティリティ
└── widgets/                   # 共通ウィジェット
```

---

## 主要な依存パッケージ

| パッケージ | 用途 |
|---|—|
| `provider` | 状態管理 |
| `sqflite` | ローカルDB (モバイル) |
| `shared_preferences` | 設定の永続化 / Web永続化 |
| `image_picker` | カメラ・ギャラリーから画像取得 |
| `crop_your_image` | 画像トリミング |
| `flutter_local_notifications` ^20.1.0 | ローカルプッシュ通知 |
| `flutter_localizations` (SDK) | カレンダー・UI の日本語ローカライゼーション |
| `timezone` | タイムゾーン管理 (通知スケジュール用) |
| `intl` ^0.20.2 | 日付フォーマット (ja ロケール) |
| `file_picker` | ファイル選択 (エクスポート/インポート) |
| `permission_handler` | ランタイムパーミッション管理 |
| `uuid` | UUID生成 |

---

## アーキテクチャと規約

### Provider パターン
- `ChangeNotifier` を継承した Provider クラスを `lib/providers/` に置く。
- 画面からは `context.watch<XxxProvider>()` または `Consumer<XxxProvider>` で参照する。
- データの永続化はProviderからServiceを呼び出すことで行う。

### サービス層
- DB操作・通知・ファイルI/Oなどの副作用はすべて `lib/services/` に分離する。
- `NotificationService` はシングルトン (`factory` コンストラクタ)。v20以降の API はすべて **named parameters** を使用する。
  ```dart
  await _plugin.initialize(settings: initSettings);
  await _plugin.zonedSchedule(id: ..., title: ..., body: ..., scheduledDate: ..., notificationDetails: ...);
  await _plugin.cancel(id: ...);
  ```

### プラットフォーム分岐
- Web では SQLite が使えないため `web_storage_service.dart`（SharedPreferences ベース）で永続化。
- `memory_storage_service.dart` は開発時のテスト用。本番データは `web_storage_service.dart` で持つ。
- 通知・ファイル操作など Web 非対応の処理はすべて `if (kIsWeb) return;` でガードする。

### モデルクラス
- `toMap()` / `fromMap()` でシリアライズ。
- `copyWith()` パターンで不変更新。
- `fromMap()` では `?? デフォルト値` で null セーフに読み込む。

---

## データモデルの関係

```
Plant (1) ──── (N) LogEntry      # 水やりログ
Plant (1) ──── (N) Note          # ノート (plantIds: List<String> で多対多も可)
AppSettings                       # 設定 (テーマ・通知時刻・通知ON/OFF)
```

---

## コーディング規約

- **Dart の命名規則**に従う: クラスは `UpperCamelCase`、変数・関数は `lowerCamelCase`、定数は `lowerCamelCase` (Dart標準)。
- `const` コンストラクタを積極的に使用する。
- `BuildContext` を非同期処理をまたいで使う場合は `mounted` チェックを行う。
- 画面ウィジェットは基本的に `StatelessWidget` とし、ローカルな UI 状態のみ `StatefulWidget` にする。
- 長い `build()` は `_buildXxx()` メソッドや別ウィジェットに分割する。

---

## GitHub Issues の管理方針

- バグ修正は `fix/issue-タイトル` ブランチで実装し、PR に `Fixes #番号` を含める。
- 機能追加は `feature/機能名` ブランチで実装し、PR に `Closes #番号` を含める。
- PR は `main` ブランチをベースとする。
- コミットメッセージの形式: `feat: 説明 (#番号)` / `fix: 説明 (#番号)`

---

## 残課題 (Issues)

現時点でオープンの Issue はありません。実装済みの主な機能一覧：

| 機能 | 対応内容 |
|---|---|
| フォント | Noto Sans JP（可変フォント）をモバイル・ Web 両方に適用 |
| カレンダー日本語化 | `flutter_localizations` + `locale: ja` を MaterialApp に設定 |
| ダークテーマ | `AppThemes.getDarkTheme()` + `ThemeMode` + 設定画面 RadioListTile で完全実装済 |
| プッシュ通知 | `flutter_local_notifications` v20 で実装（Android/iOS） |
| エクスポート/インポート | `ExportService` で JSON 形式・ Web/モバイル分岐実装済 |
| Web 永続化 | `WebStorageService`（SharedPreferences）でリロード後もデータ保持 |
| グリッド表示 | 植物一覧でリスト/グリッド切り替え対応済 |
| 植物画像背景化 | 詳細画面で画像を背景ヘッダーとして表示 |

---

## よく使うコマンド

```powershell
# 依存パッケージ取得
flutter pub get

# Android 向けビルド・実行
flutter run -d android

# Web 向けビルド・実行
flutter run -d chrome

# 静的解析
flutter analyze

# テスト実行
flutter test
```
