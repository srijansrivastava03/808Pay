# 808Pay - Algorand Offline Payment Settlement Engine

## 🚀 Get Started NOW

### Quick Install (No Building Required)
✅ **Download the pre-built APK**  
Visit [GitHub Releases](https://github.com/yourusername/808Pay/releases) and download `app-release.apk`
- No compilation needed
- No dependencies to install  
- Ready to install on Android phone
- Fully tested & signed

---

## Overview

**808Pay** is a blockchain-based offline payment system that enables secure transactions without internet connectivity. Users can generate cryptographically signed payment QR codes offline, and merchants can settle them when online using Algorand smart contracts.

## 🚀 Team Getting Started?

**New to the project?** Start here:

- **[TEAM_SETUP_GUIDE.md](./TEAM_SETUP_GUIDE.md)** - Complete step-by-step setup (5-15 min)
- **[QUICK_COMMANDS.md](./QUICK_COMMANDS.md)** - Copy-paste ready commands

Choose your path:
- **Local Development** (easiest) - Run Algorand in Docker on your machine
- **Testnet** (for testing with real ALGO) - Use Algorand public testnet

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│  BACKEND (Express.js + Node.js)                         │
│  - Transaction Settlement                              │
│  - Signature Verification (Ed25519)                     │
│  - Payment Splitting Logic                              │
│  - In-Memory Transaction Store                          │
└─────────────────────────────────────────────────────────┘
         ↑
         │ HTTP REST API
         ↓
┌─────────────────────────────────────────────────────────┐
│  FRONTEND (Flutter Mobile / React Web)                  │
│  - Offline Payment Creation                             │
│  - QR Code Generation                                   │
│  - Cryptographic Signing                                │
│  - Transaction History                                  │
└─────────────────────────────────────────────────────────┘
         ↑
         │ Settlement
         ↓
┌─────────────────────────────────────────────────────────┐
│  BLOCKCHAIN (Algorand)                                  │
│  - Smart Contract Validation                            │
│  - Payment Splits (90/5/5)                              │
│  - Loyalty Points Minting                               │
│  - Immutable Settlement Records                         │
└─────────────────────────────────────────────────────────┘
```

## Quick Start

### Option 1: Download & Install (Easiest) 📱

**Get the pre-built APK from GitHub Releases:**
1. Go to [GitHub Releases](https://github.com/yourusername/808Pay/releases)
2. Download the latest `app-release.apk`
3. Transfer to your Android device and tap to install
4. Open the app and connect your Pera Wallet
5. Done! Ready to use

---

### Option 2: Run from Source 🔧

#### Prerequisites
- **Backend**: Node.js v18+, npm/yarn, Port 3000 available
- **Mobile**: Flutter 3.0+, Android SDK (for APK building)
- **Both**: Git

#### Backend Setup

```bash
cd /Users/srijan/808Pay/backend

# Install dependencies
npm install

# Build TypeScript
npm run build

# Development (with hot reload)
npm run dev

# Demo (test the full flow)
npm run demo

# Production
PORT=3000 npm run start
```

Backend will start on `http://localhost:3000`

#### Mobile Setup

```bash
cd /Users/srijan/808Pay/mobile

# Get dependencies
flutter pub get

# Run on connected Android device (dev mode - debug)
flutter run

# Build release APK (production)
flutter build apk --release
```

Built APK location: `build/app/outputs/flutter-apk/app-release.apk`

---

### Complete Setup Flow

**Step 1: Start Backend**
```bash
cd /Users/srijan/808Pay/backend
npm install && npm run build
PORT=3000 npm run dev
```

**Step 2: Start Mobile App**
```bash
cd /Users/srijan/808Pay/mobile
flutter pub get
flutter run  # or flutter build apk --release
```

**Step 3: Connect to Pera Wallet**
- Open app on Android device
- Tap "Connect Wallet"
- Authorize Pera Wallet connection
- Select testnet account

**Step 4: Try a Payment**
- Go to "Create Payment" tab
- Enter amount (e.g., ₹100)
- Use QR or NFC to set recipient
- Sign with wallet
- Watch balance update in real-time

## API Endpoints

### Health Check
```bash
GET http://localhost:3000/api/algorand/health

Response:
{
  "status": "ok",
  "network": "testnet",
  "timestamp": "2026-04-09T..."
}
```

### Settle Transaction
```bash
POST http://localhost:3000/api/transactions/settle

Request Body:
{
  "data": {...transaction data...},
  "signature": "0x...",
  "publicKey": "0x..."
}

Response:
{
  "success": true,
  "transactionId": "uuid-string",
  "message": "Transaction settled successfully",
  "splits": {
    "merchant": 90,
    "tax": 8,
    "loyalty": 2
  }
}
```

### Get Transaction Status
```bash
GET http://localhost:3000/api/transactions/:id

Response:
{
  "id": "uuid-string",
  "status": "settled",
  "sender": "0x...",
  "recipient": "merchant_001",
  "amount": 5000,
  "createdAt": "2026-04-09T...",
  "settledAt": "2026-04-09T...",
  "splits": {...}
}
```

### List All Transactions
```bash
GET http://localhost:3000/api/transactions

Response:
{
  "count": 5,
  "transactions": [...]
}
```

## Project Structure

```
808Pay/
├── backend/
│   ├── src/
│   │   ├── index.ts                 # Express server entry point
│   │   ├── services/
│   │   │   ├── algorandService.ts   # Algorand blockchain integration
│   │   │   ├── settlementService.ts # Payment settlement logic
│   │   │   └── cryptoService.ts     # Ed25519 verification
│   │   ├── routes/
│   │   │   ├── transactions.ts      # Payment routes
│   │   │   └── algorand.ts          # Blockchain routes
│   │   └── types/
│   │       └── index.ts             # TypeScript interfaces
│   ├── dist/                        # Compiled JavaScript
│   └── package.json
├── mobile/
│   ├── lib/
│   │   ├── main.dart                # App entry point
│   │   ├── screens/
│   │   │   ├── home_screen.dart     # Dashboard with balance
│   │   │   ├── payment_screen.dart  # Create payment (QR/NFC)
│   │   │   └── sync_screen.dart     # View & manage queued transactions
│   │   ├── services/
│   │   │   ├── pera_wallet_service_v2.dart  # Wallet connection
│   │   │   ├── nfc_transfer_service.dart    # NFC tap-to-transfer
│   │   │   ├── transaction_queue_service.dart # Offline queue
│   │   │   ├── settlement_sync_service.dart  # Auto-sync when online
│   │   │   └── balance_service.dart         # Balance tracking
│   │   ├── widgets/
│   │   │   └── nfc_confirmation_overlay.dart # Animated confirmation circle
│   │   └── theme/
│   │       └── app_theme.dart       # UI theme (red & black)
│   ├── android/
│   │   └── app/src/main/AndroidManifest.xml # NFC permissions
│   ├── build/
│   │   └── app/outputs/
│   │       └── flutter-apk/
│   │           └── app-release.apk  # ✅ Ready-to-install APK
│   └── pubspec.yaml
├── contracts/
│   └── payment_settlement/
│       └── contract.py              # PyTeal smart contract
└── README.md
```

## Key Features

### 📱 Mobile App Features
- **Offline-First**: Create and sign payments without internet
- **Pera Wallet Integration**: Real Ed25519 signing with private key stored on device
- **QR Code Scanning**: Scan merchant QR or create payment QR
- **NFC Tap-to-Transfer**: Tap two devices together to exchange payment data
- **Real-Time Balance**: See balance update immediately after payment
- **Transaction Queue**: Payments queue automatically when offline
- **Auto-Sync**: When online, queued payments automatically submit to settlement
- **Network Status**: Visual indicator (🟢 online / 🔴 offline)
- **Sync Management**: View pending transactions and clear queue if needed

### ⛓️ Blockchain Features
- **Offline Transaction Creation**: Sign payments with Ed25519 private key (no internet needed)
- **Smart Contract Verification**: Algorand validates signatures and splits payments atomically
- **Payment Splitting**: 90% merchant, 8% platform, 2% loyalty (automatic)
- **Atomic Settlement**: All-or-nothing guarantee - payment either fully settles or fully fails
- **Immutable Records**: Once on blockchain, transactions cannot be reversed or tampered with

### 1. Offline Transaction Creation
- Users can create payments without internet
- Transactions are signed with Ed25519 private keys
- QR codes contain complete transaction data + signature

### 2. Signature Verification
- Backend verifies Ed25519 signatures
- Uses tweetnacl.js for cryptography
- Ensures transactions haven't been tampered with

### 3. Payment Splitting
- **Merchant**: 90% of payment
- **Tax/Regulatory**: 8%
- **Loyalty Points**: 2%

Example: ₹100 payment → ₹90 merchant, ₹8 platform, ₹2 loyalty

### 4. Smart Contract Settlement
- Algorand blockchain handles final settlement
- Dual-signature verification (both parties sign)
- Prevents replay attacks with settlement counter
- Records immutably on-chain

## How It Works

### Offline Flow
1. User enters payment amount (₹50)
2. App creates transaction object
3. App signs with private key (offline - no internet needed)
4. QR code generated with signed transaction data

### Online Settlement Flow
1. Merchant scans QR → backend receives data
2. Backend verifies signature with user's public key
3. Backend validates transaction structure
4. Payment splits calculated automatically
5. Transaction marked as "settled"
6. Response sent back with confirmation

### Verification Without Internet
```
User's Transaction Data
         ↓
User's Private Key (on device)
         ↓
Create Signature (offline math)
         ↓
Anyone Can Verify:
  - Transaction Data
  - Signature
  - User's Public Key
  = Mathematical Proof of Authenticity
  (No internet needed for verification!)
```

## Crypto Details

### Ed25519
- Modern public-key signature algorithm
- 32-byte keys (256-bit)
- Secure, efficient, widely used
- Used by Bitcoin, Algorand, and many others

### Key Format
- Public Key: 32 bytes → 64 hex characters → `0x...`
- Signature: 64 bytes → 128 hex characters → `0x...`

### How Verification Works
```typescript
verifySignature(data, signature, publicKey)
  ↓
1. Hash transaction data
2. Use public key + signature to verify hash
3. If math checks out → Signature is valid
4. If not → Signature is forged
```

## Testing

### Download & Install Release (Recommended) 📥

**Quick start without building from source:**

1. Visit: [GitHub Releases](https://github.com/yourusername/808Pay/releases)
2. Download latest `app-release.apk` (already tested & signed)
3. Install on Android device:
   ```bash
   adb install app-release.apk
   ```
   Or transfer APK file to phone and tap to install
4. Start backend locally and scan QR codes

---

### Run Demo (Backend Only)
```bash
cd /Users/srijan/808Pay/backend
npm run demo
```

This will:
1. Start local server
2. Simulate a payment flow
3. Show settlement summary

### Manual Testing with cURL

```bash
# Check backend health
curl http://localhost:3000/api/algorand/health

# Get settlement data
curl http://localhost:3000/api/transactions

# Settle a transaction
curl -X POST http://localhost:3000/api/transactions/settle \
  -H "Content-Type: application/json" \
  -d '{
    "data": {...},
    "signature": "0x...",
    "publicKey": "0x..."
  }'
```

### Test NFC Features

- **Tap-to-Transfer**: Two devices with NFC enabled
- **Hold devices together** after tapping NFC button
- **Watch confirmation circle animate**
- **Tap to confirm** or auto-confirm after 5 seconds

## Environment Variables

```env
PORT=3000                                    # Backend server port
NODE_ENV=development                         # Environment (development/production)
PAYMENT_APP_ID=7752881                       # Algorand smart contract app ID
ALGORAND_SERVER=https://lora1-api.algokit.io # Algorand testnet API
```

## Next Steps (For Production)

1. **Algorand Smart Contract**
   - Deploy PyTeal contract to testnet/mainnet
   - Handle settlement on-chain
   - Mint loyalty tokens (ASA)

2. **Flutter Frontend**
   - Mobile app for payment creation
   - QR scanning with camera
   - Offline transaction storage

3. **Database**
   - Replace in-memory store with PostgreSQL
   - Add transaction history persistence
   - Add merchant/user management

4. **Security**
   - Secure key storage in device enclave
   - Rate limiting on API endpoints
   - Transaction amount limits
   - KYC/AML compliance

5. **Deployment**
   - Deploy backend to cloud (Heroku, Railway, etc.)
   - Publish Flutter app to stores
   - Deploy smart contract to mainnet

## Dependencies

- **express**: Web framework
- **tweetnacl**: Ed25519 crypto library
- **cors**: Cross-origin resource sharing
- **dotenv**: Environment variable management
- **uuid**: Unique ID generation
- **typescript**: Type-safe JavaScript
- **axios**: HTTP client (for demo)

## Downloads & Releases

### 📥 Latest Release
**[Download APK from GitHub Releases](https://github.com/yourusername/808Pay/releases)**

- `app-release.apk` - Production build (64.4MB)
- Pre-signed and ready to install
- Full NFC support enabled
- Real-time balance tracking
- Auto-sync on network connection

### Installation Steps
1. Download `.apk` file from releases
2. Transfer to Android device or click to download directly
3. Enable "Install from Unknown Sources" in settings
4. Tap APK file to install
5. Open app and connect Pera Wallet

---

## License

MIT

## Contact & Support

📧 **Questions?** Check the docs or open an issue on GitHub  
🐛 **Found a bug?** Submit an issue with details  
💬 **Want to contribute?** Pull requests welcome!

### Related Resources
- [Algorand Docs](https://developer.algorand.org)
- [Flutter Docs](https://flutter.dev/docs)
- [Pera Wallet](https://perawallet.app)
- [PyTeal](https://pyteal.readthedocs.io)

---

**Built for Blockchain Payment Innovation with ❤️**
