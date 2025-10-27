# iOS App Architecture

## Overview

Clean architecture with separation of concerns, testability, and robust error handling.

---

## Layer Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  WeekView    │  │  PrepView    │  │ SettingsView │      │
│  │  (SwiftUI)   │  │  (SwiftUI)   │  │  (SwiftUI)   │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                  │                  │               │
│         └──────────────────┼──────────────────┘               │
└────────────────────────────┼──────────────────────────────────┘
                             │
┌────────────────────────────┼──────────────────────────────────┐
│                     VIEW MODEL LAYER                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │WeekViewModel │  │PrepViewModel │  │RerollViewModel│       │
│  │              │  │              │  │              │       │
│  │@Published    │  │@Published    │  │@Published    │       │
│  │planState     │  │prepState     │  │isRerolling   │       │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘       │
│         │                  │                  │               │
│         └──────────────────┼──────────────────┘               │
└────────────────────────────┼──────────────────────────────────┘
                             │
┌────────────────────────────┼──────────────────────────────────┐
│                      NETWORKING LAYER                         │
│                    ┌──────▼───────┐                           │
│                    │  APIClient   │                           │
│                    │   (Actor)    │                           │
│                    │              │                           │
│                    │ - health()   │                           │
│                    │ - generate() │                           │
│                    │ - reroll()   │                           │
│                    └──────┬───────┘                           │
│                           │                                   │
│    ┌──────────────────────┼──────────────────────┐           │
│    │                      │                      │           │
│ ┌──▼──────┐        ┌──────▼──────┐       ┌──────▼──────┐    │
│ │APIError │        │   Config    │       │Reachability │    │
│ └─────────┘        └─────────────┘       └─────────────┘    │
└────────────────────────────┬──────────────────────────────────┘
                             │
┌────────────────────────────┼──────────────────────────────────┐
│                      FOUNDATION LAYER                         │
│                    ┌──────▼───────┐                           │
│                    │  URLSession  │                           │
│                    └──────┬───────┘                           │
│                           │                                   │
│                    ┌──────▼───────┐                           │
│                    │   Backend    │                           │
│                    │ :8081        │                           │
│                    └──────────────┘                           │
└───────────────────────────────────────────────────────────────┘
```

---

## Data Flow

### 1. User Action → API Call → UI Update

```
User taps              ViewModel receives       ViewModel calls
"Generate Plan"        action                   APIClient
     │                      │                        │
     ▼                      ▼                        ▼
┌────────┐            ┌────────┐              ┌────────┐
│WeekView│───tap───▶  │ Week   │──async call─▶│  API   │
│        │            │ViewModel              │ Client │
└────────┘            │        │              │        │
                      │ State: │              │ Actor  │
                      │.loading│              │        │
                      └────────┘              └───┬────┘
                           ▲                      │
                           │                      │
                           │    ┌─────────────────┘
                           │    │ HTTP POST
                           │    ▼
                           │ ┌────────┐
                           │ │Backend │
                           │ │        │
                           │ └────┬───┘
                           │      │ Response
                           └──────┘
                      Success/Error
```

### 2. State Machine

```
┌─────┐
│Idle │ ◀──┐
└──┬──┘    │
   │ generatePlan()
   ▼       │
┌────────┐ │
│Loading │ │
└───┬────┘ │
    │      │
    ├──────┴────────┐
    │               │
Success           Error
    │               │
    ▼               ▼
┌────────┐    ┌─────────┐
│Loaded  │    │ Failed  │
│(Plan)  │    │(APIError)│
└────────┘    └─────────┘
```

---

## Component Responsibilities

### Views (UI)
- **Responsibility**: Render UI, handle user input
- **No business logic**: Delegate to ViewModels
- **Examples**: `WeekView`, `PrepView`, `SettingsView`

### ViewModels (State + Logic)
- **Responsibility**: State management, API calls, persistence
- **Published properties**: Reactive UI updates
- **Examples**: `WeekViewModel`, `PrepViewModel`

### APIClient (Network)
- **Responsibility**: HTTP requests, retry logic, error mapping
- **Actor-based**: Thread-safe, async/await
- **Example**: `APIClient.generateRoutine(profile:)`

### Models (Data)
- **API Models**: Match backend schema (`APIProfile`, `APIPlan`)
- **UI Models**: Rich models for UI (`UserProfile`, `Routine`)
- **Conversion**: ViewModels convert between API ↔ UI models

---

## Error Handling Flow

```
┌──────────┐
│URLSession│
│ .data()  │
└────┬─────┘
     │
     ├─ Success ──▶ Decode JSON ──▶ Return T
     │
     ├─ URLError.timedOut ──▶ APIError.timeout
     │
     ├─ URLError.notConnectedToInternet ──▶ APIError.networkUnavailable
     │
     ├─ HTTPURLResponse(400) ──▶ APIError.server(400, message)
     │
     ├─ HTTPURLResponse(500) ──▶ Retry with backoff
     │                              │
     │                              ▼
     │                         (200ms, 500ms, 1s)
     │                              │
     │                              ├─ Success ──▶ Return T
     │                              │
     │                              └─ Final fail ──▶ APIError.server(500)
     │
     └─ DecodingError ──▶ APIError.decoding(message)
