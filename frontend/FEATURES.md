# Interview Prep App - Feature Overview

## MVP Features Implemented ✅

### 1. Onboarding Flow (5 Steps)

**Step 1: Welcome**
- App introduction
- Feature highlights
- Visual design with icons

**Step 2: Name Input**
- Simple text field
- Validation (non-empty)

**Step 3: Stage & Target Role**
- Academic stage picker (1st year → Career Changer)
- Target role text input (e.g., "iOS SWE")

**Step 4: Time Budget & Schedule**
- Slider for hours per day (0.5 - 8 hours)
- Multi-select for available days
- Visual feedback for selections

**Step 5: Preferred Tools**
- Suggested tools (LeetCode, HackerRank, etc.)
- Custom tool input
- Selected tools display with remove option

**Progress Indicator**
- Progress bar at top
- Back/Next navigation
- "Get Started" on final step

---

### 2. Home Screen (3 Tabs)

#### Tab 1: Week View
**Features:**
- Day selector (Mon-Fri) with today indicator
- Weekly milestones card
- Time-blocked schedule for selected day
- Expandable task cards showing:
  - Time range (start - end)
  - Task title & description
  - Category with icon
  - Resources list

**Empty States:**
- No routine: "Generate Plan" button
- No tasks for day: Encouraging message

#### Tab 2: Today View
**Features:**
- Streak card showing:
  - Current streak (with flame icon)
  - Longest streak
  - Total tasks completed
- Progress card:
  - Completed/total tasks
  - Visual progress bar
  - Completion celebration message
- Task checklist:
  - Status cycling (pending → done → skipped)
  - Task details (time, title, category)
  - Expandable for description & resources
  - Note-taking capability
  - Visual feedback for status

**Empty States:**
- No tasks: "Enjoy your free time" message

#### Tab 3: Prep View
**Features:**
- Practice plan overview
- Topic roadmap cards:
  - Priority indicator (High/Medium/Low)
  - Estimated weeks
  - Expandable subtopics
- Recommended resources:
  - Resource type icons
  - Title, description, URL
  - Clickable links
- Practice questions:
  - Numbered prompts
  - Interview scenarios

**Regeneration Options:**
- Refresh resources
- New practice questions
- Regenerate everything

---

### 3. Settings Screen

**Profile Section:**
- Display name, role, stage
- Edit button → EditProfileView
- Quick stats (time budget, available days)

**Routine Management:**
- Current plan version
- Regenerate button

**Prep Pack Management:**
- Topic & resource count
- Regenerate button

**Statistics:**
- Current streak
- Longest streak
- Total tasks completed

**Data Management:**
- Reset all data (with confirmation)

**App Info:**
- Version number

---

### 4. Edit Profile Screen

**Editable Fields:**
- Name
- Academic stage (picker)
- Target role
- Hours per day (slider)
- Available days (multi-select grid)
- Preferred tools (add/remove)

**Validation:**
- Name required
- Target role required
- At least one available day

**Actions:**
- Cancel (discard changes)
- Save (update profile)

---

## Data Models

### UserProfile
```swift
- id: UUID
- name: String
- currentStage: AcademicStage
- targetRole: String
- timeBudgetHoursPerDay: Double
- availableDays: Set<Weekday>
- preferredTools: [String]
- createdAt, updatedAt: Date
```

### Routine
```swift
- id: UUID
- version: Int
- weeklySchedule: [Weekday: [TimeBlock]]
- weeklyMilestones: [String]
- createdAt, updatedAt: Date
```

### TimeBlock
```swift
- id: UUID
- title: String
- description: String
- startTime, endTime: String
- category: TaskCategory
- resources: [String]
```

### DailyTask
```swift
- id: UUID
- timeBlockId: UUID
- date: Date
- status: TaskStatus
- notes: String?
```

### PrepPack
```swift
- id: UUID
- topicLadder: [PrepTopic]
- practiceCadence: String
- resources: [Resource]
- mockInterviewPrompts: [String]
- createdAt, updatedAt: Date
```

### StreakData
```swift
- currentStreak: Int
- longestStreak: Int
- lastCompletedDate: Date?
- totalTasksCompleted: Int
```

---

## Technical Implementation

### Architecture
- **Pattern**: MVVM with Services
- **State Management**: Combine + @Published
- **UI Framework**: SwiftUI
- **Persistence**: JSON files + UserDefaults
- **Networking**: Async/await (stubbed)

### Services

**AppState** (Global State)
- ObservableObject
- Manages all app data
- Coordinates storage & network
- Handles business logic

**StorageService** (Local Persistence)
- JSON encoding/decoding
- FileManager for file operations
- UserDefaults for flags
- Generic save/load methods

**NetworkService** (API Client)
- Mock data generators
- Async/await API methods
- Ready for backend integration

### Key Features

**Local-First Design**
- All data stored locally
- Works offline
- Instant load times
- No authentication required

**Streak Tracking**
- Automatic calculation
- Daily completion detection
- Longest streak tracking

**Flexible Regeneration**
- Full routine regeneration
- Partial updates (resources, prompts)
- Version tracking

**Data Versioning**
- Routine versions
- Update timestamps
- Migration-ready structure

---

## User Flows

### First-Time User
1. Launch app → Onboarding
2. Complete 5 steps (< 2 min)
3. App generates mock routine & prep pack
4. Land on Today tab
5. See today's tasks & streak (0 days)

### Returning User
1. Launch app → Home screen
2. See Today tab by default
3. Check tasks, update status
4. Streak updates automatically
5. Navigate between tabs

