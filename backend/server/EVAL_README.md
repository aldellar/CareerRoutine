# Evaluation & Logging System

This document explains how to use evaluation logs to refine prompts and improve LLM quality.

## 🎯 Purpose

The evaluation system logs all LLM interactions to:
1. **Track quality metrics** (risk scores, confidence, latency)
2. **Identify regressions** (when prompts get worse)
3. **Refine prompts** (based on what works/doesn't work)
4. **Monitor safety** (detect risky outputs)

---

## 📊 How It Works

### 1. Automatic Logging

Every LLM call is automatically logged to `eval-logs/` directory with:
- Full prompt and response
- Risk assessment
- Latency metrics
- Token usage
- Quality scores

### 2. Log Structure

Each log file contains:
```json
{
  "traceId": "unique-id",
  "timestamp": "2025-01-15T10:30:00.000Z",
  "model": "gpt-4o-mini",
  "riskLevel": "safe",
  "riskScore": 0,
  "confidence": 0.95,
  "latencyMs": 1234,
  "tokens": 500,
  "promptLength": 245,
  "responseLength": 1024,
  "hasURLs": true,
  "hasHighRisk": false,
  "prompt": "... full prompt ...",
  "response": "... full response ..."
}
```

---

## 🔧 Usage

### View Summary Report

```bash
node eval.js
```

Shows:
- Total interactions
- Average latency, tokens, risk scores
- Safety metrics
- Warnings for regressions

### Find Specific Log

```bash
node eval.js --find <traceId>
```

Useful for debugging specific issues.

### Example Output

```
📊 EVALUATION REPORT
══════════════════════════════════════════════

📈 Summary:
  Total interactions: 45
  Date range: 2025-01-10 → 2025-01-15

⚡ Performance:
  Avg latency: 2345ms
  Avg tokens: 512
  Avg response length: 892 chars

🎯 Quality:
  Avg risk score: 2.3
  Avg confidence: 0.87
  High risk rate: 4.4%

🔗 Content:
  Responses with URLs: 38/45
  URL rate: 84.4%

✅ Safety:
  High risk interactions: 2
  High risk rate: 4.4%
```

---

## 🔄 Prompt Refinement Workflow

### Step 1: Make a Change

Edit a prompt in `src/prompts/`:
```javascript
// routinePrompt.js
SYSTEM_PROMPT = `You are a career coach...
[Your improved prompt here]
`;
```

### Step 2: Test the Change

```bash
# Make some test requests
curl -X POST http://localhost:3000/generate/routine ...

# Check the logs
node eval.js
```

### Step 3: Compare Metrics

Look for:
- **Lower risk scores** = safer outputs
- **Higher confidence** = more reliable
- **Lower latency** = faster
- **Better quality** = more complete responses

### Step 4: Detect Regressions

If metrics get worse:
```bash
⚠️  WARNING: High risk rate > 10%. Prompt may need refinement.
⚠️  WARNING: Average latency > 5s. Performance may need optimization.
```

---

## 📈 What to Track

### Safety Metrics
- **Risk score**: Lower is better (< 5)
- **Confidence**: Higher is better (> 0.8)
- **High risk rate**: Should be < 10%

### Quality Metrics
- **Response length**: Appropriate for task
- **URL coverage**: Are resources included?
- **Completeness**: All fields present?

### Performance Metrics
- **Latency**: Should be < 3s for good UX
- **Tokens**: Cost tracking

---

## 🎯 Example: Refining the Routine Prompt

### Before (Generic Prompt)
```javascript
SYSTEM_PROMPT = "You are a career coach. Generate a weekly routine."
```

### After Looking at Logs
You notice:
- Risk score: 8.5
- Missing URLs in 30% of responses
- Average response too short

### After (Improved Prompt)
```javascript
SYSTEM_PROMPT = `You are a focused career coach for CS students.

CRITICAL REQUIREMENTS:
- Include 4-8 resources with valid URLs (LeetCode, YouTube, courses)
- Tasks should be specific and actionable
- All time blocks must sum to daily budget
- Focus on technical interview prep topics

Output format: Structured JSON with time blocks for Mon-Fri.
Each task: 0.25-2.0 hours duration.
`;
```

### Test Again
```bash
node eval.js
# Compare new metrics: Lower risk score? Better URLs?
```

---

## 🔍 Analyzing Logs for Insights

### Find Low-Quality Responses

```bash
# Look for logs with low confidence
cat eval-logs/*.json | jq 'select(.confidence < 0.7)'
```

### Find Slow Requests

```bash
# Find requests > 5s
cat eval-logs/*.json | jq 'select(.latencyMs > 5000)'
```

### Find Risky Content

```bash
# Find high-risk interactions
cat eval-logs/*.json | jq 'select(.hasHighRisk == true)'
```

---

## 💡 Best Practices

1. **Run eval after significant prompt changes**
2. **Compare before/after metrics**
3. **Track regressions**: If quality drops, revert
4. **Sample logs**: Read actual prompts/responses for insights
5. **Document changes**: Why did you change the prompt?

---

## 🚀 For Production

The job you're applying for emphasizes:
- **Offline evals**: Test suite against ground truth
- **Regression prevention**: Don't ship worse prompts
- **Metrics tracking**: GAD-7 equivalent

To show you understand this:

1. **Add unit tests** that run against eval logs
2. **Set quality gates** (e.g., risk score < 5)
3. **Document decisions** (why this prompt works)

Example:
```javascript
// test-eval.js
test('routine generation quality', async () => {
  const logs = await loadEvalLogs();
  const avgRisk = logs.reduce((sum, l) => sum + l.riskScore, 0) / logs.length;
  expect(avgRisk).toBeLessThan(5); // Quality gate
});
```

---

## 📝 Summary

✅ **You're now logging** all LLM interactions with full prompts/responses  
✅ **You can analyze** quality, safety, and performance metrics  
✅ **You can refine** prompts based on data, not guesses  
✅ **You can detect** regressions before shipping  

This demonstrates the "eval loop" and "evidence-driven" mindset the job requires!

---

## Next Steps

1. Make some API calls to generate logs
2. Run `node eval.js` to see metrics
3. Try refining a prompt based on logs
4. Show in your job application: "Built eval infrastructure for prompt refinement"

This addresses the **"offline and online eval loops"** requirement! 🎉
