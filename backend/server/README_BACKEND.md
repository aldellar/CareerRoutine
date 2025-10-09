# CareerRoutine API

**Production-ready, stateless Node.js Express API for the CareerRoutine iOS app.**

This API proxies OpenAI calls to generate personalized interview preparation routines and materials. It enforces strict JSON schema validation on all inputs and outputs, ensuring type safety and reliability.

## 🎯 Features

- **Stateless architecture** – No database, no persistence
- **Strict JSON validation** – Ajv-powered schema enforcement
- **OpenAI integration** – Uses Structured Outputs (JSON Schema mode)
- **Production security** – Helmet, CORS, rate limiting
- **Comprehensive logging** – Pino with request tracing
- **JSON repair** – Automatic recovery from malformed OpenAI responses
- **ESM modules** – Modern JavaScript with native imports

---

## 📋 Requirements

- **Node.js** 18+ (ESM support)
- **OpenAI API Key** with GPT-4o access
- **npm** or **yarn**

---

## 🚀 Quick Start

### 1. Install Dependencies

```bash
cd backend/server
npm install
```

### 2. Configure Environment

Copy `env.example` to `.env` and set your OpenAI API key:

```bash
cp env.example .env
```

Edit `.env`:

```env
OPENAI_API_KEY=sk-your-actual-api-key-here
OPENAI_MODEL=gpt-4o-mini
PORT=8081
NODE_ENV=development
CORS_ORIGIN=http://localhost:3000,http://localhost:8081
RATE_WINDOW_MS=60000
RATE_MAX=60
OPENAI_TIMEOUT_MS=15000
```

### 3. Run the Server

**Development (with auto-reload):**
```bash
npm run dev
```

**Production:**
```bash
npm start
```

The server will start on `http://localhost:8081` (or the port specified in `.env`).

---

## 📡 API Endpoints

### Health Check

**GET** `/health`

Returns server status.

**Response:**
```json
{
  "status": "ok"
}
```

---

### Generate Weekly Routine

**POST** `/generate/routine`

Generates a personalized weekly interview prep routine (Mon–Fri).

**Request Body:**
```json
{
  "profile": {
    "name": "Andrew",
    "stage": "recent_grad",
    "targetRole": "iOS Software Engineer",
    "timeBudgetHoursPerDay": 3,
    "availableDays": ["Mon", "Tue", "Wed", "Thu", "Fri"],
    "constraints": ["no weekends"]
  },
  "preferences": {}
}
```

**Response (200 OK):**
```json
{
  "plan": {
    "weekOf": "2025-10-06",
    "timeBlocks": {
      "Mon": [
        { "start": "09:00", "end": "09:45", "label": "DS&A: Arrays & Strings" },
        { "start": "10:00", "end": "10:45", "label": "Swift Fundamentals" },
        { "start": "11:00", "end": "11:45", "label": "Portfolio: Update GitHub" },
        { "start": "14:00", "end": "14:30", "label": "Applications & Networking" }
      ],
      "Tue": [...],
      ...
    },
    "dailyTasks": {
      "Mon": [
        "Complete 2 LC Easy problems on arrays",
        "Review Swift optionals and error handling",
        "Apply to 3 iOS roles on LinkedIn"
      ],
      ...
    },
    "milestones": [
      "Complete 10 medium LeetCode problems",
      "Build and deploy a SwiftUI app",
      "Send 15 applications"
    ],
    "resources": [
      { "title": "LeetCode Top Interview 150", "url": "https://leetcode.com/..." },
      { "title": "Swift by Sundell", "url": "https://swiftbysundell.com" }
    ],
    "version": 1
  }
}
```

---

### Generate Prep Pack

**POST** `/generate/prep`

Generates a comprehensive interview prep pack with outline, drill plan, and practice questions.

**Request Body:**
```json
{
  "profile": {
    "name": "Andrew",
    "stage": "recent_grad",
    "targetRole": "iOS Software Engineer",
    "timeBudgetHoursPerDay": 3,
    "availableDays": ["Mon", "Tue", "Wed", "Thu", "Fri"]
  }
}
```

