# Pera Wallet Integration - Quick Start

**For team members integrating Pera Wallet into the 808Pay Flutter app**

---

## 🎯 What is Pera Wallet?

Pera Wallet is an **Algorand wallet** for iOS/Android that lets users securely sign transactions. Think of it like MetaMask but for Algorand.

**Why we need it:**
- Users can connect their Algorand accounts
- Sign payments with their private keys (keys stay secure in Pera)
- Submit settled transactions to the blockchain

---

## ✅ 5-Minute Setup

### Step 1: Install Pera Wallet App

**On your iOS/Android simulator or device:**
- Download: https://perawallet.app/
- Or install from App Store/Google Play

**Create a testnet account:**
1. Open Pera Wallet
2. Tap "Create Account"
3. Choose "Testnet" (important! not mainnet)
4. Save your recovery phrase (24 words)
5. Get test ALGO from faucet: https://dispenser.testnet.algorand.com/

### Step 2: Add Pera Package to Flutter

Edit `mobile/pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Add this line:
  pera_wallet_flutter: ^1.0.0
```

Then run:
```bash
cd mobile
flutter pub get
```

### Step 3: Create Pera Wallet Service

Create file: `mobile/lib/services/pera_wallet_service.dart`

```dart
import 'package:pera_wallet_flutter/pera_wallet_flutter.dart';

class PeraWalletService {
  late PeraWalletConnect peraWalletConnect;
  String? connectedAddress;
  
  PeraWalletService() {
    peraWalletConnect = PeraWalletConnect();
  }
  
  // Initialize Pera
  Future<void> initialize() async {
    await peraWalletConnect.init();
  }
  
  // Connect wallet (user approves in Pera Wallet app)
  Future<String?> connectWallet() async {
    try {
      final session = await peraWalletConnect.connect();
      if (session != null && session.isNotEmpty) {
        connectedAddress = session.first;
        print("Connected: $connectedAddress");
        return connectedAddress;
      }
    } catch (e) {
      print("Wallet connection failed: $e");
    }
    return null;
  }
  
  // Disconnect wallet
  Future<void> disconnectWallet() async {
    await peraWalletConnect.disconnect();
    connectedAddress = null;
  }
  
  // Get current address
  String? getAddress() => connectedAddress;
  
  // Check if connected
  bool isConnected() => connectedAddress != null;
  
  // Sign a transaction
  Future<String?> signTransaction(String txn) async {
    try {
      final signed = await peraWalletConnect.signTransaction(
        txn,
        message: "Sign payment for 808Pay",
      );
      return signed;
    } catch (e) {
      print("Signing failed: $e");
    }
    return null;
  }
}
```

### Step 4: Use in Your Screen

Create a button to connect wallet:

```dart
import 'package:flutter/material.dart';
import 'services/pera_wallet_service.dart';

class WalletScreen extends StatefulWidget {
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final peraService = PeraWalletService();
  String? walletAddress;
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
    peraService.initialize();
  }
  
  Future<void> _connectWallet() async {
    setState(() => isLoading = true);
    
    final address = await peraService.connectWallet();
    
    setState(() {
      walletAddress = address;
      isLoading = false;
    });
    
    if (address != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connected: $address")),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pera Wallet")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (walletAddress != null) ...[
              Text("Connected Wallet:", style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              SelectableText(
                walletAddress!,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'monospace',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await peraService.disconnectWallet();
                  setState(() => walletAddress = null);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: Text("Disconnect"),
              ),
            ] else ...[
              Text("Wallet not connected"),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _connectWallet,
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(),
                      )
                    : Text("Connect Wallet"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

### Step 5: Test Connection

```bash
cd mobile
flutter run -d chrome  # or your device
```

1. Tap "Connect Wallet"
2. Pera Wallet app opens on your device
3. Approve the connection
4. Your address appears on screen ✅

---

## 🔐 Signing Transactions with Pera

Once connected, sign transactions like this:

```dart
// Create an unsigned transaction (we'll provide this)
final unsignedTxn = createPaymentTransaction(
  sender: walletAddress,
  recipient: "MERCHANT_ADDRESS",
  amount: 5000,
);

// Sign with Pera Wallet (user confirms in Pera app)
final signedTxn = await peraService.signTransaction(unsignedTxn);

