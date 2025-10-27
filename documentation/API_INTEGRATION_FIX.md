# API Integration Fix

## Problem Identified

The app was **NOT making any real API requests** to the backend. Instead, it was only returning mock data from `NetworkService`.

### What Was Wrong

1. **Two separate networking layers existed:**
   - `APIClient` - Complete, production-ready HTTP client that makes real API calls
   - `NetworkService` - Only returned mock data, never called the backend

2. **NetworkService was being used everywhere** but it only returned mock data with simulated delays

3. **No actual HTTP requests** were being sent to the backend endpoints at `http://localhost:8081`

## Solution

### Updated NetworkService

`NetworkService` now:
1. ✅ **Uses `APIClient` internally** to make real HTTP requests
2. ✅ **Converts between API models and app models** automatically
3. ✅ **Supports both mock and real modes** via a flag
4. ✅ **Has detailed logging** to show what's happening

### Architecture Flow

```
User Profile (app model)
    ↓
NetworkService.generateRoutine()
    ↓
APIProfile.from(profile)  [Convert to API model]
    ↓
APIClient.generateRoutine()  [REAL HTTP POST to /generate/routine]
    ↓
APIPlan (API response)
    ↓
convertToRoutine(apiPlan)  [Convert back to app model]
    ↓
Routine (app model)
```

## How to Use

### Mock Mode (Default - for testing)

```swift
// Default: Uses mock data with 8-second delays
let service = NetworkService.shared
```

This mode:
- Returns mock data after 8-second delay
- No backend needed
- Good for testing UI/UX flow

### Real API Mode

```swift
// Create NetworkService with real API enabled
let service = NetworkService(useMockData: false)

// OR modify the shared instance default in NetworkService.swift:
init(apiClient: APIClient? = nil, useMockData: Bool = false) {
    //                                              ^^^^^ change to false
```

This mode:
- Makes real HTTP requests to backend
- Requires backend server running at `http://localhost:8081`
- Real OpenAI API calls (can be slow, 10-30 seconds)

### Backend Setup

Before enabling real API mode, make sure the backend is running:

```bash
cd backend/server
npm install
npm start
```

Backend will be available at: `http://localhost:8081`

Test with:
```bash
curl http://localhost:8081/health
```

## API Endpoints Used

### 1. Generate Routine
- **Endpoint:** `POST /generate/routine`
- **Request:**
  ```json
  {
    "profile": {
      "name": "Alex",
      "stage": "2nd Year",
      "targetRole": "iOS Engineer",
      "timeBudgetHoursPerDay": 2.0,
      "availableDays": ["Mon", "Tue", "Wed", "Thu", "Fri"],
      "constraints": ["SwiftUI", "Combine"]
    }
  }
  ```
- **Response:** APIPlan with timeBlocks, milestones, resources

### 2. Generate Prep Pack
- **Endpoint:** `POST /generate/prep`
- **Request:** Same profile structure
- **Response:** APIPrep with prepOutline, weeklyDrillPlan, starterQuestions, resources

## Verification

### Check if Real API Calls Are Working

Look for these logs in Xcode console:

#### Mock Mode:
```
⚠️ NetworkService: Running in MOCK mode (no real API calls)
🌐 NetworkService.generateRoutine called
   - Mock mode: true
   - Using MOCK data (8 second delay)
```

#### Real API Mode:
```
✅ NetworkService: Running in REAL API mode
   Backend URL: http://localhost:8081
🌐 NetworkService.generateRoutine called
   - Mock mode: false
   - Making REAL API call to backend...
   - ✅ API response received, converting to Routine
```

### Check Backend Logs

When real API calls are made, you should see in backend terminal:
```
POST /generate/routine 200 15234ms
POST /generate/prep 200 12456ms
```

## Configuration

### API Base URL

The base URL is configured in `APIConfig.swift`:
- **Simulator:** `http://localhost:8081`
- **Physical Device:** Needs your Mac's local IP (e.g., `http://192.168.1.100:8081`)

### Timeouts

- Request timeout: 30 seconds (configured in `APIConfig.requestTimeout`)
- Retries: 3 attempts with exponential backoff (0.5s, 1s, 2s)

## Testing Checklist

- [ ] Backend server is running on port 8081
- [ ] Can access `/health` endpoint
- [ ] Set `useMockData = false` in NetworkService
- [ ] Complete onboarding flow
- [ ] Check Xcode console for "Making REAL API call" logs
- [ ] Verify backend logs show POST requests
- [ ] Loading screen shows realistic progress (varies based on OpenAI response time)
- [ ] Both routine AND prep pack are generated
- [ ] Data is saved to AppState correctly

## Next Steps

1. **Start backend:** `cd backend/server && npm start`
2. **Enable real API mode** by changing default in NetworkService.swift
3. **Test the flow** end-to-end
4. **Monitor logs** in both Xcode and backend terminal

## Files Modified

- `NetworkService.swift` - Now uses APIClient for real HTTP requests
- `LoadingViewExample.swift` - Already set up to handle real API timing
- `APIClient.swift` - Already had full HTTP implementation (no changes needed)

## Notes

- Mock mode is useful for UI development without backend
- Real API mode requires OpenAI API key configured in backend
- Real API calls take 10-30 seconds depending on OpenAI response time
- Progress simulation in LoadingCoordinator will automatically adapt to real timing

