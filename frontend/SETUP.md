# Setup Guide

## Prerequisites

- macOS 12.0 or later
- Xcode 14.0 or later
- iOS 15.0+ device or simulator

## Quick Start

### Option 1: Open in Xcode (Recommended)

Since this is a pure SwiftUI project without external dependencies, you can open it directly:

1. Navigate to the frontend directory:
   ```bash
   cd /Users/dellaringo/Documents/GitHub/AiOSapp/frontend/InterviewPrepApp
   ```

2. Open the project in Xcode:
   ```bash
   open InterviewPrepApp.xcodeproj
   ```

3. Wait for Xcode to index the project

4. Select a simulator or device from the scheme selector

5. Press ⌘R to build and run

### Option 2: Manual Setup

If you need to create the Xcode project from scratch:

1. Open Xcode
2. File → New → Project
3. Choose "iOS" → "App"
4. Fill in:
   - Product Name: `InterviewPrepApp`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - Storage: `None` (we handle it manually)
5. Save to `frontend/` directory
6. Copy all the Swift files from the provided structure into the project

## Project Structure in Xcode

After opening, you should see this structure in the Project Navigator:

```
InterviewPrepApp
├── InterviewPrepAppApp.swift
├── ContentView.swift
├── Models/
│   ├── UserProfile.swift
│   ├── Routine.swift
│   ├── DailyTask.swift
│   └── PrepPack.swift
├── Services/
│   ├── AppState.swift
│   ├── StorageService.swift
│   └── NetworkService.swift
├── Views/
│   ├── Onboarding/
│   │   ├── OnboardingView.swift
│   │   └── OnboardingViewModel.swift
│   ├── Home/
│   │   ├── HomeView.swift
│   │   ├── WeekView.swift
│   │   ├── TodayView.swift
│   │   └── PrepView.swift
│   └── Settings/
│       ├── SettingsView.swift
│       └── EditProfileView.swift
├── Utils/
│   ├── DateExtensions.swift
│   └── ColorExtensions.swift
└── Assets.xcassets/
```

## Adding Files to Xcode

If files are missing from the project:

1. Right-click on the group (e.g., "Models")
2. Select "Add Files to 'InterviewPrepApp'..."
3. Navigate to the file location
4. Ensure "Copy items if needed" is checked
5. Click "Add"

## Build Settings

The project should work with default settings, but verify:

- **Deployment Target**: iOS 15.0 or later
- **Swift Language Version**: Swift 5
- **Bundle Identifier**: `com.yourname.InterviewPrepApp` (change as needed)

## Running the App

### First Launch
- App will show onboarding flow
- Complete all 5 steps
- You'll see the home screen with mock data

### Subsequent Launches
- App will skip onboarding
- Home screen with tabs (Week, Today, Prep)

### Reset Data
- Go to Settings tab
- Scroll to bottom
- Tap "Reset All Data"

## Troubleshooting

### Build Errors

If you see "Cannot find type 'X' in scope":
1. Ensure all Swift files are added to the target
2. Check File Inspector → Target Membership
3. Clean build folder (⇧⌘K)
4. Rebuild (⌘B)

### Missing Files

If Xcode shows files in red:
1. Select the file in Project Navigator
2. File Inspector → Location → Click folder icon
3. Navigate to the actual file location
4. Click "Choose"

### Simulator Issues

If the app doesn't launch:
1. Reset simulator: Device → Erase All Content and Settings
2. Quit and restart Xcode
3. Clean build folder (⇧⌘K)
4. Rebuild and run

## Development Workflow

### Making Changes

1. Edit Swift files in Xcode
2. Xcode will auto-save
3. Build (⌘B) to check for errors
4. Run (⌘R) to test changes

### Live Preview

SwiftUI views include `#Preview` blocks:
1. Open any View file
2. Click "Resume" in the canvas (right side)
3. See live preview of the view
4. Changes update in real-time

### Debugging

- Set breakpoints by clicking line numbers
- Run in debug mode (⌘R)
- Use `print()` statements for logging
- View console output in Debug Area (⇧⌘Y)

## File Organization Tips

### Adding New Views

1. Right-click on `Views/` folder
2. New File → SwiftUI View
3. Name it (e.g., `NewFeatureView.swift`)
4. Implement the view

### Adding New Models

1. Right-click on `Models/` folder
2. New File → Swift File
3. Name it (e.g., `NewModel.swift`)
4. Make it `Codable` and `Identifiable`

## Backend Integration (Future)

When ready to connect to the backend:

1. Update `NetworkService.swift`
2. Replace mock functions with real API calls
3. Update `baseURL` to your backend URL
4. Add error handling and loading states

Example:
```swift
func generateRoutine(profile: UserProfile) async throws -> Routine {
    let url = URL(string: "\(baseURL)/routine/generate")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONEncoder().encode(profile)
    
    let (data, _) = try await session.data(for: request)
    return try JSONDecoder().decode(Routine.self, from: data)
}
```

## Testing

### Manual Testing Checklist

- [ ] Complete onboarding flow
- [ ] View weekly schedule
- [ ] Mark tasks as done/skipped
- [ ] Check streak updates
- [ ] View prep pack
- [ ] Edit profile
- [ ] Regenerate routine
- [ ] Reset all data

### Data Persistence Testing

1. Complete onboarding
2. Force quit app (swipe up in app switcher)
3. Relaunch app
4. Verify data persists

## Known Limitations (MVP)

- No backend integration (mock data only)
- No user authentication
- No cloud sync
- No push notifications
- No analytics
- No error recovery UI

These will be added in future iterations.

## Support

For issues or questions:
1. Check `PROJECT_STRUCTURE.md` for architecture details
2. Review `README.md` for feature documentation
3. Check Xcode console for error messages

## Next Steps

After setup:
1. Familiarize yourself with the codebase
2. Run the app and test all features
3. Review the mock data in `NetworkService.swift`
4. Plan backend integration
5. Add unit tests
6. Improve UI/UX based on feedback

