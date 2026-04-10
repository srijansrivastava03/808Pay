# 808Pay - Team Setup Guide

**For team members cloning the repo and wanting to run the Algorand integration locally.**

---

## 📋 Prerequisites

Before you start, make sure you have:

- **Node.js** v18+ (`node --version`)
- **Python** 3.10+ (`python3 --version`)
- **Docker** installed (for local Algorand network)
- **Git** (already set up)
- A Unix-like shell (Mac/Linux terminal or WSL on Windows)

```bash
# Verify all are installed
node --version    # v18.0.0+
python3 --version # 3.10+
docker --version  # Docker version
```

---

## 🚀 Quick Start (5 minutes)

### Step 1: Clone & Install Dependencies

```bash
# Clone the repo (if not already done)
git clone https://github.com/srijansrivastava03/808Pay.git
cd 808Pay

# Install backend dependencies
cd backend
npm install
cd ..

# Install mobile (Flutter) dependencies
cd mobile
flutter pub get
cd ..
```

### Step 2: Set Up Environment

Copy the example environment file and fill it in:

```bash
# From root directory
cp .env.example .env
```

Edit `.env` with your information:

```env
# Choose your network:
# - localnet (for local development - easiest)
# - testnet (for testing on Algorand testnet)
ALGO_NETWORK=localnet

# Only needed for testnet:
# Get from: https://www.purestake.com/
ALGORAND_TOKEN=your-purestake-api-key-here
ALGORAND_SERVER=https://testnet-algorand.api.purestake.io/ps2
ALGORAND_INDEXER=https://testnet-algorand.api.purestake.io/idx2

# For smart contract deployment:
CREATOR_ADDRESS=your-algorand-address
CREATOR_MNEMONIC=your-24-word-mnemonic
```

### Step 3: Choose Your Path

---

## 🔷 **Path A: Local Development (Recommended for beginners)**

Runs Algorand on your machine in Docker. No external accounts needed.

### 1. Start Local Algorand Network

```bash
# Make sure Docker is running first!
docker ps  # This should show Docker is accessible

# Start the local Algorand network
algokit localnet start
```

**Expected output:**
```
Starting AlgoKit localnet...
✓ algod running at http://localhost:4001
✓ indexer running at http://localhost:8980
✓ PostgreSQL running at localhost:5432
```

Leave this terminal open (it will keep the services running).

### 2. Deploy Smart Contract (New Terminal)

Open a **new terminal window** and run:

```bash
cd /Users/srijan/808Pay  # or your 808Pay directory
python3 contracts/deploy.py
```

**Expected output:**
```
========================================
  Deployment Information
========================================
App ID: 1001
Creator: AAAA...
Network: LOCALNET
Settlement Counter: 0
Total Volume: 0

✅ Contract deployed successfully!
```

**Save the App ID** shown (e.g., `1001`).

### 3. Update Backend Configuration

Edit `backend/.env`:

```env
PAYMENT_APP_ID=1001
CREATOR_ADDRESS=AAAA...
DEPLOY_NETWORK=localnet
```

### 4. Start Backend Server

```bash
cd backend
npm run dev
```

**Expected output:**
```
🚀 Server running on http://localhost:3000
✅ Smart contract app loaded (ID: 1001)
📦 Environment: development
```

### 5. Verify Setup

In a **new terminal**, test the health endpoint:

```bash
curl http://localhost:3000/api/algorand/health
```

**Expected response:**
```json
{
  "network": "localnet",
  "status": "healthy",
  "latestRound": 1234,
  "message": "Network is healthy"
}
```

✅ If you see `"status": "healthy"`, you're done!

### 6. Run the Flutter App

In **another terminal**:

```bash
cd mobile
flutter run -d chrome  # or -d web for browser
```

The app should open at `http://localhost:54540` (or similar port).

---

## 🌐 **Path B: Algorand Testnet (For testing with real ALGO)**

Use Algorand's public testnet. Requires an account and free testnet ALGO.

### 1. Create/Fund an Algorand Account

**Option A: Generate a new account**
```bash
algokit generate account
```

Save the output - you'll get a mnemonic and address.

**Option B: Use AlgoExplorer**
1. Go to: https://www.algoexplorer.io/
2. Click "Create Account"
3. Download your account details
4. Save your mnemonic (24 words)

### 2. Get Free Testnet ALGO

Visit: https://dispenser.testnet.algorand.com/

- Paste your address from Step 1
- Click "Get Testnet ALGO"
- Wait ~30 seconds for confirmation
- You'll get 10 test ALGO

### 3. Get PureStake API Key

1. Go to: https://www.purestake.com/
2. Sign up for free account
3. Go to Dashboard
4. Copy your **Testnet API Key**

### 4. Update .env

```env
ALGO_NETWORK=testnet
ALGORAND_TOKEN=your-purestake-api-key
ALGORAND_SERVER=https://testnet-algorand.api.purestake.io/ps2
ALGORAND_INDEXER=https://testnet-algorand.api.purestake.io/idx2
CREATOR_ADDRESS=your-algorand-address
CREATOR_MNEMONIC=your-24-word-mnemonic-here
```

### 5. Deploy Smart Contract

```bash
cd /Users/srijan/808Pay
python3 contracts/deploy.py
```

**Expected output:**
```
========================================
  Deployment Information
========================================
App ID: 12345
Creator: XXXXX...
Network: TESTNET
```

Save the App ID.

### 6. Update Backend Configuration

Edit `backend/.env`:

```env
PAYMENT_APP_ID=12345
DEPLOY_NETWORK=testnet
```

### 7. Start Backend Server

