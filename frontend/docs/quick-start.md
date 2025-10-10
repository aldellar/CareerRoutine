# Quick Start Guide

## 🚀 Get Running in 3 Steps

### 1. Open the Project
```bash
cd /Users/dellaringo/Documents/GitHub/AiOSapp/frontend/ios/InterviewPrepApp
open InterviewPrepApp.xcodeproj
```

### 2. Select Target
- Click the scheme selector (next to Play button)
- Choose "iPhone 15 Pro" or any simulator
- Or connect your iPhone and select it

### 3. Run
- Press ⌘R (or click the Play button)
- Wait for build to complete
- App launches in simulator/device

## 📱 What You'll See

### First Launch: Onboarding
1. **Welcome screen** - App introduction
2. **Name input** - Enter your name
3. **Stage & Role** - Select year and target role
4. **Schedule** - Set hours/day and available days
5. **Tools** - Pick preferred learning resources

**Time to complete: < 2 minutes**

### After Onboarding: Home Screen
- **Today Tab** (default) - Daily tasks and streak
- **Week Tab** - Weekly schedule (Mon-Fri)
- **Prep Tab** - Interview prep resources

## 🎯 Try These Features

### Mark a Task Complete
1. Go to **Today** tab
2. Tap the circle icon next to a task
3. Watch it turn green (Done)
4. Tap again → orange (Skipped)
5. Tap again → gray (Pending)

### View Weekly Schedule
1. Go to **Week** tab
2. Tap different days (Mon-Fri)
3. Tap a task card to expand details
4. See time blocks, descriptions, resources

### Check Your Streak
1. **Today** tab shows streak card at top
2. Complete a task to increase streak
3. Streak updates automatically

### Edit Your Profile
1. Tap **gear icon** (top-right)
2. Tap **Edit** in Profile section
3. Change any field
4. Tap **Save**

### Regenerate Content
1. Go to **Settings**
2. Tap **Regenerate** next to Routine or Prep Pack
3. New mock data is generated

## 📂 File Structure at a Glance

```
InterviewPrepApp/
├── Models/                    # Data structures
│   ├── UserProfile.swift     # User info
│   ├── Routine.swift         # Weekly schedule
│   ├── DailyTask.swift       # Task tracking
│   └── PrepPack.swift        # Interview prep
│
├── Services/                  # Business logic
│   ├── AppState.swift        # Global state
│   ├── StorageService.swift  # JSON persistence
│   └── NetworkService.swift  # API (mock data)
│
├── Views/                     # UI screens
│   ├── Onboarding/           # 5-step flow
│   ├── Home/                 # 3 main tabs
│   └── Settings/             # Profile & settings
│
└── Utils/                     # Helper code
```

## 🔧 Common Tasks

### Reset the App
1. Settings → Scroll to bottom
2. Tap "Reset All Data"
3. Confirm
4. App returns to onboarding

### Add a Note to a Task
1. Today tab → Tap a task to expand
2. Tap "Add Note" at bottom
3. Type your note
4. Tap "Save"

### View Resources for a Task
1. Expand any task card
2. Scroll to "Resources:" section
3. See list of learning materials

### Check Statistics
1. Go to Settings
2. See "Statistics" section
3. View streak and completion data

## 💡 Understanding the Data

### Where Data is Stored
- **Location**: App's Documents directory
- **Format**: JSON files
- **Files**:
  - `user_profile.json` - Your profile
  - `routine.json` - Weekly schedule
  - `prep_pack.json` - Interview prep
  - `daily_tasks.json` - Task completion
  - `streak_data.json` - Streak info

### Mock Data
Currently, all content is **mock data**:
- Weekly schedules are hardcoded
- Resources are sample links
- Practice questions are examples

**When backend is connected**, this will be AI-generated!

## 🎨 UI Components

### Cards
- **Rounded corners** (12pt)
- **Subtle shadows**
- **Tap to expand** (most cards)

### Colors
- **Blue**: Primary actions
- **Orange**: Streaks
- **Green**: Completed tasks
- **Gray**: Pending items

### Icons
- All icons from **SF Symbols**
- Category-specific colors
- Consistent throughout app

## 🐛 Troubleshooting

### Build Fails
```bash
# Clean build folder
⇧⌘K (Shift + Cmd + K)

# Rebuild
⌘B (Cmd + B)
```

### Simulator Not Responding
1. Simulator → Device → Erase All Content and Settings
2. Quit Xcode
3. Reopen and run

### Files Not Found
1. Check all files are in correct folders
2. File Inspector → Target Membership → Check "InterviewPrepApp"
3. Clean and rebuild

### App Crashes on Launch
1. Check Xcode console for errors
2. Verify all Swift files compile
3. Check for missing imports

## 📚 Learn More

- **FEATURES.md** - Complete feature list
- **PROJECT_STRUCTURE.md** - Architecture details
- **SETUP.md** - Detailed setup guide
- **README.md** - Project overview

## 🔜 Next Steps

### For Development
1. ✅ Run the app and test all features
2. ✅ Familiarize yourself with the code
3. ✅ Review the mock data in `NetworkService.swift`
4. 🔲 Plan backend integration
5. 🔲 Design API endpoints
6. 🔲 Replace mock functions with real API calls

### For Backend Integration
When ready to connect to your Node.js backend:

1. **Update NetworkService.swift**:
   ```swift
   // Change this:
   private let baseURL = "http://localhost:3000/api"
   
   // To your backend URL:
   private let baseURL = "https://your-backend.com/api"
   ```

2. **Replace mock functions** with real API calls:
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

3. **Add error handling**:
   ```swift
   do {
       let routine = try await networkService.generateRoutine(profile: profile)
       appState.saveRoutine(routine)
   } catch {
       // Show error to user
       print("Error: \(error)")
   }
   ```

## 🎉 Success!

You now have a fully functional iOS interview prep app!

**Key Achievements:**
- ✅ Beautiful SwiftUI interface
- ✅ Complete onboarding flow
- ✅ Weekly schedule management
- ✅ Daily task tracking with streaks
- ✅ Interview prep resources
- ✅ Local data persistence
- ✅ Profile editing
- ✅ Settings and statistics

**Ready for backend when you are!**

---

## 📞 Need Help?

1. Check the console in Xcode (⇧⌘Y)
2. Review error messages
3. Check file locations
4. Verify target membership
5. Clean and rebuild

## 🎯 Testing Checklist

Quick test to verify everything works:

- [ ] App launches without errors
- [ ] Onboarding completes successfully
- [ ] Home screen shows 3 tabs
- [ ] Week view displays schedule
- [ ] Today view shows tasks
- [ ] Task status can be changed
- [ ] Streak updates when task completed
- [ ] Prep view shows resources
- [ ] Settings displays profile
- [ ] Edit profile works
- [ ] Data persists after app restart

If all checked, you're good to go! 🚀

