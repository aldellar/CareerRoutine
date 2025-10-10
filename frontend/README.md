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
frontend/
├── docs/                    # Documentation
│   ├── architecture.md      # Architecture overview
│   ├── backend-integration.md
│   ├── features.md
│   ├── project-structure.md
│   ├── quick-reference.md
│   ├── quick-start.md
│   ├── setup.md
│   └── xcode-fix.md
├── ios/                     # iOS Application
│   └── InterviewPrepApp/
│       ├── InterviewPrepApp/     # App source code
│       │   ├── Models/           # Data models
│       │   ├── Views/            # SwiftUI views
│       │   ├── ViewModels/       # View models
│       │   ├── Networking/       # API client & models
│       │   ├── Services/         # Business logic
│       │   └── Utils/            # Helpers and extensions
│       ├── InterviewPrepApp.xcodeproj/
│       └── InterviewPrepAppTests/
└── README.md
```

## Getting Started

1. Open `ios/InterviewPrepApp/InterviewPrepApp.xcodeproj` in Xcode
2. Select your target device/simulator
3. Build and run (⌘R)

## Tech Stack

- SwiftUI for UI
- Combine for reactive programming
- FileManager for JSON storage
- UserDefaults for preferences
- URLSession for networking (future backend integration)

## MVP Scope

This app is now fully integrated with the Node.js backend for AI-powered plan generation.

---

## iOS → Backend Wiring

### Architecture Overview

The iOS app connects to the Node.js backend running at `http://localhost:8081` (DEBUG) or a production URL (RELEASE). The networking layer provides:

- **Clean API abstraction** via `APIClient`
- **Environment-based configuration** (DEBUG/RELEASE)
- **Comprehensive error handling** with humanized messages
- **Retry logic** with exponential backoff for transient errors
- **Timeout protection** (15 seconds default)
- **Offline detection** via `NWPathMonitor`
- **Cancellation support** for in-flight requests

### Core Components

#### 1. Networking Layer (`Networking/`)

- **`APIClient.swift`**: Main networking client with async/await
  - `health()` - Health check endpoint
  - `generateRoutine(profile:)` - Generate weekly plan
  - `generatePrep(profile:)` - Generate prep pack
  - `reroll(section:profile:currentPlan:)` - Reroll specific sections

- **`APIError.swift`**: Comprehensive error types
  - `.networkUnavailable` - Offline/connection lost
  - `.timeout` - Request exceeded 15s
  - `.server(status:message:)` - 4xx/5xx errors
  - `.decoding(message:)` - JSON decode failures
  - `.invalidURL` - Malformed URLs
  - `.cancelled` - User/system cancelled
  - `.unknown(underlying:)` - Catch-all

- **`APIError+Display.swift`**: Human-readable error messages
  ```swift
  error.displayMessage // "The request took too long. Please try again."
  error.isRetryable    // true for 5xx, timeouts, network issues
  ```

- **`Config.swift`**: Environment configuration
  - DEBUG: `http://localhost:8081`
  - RELEASE: Reads from `Info.plist` key `API_BASE_URL`
  - Override: `UserDefaults` key `api_base` (for testing)

- **`Reachability.swift`**: Network status monitoring
  ```swift
  @Published var isOnline: Bool
  ```

#### 2. API Models (`Networking/Models/`)

Models that match backend JSON schemas:

- **`APIProfile.swift`**: User profile for API requests
  ```swift
  struct APIProfile: Codable {
      let name: String
      let stage: String
      let targetRole: String
      let timeBudgetHoursPerDay: Double
      let availableDays: [String]  // ["Mon", "Tue", ...]
      let constraints: [String]?
  }
  ```

- **`APIPlan.swift`**: Weekly plan response
  ```swift
  struct APIPlan: Codable {
      let weekOf: String  // "2025-10-13"
      let timeBlocks: [String: [APITimeBlock]]
      let dailyTasks: [String: [String]]
      let milestones: [String]
      let resources: [APIResource]
      let version: Int
  }
  ```

- **`APIPrep.swift`**: Prep pack response
  ```swift
  struct APIPrep: Codable {
      let prepOutline: [OutlineSection]
      let weeklyDrillPlan: [DrillDay]
      let starterQuestions: [String]
      let resources: [APIResource]
  }
  ```

#### 3. State Management (`Utils/`)

- **`Loadable.swift`**: Async operation state wrapper
  ```swift
  enum Loadable<T> {
      case idle
      case loading
      case loaded(T)
      case failed(APIError)
  }
  ```

- **`AlertState.swift`**: Error presentation helper
  ```swift
  let alert = AlertState.error(apiError) { retry() }
  ```

#### 4. ViewModels (`ViewModels/`)

- **`WeekViewModel`**: Weekly plan generation
  ```swift
  @Published var planState: Loadable<Routine>
  func generatePlan(profile: UserProfile)
  ```

