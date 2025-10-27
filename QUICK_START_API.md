# Quick Start: Enable Real API Calls

## Current Status

✅ **NetworkService is now integrated with APIClient**  
⚠️ **Currently running in MOCK mode** (returns fake data, no real API calls)

## To Enable Real API Calls

### Step 1: Start the Backend

```bash
cd backend/server
npm install  # First time only
npm start    # Starts server on port 8081
```

You should see:
```
Server running on port 8081
OpenAI client initialized
```

### Step 2: Verify Backend is Running

```bash
# In a new terminal
curl http://localhost:8081/health
```

Expected response:
```json
{"status":"ok"}
```

### Step 3: Enable Real API Mode in iOS App

Open `NetworkService.swift` and change line 21:

```swift
// BEFORE (mock mode):
init(apiClient: APIClient? = nil, useMockData: Bool = true) {

// AFTER (real API mode):
init(apiClient: APIClient? = nil, useMockData: Bool = false) {
//                                              ^^^^^ change to false
```

### Step 4: Run the App

1. Build and run in Xcode
2. Complete the onboarding flow
3. Watch the Xcode console for:

```
✅ NetworkService: Running in REAL API mode
   Backend URL: http://localhost:8081
🌐 NetworkService.generateRoutine called
   - Mock mode: false
   - Making REAL API call to backend...
```

4. Watch the backend terminal for:

```
POST /generate/routine - Generating routine...
POST /generate/routine 200 12345ms
POST /generate/prep - Generating prep pack...
POST /generate/prep 200 10234ms
```

## Expected Timeline with Real API

- **Routine generation:** 10-30 seconds (depends on OpenAI)
- **Prep pack generation:** 10-30 seconds (depends on OpenAI)
- **Total loading time:** ~20-60 seconds (real AI generation takes time!)

The progress bar will automatically sync with actual response times.

## Troubleshooting

### Backend not responding
```bash
# Check if backend is running
lsof -i :8081

# Check backend logs
cd backend/server
npm start
```

### iOS can't connect to localhost (physical device)
If running on a physical device, you need your Mac's IP address:

1. Find your Mac's IP: System Settings → Network → Your IP (e.g., 192.168.1.100)
2. Set in `APIConfig.swift` or UserDefaults
3. Make sure iPhone and Mac are on same WiFi

### OpenAI API Key not configured
Check `backend/server/.env`:
```env
OPENAI_API_KEY=sk-...
```

### Request timeout
If OpenAI is slow, you might need to increase timeout in `APIConfig.swift`:
```swift
static let requestTimeout: TimeInterval = 60.0  // Increase from 30 to 60
```

## Testing Both Modes

### Test Mock Mode (Fast, No Backend Needed)
```swift
let service = NetworkService(useMockData: true)
// Returns fake data after 8 seconds
```

### Test Real Mode (Slow, Requires Backend)
```swift
let service = NetworkService(useMockData: false)
// Makes real API calls to localhost:8081
```

## Verification Checklist

- [ ] Backend server is running (`curl http://localhost:8081/health`)
- [ ] OpenAI API key is configured in backend `.env`
- [ ] `useMockData` is set to `false` in NetworkService
- [ ] App builds and runs
- [ ] Console shows "REAL API mode" logs
- [ ] Backend logs show POST requests
- [ ] Loading screen takes 20-60 seconds (real AI generation)
- [ ] Both routine and prep pack are generated
- [ ] Can see the generated content after loading completes

## Quick Commands

```bash
# Start backend
cd backend/server && npm start

# Test backend health
curl http://localhost:8081/health

# Test routine generation (replace with your profile data)
curl -X POST http://localhost:8081/generate/routine \
  -H "Content-Type: application/json" \
  -d '{
    "profile": {
      "name": "Test User",
      "stage": "2nd Year",
      "targetRole": "iOS Engineer",
      "timeBudgetHoursPerDay": 2.0,
      "availableDays": ["Mon", "Tue", "Wed", "Thu", "Fri"],
      "constraints": ["SwiftUI"]
    }
  }'
```

## Switching Back to Mock Mode

Just change back to `useMockData: Bool = true` in `NetworkService.swift` line 21.

This is useful for:
- Testing UI without waiting for real API
- Developing when backend isn't running
- Saving OpenAI API costs during development