```

---

## Dependency Injection

### Testing
```swift
// Production
let apiClient = APIClient(
    session: URLSession.shared,
    baseURL: APIConfig.baseURL
)

// Testing
let mockSession = MockURLSession()
mockSession.mockResponse = HTTPURLResponse(statusCode: 200)
mockSession.mockData = mockPlanData

let apiClient = APIClient(
    session: mockSession,
    baseURL: URL(string: "http://test.com")!
)
```

### ViewModels
```swift
// Production
let viewModel = WeekViewModel()

// Testing
let mockClient = APIClient(session: MockURLSession())
let mockStorage = StorageService()
let viewModel = WeekViewModel(
    apiClient: mockClient,
    storage: mockStorage
)
```

---

## Thread Safety

### Actor-based APIClient
```swift
actor APIClient {
    // All properties isolated to actor
    private let session: URLSessionProtocol
    private let baseURL: URL
    
    // Methods automatically run on actor
    func generateRoutine(...) async throws -> APIPlan {
        // Thread-safe by default
    }
}
```

### MainActor ViewModels
```swift
@MainActor
class WeekViewModel: ObservableObject {
    // Always runs on main thread
    @Published var planState: Loadable<Routine>
    
    func generatePlan(profile: UserProfile) {
        Task {
            // Actor calls happen on actor thread
            let plan = try await apiClient.generateRoutine(...)
            
            // UI updates back on main thread
            planState = .loaded(plan)
        }
    }
}
```

---

## Retry Strategy

```
Request fails
     │
     ▼
Is retryable? ─No──▶ Throw error
     │
    Yes
     │
     ▼
Attempt 1 ─Fail─▶ Wait 200ms ─▶ Retry
     │
  Success ──▶ Return
     │
    Fail
     │
     ▼
Attempt 2 ─Fail─▶ Wait 500ms ─▶ Retry
     │
  Success ──▶ Return
     │
    Fail
     │
     ▼
Attempt 3 ─Fail─▶ Wait 1s ─▶ Retry
     │
  Success ──▶ Return
     │
    Fail ──▶ Throw final error
```

**Retryable errors:**
- 5xx server errors
- Network connection lost
- Timeouts

**Non-retryable errors:**
- 400, 401, 403, 404 (client errors)
- Decoding errors
- Cancelled requests

---

## Configuration Priority

```
1. UserDefaults override (api_base)
   │
   ├─ Has value? ──▶ Use it
   │
   └─ No value
       │
       ▼
2. Build configuration
   │
   ├─ DEBUG? ──▶ http://localhost:8081
   │
   └─ RELEASE
       │
       ▼
3. Info.plist (API_BASE_URL)
   │
   └─▶ Use production URL
```

---

## Testing Strategy

### Unit Tests (APIClient)
```swift
// Mock URLSession
class MockURLSession: URLSessionProtocol {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = mockError { throw error }
        return (mockData!, mockResponse!)
    }
}

// Test success
func testGenerateRoutineSuccess() async throws {
    mockSession.mockResponse = HTTPURLResponse(statusCode: 200)
    mockSession.mockData = validPlanData
    
    let result = try await apiClient.generateRoutine(profile: profile)
    XCTAssertEqual(result.version, 1)
}

// Test error
func testGenerateRoutine500Error() async {
    mockSession.mockResponse = HTTPURLResponse(statusCode: 500)
    mockSession.mockData = errorData
    
    do {
        _ = try await apiClient.generateRoutine(profile: profile)
        XCTFail("Should throw")
    } catch let error as APIError {
        XCTAssertEqual(error, .server(500, "Internal error"))
    }
}
```

### Integration Tests (Manual)
1. Start backend
2. Run app in simulator
3. Use Developer Tools to verify endpoints
4. Test error scenarios (stop server, slow network)

---

## Performance Considerations

### Request Timeout
- Default: 15 seconds
- Configurable in `Config.swift`
- Hard timeout via Task + Task.sleep

### Retry Delays
- 200ms → 500ms → 1s
- Exponential backoff prevents server overload
- Max 3 attempts (1 original + 2 retries)

### Cancellation
- ViewModels cancel on deinit
- Prevents stale updates
- Respects Task.isCancelled

### Memory
- Actor ensures no retain cycles
- Weak self in closures
- No global state

---

## Security Notes

### No Secrets in Code
- URLs configurable (Info.plist, UserDefaults)
- No API keys hardcoded
- Ready for auth tokens (headers)

### HTTPS in Production
```xml
<key>API_BASE_URL</key>
<string>https://your-api.com</string>  <!-- Always HTTPS -->
```

### Error Messages
- Don't leak sensitive info
- Generic messages for users
- Detailed logs for developers

---

## Future Enhancements

1. **Authentication**: Add JWT tokens to headers
2. **Caching**: Cache plans for offline mode
3. **Request Queue**: Queue failed requests for retry on reconnect
4. **Websockets**: Real-time updates
5. **Analytics**: Track API performance
6. **Rate Limiting**: Client-side throttling

---

This architecture provides:
✅ Clean separation of concerns  
✅ Testability via dependency injection  
✅ Thread safety via actors  
✅ Robust error handling  
✅ Reactive UI updates  
✅ Type safety  
✅ Scalability  

