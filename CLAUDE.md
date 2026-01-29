# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Life in the UK Prep - an iOS SwiftUI application for practicing the mandatory UK citizenship test. The app provides practice exams with 24 multiple-choice questions, study materials via an integrated handbook reader, and progress tracking.

## Build Commands

```bash
# Build from command line
xcodebuild -scheme QuizUp-Mock -configuration Debug build

# Open in Xcode (then Cmd+R to run)
open QuizUp-Mock.xcodeproj
```

Requires Xcode with iOS 16+ SDK. No external dependencies (pure Swift/SwiftUI).

## Architecture

**Pattern**: MVVM with Repository pattern and centralized navigation

```
QuizUp_MockApp.swift (Entry Point)
    → RouterView (Navigation/AppRouter.swift)
        → Destination enum (Route.swift)
            → Feature Views + ViewModels
                → Repository Layer (data access)
                    → Local Storage (UserDefaults)
```

### Key Components

- **Navigation**: `AppRouter` manages NavigationStack with push, sheet, and fullScreenCover presentations. Routes defined in `Route.swift` as `Destination` enum
- **ViewModels**: Use `@MainActor @Observable` pattern (modern Swift 5.9+ observation). Key VMs: `ExamViewModel`, `QuestionViewModel`, `MenuViewModel`
- **Repositories**: Singletons handling data loading and persistence - `ExamRepository`, `HandbookRepository`
- **Feature Flags**: Centralized in `FeatureFlags.swift`

### Data Flow

Questions loaded from JSON files in `/Repository/`:
- `questions.json` - Complete question bank
- `explanation.json` - Question explanations
- `book_index.json` - Maps questions to handbook sections
- `handbook.json` - Study material content

User progress persisted via UserDefaults with suite name "v0.0.1".

### Directory Organization by Feature

- `/Exam/` - Test-taking flow (Question views, results, confetti animation)
- `/Menu/` - Landing page, search, practice exam list
- `/Handbook/` - WebView-based HTML content reader with highlighting
- `/Navigation/` - Routing and navigation stack management
- `/Repository/` - Data access layer and JSON data files
- `/Extensions/` - Color system, animations, UI helpers
- `/SettingsView/`, `/ProgressReport/`, `/QuestionBank/`, `/Monitization/`

### UI Conventions

- Color gradients defined in `Extensions/Colors.swift`
- Custom animations in `Extensions/Animation.swift`
- 3D background effects in `Extensions/3DBackground.swift`
- Circular progress indicators and confetti in `/Exam/Result/`
