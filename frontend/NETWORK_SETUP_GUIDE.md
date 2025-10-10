# iOS App Network Setup Guide

## Problems Fixed

### 1. **Blank Home Page** ✅
- **Issue**: After generating a schedule, `AppState` wasn't updated
- **Fix**: `WeekViewModel` now updates both storage and `AppState`

### 2. **No Server Requests** ✅
- **Issue**: `localhost` doesn't work on physical iPhones (it refers to the phone itself)
- **Fix**: Added device detection and configuration instructions

### 3. **Potential Crashes** ✅
- **Issue**: Network errors weren't properly handled
- **Fix**: Improved error handling and increased timeout for OpenAI API calls

## How to Test

### Testing on Simulator

1. **Start your backend server:**
   ```bash
   cd backend/server
   npm run dev
   ```

2. **Look for the network addresses in the terminal:**
   ```
   📱 iOS App Configuration:
   ─────────────────────────────────────
   Simulator:      http://localhost:8081
   Physical Device:
                   http://192.168.1.100:8081  <-- Use this for your phone
   ─────────────────────────────────────
   ```

3. **Run the app in Xcode on Simulator**
   - It will automatically use `http://localhost:8081`
   - Complete onboarding
   - Click "Generate Plan" button
   - You should see the server receive a POST request

### Testing on Physical iPhone

1. **Make sure both your Mac and iPhone are on the SAME WiFi network**

2. **Note the IP address** shown when your server starts (e.g., `192.168.1.100`)

3. **In the iOS app:**
   - Open the app
   - Go to **Settings** (bottom right)
   - Scroll down to **Developer Tools** section
   - Under "API Base URL Override", enter: `http://YOUR_IP:8081`
   - Example: `http://192.168.1.100:8081`
   - Restart the app

4. **Test the connection:**
   - Still in Settings, tap "Ping Health Endpoint"
   - Should show "✅ OK" if connected

5. **Generate schedule:**
   - Go to home page
   - Click "Generate Plan"
   - Check your Mac terminal for the incoming request

## Troubleshooting

### "Connection Failed" or "Timeout"

**Check 1: Same WiFi?**
- Mac and iPhone must be on the same WiFi network
- Corporate/School WiFi may block device-to-device communication

**Check 2: Server Running?**
```bash
# In backend/server directory
npm run dev
# Should show: "Server started successfully"
```

**Check 3: Firewall?**
- macOS Firewall might block incoming connections
- Go to: System Settings → Network → Firewall
- Allow Node.js or disable temporarily for testing

**Check 4: Correct IP?**
- IP addresses can change when you reconnect to WiFi
- Always check the IP shown in the server terminal
- Update in Settings if it changed

### "No response" or App Hangs

**OpenAI API Key Missing?**
```bash
# In backend/server directory
cat .env
# Should have: OPENAI_API_KEY=sk-...
```

If missing:
```bash
cp env.example .env
# Edit .env and add your OpenAI API key
```

### Request Timeout (30 seconds)

OpenAI API calls can take 10-20 seconds, especially for complex schedules. This is normal!
- The timeout is set to 30 seconds
- You'll see a loading spinner while it works

## Quick Reference

### URLs by Device Type

| Device Type | URL |
|------------|-----|
| **iOS Simulator** | `http://localhost:8081` (automatic) |
| **Physical iPhone** | `http://YOUR_MAC_IP:8081` (set in Settings) |

### Finding Your Mac's IP Address

**Option 1: From the server terminal**
- The IP is shown when the server starts

**Option 2: System Settings**
- Open System Settings/Preferences
- Click "Network"
- Select your WiFi connection
- IP address is shown on the right

**Option 3: Terminal**
```bash
ipconfig getifaddr en0    # WiFi on most Macs
# or
ifconfig | grep "inet " | grep -v 127.0.0.1
```

## Expected Server Logs

When the app makes a request, you should see:

```
[timestamp] INFO: Incoming request
    method: "POST"
    path: "/generate/routine"
    traceId: "..."
    
[timestamp] INFO: Generating routine
    
[timestamp] INFO: Calling OpenAI API
    model: "gpt-4o-mini"
    
[timestamp] INFO: OpenAI API call successful
    tokens: 1234
    
[timestamp] INFO: Routine generated successfully

[timestamp] INFO: Response sent
    statusCode: 200
```

## Testing Checklist

- [ ] Backend server is running
- [ ] OpenAI API key is configured in `.env`
- [ ] Mac and iPhone are on same WiFi (for physical device)
- [ ] Correct IP address set in Settings (for physical device)
- [ ] Health check passes (green ✅)
- [ ] Generate schedule button appears
- [ ] Server receives POST request
- [ ] Schedule displays after generation
- [ ] Home page shows the generated schedule

## Need Help?

1. Check the server terminal for error messages
2. Check Xcode console for iOS errors
3. Try the Health Check in Settings first
4. Make sure you're not on corporate WiFi (may block connections)

