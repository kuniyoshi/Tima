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
- `⌘-I` to focus on the new item field in the Measurement view
- `Space` to progress timebox in the TimeBox view
- `Escape` to quit textfield editing
- `⌘-E` to export model data
- `⌘-M` to import model data
- `⌘-T` to terminate measurement/timebox
- `⌘-R` to refresh the date

# CODING POLICY

We avoid overly complex coding. Instead, we prioritize effective features that
can be implemented with simple, maintainable coding.

# PURPOSE

The app helps you focus on work using the timebox method.

1. Identify and declare the work
1. Work within a timebox
1. Take a short break
1. Repeat the cycle until the work completed

The app is designed for keyboard-only control.

# FEATURES

## Importing Data

Imported data will be added to the existing data.
It will not replace, overwrite, or merge with existing records.

# BUILD AND DISTRIBUTE

1. Archive
1. Distribute App
1. Copy App
1. Run a command to create DMG: `create-dmg Tima.dmg Tima.v1.4.1/Tima.app`

# SOUND

Sound effects are from [効果音ラボ](https://soundeffect-lab.info).

# TODO

## Normal TODO

Just a TODO.

- Switching to timebox is slow
- Flicker while daily total minutes updating
- Filter old measurements and timeboxes to improve performance

## Difficult TODO

These TODOs are optional suggestions rather ran strict requirements.

- Make database singleton
- Add some indicator to show wheter the app is currently in a timebox
- Implement work completion
- Fix memory leaks caused by ContentView's Picker

## Lower Priority TODO

These TODOs are optional suggestions rather ran strict requirements.

- Change from alert to sheet
- Add a work list view, it can edit each works
- Maintain layout consistency in the Measurement view
- Implement a data import feature
- Allow editing of the date in the Measurement view (currently, only hours can be edited)
- Allow empty text field to be edited in the Measurement view
- Move sound file to settings?
- TimeBox も編集したい, しかし記号で表示しているので WYSIWYG にならない
- Add a bit animation for the timebox view
- add a bit animation for the Measurement view
- Fix scrolling behavior in the Measurement view
- Display a graph of recorded
- Set up a GitHub Action for building the application
- Improve the visibility of the timebox count. However, making the count too explicit might not be ideal.
- Use a logger for error messages instead of `print` <- Are the app users interesting in errors?
