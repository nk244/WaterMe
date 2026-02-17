# WaterMe 🌱💧

植物の水やり管理アプリ - あなたの植物たちの健康を守るスマートなリマインダー

## 概要

WaterMeは、植物の水やりスケジュールを管理し、日々の記録を残すことができるFlutterアプリケーションです。
日付ベースのタスク管理で、その日に水やりが必要な植物を一目で確認でき、完了状態も視覚的に把握できます。

### 主な機能

- 📅 **日付ベースの水やり管理** - 今日水やりが必要な植物を一覧表示
- ✅ **クイック水やり登録** - ワンタップで水やり完了を記録
- 🌿 **植物情報管理** - 名前、品種、購入日、購入場所、画像を保存
- 💧 **水やり履歴** - 過去の水やり記録を日付ごとに確認
- 🌱 **肥料・活力剤の記録** - 水やり以外のケアも記録可能
- 📸 **画像アップロード** - 植物の写真を登録（Web対応）
- 🎨 **カスタマイズ可能な色設定** - 水やり・肥料・活力剤の色を個別に設定
- 🔄 **柔軟な並び替え機能** - 名前順、購入日順、カスタム順で植物を整理
- 📱 **リスト表示** - 見やすい1列レイアウト
- 📱 **マルチプラットフォーム** - Android、iOS、Webに対応

## 開発環境のセットアップ

### 1. Flutter SDKのインストール

#### Windows