- **`PrepViewModel`**: Prep pack generation
  ```swift
  @Published var prepState: Loadable<PrepPack>
  func generatePrep(profile: UserProfile)
  ```

- **`RerollViewModel`**: Section rerolling
  ```swift
  func rerollResources(profile:currentPlan:) async -> Routine?
  func rerollTimeBlocks(profile:currentPlan:) async -> Routine?
  func rerollDailyTasks(profile:currentPlan:) async -> Routine?
  ```

### Environment Configuration

#### DEBUG Build (Default)
- Base URL: `http://localhost:8081`
- Developer tools enabled in Settings
- API override available via `UserDefaults`

#### RELEASE Build
- Base URL: Read from `Info.plist` → `API_BASE_URL`
- Update `Info.plist` before production builds:
  ```xml
  <key>API_BASE_URL</key>
  <string>https://your-production-api.com</string>
  ```

#### Runtime Override (DEBUG only)
In Settings → Developer Tools:
1. Enter custom base URL
2. Restart app for changes to take effect
3. URL stored in `UserDefaults` key `api_base`

### Testing the Integration

#### 1. Start the Backend
```bash
cd backend/server
npm install
npm start
# Server runs on http://localhost:8081
```

#### 2. Launch the iOS App
- Open `InterviewPrepApp.xcodeproj`
- Run in simulator (⌘R)
- Ensure simulator can reach `localhost:8081`

#### 3. Use Developer Tools (DEBUG only)

Navigate to **Settings → Developer Tools**:

- **Ping Health Endpoint**: Test server connectivity
  - ✓ Server is healthy (200 OK)
  - ✗ Server unavailable

- **Generate Plan (Sample Profile)**: Generate with test data
  - Calls `POST /generate/routine`
  - Shows loading spinner
  - Saves locally on success
  - Shows error alert on failure

- **Generate Prep (Sample Profile)**: Generate prep pack
  - Calls `POST /generate/prep`

- **Load Stub Plan Locally**: Use mock data (no server needed)

- **API Base URL Override**: Change endpoint without rebuilding

#### 4. Production Flow

1. Complete onboarding (create profile)
2. Go to **Week** tab
3. Tap **Generate Plan**
   - Shows loading spinner
   - Offline? Shows "Offline" banner (button disabled)
   - Success? Shows plan + "Saved" banner
   - Error? Shows alert with retry option
4. Go to **Prep** tab
5. Tap **Generate Prep Pack**
   - Same loading/error flow

### Error Handling Examples

#### Timeout (15s exceeded)
```
Alert: "Timeout"
Message: "The request took too long. Please try again."
Action: [Retry] [Cancel]
```

#### Offline
```
Banner: "🚫 Offline"
Button: Disabled (grayed out)
```

#### Server Error (500)
```
Alert: "Server Error (500)"
Message: "Server issue. Please try again shortly."
Action: [Retry] [Cancel]
```

#### Decoding Error
```
Alert: "Data Error"
Message: "Data error: keyNotFound(...)"
Action: [OK]
```

### Retry Logic

Automatic retries (exponential backoff) for:
- 5xx server errors
- Network connection lost
- Timeouts

Retry delays: **200ms → 500ms → 1s**

No retry for:
- 400, 401, 403, 404 (client errors)
- Decoding errors
- Invalid URL
- Cancelled requests

### Cancellation

- ViewModels cancel in-flight requests on `deinit`
- User can navigate away during loading (auto-cancel)
- Respects `Task.isCancelled` to avoid stale updates

### Unit Tests

Run tests: **⌘U** in Xcode

`APIClientTests.swift` includes:
- ✓ Health check success/failure
- ✓ Generate routine success
- ✓ 400/500 error mapping
- ✓ Timeout error mapping
- ✓ Network unavailable mapping
- ✓ Decoding error handling

Mock URLSession allows testing without network:
```swift
mockSession.mockResponse = HTTPURLResponse(statusCode: 200)
mockSession.mockData = encodedPlan
let result = try await apiClient.generateRoutine(profile: profile)
```

### Troubleshooting

#### "Server unavailable" in simulator
- Check backend is running: `curl http://localhost:8081/health`
- iOS simulator should reach localhost
- If using physical device, update to computer's IP:
  ```
  Settings → Developer Tools → API Base URL Override
  http://192.168.1.100:8081
  ```

#### "Decoding error"
- Backend response doesn't match schema
- Check `backend/server/src/schemas/*.json`
- Verify API models match (`APIProfile`, `APIPlan`, `APIPrep`)

#### "Timeout" on slow responses
- Adjust timeout in `Config.swift`:
  ```swift
  static let requestTimeout: TimeInterval = 30.0  // Increase
  ```

#### Xcode can't find new files
- Add files to Xcode project target
- Check "Copy items if needed"
- Verify target membership in File Inspector

### Next Steps

- Add authentication (JWT tokens)
- Implement offline queue for failed requests
- Add telemetry/analytics
- Optimize image caching for resources
- Add push notifications for streak reminders

