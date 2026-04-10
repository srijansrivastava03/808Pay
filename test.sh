#!/bin/bash

# 808Pay Backend - Simple Test (NO Algorand needed)

API="http://localhost:5000"
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   808PAY BACKEND TEST (No Algorand!)  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}\n"

# Test 1: Health Check
echo -e "${BLUE}Test 1: Health Check${NC}"
RESPONSE=$(curl -s $API/health)
if echo $RESPONSE | grep -q "ok"; then
  echo -e "${GREEN}✅ Backend is running${NC}"
  echo "   Response: $RESPONSE"
else
  echo -e "${RED}❌ Backend not responding${NC}"
  exit 1
fi
echo ""

# Test 2: List Transactions
echo -e "${BLUE}Test 2: List All Transactions${NC}"
RESPONSE=$(curl -s $API/api/transactions)
echo "   Response: $RESPONSE"
echo ""

# Test 3: Invalid Settlement
echo -e "${BLUE}Test 3: Invalid Settlement Request (should error)${NC}"
RESPONSE=$(curl -s -X POST $API/api/transactions/settle \
  -H "Content-Type: application/json" \
  -d '{"invalid":"data"}')
echo "   Response: $RESPONSE"
echo ""

# Test 4: Get Test Info
echo -e "${BLUE}Test 4: Test Endpoint Info${NC}"
RESPONSE=$(curl -s -X POST $API/api/transactions/test)
echo "   Response: $RESPONSE"
echo ""

echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ✅ TESTS COMPLETED                 ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}\n"
