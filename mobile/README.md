# 808Pay Mobile (Flutter)

Flutter mobile application for offline Algorand payments with Pera Wallet integration.

## Project Structure

```
mobile/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── screens/                  # UI screens
│   │   ├── home_screen.dart      # Navigation hub
│   │   ├── payment_screen.dart   # Create payments
│   │   ├── qr_scanner_screen.dart# Scan QR codes
│   │   └── history_screen.dart   # Transaction history
│   ├── services/                 # Business logic
│   │   ├── api_service.dart      # Backend communication
│   │   ├── pera_wallet_service.dart  # Wallet integration
│   │   └── transaction_service.dart  # Transaction utilities
│   ├── widgets/                  # Reusable UI components
│   │   ├── payment_card.dart     # Payment preview card
│   │   └── transaction_item.dart # Transaction list item
│   └── models/                   # Data models
│       └── transaction_model.dart# Transaction data model
├── android/                      # Android platform code
├── ios/                          # iOS platform code
└── pubspec.yaml                  # Dependencies & config
```

## Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Dart SDK (included with Flutter)
- Xcode (macOS/iOS development)
- Android Studio (Android development)
- Pera Wallet app installed on device/emulator

### Setup

1. **Install dependencies:**
   ```bash
   cd mobile
   flutter pub get
   ```

2. **Run the app:**
   ```bash
   # iOS
   flutter run -d iPhone

   # Android
   flutter run -d android

   # Web (testing)
   flutter run -d chrome
   ```

3. **Build for production:**
   ```bash
   # iOS
   flutter build ios

   # Android
   flutter build apk  # or flutter build appbundle for Play Store
   ```

## Key Features to Implement

### 1. Main Screens

**Home Screen** (`screens/home_screen.dart`)
- Bottom navigation with 3 tabs: Send, Scan, History
- Navigation between screens
- Status: Skeleton complete, needs UI refinement

**Payment Screen** (`screens/payment_screen.dart`)
- Amount input field
- Recipient address input
- Create payment button
- Integration: Connect to `ApiService.createPayment()`
- TODO: Add QR code display, offline signing

**QR Scanner Screen** (`screens/qr_scanner_screen.dart`)
- Uses `qr_code_scanner` package
- Camera preview with QR detection
- Parse transaction data from QR codes
- TODO: Permission handling, error recovery

**History Screen** (`screens/history_screen.dart`)
- List all past transactions
- Show status (pending/completed/failed)
- Integration: Connect to `ApiService.getTransactionHistory()`
- TODO: Filtering, sorting, refresh

### 2. Services

**API Service** (`services/api_service.dart`)
- Communicates with backend on `http://localhost:3000/api`
- Methods:
  - `createPayment()` - Create new transaction
  - `getTransactionStatus()` - Check transaction status
  - `getTransactionHistory()` - List all transactions
  - `settleTransaction()` - Submit signed transaction
- TODO: Handle errors, retry logic, timeout management

**Pera Wallet Service** (`services/pera_wallet_service.dart`)
- Integrates with `pera_wallet_flutter` package
- Methods:
  - `initialize()` - Initialize wallet connection
  - `getAccounts()` - Get connected wallet addresses
  - `signTransaction()` - Sign transactions with Ed25519
  - `requestConnection()` - Request wallet connection
  - `disconnect()` - Disconnect from wallet
  - `isConnected()` - Check connection status
- TODO: Full integration with Pera Wallet API

**Transaction Service** (`services/transaction_service.dart`)
- Utility functions for transaction handling:
  - `generateTransactionId()` - Create unique transaction IDs
  - `createTransactionData()` - Format transaction for signing
  - `validateTransactionData()` - Validate transaction format
  - `formatTransactionForQR()` - Encode transaction as QR
  - `parseTransactionFromQR()` - Decode transaction from QR
  - `calculateSplits()` - Calculate 90/5/5 split
  - Status check helpers
- Status: Complete, ready to use

### 3. Models & Widgets

**Transaction Model** (`models/transaction_model.dart`)
- Data class for transaction objects
- JSON serialization/deserialization
- Status flags (isPending, isCompleted, isFailed)
- Status: Complete

**Payment Card Widget** (`widgets/payment_card.dart`)
- Displays payment preview (amount, recipient)
- Edit/delete actions
- Status: Complete, ready for use

**Transaction Item Widget** (`widgets/transaction_item.dart`)
- List item for transaction history
- Shows status with color coding
- Timestamp display
- Status: Complete, ready for use

## Development Workflow

1. **Clone the repository:**
   ```bash
   git clone https://github.com/srijansrivastava03/808Pay.git
   cd 808Pay/mobile
   ```

2. **Start backend & Algorand:**
   ```bash
   # In another terminal, start backend
   cd backend
   npm run dev

   # And start Algorand sandbox
   cd contracts
   algokit localnet start
   ```

3. **Implement screens:**
   - Use provided scaffolds as base
   - Replace TODO comments with actual logic
   - Test against running backend

4. **Connect services:**
   - Complete Pera Wallet integration
   - Implement API calls in `ApiService`
   - Test with backend endpoints

5. **Test locally:**
   - Use Flutter emulator or physical device
   - Test with local backend on localhost:3000
   - Verify Pera Wallet connection

6. **Commit & push:**
   ```bash
   git add .
   git commit -m "feat: implement [feature_name]"
   git push origin main
   ```

## Dependencies

Key packages (see `pubspec.yaml` for full list):
- **flutter** - UI framework
- **provider** - State management
- **pera_wallet_flutter** - Algorand wallet integration
- **qr_flutter** - QR code generation
- **qr_code_scanner** - QR code scanning
- **http** - HTTP client for API calls
- **shared_preferences** - Local data storage
- **uuid** - Unique ID generation

## Environment Variables

Create `.env` file in `mobile/` (if needed):
```
API_BASE_URL=http://localhost:3000/api
ALGORAND_NETWORK=testnet
```

## Error Handling

Always wrap API calls in try-catch:
```dart
try {
  final result = await ApiService.createPayment(...);
} catch (e) {
  showErrorDialog(context, 'Error: $e');
}
```

## Testing Checklist

- [ ] Wallet connects successfully
- [ ] Can create payment (offline)
- [ ] Can scan QR codes
- [ ] Payment settles on backend
- [ ] Transaction history displays
- [ ] Works on iOS
- [ ] Works on Android

## Debugging Tips

1. **View logs:** `flutter logs`
2. **Debug app:** `flutter run -v` for verbose output
3. **Hot reload:** Press `r` in terminal to reload
4. **Hot restart:** Press `R` in terminal for full restart
5. **Check backend:** Visit `http://localhost:3000/api/transactions`

## Backend API Reference

See `/BACKEND_INTEGRATION_GUIDE.md` for full API documentation.

### Key Endpoints

- `POST /api/transactions/settle` - Settle payment
- `GET /api/transactions/:id` - Get transaction status
- `GET /api/transactions` - List transactions

## Support

- Backend integration: See `BACKEND_INTEGRATION_GUIDE.md`
- Wallet setup: See `WALLET_INTEGRATION_GUIDE.md`
- Smart contracts: See `SMART_CONTRACT_GUIDE.md`

## Next Steps

1. Run `flutter pub get` to install dependencies
2. Replace TODO comments with implementations
3. Test each screen individually
4. Integrate Pera Wallet connection
5. Connect to backend API
6. Test end-to-end payment flow