```bash
cd backend
npm run dev
```

### 8. Test Settlement Flow

```bash
# Test with a dummy settlement
curl -X POST http://localhost:3000/api/transactions/atomic-settle-sc \
  -H "Content-Type: application/json" \
  -d '{
    "dealId": "deal-123",
    "buyerAddress": "BUYER_ADDRESS",
    "buyerSignature": "0000...",
    "sellerAddress": "SELLER_ADDRESS", 
    "sellerSignature": "0000...",
    "amount": 50000,
    "category": "electronics",
    "settlingPartyAddress": "YOUR_ADDRESS"
  }'
```

### 9. View Transaction

The response will include a `transactionId`. View it on Algorand Testnet:

```
https://testnet.algoexplorer.io/tx/[transactionId]
```

---

## 🧪 Testing

### Run All Tests

```bash
# Backend tests
cd backend
npm test

# Flutter tests
cd mobile
flutter test
```

### Run Specific Test Suite

```bash
# E2E integration tests
cd mobile
flutter test test/atomic_settlement_integration_test.dart
```

Expected: **14/14 tests passing** ✅

### Manual Flow Test

1. **Open Flutter app** at `http://localhost:54540`
2. **Create a deal**:
   - Select Buyer/Seller role
   - Enter amount (₹5000)
   - Choose category (Electronics)
   - Enter addresses
   - Click "Create Deal"

3. **Sign the deal**:
   - Both parties click "Sign"
   - Progress should go 1/2 → 2/2
   - Auto-navigate to confirmation

4. **Submit settlement**:
   - Review payment breakdown
   - Click "Submit to Settlement"
   - Get transaction ID back

5. **Verify on blockchain**:
   - Copy transaction ID
   - Visit Algorand Testnet Explorer
   - Paste transaction ID to view on-chain record

---

## 📁 Project Structure

```
808Pay/
├── backend/                    # Node.js/Express backend
│   ├── src/
│   │   ├── services/          # Business logic
│   │   ├── routes/            # REST endpoints
│   │   └── middleware/        # Express middleware
│   ├── package.json
│   └── .env                   # Backend config
├── mobile/                     # Flutter app
│   ├── lib/
│   │   ├── screens/           # UI screens
│   │   ├── services/          # Business logic
│   │   └── widgets/           # Reusable widgets
│   ├── test/                  # Tests
│   └── pubspec.yaml
├── contracts/                  # Smart contracts
│   ├── payment_settlement/
│   │   ├── contract.py        # PyTeal smart contract
│   │   └── deploy.py          # Deployment script
│   └── requirements.txt
├── docker-compose.yml         # Docker orchestration
├── .env                       # Environment config
└── README.md
```

---

## 🔧 Common Issues & Solutions

### Issue: "Docker daemon not running"

**Solution:**
```bash
# Start Docker (Mac)
open /Applications/Docker.app

# Or verify it's running
docker ps
```

### Issue: "Port 4001 already in use"

**Solution:**
```bash
# Stop existing containers
docker stop $(docker ps -q)

# Or run with different network:
algokit localnet stop
algokit localnet start
```

### Issue: "Python not found" when running deploy script

**Solution:**
```bash
# Use python3 explicitly
python3 contracts/deploy.py

# Or check Python installation
which python3
python3 --version  # Should be 3.10+
```

### Issue: "ALGORAND_TOKEN not found" on testnet

**Solution:**
```bash
# Make sure .env is set correctly
cat .env | grep ALGORAND_TOKEN

# If empty, go to https://www.purestake.com/ and get API key
# Then update .env:
ALGORAND_TOKEN=your-key-here
```

### Issue: "Connection refused" when calling backend endpoints

**Solution:**
```bash
# Make sure backend is running:
cd backend
npm run dev

# Check if it's listening on port 3000:
lsof -i :3000
```

### Issue: "Transaction failed - insufficient balance"

**Solution:**
```bash
# Get more testnet ALGO from faucet
https://dispenser.testnet.algorand.com/

# Paste your address and request ALGO
# Wait 30 seconds for confirmation
```

---

## 📞 Getting Help

### Documentation Files

- **SMART_CONTRACT_DEPLOYMENT.md** - Detailed contract deployment guide
- **ALGORAND_QUICK_START.md** - Algorand network quick reference
- **UI_COMPONENTS_GUIDE.md** - Flutter UI documentation
- **BACKEND_INTEGRATION_GUIDE.md** - Backend API reference

### Useful Links

- **Algorand Docs:** https://developer.algorand.org/
- **PyTeal Docs:** https://pyteal.readthedocs.io/
- **AlgoKit Docs:** https://github.com/algorand/algokit-cli
- **Testnet Faucet:** https://dispenser.testnet.algorand.com/
- **Testnet Explorer:** https://testnet.algoexplorer.io/

---

## ✅ Checklist: When You're Done

- [ ] Node.js, Python, Docker installed
- [ ] Repository cloned
- [ ] Dependencies installed (`npm install`, `flutter pub get`)
- [ ] `.env` file created and configured
- [ ] Local Algorand network running (or testnet configured)
- [ ] Smart contract deployed (App ID noted)
- [ ] Backend server running on port 3000
- [ ] Backend health check passing
- [ ] Flutter app running
- [ ] Manual settlement flow tested end-to-end
- [ ] All tests passing (14/14)

---

## 🎉 You're Ready!

Your local 808Pay environment is now fully set up and ready for development. 

**Next steps:**
1. Create a test deal in the app
2. Sign it with both parties
3. Submit and verify the settlement on-chain
4. Check transaction details on Algorand Explorer

Happy coding! 🚀
