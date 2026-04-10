# 808Pay Pera Wallet & Mobile Integration Guide

## Quick Start for Pera Wallet & Mobile Developer

This guide is for the member handling Pera Wallet integration and mobile QR functionality.

### Prerequisites
- Flutter SDK installed
- Pera Wallet app installed on iOS/Android simulator or device
- Basic Flutter knowledge
- Understanding of cryptographic signing

### Current Status ✅
- ✅ Backend API built and running (port 3000)
- ✅ Smart contract being deployed
- 🔄 Frontend team starting Flutter project
- ⏳ Your role: Wallet + QR integration

---

## Your Tasks

### Phase 1: Pera Wallet Integration (Hours 0-2)
1. Add pera_wallet_flutter package
2. Implement wallet connection
3. Get user's Algorand address
4. Test account switching (testnet/mainnet)

### Phase 2: QR Functionality (Hours 2-4)
1. Add QR generation (qr_flutter)
2. Add QR scanning (qr_code_scanner)
3. Parse payment data from QR
4. Integrate with transaction flow

### Phase 3: Transaction Signing (Hours 4-5)
1. Create unsigned transactions
2. Send to Pera Wallet for signing
3. Capture signed transaction
4. Send to backend for settlement
5. Handle wallet rejections

### Phase 4: Polish (Hours 5-6)
1. Error handling
2. User feedback (loading states)
3. Edge cases
4. Demo preparation

---

## Pera Wallet Integration

### Step 1: Add Package

In `pubspec.yaml`:
```yaml
dependencies:
  pera_wallet_flutter: ^1.0.0
```

Then:
```bash
flutter pub get
```

### Step 2: Create Pera Wallet Service

File: `lib/services/pera_wallet_service.dart`

```dart
import 'package:pera_wallet_flutter/pera_wallet_flutter.dart';

class PeraWalletService {
  late PeraWalletConnect peraWalletConnect;
  late String? connectedAddress;
  
  PeraWalletService() {
    peraWalletConnect = PeraWalletConnect();
  }
  
  // Initialize Pera Wallet
  Future<void> initialize() async {
    await peraWalletConnect.init();
  }
  
  // Connect wallet
  Future<String?> connectWallet() async {
    try {
      final session = await peraWalletConnect.connect();
      if (session != null && session.isNotEmpty) {
        connectedAddress = session.first;
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
  
  // Get connected address
  String? getConnectedAddress() => connectedAddress;
  
  // Check if wallet is connected
  bool isConnected() => connectedAddress != null;
  
  // Sign transaction
  Future<String?> signTransaction(String txn) async {
    try {
      final signedTxn = await peraWalletConnect.signTransaction(
        txn,
        message: "Sign payment transaction for 808Pay",
      );
      return signedTxn;
    } catch (e) {
      print("Transaction signing failed: $e");
    }
    return null;
  }
  
  // Sign multiple transactions
  Future<List<String>?> signTransactions(List<String> txns) async {
    try {
      final signedTxns = await peraWalletConnect.signTransactions(
        txns,
        message: "Sign multiple transactions",
      );
      return signedTxns;
    } catch (e) {
      print("Multi-transaction signing failed: $e");
    }
    return null;
  }
}
```

### Step 3: Test Wallet Connection

Create a simple test screen:

```dart
class WalletTestScreen extends StatefulWidget {
  @override
  State<WalletTestScreen> createState() => _WalletTestScreenState();
}

class _WalletTestScreenState extends State<WalletTestScreen> {
  final peraService = PeraWalletService();
  String? walletAddress;
  
  @override
  void initState() {
    super.initState();
    peraService.initialize();
  }
  
  Future<void> _connectWallet() async {
    final address = await peraService.connectWallet();
    setState(() {
      walletAddress = address;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Wallet Test")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (walletAddress != null)
              Text("Connected: $walletAddress")
            else
              Text("Not connected"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _connectWallet,
              child: Text("Connect Wallet"),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## QR Code Implementation

### Step 1: Add QR Packages

In `pubspec.yaml`:
```yaml
dependencies:
  qr_flutter: ^4.0.0
  qr_code_scanner: ^1.0.0
```

### Step 2: QR Generation Service

File: `lib/services/qr_service.dart`

```dart
import 'package:qr_flutter/qr_flutter.dart';

class QRService {
  // Generate QR code data from transaction
  String generateQRData({
    required String sender,
    required String recipient,
    required double amount,
    required String timestamp,
  }) {
    // Format: 808PAY:sender:recipient:amount:timestamp
    return "808PAY:$sender:$recipient:$amount:$timestamp";
  }
  
  // Parse QR code data
  Map<String, String>? parseQRData(String qrData) {
    try {
      final parts = qrData.split(":");
      if (parts.length < 5 || parts[0] != "808PAY") {
        return null;
      }
      
      return {
        "sender": parts[1],
        "recipient": parts[2],
        "amount": parts[3],
        "timestamp": parts[4],
      };
    } catch (e) {
      print("QR parsing failed: $e");
      return null;
    }
  }
}
```

### Step 3: QR Display Widget

File: `lib/widgets/qr_display.dart`

```dart
import 'package:qr_flutter/qr_flutter.dart';

class QRDisplay extends StatelessWidget {
  final String qrData;
  final double size;
  
