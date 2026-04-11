# 808Pay - Complete Implementation Roadmap

## Current State vs. Production State

### BACKEND (Backend Service)

#### Current State ✅
- Connected to real Algorand testnet
- All GST/tax calculations working
- Settlement logic implemented
- Balance validation implemented
- Transaction storage working

#### Missing for Production ⏳
- User wallet credentials in `.env`
- Real database (using in-memory store)
- Transaction history persistence
- Merchant account management
- Admin dashboard

#### How to Make Real (5 minutes)
```bash
# 1. Get testnet ALGO from faucet
curl -X POST "https://testnet-dispenser.algoexplorer.io/ma" \
  -H "Content-Type: application/json" \
  -d '{"recipient":"YOUR_PERA_ADDRESS"}'

# 2. Update .env
nano /Users/srijan/808Pay/backend/.env
# Add:
# CREATOR_ADDRESS=YOUR_PERA_ADDRESS
# CREATOR_MNEMONIC=your 25 word recovery phrase

# 3. Restart
cd /Users/srijan/808Pay/backend
PORT=3000 npm run dev

# 4. Test
curl http://localhost:3000/api/algorand/health
# Should show "status": "healthy"
```

---

### MOBILE APP (Flutter)

#### Current State ⚠️
- UI built (deal creation, QR display, wallet widget)
- QR generation working
- QR scanner UI implemented (real-time camera)
- Mock wallet connection

#### What's Hardcoded ❌
1. **Transaction Signing** - Not implemented
   - Currently: Sends fake signature `"0xdemo"`
   - Should: Sign with Ed25519 using wallet

2. **QR Data** - Returns demo data
   - Currently: `"deal_id:12345|amount:500|..."`
   - Should: Parse actual scanned QR

3. **Backend API** - Not wired
   - Currently: All local/simulated
   - Should: Call `http://backend:3000/api/transactions/settle`

4. **Pera Wallet** - Just UI
   - Currently: Shows "Wallet Connected" (no-op)
   - Should: Actually use wallet for signing

#### How to Fix (In Order)

##### Step 1: Implement Transaction Signing (1 hour)

