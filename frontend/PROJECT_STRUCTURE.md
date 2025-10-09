# iOS Interview Prep App - Project Structure

## Overview

This is a SwiftUI-based iOS application designed to help CS students and new grads build a Mon-Fri interview prep routine with personalized plans.

## Directory Structure

```
InterviewPrepApp/
├── InterviewPrepApp.xcodeproj/     # Xcode project file
│   ├── project.pbxproj             # Project configuration
│   └── project.xcworkspace/        # Workspace data
│
├── InterviewPrepApp/               # Main app source code
│   ├── InterviewPrepAppApp.swift   # App entry point
│   ├── ContentView.swift           # Root view (routing)
│   ├── Info.plist                  # App configuration
│   │
│   ├── Models/                     # Data models
│   │   ├── UserProfile.swift       # User profile & academic stage
│   │   ├── Routine.swift           # Weekly routine & time blocks
│   │   ├── DailyTask.swift         # Daily tasks & streak data
│   │   └── PrepPack.swift          # Interview prep pack & resources
│   │
│   ├── Services/                   # Business logic layer
│   │   ├── AppState.swift          # Global app state management
│   │   ├── StorageService.swift    # Local JSON persistence
│   │   └── NetworkService.swift    # API client (mock data for now)
│   │
│   ├── Views/                      # SwiftUI views
│   │   ├── Onboarding/
│   │   │   ├── OnboardingView.swift        # Multi-step onboarding flow
│   │   │   └── OnboardingViewModel.swift   # Onboarding logic
│   │   │
│   │   ├── Home/
│   │   │   ├── HomeView.swift      # Main tab container
│   │   │   ├── WeekView.swift      # Weekly schedule display
│   │   │   ├── TodayView.swift     # Daily checklist & streak
│   │   │   └── PrepView.swift      # Interview prep pack
│   │   │
│   │   └── Settings/
│   │       ├── SettingsView.swift      # Settings & stats
│   │       └── EditProfileView.swift   # Profile editing
│   │
│   ├── Utils/                      # Helper utilities
│   │   ├── DateExtensions.swift    # Date helper methods
│   │   └── ColorExtensions.swift   # Color utilities
│   │
│   └── Assets.xcassets/            # App assets
│       ├── AppIcon.appiconset/     # App icon
│       └── AccentColor.colorset/   # Accent color
│
├── README.md                       # Project documentation
├── PROJECT_STRUCTURE.md            # This file
└── .gitignore                      # Git ignore rules
```

## Architecture

### MVVM Pattern
- **Models**: Pure data structures (Codable for JSON persistence)
- **Views**: SwiftUI views (declarative UI)
- **ViewModels**: Business logic (e.g., OnboardingViewModel)
- **Services**: Shared services (Storage, Network, AppState)

### Data Flow
1. **AppState** (ObservableObject) holds global state
2. Views observe AppState via `@EnvironmentObject`
3. User actions → View → AppState → Service → Storage/Network
4. State changes → SwiftUI auto-updates UI

### Local Storage
- **StorageService** handles all persistence
- JSON files in app's Documents directory
- UserDefaults for simple flags (onboarding status)
- Files:
  - `user_profile.json` - User profile
  - `routine.json` - Weekly routine
  - `prep_pack.json` - Interview prep pack
  - `daily_tasks.json` - Task completion data
  - `streak_data.json` - Streak statistics

### Network Layer (Stubbed)
- **NetworkService** provides mock data
- Ready for backend integration (async/await)
- Endpoints to implement:
  - `POST /api/routine/generate` - Generate weekly routine
  - `POST /api/prep/generate` - Generate prep pack
  - `POST /api/prep/regenerate-resources` - Refresh resources
  - `POST /api/prep/regenerate-prompts` - Refresh mock prompts

## Key Features

### 1. Onboarding (5 steps)
- Welcome screen
- Name input
- Stage & target role selection
- Time budget & available days
- Preferred tools selection

### 2. Weekly Plan (WeekView)
- Mon-Fri day selector
- Weekly milestones display
- Time-blocked schedule cards
- Expandable task details with resources

### 3. Today's Tasks (TodayView)
- Streak card (current, longest, total)
- Progress bar (completed/total)
- Task checklist with status cycling (pending → done → skipped)
- Note-taking for each task

### 4. Interview Prep (PrepView)
- Practice cadence overview
- Topic roadmap with priorities
- Recommended resources (with links)
- Practice questions
- Quick regeneration options

### 5. Settings
- Profile editing
- Routine regeneration
- Prep pack regeneration
- Statistics display
- Data reset option

## Models

### UserProfile
- Name, stage, target role
- Time budget (hours/day)
- Available days
- Preferred tools

### Routine
- Version tracking
- Weekly schedule (Weekday → [TimeBlock])
- Weekly milestones

### TimeBlock
- Title, description
- Start/end time
- Category (DS&A, System Design, etc.)
- Resources

### DailyTask
- Links to TimeBlock
- Date
- Status (pending/done/skipped)
- Notes

### PrepPack
- Topic ladder (with priorities)
- Practice cadence
- Resources (with URLs)
- Mock interview prompts

### StreakData
- Current streak
- Longest streak
- Last completed date
- Total tasks completed

## Next Steps (Backend Integration)

1. **Replace mock data** in NetworkService with real API calls
2. **Add authentication** (optional - user accounts)
3. **Add error handling** for network failures
4. **Add loading states** during API calls
5. **Add pull-to-refresh** on views
6. **Add push notifications** for daily reminders
7. **Add analytics** to track user engagement

## Development Notes

- **Minimum iOS version**: iOS 15.0+
- **Language**: Swift 5.5+
- **UI Framework**: SwiftUI
- **Concurrency**: async/await
- **State Management**: Combine + @Published
- **Persistence**: FileManager + JSONEncoder/Decoder

## Running the App

1. Open `InterviewPrepApp.xcodeproj` in Xcode
2. Select a simulator or device
3. Build and run (⌘R)

The app will start with onboarding if it's the first launch, otherwise it will show the home screen with tabs.

## Testing Strategy (Future)

- Unit tests for models and services
- UI tests for critical user flows
- Mock NetworkService for testing without backend
- Snapshot tests for UI consistency

## Design Principles

- **Day-1 value**: User gets value in < 2 minutes
- **Local-first**: Everything works offline
- **Simple & focused**: MVP features only
- **Modern iOS design**: Native SwiftUI components
- **Accessible**: Support for VoiceOver and Dynamic Type

