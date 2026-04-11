# 808Pay Backend - Algorand Testnet Setup Guide

## Current Status
❌ **Backend is NOT connected to real Algorand yet** - It's using:
- **Hardcoded in-memory balances** (everyone starts with ₹1000)
- **Local transaction storage** (transactions aren't actually submitted to blockchain)
- **Fallback mode** when Algorand connection fails

## What You Need To Do

### Step 1: Create a Pera Wallet Account on Testnet
1. Install Pera Wallet (mobile or browser extension)
2. Create account and select **Testnet** network
3. Fund your wallet:
   - Go to https://testnet.algoexplorer.io/
   - Click "Faucet" (top right)
   - Enter your address
   - You'll receive **1000 TestNet ALGO** (~10 minutes)
4. **Save your mnemonic** (recovery phrase) in a safe place

### Step 2: Update Backend .env File
Edit `/Users/srijan/808Pay/backend/.env` and add:

```env
# Your Pera wallet address (43 characters, starts with address format)
CREATOR_ADDRESS=<your-pera-wallet-address>

# Your Pera wallet mnemonic (25 words from recovery phrase)
CREATOR_MNEMONIC=word1 word2 word3 ... word25

# AlgoNode is free and public - no token needed
ALGORAND_TOKEN=
ALGORAND_SERVER=https://testnet-api.algonode.cloud
ALGORAND_INDEXER=https://testnet-idx.algonode.cloud
```

### Step 3: Test the Connection
```bash
cd /Users/srijan/808Pay/backend
curl http://localhost:3000/api/algorand/health
```

**Expected response (if working):**
```json
{
  "network": "testnet",
  "status": "healthy",
  "latestRound": 43567894,
  "message": "Network is healthy"
}
```

**If you get "unhealthy":**
- Your ALGORAND_SERVER URL might be wrong
- Network might be down temporarily
- Check firewall/proxy issues

### Step 4: Check Your Balance
```bash
curl http://localhost:3000/api/algorand/balance/<your-wallet-address>
```

**Expected response:**
```json
{
  "address": "XXXXXX...",
  "balance": 1000000000,
  "balanceAlgo": 1000,
  "currency": "ALGO"
}
```

---

## Understanding the Amount Mismatch Issue

### Current Problem:
When you create a deal for ₹500:
- **Sender sees:** ₹500 deducted from balance
- **Receiver sees:** ₹500 added to balance
- **Actually happening:** In-memory balance changes (not real money)

### Real-World Flow (After Setup):
1. **Sender:** Has 1000 TestNet ALGO in Pera Wallet
2. **Creates deal:** ₹500
3. **QR scans** → Settlement happens:
   - ₹434 → Merchant (after 13% GST on electronics)
   - ₹66 → Tax authority
   - ₹0 → Loyalty (if applicable)
4. **On Algorand testnet:** Transaction is recorded with all splits

---

## Production Differences

**Current (Testing):**
- Balance: In-memory
- Transactions: Local storage only
- Amount validation: Simple (₹1000 starting balance)

**Production (Real Money):**
- Balance: From actual Algorand blockchain or bank API
- Transactions: Submitted to Algorand mainnet
- Amount validation: Real-time bank balance check
- GST/Tax: Calculated and sent to tax authority's wallet

---

## API Endpoints to Test

### 1. Settlement Endpoint
```bash
POST http://localhost:3000/api/transactions/settle

Body:
{
  "data": {
    "sender": "user1",
    "recipient": "merchant_001",
    "amount": 500,
    "timestamp": 1681234567,
    "category": "electronics"
  },
  "signature": "0x...",
  "publicKey": "0x..."
}
```

### 2. Check Algorand Health
```bash
GET http://localhost:3000/api/algorand/health
```

### 3. Get Account Balance
```bash
GET http://localhost:3000/api/algorand/balance/<address>
```

### 4. Get Transaction History
```bash
GET http://localhost:3000/api/algorand/history/<address>
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Invalid public key format" | Signature verification hasn't been implemented in mobile app yet |
| "Network is unhealthy" | Check `.env` Algorand endpoints are correct |
| "Insufficient balance" | You have < ₹500 in-memory (unlikely in testing) |
| "Transaction not found" | Wait a few seconds, then check again |
| Empty `.env` values | Backend falls back to demo mode silently |

---

## Next Steps

1. **Fill in .env** with your Pera wallet details
2. **Restart backend:** `PORT=3000 npm run dev`
3. **Test connection:** `curl http://localhost:3000/api/algorand/health`
4. **Wire mobile app to backend settlement endpoint**
5. **Implement real signature verification** on mobile app

---

## Files That Need Updates

| File | Issue | Fix |
|------|-------|-----|
| `.env` | Missing credentials | Add Pera wallet address & mnemonic |
| Mobile app | No signature verification | Implement proper Ed25519 signing |
| Mobile app | Hardcoded QR data | Parse actual scanned QR and send to backend |
| Settlement service | In-memory balances | (Optional: connect to real bank API) |

---

## Security Notes

⚠️  **NEVER:**
- Commit `.env` to GitHub
- Share your mnemonic with anyone
- Use mainnet credentials in development

✅ **ALWAYS:**
- Keep `.env` file in `.gitignore` (check: `cat .gitignore | grep .env`)
- Use testnet for development
- Rotate keys regularly in production
