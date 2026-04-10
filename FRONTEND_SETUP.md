# 808Pay Frontend Setup Guide

## Quick Start for Frontend Developer

This guide is for the Flutter frontend developer on the 808Pay team.

### Prerequisites
- Flutter SDK installed
- Dart SDK (comes with Flutter)
- iOS Simulator or Android Emulator running
- Pera Wallet mobile app (for testing)

### What's Already Done ✅
- Backend API running on `http://localhost:3000`
- Smart contract being developed (will be deployed to testnet)
- Local Algorand sandbox running on `http://localhost:4001`
- Docker infrastructure ready

### What You Need to Build
1. **Payment Creation Screen** - User enters amount, merchant, creates unsigned transaction
2. **QR Code Generation** - Display payment as QR code
3. **QR Code Scanner** - Scan merchant's QR to settle payment
4. **Transaction History** - Show pending and settled transactions
5. **Pera Wallet Integration** - Connect wallet, sign transactions

---

## Project Structure

```
808Pay/
├── src/                          # Backend (Express.js) - DO NOT MODIFY
├── contracts/                    # Smart Contracts - DO NOT MODIFY
├── mobile/                        # YOUR FLUTTER APP (CREATE THIS)
│   ├── lib/
│   │   ├── main.dart
│   │   ├── screens/
│   │   │   ├── payment_screen.dart
│   │   │   ├── qr_display_screen.dart
│   │   │   ├── qr_scanner_screen.dart
│   │   │   └── history_screen.dart
│   │   ├── services/
│   │   │   ├── pera_wallet_service.dart
│   │   │   ├── api_service.dart
│   │   │   └── transaction_service.dart
│   │   └── widgets/
│   │       ├── payment_card.dart
│   │       └── transaction_item.dart
│   ├── pubspec.yaml
│   ├── android/
│   └── ios/
└── README.md
```

---

## Backend API Endpoints (For Reference)

### Health Check
```
GET http://localhost:3000/health
Response: { status: "ok", timestamp: "..." }
```

### Settle Payment
```
POST http://localhost:3000/api/transactions/settle
Body: {
  data: "payment_data_bytes",
  signature: "0x...",           // Ed25519 signature from Pera Wallet
  publicKey: "0x..."           // User's public key
}
Response: {
  success: true,
  transactionId: "uuid",
  splits: {
    merchant: 45,              // 90% of 50
    tax: 2.5,                 // 5% of 50
    loyalty: 2.5              // 5% of 50
  }
}
```

### Get Transaction Status
```
GET http://localhost:3000/api/transactions/{id}
Response: {
  id: "uuid",
  status: "settled",
  sender: "user_address",
  recipient: "merchant_address",
  amount: 50,
  createdAt: "2026-04-10T...",
  settledAt: "2026-04-10T...",
  splits: { merchant: 45, tax: 2.5, loyalty: 2.5 }
}
```

### List Transactions
```
GET http://localhost:3000/api/transactions
Response: {
  count: 5,
  transactions: [...]
}
```

---

## Dependencies to Add (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Pera Wallet Integration
  pera_wallet_flutter: ^1.0.0
  
  # QR Code
  qr_flutter: ^4.0.0
  qr_code_scanner: ^1.0.0
  
  # HTTP Client
  http: ^1.0.0
  
  # State Management
  provider: ^6.0.0
  
  # Local Storage
  shared_preferences: ^2.0.0
  
  # Date Formatting
  intl: ^0.19.0
  
  # UI Components (VibeKit will be added later)
```

---

## Development Workflow

### Step 1: Initialize Flutter Project
```bash
cd /Users/srijan/808Pay
flutter create --org com.808pay mobile
cd mobile
```

### Step 2: Update pubspec.yaml
Add the dependencies above to `pubspec.yaml`

### Step 3: Get Dependencies
```bash
flutter pub get
```

### Step 4: Start Development
```bash
flutter run
```

### Step 5: Connect to Backend
Update `lib/services/api_service.dart`:
```dart
const String BASE_URL = 'http://localhost:3000/api';
```

---

## Key Integration Points

### 1. Pera Wallet Service
- Connect wallet
- Get user's Algorand address
- Sign transactions with Ed25519
- **File:** `lib/services/pera_wallet_service.dart`

### 2. API Service
- Call backend endpoints
- Handle payments
- Retrieve transaction history
- **File:** `lib/services/api_service.dart`

### 3. Transaction Service
- Create unsigned transactions
- Store locally (offline)
- Format data for signing
- **File:** `lib/services/transaction_service.dart`

---

## Testing Checklist

- [ ] Pera Wallet connects
- [ ] Can enter payment amount
- [ ] QR code generates correctly
- [ ] QR scanner works
- [ ] Payment signed by Pera Wallet
- [ ] Backend receives and settles payment
- [ ] Transaction appears in history
- [ ] Splits (90/5/5) are correct
- [ ] Can scan multiple payments

---

## Important Notes

⚠️ **Backend API runs on port 3000** - Make sure it's running:
```bash
npm run dev
```

⚠️ **Pera Wallet Integration** - Test with testnet wallet (not mainnet)

⚠️ **Offline Storage** - Use SharedPreferences to store pending transactions locally

⚠️ **Ed25519 Signing** - Pera Wallet handles this automatically, don't re-implement

---

## Questions?

- Backend API docs: See `src/routes/transactions.ts`
- Smart contract: See `contracts/payment_settlement/contract.py`
- Team: Coordinate with backend developer for API updates

Good luck! 🚀