**Response (200 OK):**
```json
{
  "prep": {
    "prepOutline": [
      {
        "section": "Data Structures & Algorithms",
        "items": [
          "Master arrays, strings, hash maps",
          "Practice tree and graph traversals",
          "Study dynamic programming patterns"
        ]
      },
      {
        "section": "iOS & Swift",
        "items": [
          "SwiftUI vs UIKit tradeoffs",
          "Memory management (ARC)",
          "Concurrency with async/await"
        ]
      }
    ],
    "weeklyDrillPlan": [
      {
        "day": "Mon",
        "drills": [
          "Solve 2 easy LC problems",
          "Review Swift basics"
        ]
      },
      ...
    ],
    "starterQuestions": [
      "Implement a function to reverse a string in Swift",
      "Design a UITableView with custom cells",
      "Explain the difference between weak and unowned"
    ],
    "resources": [
      { "title": "Hacking with Swift", "url": "https://hackingwithswift.com" }
    ]
  }
}
```

---

### Reroll a Plan Section

**POST** `/reroll/:section`

Regenerates a specific section of an existing plan. Valid sections:
- `timeBlocks`
- `resources`
- `dailyTasks`

**Request Body:**
```json
{
  "profile": {
    "name": "Andrew",
    "stage": "recent_grad",
    "targetRole": "iOS Software Engineer",
    "timeBudgetHoursPerDay": 3,
    "availableDays": ["Mon", "Tue", "Wed", "Thu", "Fri"]
  },
  "currentPlan": {
    "weekOf": "2025-10-06",
    "timeBlocks": { ... },
    "dailyTasks": { ... },
    "milestones": [ ... ],
    "resources": [ ... ],
    "version": 1
  }
}
```

**Response (200 OK):**

When rerolling `resources`:
```json
{
  "resources": [
    { "title": "iOS Interview Guide", "url": "https://..." },
    { "title": "Cracking the Coding Interview", "url": "https://..." }
  ]
}
```

When rerolling `timeBlocks`:
```json
{
  "timeBlocks": {
    "Mon": [ ... ],
    "Tue": [ ... ],
    ...
  }
}
```

---

## 🛡️ Error Responses

All errors return JSON with `error`, optional `details`, and `traceId` for debugging.

### 400 Bad Request
```json
{
  "error": "Profile validation failed",
  "details": [
    {
      "instancePath": "/timeBudgetHoursPerDay",
      "message": "must be >= 0.5"
    }
  ],
  "traceId": "f47ac10b-58cc-4372-a567-0e02b2c3d479"
}
```

### 429 Too Many Requests
```json
{
  "error": "Too many requests, please try again later."
}
```

### 502 Bad Gateway
```json
{
  "error": "OpenAI API request failed",
  "traceId": "f47ac10b-58cc-4372-a567-0e02b2c3d479"
}
```

### 504 Gateway Timeout
```json
{
  "error": "OpenAI request timed out",
  "traceId": "f47ac10b-58cc-4372-a567-0e02b2c3d479"
}
```

---

## 🧪 Testing with cURL

### Generate Routine
```bash
curl -s -X POST http://localhost:8081/generate/routine \
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

### Generate Prep Pack
```bash
curl -s -X POST http://localhost:8081/generate/prep \
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

### Reroll Resources
```bash
curl -s -X POST http://localhost:8081/reroll/resources \
  -H 'Content-Type: application/json' \
  -d '{
    "profile": {
      "name": "Andrew",
      "stage": "recent_grad",
      "targetRole": "iOS Software Engineer",
      "timeBudgetHoursPerDay": 3,
      "availableDays": ["Mon","Tue","Wed","Thu","Fri"]
    },
    "currentPlan": {
      "weekOf": "2025-10-06",
      "timeBlocks": {},
      "dailyTasks": {},
      "milestones": [],
      "resources": [],
      "version": 1
    }
  }' | jq
```

---

## 🔧 Configuration

