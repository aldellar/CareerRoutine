# Frontend Structure

Clean, organized directory structure with clear separation of concerns.

## Directory Layout

```
frontend/
├── docs/                         # 📚 All documentation
│   ├── architecture.md           # Architecture overview & patterns
│   ├── backend-integration.md    # API integration guide
│   ├── features.md               # Feature documentation
│   ├── project-structure.md      # Detailed structure guide
│   ├── quick-reference.md        # Quick reference guide
│   ├── quick-start.md            # Getting started quickly
│   ├── setup.md                  # Setup instructions
│   └── xcode-fix.md              # Xcode troubleshooting
│
├── ios/                          # 📱 iOS Application
│   └── InterviewPrepApp/
│       ├── InterviewPrepApp/     # App source code
│       │   ├── Models/           # Data models
│       │   ├── Views/            # SwiftUI views
│       │   │   ├── Home/         # Main app screens
│       │   │   ├── Onboarding/   # Onboarding flow
│       │   │   └── Settings/     # Settings screens
│       │   ├── ViewModels/       # MVVM view models
│       │   ├── Networking/       # API client & models
│       │   │   └── Models/       # API request/response models
│       │   ├── Services/         # Business logic services
│       │   ├── Utils/            # Utility helpers
│       │   └── Assets.xcassets/  # Images & colors
│       ├── InterviewPrepApp.xcodeproj/  # Xcode project
│       └── InterviewPrepAppTests/       # Unit tests
│
├── add-files-to-xcode.sh         # Helper script for Xcode
└── README.md                     # Main readme

```

## Key Improvements

### ✅ Consolidated Documentation
- All `.md` files moved to `docs/` folder
- Consistent lowercase-with-hyphens naming
- Easy to find and maintain

### ✅ Clean iOS Structure
- iOS project in dedicated `ios/` directory
- Standard Xcode project layout preserved
- Clear separation from documentation

### ✅ Consistent Naming
- Documentation: `lowercase-with-hyphens.md`
- Code: Standard Swift conventions (PascalCase for types, camelCase for properties)
- Directories: lowercase

### ✅ No Redundancy
- Single source of truth for each file type
- Removed duplicate directory structures
- Clear hierarchy

## Quick Access

| Task | Command |
|------|---------|
| Open iOS Project | `cd ios/InterviewPrepApp && open InterviewPrepApp.xcodeproj` |
| Read Docs | `open docs/` |
| View Architecture | `open docs/architecture.md` |
| Quick Start | `open docs/quick-start.md` |

## File Recognition

All files are now properly organized and should be recognized by:
- ✅ Git (tracking correct files)
- ✅ Xcode (project structure intact)
- ✅ IDEs (clear directory hierarchy)
- ✅ Documentation tools (centralized docs)