  const QRDisplay({
    required this.qrData,
    this.size = 300,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: QrImage(
        data: qrData,
        version: QrVersions.auto,
        size: size,
        gapless: true,
        errorStateBuilder: (ctx, err) {
          return Container(
            child: Center(
              child: Text("Error generating QR code"),
            ),
          );
        },
      ),
    );
  }
}
```

### Step 4: QR Scanner Widget

File: `lib/widgets/qr_scanner.dart`

```dart
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScannerWidget extends StatefulWidget {
  final Function(String) onScan;
  
  const QRScannerWidget({required this.onScan});
  
  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;
  
  @override
  void reassemble() {
    super.reassemble();
    controller.pauseCamera();
    controller.resumeCamera();
  }
  
  @override
  Widget build(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.blue,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: 300,
      ),
    );
  }
  
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        controller.pauseCamera();
        widget.onScan(scanData.code!);
        // Don't dispose, just pause for now
      }
    });
  }
  
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
```

---

## Transaction Signing Flow

### Step 1: Create Unsigned Transaction

```dart
class TransactionService {
  // Create unsigned transaction
  Map<String, dynamic> createUnsignedTransaction({
    required String sender,
    required String recipient,
    required double amount,
  }) {
    return {
      'sender': sender,
      'recipient': recipient,
      'amount': amount,
      'timestamp': DateTime.now().toIso8601String(),
      'nonce': _generateNonce(),
    };
  }
  
  String _generateNonce() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
```

### Step 2: Sign Transaction

```dart
Future<void> _signAndSettle(BuildContext context) async {
  // 1. Create transaction
  final txn = transactionService.createUnsignedTransaction(
    sender: walletAddress!,
    recipient: merchantAddress,
    amount: amount,
  );
  
  // 2. Convert to JSON string for signing
  final txnJson = jsonEncode(txn);
  
  // 3. Sign with Pera Wallet
  final signature = await peraService.signTransaction(txnJson);
  
  if (signature == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Signing failed or cancelled")),
    );
    return;
  }
  
  // 4. Get public key from wallet
  final publicKey = walletAddress;
  
  // 5. Send to backend for settlement
  final result = await apiService.settleTransaction(
    data: txnJson,
    signature: signature,
    publicKey: publicKey,
  );
  
  // 6. Handle result
  if (result['success']) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment settled: ₹${result['splits']['merchant']}")),
    );
  }
}
```

---

## Complete Integration Workflow

### Payment Creation Flow
```
User Input → Create Transaction → Generate QR → Display QR
                                      ↓
                            User shares/shows QR
                                      ↓
                        Merchant scans QR (payment details)
                                      ↓
                        User confirms → Sign with Pera Wallet
                                      ↓
                        Send to Backend → Settlement
                                      ↓
                        Show confirmation → Add to history
```

---

## Error Handling

```dart
// Wallet connection errors
try {
  final address = await peraService.connectWallet();
} on PeraWalletException catch (e) {
  print("Wallet error: ${e.message}");
  // Handle error
}

// QR parsing errors
final data = qrService.parseQRData(qrData);
if (data == null) {
  showError("Invalid QR code");
  return;
}

// Signing errors
try {
  final signature = await peraService.signTransaction(txn);
} catch (e) {
  showError("Failed to sign transaction: $e");
}

// Network errors
try {
  final result = await apiService.settleTransaction(...);
} catch (e) {
  showError("Settlement failed: $e");
}
```

---

## Testing Checklist

- [ ] Pera Wallet connects
- [ ] User's address displays correctly
- [ ] QR code generates
- [ ] QR code scans successfully
- [ ] Payment data parses from QR
- [ ] Transaction signs with Pera Wallet
- [ ] Backend receives signed transaction
- [ ] Payment settles successfully
- [ ] Confirmation message displays
- [ ] Transaction appears in history
- [ ] Error handling works

---

## Important Notes

⚠️ **Testnet Only**: Always use testnet addresses, never mainnet

⚠️ **Key Security**: Pera Wallet handles all key operations - NEVER ask user for private keys

⚠️ **Signature Format**: Pera returns Ed25519 signatures - backend verifies them

⚠️ **QR Format**: Use consistent format so scanning is reliable

⚠️ **Camera Permissions**: Request permissions in pubspec.yaml for both iOS/Android

---

## Permissions Setup

### iOS (Info.plist)
```xml
<key>NSCameraUsageDescription</key>
<string>808Pay needs camera access to scan payment QR codes</string>
```

### Android (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.CAMERA" />
```

---

## Timeline

| Time | Task | Output |
|------|------|--------|
| 0-1h | Pera Wallet setup | Wallet connection working |
| 1-2h | QR generation | QR codes displaying |
| 2-3h | QR scanning | QR codes scanning |
| 3-4h | Transaction signing | Pera signing working |
| 4-5h | Integration | Full flow working |
| 5-6h | Polish & testing | Ready for demo |

---

## Resources

- Pera Wallet Docs: https://github.com/perawallet/pera-wallet
- QR Flutter: https://pub.dev/packages/qr_flutter
- QR Code Scanner: https://pub.dev/packages/qr_code_scanner
- Flutter Permissions: https://pub.dev/packages/permission_handler

---

## Communication

- **Frontend Lead**: Coordinate UI/UX
- **Backend Developer**: Clarify payment settlement API
- **Smart Contract Dev**: Understand signature verification
- **Team**: Daily sync-ups

Good luck! 🚀