All configuration is via environment variables (see `env.example`).

| Variable            | Default               | Description                              |
|---------------------|-----------------------|------------------------------------------|
| `OPENAI_API_KEY`    | *(required)*          | Your OpenAI API key                      |
| `OPENAI_MODEL`      | `gpt-4o-mini`         | Model to use (e.g., gpt-4o, gpt-4o-mini) |
| `PORT`              | `8081`                | Server port                              |
| `NODE_ENV`          | `development`         | Environment (development/production)     |
| `CORS_ORIGIN`       | `http://localhost:*`  | Comma-separated allowed origins          |
| `RATE_WINDOW_MS`    | `60000` (1 min)       | Rate limit window                        |
| `RATE_MAX`          | `60`                  | Max requests per window                  |
| `OPENAI_TIMEOUT_MS` | `15000` (15s)         | OpenAI request timeout                   |

---

## 📂 Project Structure

```
backend/server/
├── package.json
├── env.example
├── README_BACKEND.md (this file)
└── src/
    ├── index.js              # Express server entry point
    ├── config.js             # Environment configuration
    ├── openaiClient.js       # OpenAI API wrapper
    ├── routes/
    │   └── generate.js       # API route handlers
    ├── schemas/
    │   ├── profile.schema.json
    │   ├── plan.schema.json
    │   └── prep.schema.json
    ├── prompts/
    │   ├── routinePrompt.js
    │   ├── prepPrompt.js
    │   └── rerollPrompt.js
    └── utils/
        ├── logger.js         # Pino logger
        ├── validate.js       # Ajv validation
        └── jsonFix.js        # JSON repair utility
```

---

## 📜 OpenAPI Specification

See [openapi.yaml](./openapi.yaml) for the full OpenAPI 3.0 specification.

### Quick Reference

**Schemas:**

- **Profile** (input): name, stage, targetRole, timeBudgetHoursPerDay, availableDays, constraints
- **Plan** (output): weekOf, timeBlocks, dailyTasks, milestones, resources, version
- **Prep** (output): prepOutline, weeklyDrillPlan, starterQuestions, resources

**Endpoints:**

- `POST /generate/routine` → `{ plan: Plan }`
- `POST /generate/prep` → `{ prep: Prep }`
- `POST /reroll/{section}` → `{ [section]: ... }`

---

## 🔒 Security Features

- **Helmet**: Sets secure HTTP headers
- **CORS**: Whitelist-based origin validation
- **Rate Limiting**: 60 req/min per IP (configurable)
- **Body Size Limits**: 1MB max
- **Request Tracing**: UUID-based traceId for debugging
- **No Data Persistence**: All user data stays on-device
- **Timeouts**: 15s default for OpenAI calls

---

## 🐛 Troubleshooting

### OpenAI returns invalid JSON
The API uses `jsonrepair` to automatically fix common JSON issues. If repair fails, you'll get a 502 error with a snippet of the response.

### Rate limit errors
Adjust `RATE_MAX` and `RATE_WINDOW_MS` in `.env`. Default is 60 requests per minute.

### CORS issues
Add your client origin to `CORS_ORIGIN` in `.env`:
```
CORS_ORIGIN=http://localhost:3000,http://localhost:8081,https://myapp.com
```

### Validation errors
Check the `details` field in the error response. It shows exactly which fields failed validation.

---

## 🚢 Deployment

### Docker (Recommended)

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --production
COPY src ./src
EXPOSE 8081
CMD ["node", "src/index.js"]
```

Build and run:
```bash
docker build -t career-routine-api .
docker run -p 8081:8081 --env-file .env career-routine-api
```

### Environment Variables in Production

- Use secrets management (AWS Secrets Manager, Vault, etc.)
- Set `NODE_ENV=production`
- Configure proper `CORS_ORIGIN`
- Increase `RATE_MAX` if needed
- Use a reverse proxy (nginx) for SSL

---

## 📝 License

MIT

---

## 🙋 Support

For issues or questions, open an issue on GitHub or contact the maintainers.

