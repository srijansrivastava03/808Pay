# 808Pay Flutter Mobile App

Flutter mobile application for 808Pay - Algorand-based payment settlement system.

## Features

- **Payment Creation** - Create unsigned transactions for payments
- **QR Code Generation** - Display payments as QR codes
- **QR Code Scanner** - Scan merchant QR codes for settlement
- **Transaction History** - View all transactions and their status
- **Pera Wallet Integration** - Sign transactions with Ed25519 signatures

## Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart SDK (comes with Flutter)
- iOS Simulator or Android Emulator
- Pera Wallet mobile app (for testing)

## Setup

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Update Configuration

Update the backend URL in `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'http://localhost:3000/api';
```

### 3. Run the App

```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
│   └── transaction.dart         # Transaction model
├── screens/                     # UI screens
│   ├── payment_screen.dart
│   ├── history_screen.dart
│   ├── qr_display_screen.dart
│   └── qr_scanner_screen.dart
├── services/                    # Services & API
│   ├── api_service.dart         # Backend API calls
│   ├── pera_wallet_service.dart # Wallet integration
│   └── transaction_service.dart # Transaction logic
└── widgets/                     # Reusable widgets
    ├── payment_card.dart
    └── transaction_item.dart
```

## Backend Integration

The app connects to the 808Pay backend running on `http://localhost:3000`.

### Key Endpoints

- `GET /health` - Health check
- `POST /api/transactions/settle` - Submit signed payment
- `GET /api/transactions` - Get transaction history
- `GET /api/transactions/{id}` - Get transaction details

## Next Steps

- [ ] Implement Pera Wallet connection
- [ ] Add QR code scanner functionality
- [ ] Complete transaction signing flow
- [ ] Add error handling and logging
- [ ] Implement state management (Provider/GetX)
- [ ] Add UI polish and animations
- [ ] Write unit & integration tests
- [ ] Deploy to TestFlight and Google Play

## Support

For questions or issues, refer to the main [README.md](../README.md) or FRONTEND_SETUP.md