if (signedTxn != null) {
  // Send to backend for settlement
  final result = await apiService.settleTransaction(
    transaction: signedTxn,
  );
  
  print("Settlement successful: ${result['txId']}");
}
```

---

## 🔄 Full Payment Flow

```
User taps "Pay"
    ↓
Connect Pera Wallet (if not connected)
    ↓
Create payment transaction
    ↓
Generate QR code (show to merchant)
    ↓
User taps "Confirm & Sign"
    ↓
Pera Wallet opens (user approves)
    ↓
Signature captured
    ↓
Send to backend API
    ↓
Backend settles on blockchain
    ↓
Show confirmation "Payment settled!"
    ↓
Add to transaction history
```

---

## 📱 iOS & Android Permissions

### iOS (ios/Runner/Info.plist)

Add camera permission for QR scanning:

```xml
<key>NSCameraUsageDescription</key>
<string>808Pay needs camera to scan QR codes</string>
```

### Android (android/app/src/main/AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.CAMERA" />
```

---

## ⚠️ Important Notes

1. **Always use TESTNET** - Never test with real money (mainnet)
   - Testnet addresses start with `AAAA...`
   - Mainnet addresses also start with `AAAA...` but have different prefix

2. **Keys Stay Safe** - Pera Wallet holds user's private keys
   - Never ask user for private keys
   - Never extract keys from Pera
   - Always use Pera for signing

3. **Offline Signing** - User signs offline, you send online
   - Get signature from Pera
   - Send to backend when online
   - Backend submits to blockchain

4. **Error Handling** - User might reject in Pera app
   - Show clear error messages
   - Let user try again
   - Don't crash the app

---

## 🧪 Testing Checklist

- [ ] Pera Wallet app installed
- [ ] Testnet account created
- [ ] Test ALGO obtained from faucet
- [ ] Flutter app connects to Pera
- [ ] Wallet address displays correctly
- [ ] Sign button works
- [ ] Pera app opens when signing
- [ ] Signature captured correctly
- [ ] Error handling works (reject/cancel)
- [ ] Can disconnect and reconnect

---

## 🐛 Common Issues

### Issue: "Pera Wallet app not installed"

**Solution:**
```bash
# Download from App Store (iOS) or Google Play (Android)
# Or install from: https://perawallet.app/
```

### Issue: "Cannot connect to simulator"

**Solution:**
```bash
# Make sure Pera is actually open in the simulator
# Try disconnecting and reconnecting
# Restart simulator if needed
```

### Issue: "Invalid transaction format"

**Solution:**
```dart
// Make sure transaction is properly formatted
// Transaction must be:
// - Valid Algorand transaction
// - Base64 encoded
// - Unsigned (not yet signed)

// Check with backend developer on format
```

### Issue: "User rejected in Pera app"

**Solution:**
```dart
// This is normal! User can reject for any reason
if (signedTxn == null) {
  print("User rejected signing");
  // Show message: "Signing cancelled"
  // Let user try again
}
```

---

## 📚 Resources

- **Pera Wallet Docs:** https://github.com/perawallet/pera-wallet
- **pera_wallet_flutter Package:** https://pub.dev/packages/pera_wallet_flutter
- **Algorand Documentation:** https://developer.algorand.org/
- **Testnet Faucet:** https://dispenser.testnet.algorand.com/

---

## 🎓 Next Steps After Setup

1. **QR Code Generation** - Display payment as QR code
2. **QR Code Scanning** - Scan merchant's QR to pay
3. **Transaction History** - Show past settlements
4. **Integration with Backend** - Send signed transactions
5. **Error Handling** - Handle network/wallet errors
6. **Testing** - Full E2E flow with real Pera wallet

---

## 📞 Getting Help

- **Backend Integration:** Ask backend dev about API format
- **Pera Issues:** Check https://github.com/perawallet/pera-wallet
- **Flutter Help:** Check Flutter documentation
- **Team:** Daily syncs to align on progress

---

## ✅ Success Criteria

**Wallet integration is working when:**

✅ User can tap "Connect Wallet"
✅ Pera Wallet app opens
✅ User approves connection
✅ Wallet address displays in app
✅ User can sign a transaction
✅ Signature is captured correctly
✅ Backend receives signed transaction
✅ Payment settles on blockchain

**When all these work → Move to next phase** 🚀
