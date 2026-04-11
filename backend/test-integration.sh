#!/bin/bash

# 808Pay Backend Test Script
# Tests real Algorand integration and amount validation

set -e

BACKEND_URL="http://localhost:3000"
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}   808Pay Backend - Algorand Integration Test Suite${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Test 1: Check if backend is running
echo -e "${YELLOW}[Test 1] Checking if backend is running...${NC}"
if ! curl -s "$BACKEND_URL/health" > /dev/null 2>&1; then
    echo -e "${RED}❌ Backend not running!${NC}"
    echo "Start it with: cd /Users/srijan/808Pay/backend && PORT=3000 npm run dev"
    exit 1
fi
echo -e "${GREEN}✅ Backend is running${NC}"
echo ""

# Test 2: Check Algorand connection
echo -e "${YELLOW}[Test 2] Testing Algorand testnet connection...${NC}"
ALGO_HEALTH=$(curl -s "$BACKEND_URL/api/algorand/health")
echo "Response: $ALGO_HEALTH"

if echo "$ALGO_HEALTH" | grep -q "healthy"; then
    echo -e "${GREEN}✅ Algorand testnet connection: HEALTHY${NC}"
    LATEST_ROUND=$(echo "$ALGO_HEALTH" | grep -o '"latestRound":"*[0-9]*' | grep -o '[0-9]*')
    echo "   Latest round: $LATEST_ROUND"
else
    echo -e "${RED}❌ Algorand testnet connection: UNHEALTHY${NC}"
    echo "   This means:"
    echo "   1. Your .env file is missing Algorand credentials"
    echo "   2. ALGORAND_SERVER URL might be incorrect"
    echo "   3. Network might be temporarily down"
    echo ""
    echo "   Fix: Edit /Users/srijan/808Pay/backend/.env"
fi
echo ""

# Test 3: Check sample wallet balance
echo -e "${YELLOW}[Test 3] Testing balance query (if .env has credentials)...${NC}"
SAMPLE_ADDRESS="AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAY5HVY"
BALANCE_RESPONSE=$(curl -s "$BACKEND_URL/api/algorand/balance/$SAMPLE_ADDRESS" 2>&1 || echo "error")

if echo "$BALANCE_RESPONSE" | grep -q "error"; then
    echo -e "${RED}❌ Balance query failed${NC}"
    echo "   Reason: Missing CREATOR_ADDRESS in .env or network issue"
else
    echo -e "${GREEN}✅ Balance query successful${NC}"
    echo "$BALANCE_RESPONSE" | head -5
fi
echo ""

# Test 4: Show settlement flow
echo -e "${YELLOW}[Test 4] Settlement Flow (Backend Logic)${NC}"
echo ""
echo "When you settle a ₹500 deal:"
echo ""
echo "  SENDER (Public Key: user1)"
echo "  ├─ Balance: ₹10,000 (from Algorand wallet or local store)"
echo "  ├─ Creates Deal: ₹500"
echo "  └─ Scans & Settles"
echo ""
echo "  SETTLEMENT CALCULATION:"
echo "  ├─ Category: electronics (12% GST)"
echo "  ├─ Merchant Gets: ₹440 (₹500 - 12% tax)"
echo "  ├─ Tax Authority Gets: ₹60 (12% GST)"
echo "  └─ Loyalty Bonus: ₹0"
echo ""
echo "  BLOCKCHAIN (Algorand Testnet):"
echo "  ├─ Transaction submitted with all details"
echo "  ├─ Signature verified (if mobile app implements it)"
echo "  └─ Amount splits recorded on-chain"
echo ""
echo "  FINAL BALANCES:"
echo "  ├─ Sender: ₹9,500 (₹10,000 - ₹500)"
echo "  ├─ Merchant: ₹10,440 (existing + ₹440)"
echo "  └─ Tax Authority: ₹60"
echo ""

# Test 5: Show what's NOT working yet
echo -e "${YELLOW}[Test 5] Current Limitations (In Testing Mode)${NC}"
echo ""
echo -e "${RED}❌ HARDCODED (NOT REAL):${NC}"
echo "   • Starting balance: ₹1,00,000 per user (demo mode)"
echo "   • Signature verification: Not implemented yet on mobile"
echo "   • Blockchain fallback: Fails silently if CREATOR_ADDRESS is empty"
echo ""
echo -e "${GREEN}✅ REAL (Connected to Algorand):${NC}"
echo "   • Network connection: Real testnet (AlgoNode endpoints)"
echo "   • Account balance queries: From blockchain (if .env filled)"
echo "   • Transaction history: From Algorand indexer"
echo "   • Transaction submission: Will go to blockchain (if credentials added)"
echo ""

# Test 6: Show how to fix the amount mismatch
echo -e "${YELLOW}[Test 6] How to Fix Amount Mismatch${NC}"
echo ""
echo "PROBLEM: When sender sends ₹500, receiver doesn't get ₹500"
echo ""
echo "REASONS:"
echo "  1. GST/Tax deducted automatically (example: ₹500 → ₹440 merchant + ₹60 tax)"
echo "  2. Balance validation uses blockchain balance (if .env configured)"
echo "  3. Local in-memory fallback if Algorand not connected"
echo ""
echo "SOLUTION:"
echo "  1. Add your Pera wallet to .env:"
echo "     cd /Users/srijan/808Pay/backend"
echo "     nano .env"
echo ""
echo "  2. Add these lines:"
echo "     CREATOR_ADDRESS=<your-pera-address>"
echo "     CREATOR_MNEMONIC=<your-25-word-phrase>"
echo ""
echo "  3. Restart backend:"
echo "     PORT=3000 npm run dev"
echo ""
echo "  4. Now the backend will:"
echo "     ✓ Query your real Algorand balance"
echo "     ✓ Validate amounts against real funds"
echo "     ✓ Submit transactions to blockchain"
echo ""

# Test 7: Show verification steps
echo -e "${YELLOW}[Test 7] Verification Checklist${NC}"
echo ""
echo "To ensure it's NOT hardcoded:"
echo ""
echo "  1. Check Algorand health:"
echo "     curl http://localhost:3000/api/algorand/health"
echo "     Should show 'healthy' with latestRound number"
echo ""
echo "  2. Check your balance:"
echo "     curl http://localhost:3000/api/algorand/balance/<pera-address>"
echo "     Should show balance from blockchain"
echo ""
echo "  3. Check .env file:"
echo "     cat /Users/srijan/808Pay/backend/.env | grep CREATOR"
echo "     Should show your address and mnemonic (if filled)"
echo ""
echo "  4. Check backend logs:"
echo "     Should show lines like:"
echo "     '✅ Transaction submitted to Algorand: <txId>'"
echo "     '💾 Balance from Algorand: ...' (not local store)"
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}   Next Steps:${NC}"
echo -e "${BLUE}   1. Get testnet ALGO: https://testnet.algoexplorer.io/${NC}"
echo -e "${BLUE}   2. Update .env with your Pera wallet${NC}"
echo -e "${BLUE}   3. Restart backend${NC}"
echo -e "${BLUE}   4. Test with curl commands above${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
