#!/bin/bash
# CareerRoutine API Test Script
# This script tests all endpoints of your API

echo "🧪 Testing CareerRoutine API"
echo "================================"
echo ""

BASE_URL="http://localhost:8081"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test 1: Health Check
echo "1️⃣  Testing Health Endpoint..."
HEALTH_RESPONSE=$(curl -s -w "\n%{http_code}" "$BASE_URL/health")
HTTP_CODE=$(echo "$HEALTH_RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$HEALTH_RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✅ Health check passed${NC}"
    echo "Response: $RESPONSE_BODY"
else
    echo -e "${RED}❌ Health check failed (HTTP $HTTP_CODE)${NC}"
    echo "Response: $RESPONSE_BODY"
    exit 1
fi

echo ""
echo "================================"
echo ""

# Test 2: Generate Routine
echo "2️⃣  Testing Generate Routine Endpoint..."
echo -e "${YELLOW}⏳ This may take 10-20 seconds (calling OpenAI)...${NC}"

ROUTINE_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/generate/routine" \
  -H 'Content-Type: application/json' \
  -d '{
    "profile": {
      "name": "Test User",
      "stage": "recent_grad",
      "targetRole": "iOS Software Engineer",
      "timeBudgetHoursPerDay": 3,
      "availableDays": ["Mon","Tue","Wed","Thu","Fri"],
      "constraints": ["no weekends"]
    }
  }')

HTTP_CODE=$(echo "$ROUTINE_RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$ROUTINE_RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✅ Generate routine passed${NC}"
    
    # Parse and show key info
    WEEK_OF=$(echo "$RESPONSE_BODY" | grep -o '"weekOf":"[^"]*"' | cut -d'"' -f4)
    VERSION=$(echo "$RESPONSE_BODY" | grep -o '"version":[0-9]*' | cut -d':' -f2)
    
    echo "  Week: $WEEK_OF"
    echo "  Version: $VERSION"
    
    # Check if we have time blocks for Monday
    if echo "$RESPONSE_BODY" | grep -q '"Mon"'; then
        echo -e "  ${GREEN}✓ Contains Monday time blocks${NC}"
    fi
    
    # Check if we have resources
    if echo "$RESPONSE_BODY" | grep -q '"resources"'; then
        echo -e "  ${GREEN}✓ Contains resources${NC}"
    fi
    
    # Save response for inspection
    echo "$RESPONSE_BODY" | python3 -m json.tool > last-routine-response.json 2>/dev/null
    echo "  Full response saved to: last-routine-response.json"
else
    echo -e "${RED}❌ Generate routine failed (HTTP $HTTP_CODE)${NC}"
    echo "Response: $RESPONSE_BODY"
fi

echo ""
echo "================================"
echo ""

# Test 3: Generate Prep Pack
echo "3️⃣  Testing Generate Prep Pack Endpoint..."
echo -e "${YELLOW}⏳ This may take 10-20 seconds (calling OpenAI)...${NC}"

PREP_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/generate/prep" \
  -H 'Content-Type: application/json' \
  -d '{
    "profile": {
      "name": "Test User",
      "stage": "recent_grad",
      "targetRole": "iOS Software Engineer",
      "timeBudgetHoursPerDay": 3,
      "availableDays": ["Mon","Tue","Wed","Thu","Fri"]
    }
  }')

HTTP_CODE=$(echo "$PREP_RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$PREP_RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✅ Generate prep pack passed${NC}"
    
    # Check for key components
    if echo "$RESPONSE_BODY" | grep -q '"prepOutline"'; then
        echo -e "  ${GREEN}✓ Contains prep outline${NC}"
    fi
    
    if echo "$RESPONSE_BODY" | grep -q '"weeklyDrillPlan"'; then
        echo -e "  ${GREEN}✓ Contains weekly drill plan${NC}"
    fi
    
    if echo "$RESPONSE_BODY" | grep -q '"starterQuestions"'; then
        echo -e "  ${GREEN}✓ Contains starter questions${NC}"
    fi
    
    # Save response for inspection
    echo "$RESPONSE_BODY" | python3 -m json.tool > last-prep-response.json 2>/dev/null
    echo "  Full response saved to: last-prep-response.json"
else
    echo -e "${RED}❌ Generate prep pack failed (HTTP $HTTP_CODE)${NC}"
    echo "Response: $RESPONSE_BODY"
fi

echo ""
echo "================================"
echo ""

# Test 4: Invalid Request (should return 400)
echo "4️⃣  Testing Error Handling (invalid request)..."

ERROR_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/generate/routine" \
  -H 'Content-Type: application/json' \
  -d '{"profile":{"name":"Test"}}')

HTTP_CODE=$(echo "$ERROR_RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$ERROR_RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "400" ]; then
    echo -e "${GREEN}✅ Error handling works correctly${NC}"
    echo "  Correctly returned 400 for invalid input"
else
    echo -e "${YELLOW}⚠️  Expected 400, got HTTP $HTTP_CODE${NC}"
fi

echo ""
echo "================================"
echo ""
echo "🎉 Testing Complete!"
echo ""
echo "📁 Check these files for full responses:"
echo "   - last-routine-response.json"
echo "   - last-prep-response.json"
echo ""

