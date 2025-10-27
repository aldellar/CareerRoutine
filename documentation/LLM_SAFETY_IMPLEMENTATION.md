# LLM Safety Implementation Guide

## 🔒 Safety as a First-Class Product Feature

This document outlines the comprehensive LLM safety, evaluation, and reliability features implemented in the Interview Prep application.

---

## Overview

We treat **safety as a product feature**, not an afterthought. Our implementation includes:

✅ **Output validation and filtering** before showing model results  
✅ **Fallback behavior** when the API fails or returns low-confidence data  
✅ **Prompt templates designed** to avoid unsafe or irrelevant content  
✅ **Tracking and logging** prompts/responses for later evaluation  
✅ **Risk detection** and content assessment  
✅ **Safe input sanitization** to prevent prompt injection  

---

## Architecture

### Backend Safety Services

#### 1. **Content Safety Assessment** (`backend/server/src/services/safety.js`)

The safety service provides:

- **Risk Detection**: Categorizes content into safe, low-risk, medium-risk, and high-risk levels
- **Content Filtering**: Removes unsafe content before returning to users
- **Input Sanitization**: Prevents prompt injection attacks
- **URL Validation**: Ensures all resources have safe, legitimate URLs
- **Fallback Responses**: Provides safe default content when LLM fails
- **Safety Logging**: Tracks all interactions for evaluation

#### Key Functions:

```javascript
// Assess content risk level
assessContentRisk(content) → { level, reasons, riskScore, confidence }

// Sanitize user input to prevent prompt injection
sanitizeInput(input) → sanitized input

// Validate URLs in responses
validateURLs(urls) → { valid, invalid }

// Filter unsafe content from LLM output
filterLLMOutput(data, dataType) → filtered data

// Create safe fallback when API fails
createFallbackResponse(type, profile) → safe default data

// Determine if content is safe to return
isSafeToReturn(data, riskAssessment) → boolean

// Log interaction for safety evaluation
logLLMInteraction(params) → logged in evaluation loop

// Add safety guidelines to prompts
addSafetyGuidelines(basePrompt) → enhanced prompt

// Validate data quality
validateDataQuality(data, expectedType) → { valid, issues, quality }
```

---

## Safety Patterns Detected

### 1. Risky Content Detection

The system detects multiple risk categories:

- **Inappropriate Content**: Violence, harmful, illegal content markers
- **Off-Topic Content**: Financial advice, medical advice, unrelated topics
- **Suspicious URLs**: Shortened URLs, non-standard domains
- **Low-Quality Content**: Placeholders, example data, lorem ipsum
- **Malformed Data**: Undefined, null values in structured data

### 2. Prompt Injection Prevention

User inputs are sanitized to prevent attempts to:
- Override system instructions
- Inject malicious prompts
- Manipulate model behavior

```javascript
// Example sanitization
profile.name = sanitizeInput(profile.name)
profile.targetRole = sanitizeInput(profile.targetRole)
```

### 3. URL Safety

All URLs in responses are validated:
- Only http/https protocols allowed
- Suspicious shorteners (bit.ly, tinyurl) are blocked
- Malformed URLs are filtered out

### 4. Output Quality Validation

Responses are checked for:
- Data completeness
- Required fields presence
- Content structure integrity
- Confidence scores

---

## Integration Points

### Backend Routes

All API endpoints implement safety checks:

**`/generate/routine`**:
1. Sanitize user inputs
2. Enhance prompts with safety guidelines
3. Call OpenAI with safety-enhanced prompts
4. Assess response risk
5. Filter unsafe content
6. Validate data quality
7. Check if safe to return
8. Log interaction for evaluation
9. Fallback on any failure

**`/generate/prep`**:
- Same comprehensive safety pipeline

**`/reroll/:section`**:
- Section-specific safety checks
- Preserves existing data on failure

### iOS Client

The iOS `NetworkService` includes:

1. **Input Validation**: Checks profile data before sending
   - Name/target role length limits
   - Stage validation
   - Time budget bounds checking

2. **Response Quality Checks**:
   - Empty response detection
   - Automatic fallback to mock data
   - Graceful error handling

3. **Fallback Strategy**:
   - Never fails silently
   - Always returns usable data
   - Logs warnings for monitoring

