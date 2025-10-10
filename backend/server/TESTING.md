# Testing Guide

## 🚀 Quick Test (Automated)

### Step 1: Start the Server

In one terminal window:

```bash
cd backend/server
npm run dev
```

You should see:
```
Server started successfully
  port: 8081
  nodeEnv: "development"
  model: "gpt-4o-mini"
```

### Step 2: Run the Test Script

In a **second terminal window**:

```bash
cd backend/server
./test-api.sh
```

This will test all endpoints and show you:
- ✅ Which tests passed
- ❌ Which tests failed
- 📁 Save full JSON responses for inspection

---

## 🔍 Manual Testing

### Test 1: Health Check

```bash
curl http://localhost:8081/health
```

**Expected Response:**
```json
{
  "status": "ok"
}
```

---

### Test 2: Generate Routine

```bash
curl -X POST http://localhost:8081/generate/routine \
  -H 'Content-Type: application/json' \
  -d '{
    "profile": {
      "name": "Andrew",
      "stage": "recent_grad",
      "targetRole": "iOS Software Engineer",
      "timeBudgetHoursPerDay": 3,
      "availableDays": ["Mon","Tue","Wed","Thu","Fri"],
      "constraints": ["no weekends"]
    }
  }' | jq
```

**Expected Response:**
- HTTP 200
- JSON with `plan` object containing:
  - `weekOf` (date string)
  - `timeBlocks` (object with day keys)
  - `dailyTasks` (object with day keys)
  - `milestones` (array)
  - `resources` (array)
  - `version` (number)

**What to Check:**
- ✅ Response is valid JSON
- ✅ Contains time blocks for Mon-Fri
- ✅ Daily tasks are specific and actionable
- ✅ Resources have valid URLs
- ✅ Response completes in 10-30 seconds

---

### Test 3: Generate Prep Pack

```bash
curl -X POST http://localhost:8081/generate/prep \
  -H 'Content-Type: application/json' \
  -d '{
    "profile": {
      "name": "Andrew",
      "stage": "recent_grad",
      "targetRole": "iOS Software Engineer",
      "timeBudgetHoursPerDay": 3,
      "availableDays": ["Mon","Tue","Wed","Thu","Fri"]
    }
  }' | jq
```

**Expected Response:**
- HTTP 200
- JSON with `prep` object containing:
  - `prepOutline` (array of sections)
  - `weeklyDrillPlan` (array for Mon-Fri)
  - `starterQuestions` (3-10 questions)
  - `resources` (array)

---

### Test 4: Reroll Resources

First, generate a routine and save it to a file:

```bash
curl -X POST http://localhost:8081/generate/routine \
  -H 'Content-Type: application/json' \
  -d '{
    "profile": {
      "name": "Andrew",
      "stage": "recent_grad",
      "targetRole": "iOS Software Engineer",
      "timeBudgetHoursPerDay": 3,
      "availableDays": ["Mon","Tue","Wed","Thu","Fri"]
    }
  }' > current-plan.json
```

Then reroll just the resources:

```bash
curl -X POST http://localhost:8081/reroll/resources \
  -H 'Content-Type: application/json' \
  -d "{
    \"profile\": {
      \"name\": \"Andrew\",
      \"stage\": \"recent_grad\",
      \"targetRole\": \"iOS Software Engineer\",
      \"timeBudgetHoursPerDay\": 3,
      \"availableDays\": [\"Mon\",\"Tue\",\"Wed\",\"Thu\",\"Fri\"]
    },
    \"currentPlan\": $(cat current-plan.json | jq '.plan')
  }" | jq
```

**Expected Response:**
- HTTP 200
- JSON with ONLY `resources` key
- Different resources than the original plan

---

## ❌ Error Testing

### Test Invalid Input (should return 400)

```bash
curl -X POST http://localhost:8081/generate/routine \
  -H 'Content-Type: application/json' \
  -d '{"profile":{"name":"Test"}}'
```

