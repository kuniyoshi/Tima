# NAME

Tima

# USAGE

First, select a view from, `Measurement` or `TimeBoxe`.

in `Measurement`,


# KEY BINDINGS

- `⌘-1` to show Measurement view
- `⌘-2` to show TimeBox view
- `⌘-I` to focus new item field in Measurement view
- `Space` to progress time box in TimeBox view
- `Escape` to quit editing
- `⌘-E` to export model data

# POLICY

We don't do complicated coding. Instead, we adopt effective features that
can be implemented with simple coding.

# SPECIFICATION NOTE

- TimeBox
- ImageColor decorates measurement's work
- Measurement

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

# SOUND

Sounds are from [効果音ラボ](https://soundeffect-lab.info).

# TODO

These TODOs are not mandatory; they are just potential tasks (or suggestions).

## Difficult TODO

- add indicator that wheter is in time box or not
- add work completion
- ContentView's Picker leads to memory leak

## Lower Priority TODO

- change from alert to sheet
- add work list view, it can edit each works
- keep layout while using measurement view
- add data import feature
- Measurement can't edit date, it can only hour
- empty text can be edit in measurement view
- move sound file to settings?
- TimeBox も編集したい, しかし記号で表示しているので WYSIWYG にならない
- add a bit animation while time box
- add a bit animation while measurement
- fix scroll on measurements
- show graph
- github action to build applicatoin
- use logger to show error, instead of `print` <- Are the app users interesting in errors?
