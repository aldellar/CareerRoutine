# Interview Prep iOS App

A SwiftUI app to help CS students and new grads build a Mon-Fri routine with tailored interview prep plans.

## Features

- **Onboarding**: Capture user profile (year, target role, time budget, constraints)
- **Weekly Routine**: AI-generated Mon-Fri schedule with time-boxed blocks
- **Daily Checklist**: Track daily tasks with streak counter
- **Interview Prep Pack**: Tailored prep outline with resources
- **Quick Re-rolls**: Regenerate specific parts of the plan

## Project Structure

```
InterviewPrepApp/
├── Models/              # Data models
├── Views/               # SwiftUI views
│   ├── Onboarding/     # Onboarding flow
│   ├── Home/           # Main tabs (Week, Today, Prep)
│   └── Settings/       # Profile editing
├── Services/           # Business logic
│   ├── Storage/        # Local persistence
│   └── Network/        # API client (stubs for now)
└── Utils/              # Helpers and extensions
```

## Getting Started

1. Open `InterviewPrepApp.xcodeproj` in Xcode
2. Select your target device/simulator
3. Build and run (⌘R)

## Tech Stack

- SwiftUI for UI
- Combine for reactive programming
- FileManager for JSON storage
- UserDefaults for preferences
- URLSession for networking (future backend integration)

## MVP Scope

This is a frontend-only MVP. Backend integration will be added later.

