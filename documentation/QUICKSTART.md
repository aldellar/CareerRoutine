# Quick Start Guide

## 🚀 Get Running in 3 Minutes

### Step 1: Install Dependencies
```bash
cd backend/server
npm install
```

### Step 2: Configure Environment
```bash
# Copy the example env file
cp env.example .env

# Edit .env and add your OpenAI API key
nano .env
# or
open .env
```

**Required:** Set your `OPENAI_API_KEY` in `.env`:
```env
OPENAI_API_KEY=sk-your-actual-key-here
```

### Step 3: Start the Server
```bash
npm run dev
```

The server will start on `http://localhost:8081`

### Step 4: Test It
```bash
# Health check
curl http://localhost:8081/health

# Generate a routine (replace with your actual data)
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
  }'
```

---

## 📁 Complete File Structure

```
backend/server/
├── package.json              # Dependencies & scripts
├── env.example               # Environment template
├── .gitignore                # Git ignore rules
├── .eslintrc.json            # ESLint configuration
├── README_BACKEND.md         # Full documentation
├── QUICKSTART.md             # This file
├── openapi.yaml              # OpenAPI specification
└── src/
    ├── index.js              # Express server
    ├── config.js             # Configuration loader
    ├── openaiClient.js       # OpenAI API client
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
        └── jsonFix.js        # JSON repair
```

---

## ✅ Verification Checklist

- [ ] Node.js 18+ installed (`node --version`)
- [ ] Dependencies installed (`npm install`)
- [ ] `.env` file created with valid `OPENAI_API_KEY`
- [ ] Server starts without errors (`npm run dev`)
- [ ] Health endpoint responds (`curl http://localhost:8081/health`)
- [ ] Can generate a routine (see curl example above)

---

## 🐛 Common Issues

### "Missing required environment variable: OPENAI_API_KEY"
→ Create `.env` file and add your OpenAI API key

### "Cannot find module"
→ Run `npm install` to install dependencies

### "EADDRINUSE: address already in use"
→ Another service is using port 8081. Change `PORT` in `.env`

### "OpenAI API request failed"
→ Check your API key is valid and has sufficient credits

---

## 📚 Next Steps

1. Read the full [README_BACKEND.md](./README_BACKEND.md) for detailed documentation
2. Review [openapi.yaml](./openapi.yaml) for complete API specification
3. Test all three endpoints (routine, prep, reroll)
4. Integrate with your iOS app

---

## 💡 Tips

- Use `npm run dev` for development (auto-reload on file changes)
- Use `npm start` for production
- Check logs for request tracing with `traceId`
- Adjust rate limits in `.env` if needed
- All responses are strictly validated against JSON schemas

---

Happy coding! 🎉