**Expected:**
- HTTP 400
- JSON with `error` and `details` fields
- `traceId` for debugging

### Test Invalid Section (should return 400)

```bash
curl -X POST http://localhost:8081/reroll/invalid \
  -H 'Content-Type: application/json' \
  -d '{}'
```

**Expected:**
- HTTP 400
- Error message about invalid section

---

## 📊 What Success Looks Like

### Server Logs Should Show:

```
[INFO]: Incoming request
  traceId: "f47ac10b-58cc-4372-a567-0e02b2c3d479"
  method: "POST"
  path: "/generate/routine"
  
[INFO]: Generating routine
  traceId: "f47ac10b-58cc-4372-a567-0e02b2c3d479"

[INFO]: Calling OpenAI API
  model: "gpt-4o-mini"
  timeoutMs: 15000

[INFO]: OpenAI API call successful
  tokens: 2547

[INFO]: Routine generated successfully
  traceId: "f47ac10b-58cc-4372-a567-0e02b2c3d479"

[INFO]: Response sent
  traceId: "f47ac10b-58cc-4372-a567-0e02b2c3d479"
  statusCode: 200
```

### Response Validation Checklist:

**For Routine (`/generate/routine`):**
- [ ] Response is valid JSON
- [ ] Contains `plan` object
- [ ] `weekOf` is in YYYY-MM-DD format
- [ ] `timeBlocks` has Mon-Fri entries
- [ ] Each time block has `start`, `end`, `label`
- [ ] Times are in 24-hour format (HH:MM)
- [ ] `dailyTasks` has Mon-Fri entries
- [ ] `milestones` array has 3-6 items
- [ ] `resources` array has 4-8 items
- [ ] Each resource has `title` and valid `url`
- [ ] `version` is 1

**For Prep Pack (`/generate/prep`):**
- [ ] Response is valid JSON
- [ ] Contains `prep` object
- [ ] `prepOutline` has 4-6 sections
- [ ] Each section has `section` name and `items` array
- [ ] `weeklyDrillPlan` has 5 days (Mon-Fri)
- [ ] Each day has `day` and `drills` array
- [ ] `starterQuestions` has 3-10 questions
- [ ] `resources` array has 5+ items

**For Reroll:**
- [ ] Response contains ONLY the requested section
- [ ] Content is different from original
- [ ] Maintains same structure as original

---

## 🐛 Troubleshooting

### Server won't start:
```
Error: Missing required environment variable: OPENAI_API_KEY
```
→ Add your API key to `.env` file

### "Connection refused":
```
curl: (7) Failed to connect to localhost port 8081: Connection refused
```
→ Make sure server is running (`npm run dev`)

### OpenAI errors:
```
{"error":"OpenAI API request failed","traceId":"..."}
```
→ Check your API key is valid and has credits

### Slow responses:
- Normal: 10-30 seconds for generation endpoints
- If > 30 seconds, check your internet connection

---

## 💡 Tips

1. **Use `jq` for pretty JSON:**
   ```bash
   curl ... | jq
   ```

2. **Save responses for inspection:**
   ```bash
   curl ... > response.json
   ```

3. **Check server logs** for detailed tracing with `traceId`

4. **Test incrementally:**
   - Start with health check
   - Then try routine generation
   - Then prep pack
   - Finally reroll

5. **Compare responses:**
   - Save first routine as `routine1.json`
   - Generate another as `routine2.json`
   - Verify they're different (AI generates unique content)

---

## 🎯 Production Readiness Checklist

Before deploying to production:

- [ ] Health endpoint returns 200
- [ ] All three generation endpoints work
- [ ] Error handling returns proper status codes
- [ ] Rate limiting is configured
- [ ] CORS is properly configured
- [ ] API responses validate against schemas
- [ ] Server logs include traceIds
- [ ] No sensitive data in logs
- [ ] `.env` is gitignored
- [ ] Documentation is up to date

---

Happy testing! 🧪

