# NAME

Tima

# USAGE

First, select a view: `Measurement` or `TimeBox`.

In `Measurement`,

1. Enter the work name and details
1. Press the play button.

In `TimeBox`,

1. Press `Space` to start a timebox
1. After the specific minutes passed, the app notifies you when timebox is over
1. Take a short break
1. The app notifies you when the next timebox to begin.

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

# PURPOSE

Focus to the work by time box.

1. assert, and recognize what work to be
1. dive into time box
1. rest a few minutes
1. repeat time box until work finished

The app will be designed to control by keyboard only.
- TimeBox
- ImageColor decorates measurement's work
- Measurement

- やることを宣言する
- かかった時間を振り返ることができる
- サウンドと通知とで 25 分のタイムボックスを提供する
- 作業を邪魔しない、つまり、キーボードだけで操作できる

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