```swift
// Example: iOS input validation
private func validateUserInput(_ profile: UserProfile) {
    if profile.name.count > 100 {
        print("⚠️ Warning: Profile name too long")
    }
    // Additional validations...
}
```

---

## Evaluation & Logging

### LLM Interaction Logging

Every LLM interaction is logged for evaluation:

```javascript
{
  traceId: "unique-request-id",
  timestamp: "ISO timestamp",
  model: "gpt-4o-mini",
  riskLevel: "safe" | "low_risk" | "medium_risk" | "high_risk",
  riskScore: 0-15,
  confidence: 0-1,
  tokens: 1234,
  latencyMs: 1234,
  promptLength: 567,
  responseLength: 890,
  hasURLs: true,
  hasHighRisk: false
}
```

This enables:
- **Eval loops**: Identify patterns in failures
- **Quality metrics**: Track confidence over time
- **Risk monitoring**: Detect unsafe content trends
- **Performance optimization**: Analyze latency patterns

---

## Fallback Strategies

### When API Fails

If the OpenAI API fails or times out:

1. **Log the error** with full context
2. **Return safe fallback data** with:
   - Generic but useful content
   - Well-known, safe resources (LeetCode, etc.)
   - Reasonable default structure
3. **Inform user** (via logs) about fallback usage
4. **Continue gracefully** without breaking user experience

### When Content is Unsafe

If high-risk content is detected:

1. **Reject the content** immediately
2. **Log detailed risk assessment**
3. **Return fallback data** instead
4. **Alert monitoring systems**

### When Quality is Low

If data quality is poor (confidence < 0.5):

1. **Log quality issues**
2. **Still attempt to return** (with warning)
3. **Track for improvement**

---

## Prompt Safety Guidelines

All prompts include safety requirements:

```
SAFETY AND RELIABILITY REQUIREMENTS:
- Generate only interview preparation content relevant to technical interviews
- Avoid off-topic content (financial, medical, legal advice)
- Ensure all URLs are safe, valid, and relevant to interview prep
- Do not generate placeholder or example content
- Provide actionable, specific recommendations
- Keep all content professional and appropriate
- Focus strictly on coding interview preparation for software engineering roles
- Do not include any potentially harmful or illegal content
- Ensure all suggested resources are legitimate learning platforms
```

---

## Monitoring & Improvement

### Safety Metrics Tracked

- Risk level distribution
- Confidence score trends
- API failure rates
- Fallback usage frequency
- URL validation rates
- Content quality scores

### Evaluation Loop

Logs enable:
1. **Identifying failure patterns**
2. **Improving prompt engineering**
3. **Adjusting risk thresholds**
4. **Training on edge cases**

---

## Best Practices

### ✅ Do's

1. **Always validate inputs** before sending to LLM
2. **Always assess outputs** before returning to users
3. **Always have fallbacks** for critical paths
4. **Always log interactions** for evaluation
5. **Always sanitize user data** to prevent injection

### ❌ Don'ts

1. **Never trust LLM output without validation**
2. **Never expose raw error messages** to users
3. **Never skip safety checks** for "performance"
4. **Never log sensitive user data**
5. **Never return without a response** (use fallbacks)

---

## Testing Safety Features

To test the safety system:

1. **Test with edge cases**: Empty inputs, very long inputs, special characters
2. **Test API failures**: Disconnect internet, timeout scenarios
3. **Test risky content**: Monitor logs for risk detection
4. **Test fallbacks**: Verify graceful degradation

---

## Summary

**Safety is not optional** - it's built into every layer:

- ✅ **Input Layer**: Sanitization, validation
- ✅ **Processing Layer**: Risk assessment, filtering
- ✅ **Output Layer**: Quality checks, URL validation
- ✅ **Failure Layer**: Graceful fallbacks
- ✅ **Evaluation Layer**: Comprehensive logging

**This ensures**:
- Users never see unsafe content
- The app never crashes on API failure
- All interactions are tracked for improvement
- Safety is a first-class product feature

---

## Implementation Files

- `backend/server/src/services/safety.js` - Core safety service
- `backend/server/src/routes/generate.js` - Integrated safety in all routes
- `frontend/ios/InterviewPrepApp/InterviewPrepApp/Services/NetworkService.swift` - iOS input validation and error handling

---

**Treating safety as a product feature** means it's:
- Designed in from the start
- Tested continuously
- Improved iteratively
- Monitored actively
- Logged comprehensively