### Editing Profile
1. Home → Settings (gear icon)
2. Profile section → Edit button
3. Modify fields
4. Save → Returns to settings

### Regenerating Content
1. Settings → Regenerate buttons
2. Or Prep tab → Refresh buttons
3. New content generated
4. UI updates automatically

---

## Mock Data Examples

### Sample Weekly Schedule
- **Monday**: Arrays & Strings, Coding Practice
- **Tuesday**: Linked Lists, Behavioral Prep
- **Wednesday**: Stack & Queue, Project Work
- **Thursday**: Trees & Graphs, Mock Interview
- **Friday**: Weekly Review, System Design Reading

### Sample Topics
1. Data Structures & Algorithms (High priority, 8 weeks)
2. Swift & iOS Development (High priority, 6 weeks)
3. System Design (Medium priority, 4 weeks)
4. Behavioral Interview (High priority, 2 weeks)

### Sample Resources
- LeetCode (Practice platform)
- Cracking the Coding Interview (Book)
- Swift Documentation (Documentation)
- iOS Interview Questions (Article)
- System Design Primer (Course)

### Sample Practice Questions
- "Implement a function to reverse a linked list..."
- "Design a simple cache with LRU eviction policy..."
- "Tell me about a time you had to debug a difficult issue..."
- "How would you design the architecture for an offline-first iOS app?"
- "Implement a binary search tree and write a method to validate..."

---

## Design Highlights

### Color Scheme
- Primary: Blue (iOS default)
- Accent: Orange (streaks)
- Categories: Blue, Purple, Green, Orange, Pink, Indigo, Red, Teal

### Icons
- SF Symbols throughout
- Consistent iconography
- Category-specific icons

### Layout
- Card-based design
- Generous spacing
- Rounded corners (12pt)
- Subtle shadows

### Interactions
- Expandable cards
- Status cycling (tap to change)
- Sheet modals for editing
- Confirmation dialogs

### Animations
- Spring animations
- Smooth transitions
- Progress bar animations

---

## Future Enhancements (Post-MVP)

### Backend Integration
- [ ] Connect to Node.js API
- [ ] Real AI-generated plans
- [ ] User authentication
- [ ] Cloud sync

### Enhanced Features
- [ ] Push notifications (daily reminders)
- [ ] Calendar integration
- [ ] Progress analytics & charts
- [ ] Social features (share progress)
- [ ] Custom themes
- [ ] iPad support
- [ ] Widget support
- [ ] Apple Watch companion

### Content Improvements
- [ ] More resource types
- [ ] Video tutorials
- [ ] Community-sourced tips
- [ ] Interview question bank
- [ ] Company-specific prep

### Technical Improvements
- [ ] Unit tests
- [ ] UI tests
- [ ] Error handling UI
- [ ] Offline queue for API calls
- [ ] Data migration system
- [ ] Performance monitoring

---

## Success Metrics (Future)

- **Day-1 Value**: User completes onboarding in < 2 minutes ✅
- **Engagement**: User checks app daily
- **Retention**: User maintains 7-day streak
- **Completion**: User marks 80%+ tasks as done
- **Satisfaction**: User regenerates content < 3 times

---

## Known Limitations

1. **Mock Data**: All content is hardcoded (no AI generation yet)
2. **No Backend**: No server communication
3. **No Auth**: No user accounts or cloud sync
4. **No Notifications**: No reminders
5. **iPhone Only**: No iPad optimization
6. **Portrait Only**: No landscape support

These are intentional for MVP and will be addressed in future iterations.

---

## Accessibility

- VoiceOver support (via SwiftUI defaults)
- Dynamic Type support
- High contrast mode compatible
- Semantic colors
- Descriptive labels

---

## Testing Checklist

### Onboarding
- [ ] Complete all 5 steps
- [ ] Back navigation works
- [ ] Validation prevents empty fields
- [ ] Data persists after completion

### Week View
- [ ] Day selector works
- [ ] Tasks display correctly
- [ ] Expand/collapse works
- [ ] Empty states show

### Today View
- [ ] Streak displays correctly
- [ ] Progress bar updates
- [ ] Task status cycling works
- [ ] Notes can be added/edited

### Prep View
- [ ] Topics display with priorities
- [ ] Resources are clickable
- [ ] Regeneration works

### Settings
- [ ] Profile displays correctly
- [ ] Edit profile works
- [ ] Stats are accurate
- [ ] Reset data works

### Persistence
- [ ] Data survives app restart
- [ ] Streak persists
- [ ] Task status persists
- [ ] Profile changes persist

---

## Developer Notes

**Code Quality:**
- SwiftUI best practices
- Proper separation of concerns
- Reusable components
- Type-safe models
- Error handling (basic)

**Performance:**
- Lazy loading in lists
- Efficient state updates
- Minimal re-renders
- Optimized JSON encoding

**Maintainability:**
- Clear file organization
- Descriptive naming
- Comments where needed
- Modular architecture

**Scalability:**
- Easy to add new features
- Backend-ready structure
- Extensible models
- Version tracking

---

## Conclusion

This MVP provides a complete, functional iOS app for interview prep with:
- ✅ Beautiful, native SwiftUI UI
- ✅ Complete onboarding flow
- ✅ Weekly routine display
- ✅ Daily task tracking with streaks
- ✅ Interview prep resources
- ✅ Local data persistence
- ✅ Profile editing
- ✅ Settings & statistics

**Ready for backend integration when needed!**