**File:** `lib/services/crypto_service.dart` (create if doesn't exist)

```dart
import 'package:cryptography/cryptography.dart' as crypto;

class CryptoService {
  // Generate Ed25519 key pair from seed
  static Future<Map<String, String>> generateKeyPair(String seed) async {
    final algorithm = crypto.Ed25519();
    final keyPair = await algorithm.newKeyPairFromSeed(
      utf8.encode(seed).sublist(0, 32),
    );
    
    final publicKey = await keyPair.extractPublicKey();
    final privateKey = await keyPair.extractPrivateKeyBytes();
    
    return {
      'publicKey': base64.encode(publicKey.bytes),
      'privateKey': base64.encode(privateKey),
    };
  }

  // Sign transaction data
  static Future<String> signTransaction(
    Map<String, dynamic> data,
    String privateKey,
  ) async {
    final algorithm = crypto.Ed25519();
    final privateKeyBytes = base64.decode(privateKey);
    
    final signature = await algorithm.sign(
      utf8.encode(jsonEncode(data)),
      keyPairFromBytes(privateKeyBytes),
    );
    
    return base64.encode(signature.bytes);
  }
}
```

##### Step 2: Wire QR Scanner to Backend (1 hour)

**File:** `lib/screens/deal_verification_screen.dart` (update)

```dart
void _proceedToSettlement() async {
  if (_amountStatus != 'match') return;

  setState(() => _isProcessing = true);

  try {
    // Get wallet info
    final publicKey = await peraWalletService.getPublicKey();
    
    // Sign transaction
    final signature = await cryptoService.signTransaction({
      'sender': publicKey,
      'recipient': widget.receiver,
      'amount': int.parse(widget.amount),
      'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'category': 'electronics', // TODO: get from deal
    }, privateKey);

    // Send to backend
    final response = await http.post(
      'http://YOUR_BACKEND_IP:3000/api/transactions/settle',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'data': {
          'sender': publicKey,
          'recipient': widget.receiver,
          'amount': int.parse(widget.amount),
          'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          'category': 'electronics',
        },
        'signature': signature,
        'publicKey': publicKey,
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Settlement successful!\nTxn: ${result['transactionId']}'),
          backgroundColor: AppColors.success,
        ),
      );
      
      // Show explorer link
      final explorerUrl = 'https://testnet.algoexplorer.io/tx/${result['algoTransaction']['txId']}';
      print('📊 View on explorer: $explorerUrl');
      
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
    );
  } finally {
    setState(() => _isProcessing = false);
  }
}
```

##### Step 3: Connect to Real Pera Wallet (2 hours)

**File:** `lib/services/pera_wallet_service.dart` (update)

```dart
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class PeraWalletService extends ChangeNotifier {
  late Web3App _web3App;
  bool _isConnected = false;
  String? _userAddress;

  // Initialize WalletConnect
  Future<void> initialize() async {
    _web3App = Web3App(
      projectId: 'YOUR_WALLETCONNECT_PROJECT_ID',
      metadata: PairingMetadata(
        name: '808Pay',
        description: 'Atomic payment settlement on Algorand',
        url: 'https://808pay.com',
        icons: ['https://808pay.com/icon.png'],
      ),
    );

    // Listen for connection changes
    _web3App.onSessionConnect.subscribe(_onSessionConnect);
    _web3App.onSessionDisconnect.subscribe(_onSessionDisconnect);
  }

  // Connect wallet
  Future<void> connectWallet() async {
    try {
      final uri = await _web3App.connect(
        requiredNamespaces: {
          'algorand': RequiredNamespace(
            chains: ['algorand:SGO1'],  // Testnet
            methods: ['algo_sign_txn'],
            events: ['algo_eventLog'],
          ),
        },
      );

      // Show connection URI to user (for deeplink)
      launch(uri.toString());
    } catch (e) {
      print('Connection error: $e');
    }
  }

  // Sign transaction with wallet
  Future<String> signTransaction(dynamic txn) async {
    if (!_isConnected) throw Exception('Wallet not connected');
    
    final response = await _web3App.request(
      topic: _userAddress!,
      chainId: 'algorand:SGO1',
      request: SessionRequestParams(
        method: 'algo_sign_txn',
        params: [txn],
      ),
    );

    return response;
  }

  void _onSessionConnect(SessionConnect? event) {
    _isConnected = true;
    _userAddress = event?.session.acknowledgedAccounts.first;
    notifyListeners();
  }

  void _onSessionDisconnect(SessionDisconnect? event) {
    _isConnected = false;
    _userAddress = null;
    notifyListeners();
  }
}
```

---

## Implementation Checklist

### Backend (Ready Now - Just Add Credentials)
- [x] Algorand network connection
- [x] Settlement service
- [x] GST calculation
- [x] Balance validation
- [x] Transaction storage
- [ ] Add `.env` with Pera wallet
- [ ] Start backend server
- [ ] Test with curl

### Mobile App - Phase 1 (1-2 Hours)
- [ ] Implement Ed25519 signing
- [ ] Create CryptoService
- [ ] Wire to backend API
- [ ] Test settlement endpoint

### Mobile App - Phase 2 (2-3 Hours)
- [ ] Integrate WalletConnect
- [ ] Real Pera wallet connection
- [ ] Wallet-based transaction signing
- [ ] Show Algorand explorer links

### Mobile App - Phase 3 (1-2 Hours)
- [ ] Complete QR scanner (mobile_scanner)
- [ ] Parse real QR data
- [ ] Amount validation improvement
- [ ] Transaction history display

### Testing & Deployment
- [ ] E2E testing (create → scan → sign → settle)
- [ ] Error handling
- [ ] Network error recovery
- [ ] Analytics/logging

---

## Testing the Complete Flow

### Step 1: Backend Setup
```bash
# Get testnet ALGO
# Update .env with Pera wallet
# Start backend
cd /Users/srijan/808Pay/backend
PORT=3000 npm run dev
```

### Step 2: Mobile Testing
```bash
# Run mobile app
cd /Users/srijan/808Pay/mobile
flutter run

# Steps:
1. Create deal (₹500, Electronics category)
2. Generate QR code
3. Tap "Scan Deal"
4. Scan the QR code
5. Verify amount matches
6. Complete settlement
7. Check backend logs for "Transaction submitted to Algorand"
8. View transaction on: https://testnet.algoexplorer.io/
```

### Step 3: Verify on Blockchain
```bash
# Every settlement creates a transaction record on Algorand testnet
# Find it at: https://testnet.algoexplorer.io/tx/<txId>

# Should see:
- Sender address
- Recipient address
- Amount with GST splits
- Transaction note
- Immutable record on blockchain
```

---

## Production Deployment

### Backend
```bash
# Replace testnet with mainnet
export ALGO_NETWORK=mainnet
export ALGORAND_SERVER=https://mainnet-api.algonode.cloud
export ALGORAND_INDEXER=https://mainnet-idx.algonode.cloud

# Use production Pera wallet
export CREATOR_ADDRESS=<production-wallet-address>
export CREATOR_MNEMONIC=<production-mnemonic>

# Deploy with Docker
docker build -t 808pay-backend .
docker run -e PORT=3000 -e NODE_ENV=production 808pay-backend
```

### Mobile
```bash
# Build release APK
flutter build apk --release

# Or iOS app
flutter build ios --release
```

---

## Success Criteria

### Backend ✅ Real if:
- [ ] `/api/algorand/health` returns "status": "healthy"
- [ ] `/api/transactions/settle` submits to blockchain
- [ ] Backend logs show "Transaction submitted to Algorand: <txId>"
- [ ] Transaction appears on https://testnet.algoexplorer.io/

### Mobile ✅ Real if:
- [ ] Can create and scan QR codes
- [ ] Sends signed transaction to backend
- [ ] Amount validation works (matches settlement)
- [ ] Receives transaction ID from backend

### Fully Real if:
- [ ] End-to-end flow works without any hardcoding
- [ ] All transactions appear on Algorand blockchain
- [ ] GST splits are correct
- [ ] Amount mismatch is ONLY due to tax deduction (not hardcoding)

---

## Next Actions (Priority Order)

1. **IMMEDIATE:** Add Pera wallet to backend `.env` (5 min)
2. **TODAY:** Implement mobile signing (1 hour)
3. **THIS WEEK:** Wire mobile to backend API (2 hours)
4. **NEXT:** Complete QR scanner integration (2 hours)
5. **THEN:** E2E testing and deployment

After these steps, it will be **100% real, 0% hardcoded**.
