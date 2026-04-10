# 808Pay - Implementation Guide

## Getting Started

### Prerequisites
- [ ] Python 3.9+
- [ ] Node.js v18+
- [ ] Flutter SDK
- [ ] Algorand Testnet wallet (funded)
- [ ] AlgoKit CLI
- [ ] Git

### Installation Order

```bash
# 1. Backend (already done)
cd 808Pay
npm install

# 2. AlgoKit & Smart Contract
pip install algokit pyteal algorand-python-sdk

# 3. Flutter
flutter pub get

# 4. Start backend
npm run dev

# 5. Deploy smart contract
algokit deploy

# 6. Run Flutter app
flutter run
```

---

## Phase 2: Smart Contract Implementation

### What We Need to Build

1. **Smart Contract File**: `contracts/payment_settlement.py`
   - Ed25519 signature verification
   - Payment splitting logic
   - Loyalty token minting
   - Settlement recording

2. **Testing**: `contracts/tests/test_payment.py`
   - Unit tests for each function
   - Integration tests with testnet

3. **Deployment**: `algokit.yaml`
   - Configuration for testnet
   - Contract parameters

### Smart Contract Pseudocode

```python
class PaymentSettlement:
    
    def __init__(self):
        self.merchant_fee_percent = 90
        self.tax_percent = 5
        self.loyalty_percent = 5
    
    def verify_signature(self, data, signature, public_key):
        # Use Ed25519 to verify
        # Returns: True/False
        
    def split_payment(self, amount):
        merchant = amount * 0.90
        tax = amount * 0.05
        loyalty = amount * 0.05
        return {merchant, tax, loyalty}
    
    def settle_payment(self, transaction_data, signature, public_key):
        # 1. Verify signature
        if not verify_signature(transaction_data, signature, public_key):
            return error("Invalid signature")
        
        # 2. Extract amount
        amount = transaction_data['amount']
        merchant = transaction_data['merchant']
        
        # 3. Split payment
        splits = split_payment(amount)
        
        # 4. Transfer funds to merchant
        # 5. Transfer tax to tax address
        # 6. Mint loyalty tokens
        
        return {
            success: True,
            transaction_id: uuid(),
            splits: splits
        }
```

---

## Phase 3: Flutter Frontend Implementation

### Project Structure

```
mobile_808pay/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── screens/
│   │   ├── home_screen.dart      # Main menu
│   │   ├── payment_screen.dart   # Create payment
│   │   ├── qr_screen.dart        # Display/scan QR
│   │   ├── history_screen.dart   # Transaction history
│   │   └── settings_screen.dart  # Wallet connection
│   ├── services/
│   │   ├── pera_wallet_service.dart   # Wallet integration
│   │   ├── api_service.dart           # Backend API calls
│   │   ├── qr_service.dart            # QR generation
│   │   └── storage_service.dart       # Local storage
│   ├── models/
│   │   ├── transaction_model.dart
│   │   ├── payment_model.dart
│   │   └── wallet_model.dart
│   ├── widgets/
│   │   ├── payment_card.dart
│   │   ├── qr_display.dart
│   │   └── transaction_item.dart
│   └── utils/
│       ├── constants.dart
│       ├── themes.dart
│       └── validators.dart
├── pubspec.yaml
└── ios/ android/
```

### Key Screens

#### 1. Home Screen
- Connect Wallet button (Pera)
- Create Payment button
- View History button
- Settings

#### 2. Payment Creation Screen
- Amount input field
- Merchant selection dropdown
- Payment preview
- Confirm/Cancel buttons

#### 3. QR Display Screen
- Large QR code
- Transaction details below
- Share button
- Copy to clipboard button

#### 4. QR Scan Screen
- Camera view
- QR detection overlay
- Confirmation dialog
- Error handling

#### 5. History Screen
- List of transactions
- Pending vs Settled tabs
- Transaction details on tap
- Refresh button

---

## Phase 4: Integration Testing

### Test Scenarios

#### Scenario 1: Full Offline Payment
1. User creates payment offline (no internet)
2. QR code generated
3. Go online
4. Backend receives QR
5. Signature verified ✓
6. Smart contract validates ✓
7. Payment split ✓
8. Confirmation returned ✓

#### Scenario 2: Invalid Signature
1. User creates payment
2. Signature tampered with
3. Backend receives
4. Verification fails ✗
5. Error returned to user ✗

#### Scenario 3: Multiple Payments
1. Create 3 payments offline
2. Go online
3. All 3 settle successfully
4. Loyalty points minted for each
5. All visible in history ✓

---

## Configuration Files

### algokit.yaml (TO CREATE)
```yaml
name: 808pay
version: 1.0.0
description: Offline payment settlement on Algorand

deployments:
  testnet:
    network: testnet
    creator: ${PERA_WALLET_ADDRESS}
    creator_mnemonic: ${WALLET_MNEMONIC}
    
projects:
  payment_settlement:
    path: contracts/payment_settlement.py
    deployment: testnet
```

### Boiler Configuration
- Use standard boiler template for Flutter
- Configure for iOS and Android
- Setup signing for app stores

---

## Pera Wallet Integration Checklist

- [ ] Create Pera Wallet Connect ID
- [ ] Configure allowed origins
- [ ] Add redirect URIs
- [ ] Test wallet connection
- [ ] Test transaction signing
- [ ] Handle wallet disconnection
- [ ] Store user preferences

---

## Next Actions

1. **Review** this entire documentation
2. **Confirm** we're using:
   - ✅ AlgoKit for smart contracts
   - ✅ VibeKit for Flutter UI
   - ✅ Boiler template for project structure
   - ✅ Pera Wallet for authentication
3. **Ask** any clarifying questions
4. **Start coding** when ready

---

**Are you ready to proceed with smart contract development (Phase 2)?**