1. **Flutter SDKのダウンロード**
   - [Flutter公式サイト](https://flutter.dev/docs/get-started/install/windows)から最新の安定版をダウンロード
   - ZIPファイルを展開（推奨パス: `C:\src\flutter`）

2. **環境変数の設定**
   ```powershell
   # システム環境変数 PATH に Flutter の bin ディレクトリを追加
   # 例: C:\src\flutter\bin
   ```
   - 「システムのプロパティ」→「環境変数」→「Path」に追加
   - または PowerShell で:
   ```powershell
   [System.Environment]::SetEnvironmentVariable('Path', $env:Path + ';C:\src\flutter\bin', 'User')
   ```

3. **インストールの確認**
   ```powershell
   flutter doctor
   ```

#### macOS

```bash
# Homebrewを使用する場合
brew install flutter

# または公式サイトからダウンロード
# https://flutter.dev/docs/get-started/install/macos
```

#### Linux

```bash
# Snapを使用する場合
sudo snap install flutter --classic

# または公式サイトからダウンロード
# https://flutter.dev/docs/get-started/install/linux
```

### 2. 開発ツールのインストール

#### Android開発環境

1. **Android Studioのインストール**
   - [Android Studio](https://developer.android.com/studio)をダウンロードしてインストール

2. **Android SDKの設定**
   - Android Studio起動時に表示されるセットアップウィザードに従う
   - SDK Managerで以下をインストール:
     - Android SDK Platform (最新版)
     - Android SDK Build-Tools
     - Android Emulator

3. **ライセンスの承認**
   ```powershell
   flutter doctor --android-licenses
   ```

#### iOS開発環境（macOSのみ）

1. **Xcodeのインストール**
   ```bash
   # App Storeからインストール、または
   xcode-select --install
   ```

2. **CocoaPodsのインストール**
   ```bash
   sudo gem install cocoapods
   ```

#### Visual Studio Code（推奨エディタ）

1. [VS Code](https://code.visualstudio.com/)をダウンロードしてインストール

2. 拡張機能のインストール:
   - Flutter
   - Dart

### 3. プロジェクトのクローンとセットアップ

```powershell
# リポジトリのクローン
git clone https://github.com/nishioko/WaterMe.git
cd WaterMe/water_me

# 依存パッケージのインストール
flutter pub get

# デバイス/エミュレータの確認
flutter devices
```

### 4. アプリの実行

#### Web（開発用）

```powershell
flutter run -d chrome
# または
flutter run -d web-server --web-port=8080
```

#### Android

```powershell
# エミュレータを起動してから
flutter run -d android

# または特定のデバイスを指定
flutter run -d <device-id>
```

#### iOS（macOSのみ）

```bash
# シミュレータを起動してから
flutter run -d ios

# または特定のデバイスを指定
flutter run -d <device-id>
```

### 5. デバッグ

#### ホットリロード
- ソースコード変更後、ターミナルで `r` キーを押す

#### ホットリスタート
- アプリの状態をリセットして再起動する場合は `R` キーを押す

#### VS Codeでのデバッグ
1. `F5` キーを押してデバッグ開始
2. ブレークポイントを設定して変数の状態を確認
3. デバッグコンソールでログを確認

## プロジェクト構成

```
lib/
├── main.dart                      # アプリのエントリーポイント
├── data/                          # テストデータ
│   └── test_data_generator.dart  # テストデータ生成（開発用）
├── models/                        # データモデル
│   ├── plant.dart                # 植物モデル
│   ├── log_entry.dart            # ログエントリモデル
│   ├── diary_entry.dart          # 日記エントリモデル
│   └── app_settings.dart         # アプリ設定モデル
├── providers/                     # 状態管理（Provider）
│   ├── plant_provider.dart       # 植物データの状態管理
│   └── settings_provider.dart    # 設定の状態管理
├── screens/                       # 画面UI
│   ├── home_screen.dart          # ホーム画面（タブナビゲーション）
│   ├── today_watering_screen.dart # 今日の水やり画面
│   ├── plant_list_screen.dart    # 植物一覧画面（並び替え機能付き）
│   ├── add_plant_screen.dart     # 植物追加・編集画面
│   ├── plant_detail_screen.dart  # 植物詳細画面
│   └── settings_screen.dart      # 設定画面（色設定含む）
├── services/                      # データ永続化
│   ├── database_service.dart     # SQLite（モバイル用）
│   ├── memory_storage_service.dart # メモリストレージ（Web用）
│   └── settings_service.dart     # 設定サービス
├── theme/                         # テーマ設定
│   └── app_themes.dart           # アプリテーマ定義
└── widgets/                       # 再利用可能なウィジェット
    └── plant_image_widget.dart   # 植物画像表示ウィジェット
```

## 使用技術

- **Flutter**: 3.41.1 (stable)
- **Dart**: ^3.11.0
- **状態管理**: Provider ^6.1.1
- **ローカルDB**: 
  - sqflite ^2.3.0 (Android/iOS)
  - メモリストレージ (Web)
- **画像選択**: image_picker ^1.0.7
- **日付処理**: intl ^0.19.0
- **設定保存**: shared_preferences ^2.2.2
- **通知**: flutter_local_notifications ^16.3.2

## 主な依存パッケージ

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1              # 状態管理
  sqflite: ^2.3.0               # SQLiteデータベース（モバイル）
  image_picker: ^1.0.7          # 画像選択
  intl: ^0.19.0                 # 国際化・日付フォーマット
  shared_preferences: ^2.2.2    # ローカル設定保存
  flutter_local_notifications: ^16.3.2  # ローカル通知
```

## トラブルシューティング

### `flutter` コマンドが認識されない
- 環境変数 PATH に Flutter の bin ディレクトリが追加されているか確認
- ターミナルを再起動して再度試行

### Android ライセンスエラー
```powershell
flutter doctor --android-licenses
```
すべてのライセンスに同意してください（`y` を入力）

### iOS シミュレータが起動しない
```bash
# Xcodeを開いて以下を実行
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

### パッケージの依存関係エラー
```powershell
flutter clean
flutter pub get
```

### Web版で画像が表示されない
Web版では画像がメモリに保存されるため、ページをリロードすると消えます。本番環境では外部ストレージとの連携が必要です。

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。

## 今後の予定

- [ ] プッシュ通知機能の実装
- [ ] 日記機能の実装
- [ ] データのエクスポート/インポート機能
- [ ] クラウド同期機能
- [ ] ウィジェット対応
- [x] カスタム並び替え機能（ドラッグ&ドロップ）
- [x] ログタイプ別色設定機能
- [x] テストデータ分離

## 貢献

プルリクエストを歓迎します。大きな変更を加える場合は、まずissueを開いて変更内容を議論してください。

## 問い合わせ

質問や提案がある場合は、GitHubのIssuesでお知らせください。
