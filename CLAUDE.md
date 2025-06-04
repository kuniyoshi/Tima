# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Tima is a macOS desktop time-tracking and productivity app built with Swift and SwiftUI. It uses SwiftData for persistence and focuses on keyboard-driven interaction for tracking work time through two modes: Measurement (time tracking) and TimeBox (Pomodoro-style intervals).

## Build Commands

```bash
# Open in Xcode (preferred method)
open Tima.xcodeproj

# Build from command line
xcodebuild -project Tima.xcodeproj -scheme Tima -configuration Debug build

# Run from command line
xcodebuild -project Tima.xcodeproj -scheme Tima -configuration Debug -derivedDataPath ./build
./build/Build/Products/Debug/Tima.app/Contents/MacOS/Tima

# Create distribution DMG (after archiving in Xcode)
create-dmg Tima.dmg Tima.v{version}/Tima.app
```

## Architecture

The app follows MVVM architecture with these key patterns:

- **Models**: SwiftData entities (`Measurement`, `TimeBox`, `ImageColor`) with `@Model` macro
- **ViewModels**: `MeasurementModel`, `TimeBoxModel` with `@Published` properties and Combine publishers
- **Views**: SwiftUI views subscribing to ViewModels via `@StateObject`/`@ObservedObject`
- **Data Layer**: `Database` class provides centralized SwiftData operations

Key architectural decisions:
- All data operations go through `Database` class
- Cross-component communication via Combine publishers
- Status bar integration through `StatusBarController` singleton
- Sound/notification managers for user feedback

## Development Guidelines

1. **SwiftData Usage**: Always use `Database` methods for data operations, never direct ModelContext access
2. **Keyboard Shortcuts**: Maintain keyboard-first design - all features must be keyboard accessible
3. **State Management**: Use `@Published` properties in ViewModels, avoid complex state in views
4. **Error Handling**: Follow existing pattern of fail-safe operations (e.g., `Database.swift` methods)
5. **No External Dependencies**: Use only Apple frameworks

## Common Tasks

- **Add new data model**: Create SwiftData `@Model` class, add corresponding Database methods
- **Add keyboard shortcut**: Define in `ContentView` commands section
- **Modify UI**: Work with SwiftUI views, maintain existing color scheme from `AppColor`
- **Add sound**: Place MP3 in `Sounds/` folder, update `SoundManager`

## Testing

Currently no automated tests. Manual testing required for all changes.

## Important Files

- `TimaApp.swift`: Entry point, SwiftData container setup
- `ContentView.swift`: Main view with tab switching logic
- `Database.swift`: All data operations
- `MeasurementModel.swift` & `TimeBoxModel.swift`: Core business logic
- `StatusBarController.swift`: Menu bar integration