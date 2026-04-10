# 808Pay Quick Command Reference

**Copy-paste ready commands for common tasks**

---

## 🚀 **Initial Setup (One Time)**

```bash
# Clone repo
git clone https://github.com/srijansrivastava03/808Pay.git
cd 808Pay

# Install dependencies
cd backend && npm install && cd ..
cd mobile && flutter pub get && cd ..

# Copy environment template
cp .env.example .env

# Edit .env with your settings
# For localnet: just set ALGO_NETWORK=localnet
# For testnet: add ALGORAND_TOKEN, etc.
```

---

## 🔷 **Local Development (AlgoKit Localnet)**

### Terminal 1: Start Algorand Network
```bash
# Make sure Docker is running first!
algokit localnet start
# Leave this running
```

### Terminal 2: Deploy Smart Contract
```bash
cd 808Pay
python3 contracts/deploy.py
# Save the App ID it shows!
```

### Terminal 3: Start Backend Server
```bash
cd 808Pay/backend
npm run dev
# Should see: "✅ Smart contract app loaded"
```

### Terminal 4: Start Flutter App
```bash
cd 808Pay/mobile
flutter run -d chrome
# Opens at http://localhost:54540
```

### Check Everything Works
```bash
curl http://localhost:3000/api/algorand/health
# Should return: "status": "healthy"
```

---

## 🌐 **Testnet Setup**

### Step 1: Create Account & Get ALGO
```bash
# Generate account
algokit generate account
# Save mnemonic!

# Get testnet ALGO (need address from above)
# Go to: https://dispenser.testnet.algorand.com/
# Paste address, wait ~30s
```

### Step 2: Get PureStake API Key
```bash
# Visit: https://www.purestake.com/
# Sign up → Copy Testnet API Key
```

### Step 3: Configure .env
```bash
# Edit .env with:
ALGO_NETWORK=testnet
ALGORAND_TOKEN=your-purestake-key
ALGORAND_SERVER=https://testnet-algorand.api.purestake.io/ps2
ALGORAND_INDEXER=https://testnet-algorand.api.purestake.io/idx2
CREATOR_MNEMONIC=your-24-word-mnemonic
CREATOR_ADDRESS=your-algorand-address
```

### Step 4: Deploy & Run
```bash
python3 contracts/deploy.py
# Update PAYMENT_APP_ID in backend/.env with the App ID

cd backend
npm run dev

cd mobile
flutter run -d chrome
```

---

## 🧪 **Testing**

```bash
# Run all backend tests
cd backend && npm test

# Run Flutter tests
cd mobile && flutter test

# Run specific Flutter test file
cd mobile && flutter test test/atomic_settlement_integration_test.dart

# Expected: 14/14 tests passing ✅
```

---

## 🔍 **Debugging & Verification**

```bash
# Check Algorand network status
curl http://localhost:3000/api/algorand/health

# Get account balance
curl http://localhost:3000/api/algorand/balance/YOUR_ADDRESS

# Get transaction details
curl http://localhost:3000/api/algorand/transaction/TX_ID

# Get account transaction history
curl http://localhost:3000/api/algorand/history/YOUR_ADDRESS
```

---

## 🛑 **Cleanup & Stop**

```bash
# Stop local Algorand network
algokit localnet stop

# Stop Docker containers
docker stop $(docker ps -q)

# Stop backend/Flutter (Ctrl+C in the terminal)
# Or kill by port:
lsof -i :3000  # backend
lsof -i :8888  # flutter

# Kill process by port
kill -9 $(lsof -t -i:3000)
```

---

## 📱 **Common Flutter Commands**

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d chrome     # Chrome browser
flutter run -d web        # Web development
flutter run -d android    # Android (if emulator running)

# Build release version
flutter build web --release

# Get dependencies
flutter pub get

# Run tests
flutter test

# Clean build
flutter clean
```

---

## 🐍 **Common Python Commands**

```bash
# Check Python version
python3 --version

# Install dependencies for contracts
cd contracts
pip3 install -r requirements.txt

# Run deployment script
python3 deploy.py

# Test contract compilation
python3 contract.py
```

---

## 📦 **Backend npm Commands**

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Run tests
npm test

# Build for production
npm run build

# Start production server
npm start
```

---

## 🔗 **Useful Links**

```
Local Algorand: http://localhost:4001
Testnet Explorer: https://testnet.algoexplorer.io/
Backend API: http://localhost:3000
Flutter App: http://localhost:54540
Testnet Faucet: https://dispenser.testnet.algorand.com/
PureStake: https://www.purestake.com/
```

---

## ⚠️ **Port Reference**

| Service | Port | URL |
|---------|------|-----|
| Algorand Node (localnet) | 4001 | http://localhost:4001 |
| Algorand Indexer | 8980 | http://localhost:8980 |
| PostgreSQL | 5432 | localhost:5432 |
| Backend API | 3000 | http://localhost:3000 |
| Flutter Web | 54540+ | http://localhost:54540 |

---

## 🆘 **Emergency Commands**

```bash
# Reset everything (careful!)
algokit localnet stop
docker stop $(docker ps -q)
docker system prune -a
git clean -fd

# Full reinstall
rm -rf node_modules package-lock.json
npm install

# Check what's using ports
lsof -i -P -n | grep LISTEN

# Kill process on specific port
kill -9 $(lsof -t -i:3000)
```

---

## 💡 **Pro Tips**

```bash
# Watch backend logs in real-time
npm run dev 2>&1 | grep -E "✅|❌|Error"

# Test contract without deployment
python3 contracts/payment_settlement/contract.py | head -50

# Check environment is set correctly
grep -E "ALGO_NETWORK|PAYMENT_APP_ID" .env

# Dry-run a settlement (see what would happen)
curl -X POST http://localhost:3000/api/transactions/atomic-settle-sc \
  -H "Content-Type: application/json" \
  --data-raw '{}' \
  -i  # Shows headers only
```

---

**Last Updated:** April 2026
**Questions?** Check `TEAM_SETUP_GUIDE.md` or the documentation files
