# **Quick Start: Algorand Integration**

## **What's Ready**

✅ Backend service to submit settlements to Algorand blockchain
✅ Flutter widgets to display settlement results
✅ Complete settlement pipeline with blockchain confirmation
✅ Explorer links to view transactions on testnet

---

## **1️⃣ Get API Token (5 mins)**

1. Visit: https://www.purestake.com/
2. Create free account
3. Go to Dashboard → Get API Key
4. Copy your testnet token

---

## **2️⃣ Update .env (2 mins)**

```env
# In /Users/srijan/808Pay/.env
ALGORAND_TOKEN=<PASTE_YOUR_TOKEN_HERE>
CREATOR_ADDRESS=<YOUR_ADDRESS>
CREATOR_MNEMONIC=<YOUR_MNEMONIC_24_WORDS>
```

To get a creator account:
- Use AlgoKit to generate: `algokit generate account`
- Or create at: https://www.algoexplorer.io/

---

## **3️⃣ Get Test Funds (5 mins)**

Visit: https://testnet-dispenser.algorand.org/
- Enter your creator address
- Get test ALGO funds
- Returns in ~10 seconds

---

## **4️⃣ Run Backend (1 min)**

```bash
cd /Users/srijan/808Pay/backend
npm run dev
```

You should see:
```
🚀 808Pay Backend running on http://localhost:3000
📝 Environment: development
✅ AlgorandService initialized (testnet)
```

---

## **5️⃣ Test Network Health (1 min)**

```bash
curl http://localhost:3000/api/algorand/health
```

**Expected Response:**
```json
{
  "network": "testnet",
  "status": "healthy",
  "latestRound": 35127643,
  "genesisTxnId": "mainnet-v1.0",
  "message": "Network is healthy"
}
```

✅ If you see "healthy" → Everything works!

---

## **6️⃣ Test Full Settlement Flow**

**Option A: Using curl**
```bash
curl -X POST http://localhost:3000/api/transactions/settle \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "sender": "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAY5HVIA",
      "recipient": "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBY46DEA",
      "amount": 50000,
      "timestamp": '$(date +%s)',
      "category": "electronics"
    },
    "signature": "0000000000000000000000000000000000000000000000000000000000000000",
    "publicKey": "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAY5HVIA"
  }'
```

**Option B: Using test script**
```bash
cd /Users/srijan/808Pay
bash test-backend-categories.sh
```

---

## **7️⃣ View Result**

**Response includes:**
```json
{
  "success": true,
  "transactionId": "tx_abc123...",
  "algoTransaction": {
    "txId": "AAAAAAAAA4E3B6X3AB7QY2RDY4...",
    "blockNumber": 35127643,
    "confirmed": true
  }
}
```

**View on Algorand Testnet:**
```
https://testnet.algoexplorer.io/tx/AAAAAAAAA4E3B6X3AB7QY2RDY4...
```

---

## **Available Endpoints**

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/algorand/health` | GET | Check network status |
| `/api/algorand/balance/:address` | GET | Get account balance |
| `/api/algorand/transaction/:txnId` | GET | Get transaction details |
| `/api/algorand/history/:address` | GET | Get transaction history |
| `/api/transactions/settle` | POST | Submit settlement |

---

## **Demo Mode vs Production**

### **Demo Mode (Current - No Contract)**
```
PAYMENT_APP_ID=0
→ Uses payment transactions
→ Settlement data stored in note field
→ Works immediately
→ Perfect for demo/hackathon
```

### **Production Mode (With Smart Contract)**
```
PAYMENT_APP_ID=<CONTRACT_ID>
→ Uses app call transactions
→ Calls smart contract logic
→ Data stored in contract state
→ More secure & auditable
```

To deploy contract:
```bash
cd /Users/srijan/808Pay/contracts
algokit deploy testnet
# Will output PAYMENT_APP_ID → Add to .env
```

---

## **Mobile Testing**

```bash
cd /Users/srijan/808Pay/mobile
flutter pub get
flutter run
```

When settlement succeeds:
- ✅ Show result widget
- 📦 Display Algorand txn ID
- 🔗 Link to AlgoExplorer
- 💳 Show payment breakdown

---

## **Debug Checklist**

### **❌ "Network is unhealthy"**
- Check internet connection
- Verify API token in .env
- Check if testnet is up: https://status.algorand.org/

### **❌ "Invalid address"**
- Use valid Algorand addresses (58 chars, start with A-Z)
- Generate with: `algokit generate account`

### **❌ "Insufficient balance"**
- Get test funds: https://testnet-dispenser.algorand.org/
- Wait 10 seconds after dispenser grants

### **❌ "Transaction failed"**
- Check creator mnemonic is correct
- Verify creator address has balance
- Check transaction size isn't too large

---

## **What Each Component Does**

### **AlgorandService (Backend)**
```typescript
await algorandService.submitSettlement({...})
// → Submits transaction to Algorand
// → Waits for confirmation
// → Returns transaction ID
```

### **AlgorandService (Flutter)**
```dart
await AlgorandService.getBalance(address)
// → Queries account balance
// → Shows on AlgoExplorer
// → Formats as display text
```

### **SettlementResultWidget**
```dart
showDialog(
  context: context,
  builder: (context) => SettlementResultWidget(result: response)
)
// → Shows beautiful result dialog
// → Displays all transaction info
// → Links to AlgoExplorer
// → Copy buttons for transaction IDs
```

---

## **Verify Everything Works**

✅ Backend starts
```bash
npm run dev
# No errors
```

✅ Network is healthy
```bash
curl http://localhost:3000/api/algorand/health
# Returns "healthy"
```

✅ Can get balance
```bash
curl http://localhost:3000/api/algorand/balance/AAAA...
# Returns balance in microAlgos
```

✅ Settlement submits
```bash
curl -X POST http://localhost:3000/api/transactions/settle \
  -H "Content-Type: application/json" \
  -d '...'
# Returns transaction with algoTransaction field
```

✅ View on explorer
```
Open in browser:
https://testnet.algoexplorer.io/tx/<TXN_ID>
```

---

## **Next Steps**

1. ✅ Get API token (Purestake)
2. ✅ Update .env
3. ✅ Get test funds (Dispenser)
4. ✅ Run backend (`npm run dev`)
5. ✅ Test endpoints (curl)
6. ✅ View on explorer
7. ✅ Test from Flutter
8. ✅ Show to judges!

---

## **Questions?**

**Documentation:**
- ALGORAND_INTEGRATION_COMPLETE.md - Full implementation details
- ALGORAND_INTEGRATION_PLAN.md - Architecture & design
- ATOMIC_SETTLEMENT_CONCEPT.md - Multi-party settlement

**Resources:**
- Algorand Docs: https://developer.algorand.org/
- AlgoExplorer: https://testnet.algoexplorer.io/
- AlgoKit Docs: https://algorandfoundation.github.io/algokit-cli/

**Status:** 🎉 Ready for testing!
