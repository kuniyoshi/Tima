# Repository Guidelines

## Project Structure & Module Organization
- 主要ソースは `Tima/` 直下にまとまり、`TimaApp.swift` がアプリのエントリーポイントです。
- ビュー層は `Measurement*View.swift` や `TimeBox*View.swift` に分離され、対応するモデルは `*Model.swift` に配置されています。
- 永続化とエクスポートは `Database.swift` と `ModelExporter.swift` が担当し、開発用の基データは `bin/generate_sample.pl` で生成できます。
- アセットは `Tima/Assets.xcassets`、サウンドは `Tima/Sounds/`、権限制御は `Tima/Tima.entitlements` を確認してください。
- SwiftUI Previews は `Preview Content/` のデモデータを参照するため、UI を変更した際はここも更新して整合性を保ちます。

## Build, Test, and Development Commands
- `open Tima.xcodeproj` : Xcode を起動して GUI でビルド・実行します。
- `xcodebuild -scheme Tima -configuration Debug build` : CLI でデバッグビルドを行います。
- `xcodebuild -scheme Tima -configuration Release archive -archivePath builds/Tima.xcarchive` : 配布用アーカイブを作成し、README 記載の DMG 作成フローに進みます。
- `bin/generate_sample.pl > sample.json` : 動作検証用の疑似データを生成します。

## Coding Style & Naming Conventions
- Swift 5/Xcode 標準のフォーマッタを使用し、インデントは 4 スペース、クロージャや if 文では必ず波括弧を付けます。
- 型は UpperCamelCase、プロパティやメソッドは lowerCamelCase、定数は `SettingsKeys` のように疎結合の構造体でまとめます。
- ファイルは機能単位で分割し、ビューとモデルはプレフィックスで揃えて検索性を維持します。

## Testing Guidelines
- 現状自動テストターゲットは未定義のため、`Measurement` と `TimeBox` の主要フローを手動で検証してください。
- サウンド通知や権限確認は macOS のシステム設定依存なので、テスト前に通知/サウンド許可を必ず確認します。
- サンプルデータで過去 200 日分のメトリクスを流し込み、スクロールや集計が期待通りに動くか確認することを推奨します。

## Commit & Pull Request Guidelines
- コミットメッセージは Git 履歴にならい、英語の命令形で 50 文字程度に収めます (例: `Adjust measurement persistence`).
- 1 コミット 1 変更を意識し、モデル・ビューの同時変更時は概要を簡潔に説明する本文を追加します。
- プルリクエストでは変更理由、確認済みの手動テスト手順、関連 Issue を記載し、UI 変更時はスクリーンショットを添付してください。

## Security & Configuration Tips
- 通知・サウンドの権限は初回起動時に求められるため、開発用の署名設定を Xcode の Signing & Capabilities で適切に維持してください。
- `Database.swift` はローカルストレージを扱うため、デバッグログに個人情報を残さないよう注意します。

## Architecture Overview
- メニューバー常駐ロジックは `StatusBarController.swift` が担い、アプリライフサイクルとの橋渡しを `TimaApp` から受け取ります。
- 通知とサウンドはそれぞれ `NotificationManager.swift` と `SoundManager.swift` に集約され、`MeasurementView`・`TimeBoxView` から依存を注入する形で利用されています。
- 測定データは `MeasurementModel` → `MeasurementDaillyListModel` → `MeasurementDailyListView` の順に流れ、ビジネスロジックと UI を分離しています。
