# NAME

Tima

# SPECIFICATION

- やることを宣言する
- かかった時間を振り返ることができる
- サウンドと通知とで 25 分のタイムボックスを提供する
- 作業を邪魔しない、つまり、キーボードだけで操作できる

## USAGE

### MEASUREMENT

1. アプリを起動する
1. Tab キーで大項目にフォーカスする
1. 大項目にテキストを入力する
1. Tab キーで小項目にフォーカスする
1. 小項目にテキストを入力する
1. Enter キーで測定を始める

### TIMEBOX

1. Tab キーでアラームにフォーカスする
1. Space キーでタイムボックスを開始する
1. 25 分経過する
1. サウンドを再生し、通知を表示する
1. 5 分経過する
1. サウンドを再生し、通知を表示する

## DISPLAY

### MEASUREMENT

- 測定中かどうか
  - ▶️ / ⏹️ / ⏺️
- 大項目
  - 内容を示すラベル、つまり `大項目`
  - テキスト
  - 色
- 小項目
  - 内容を示すラベル、つまり `小項目
  - テキスト
- 履歴
  - 今日の合計時間
    - 時間のバーで作業中だったところに目印をつける
    - 数字を表示する
  - 今日の内容, 大項目、小項目、作業時間を並べる

### TIMEBOX

- 実行中かどうか
- 実行中なら: 残り時間
- 実行中なら: 中断
- 実行中でないなら: 開始
- 履歴
  - 時間バーに実行履歴をマーク

# KEY BINDINGS

- `⌘-1` to show Measurement view
- `⌘-2` to show TimeBox view
- `⌘-I` to focus new item field in Measurement view
- `space` to progress time box in TimeBox view
- `⌘-E` to export model data

# TODO

