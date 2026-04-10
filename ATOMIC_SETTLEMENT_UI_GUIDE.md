## **808Pay Atomic Settlement - UI Implementation Guide**

### **Overview**
Atomic settlement requires TWO parties to sign the same transaction. The UI must show:
1. Who needs to sign (Buyer + Seller)
2. How many signatures are collected
3. When both have signed (ready to settle)
4. Clear status at each step

---

## **1. Data Model Updates Needed**

### **Update Transaction Model**
```dart
class Transaction {
  // ... existing fields ...
  
  // NEW: Multi-sig support
  List<String> requiredSignatures = [];      // Array of collected signatures
  int requiredSignatureCount = 1;             // How many needed (default 1, atomic = 2)
  Map<String, String> participants = {};      // {role: publicKey} e.g., {"buyer": "0x...", "seller": "0x..."}
  
  // Status tracking
  String signingStatus = 'PENDING_SIGNATURES'; // PENDING_SIGNATURES, PARTIALLY_SIGNED, FULLY_SIGNED
  
  // Getters
  bool get isFullySigned => requiredSignatures.length >= requiredSignatureCount;
  bool get isPartiallySigned => requiredSignatures.isNotEmpty && !isFullySigned;
  int get signaturesRemaining => requiredSignatureCount - requiredSignatures.length;
}
```

---

## **2. UI Screens to Create/Update**

### **Screen 1: Create Atomic Deal (New)**
**File:** `mobile/lib/screens/atomic_deal_screen.dart`

**Purpose:** Let buyer AND seller initiate an atomic deal

**UI Components:**
```
┌─────────────────────────────────────────────┐
│     CREATE ATOMIC DEAL (2-Party Payment)    │
├─────────────────────────────────────────────┤
│                                             │
│  ⚛️  ATOMIC SETTLEMENT MODE                │
│  Both parties must sign for payment        │
│                                             │
│  ═════════════════════════════════════     │
│  BUYER SIDE                                │
│  ═════════════════════════════════════     │
│                                             │
│  Your Role: [Buyer ▼]                      │
│  Your Address: [0x7f2e... (truncated)]     │
│  ✅ You are: Buyer                          │
│                                             │
│  ─────────────────────────────────────     │
│  DEAL TERMS                                │
│  ─────────────────────────────────────     │
│                                             │
│  Amount to Send: [______] USDC              │
│  Category: [Electronics ▼]                 │
│  Tax (12%): ₹1,072                         │
│                                             │
│  Recipient (Seller):                       │
│  Enter Seller Address: [________________]  │
│                                             │
│  ─────────────────────────────────────     │
│  SELLER SIDE                               │
│  ─────────────────────────────────────     │
│                                             │
│  Product Description:                      │
│  [What are you selling? _____________]     │
│                                             │
│  Product Value (optional):                 │
│  [_____] USDC                              │
│                                             │
│  ─────────────────────────────────────     │
│                                             │
│  ⚠️  Remember: Both parties must sign!     │
│  This creates a 2-signature requirement    │
│                                             │
│  [CANCEL]  [CREATE ATOMIC DEAL]            │
│                                             │
└─────────────────────────────────────────────┘
```

**Code Structure:**
```dart
class AtomicDealScreen extends StatefulWidget {
  @override
  State<AtomicDealScreen> createState() => _AtomicDealScreenState();
}

class _AtomicDealScreenState extends State<AtomicDealScreen> {
  String yourRole = 'buyer';           // or 'seller'
  String yourAddress = '';              // Your public key
  String amount = '';
  String category = 'electronics';
  String recipientAddress = '';         // The other party's address
  String productDescription = '';
  
  void _createAtomicDeal() {
    // 1. Validate both parties filled in
    // 2. Create Transaction with requiredSignatureCount = 2
    // 3. Add participants: {buyer: yourAddress, seller: recipientAddress}
    // 4. Navigate to signing screen
  }
}
```

---

### **Screen 2: Atomic Signing Screen (Updated)**
**File:** `mobile/lib/screens/atomic_signing_screen.dart`

**Purpose:** Show signing progress and which party is signing now

**UI Components:**
```
┌─────────────────────────────────────────────┐
│          ATOMIC DEAL - SIGN NOW             │
├─────────────────────────────────────────────┤
│                                             │
│  Transaction ID: tx_abc123...               │
│                                             │
│  ⚛️  SIGNATURES REQUIRED: 2/2              │
│                                             │
│  ═════════════════════════════════════     │
│  PARTY 1: BUYER                            │
│  ═════════════════════════════════════     │
│                                             │
│  Address: 0x7f2e8c9a...                    │
│  Amount: 50,000 USDC                       │
│  Category: Electronics (12% GST)           │
│                                             │
│  Signature Status:                         │
│  ❌ NOT SIGNED YET                         │
│                                             │
│  [SIGN AS BUYER]                           │
│                                             │
│  ═════════════════════════════════════     │
│  PARTY 2: SELLER                           │
│  ═════════════════════════════════════     │
│                                             │
│  Address: 0x9k2x1q...                      │
│  Sends: Product/Service                    │
│                                             │
│  Signature Status:                         │
│  ❌ WAITING FOR SELLER TO SIGN             │
│  (Seller needs to scan this QR)            │
│                                             │
│  ═════════════════════════════════════     │
│                                             │
│  PROGRESS:                                 │
│  ████░░░░░░░░░░░░░░░░ 1/2 Signatures      │
│                                             │
│  ⚠️  Need 1 more signature from Seller!    │
│  Share QR code or send link                │
│                                             │
│  ═════════════════════════════════════     │
│  QR CODE TO SHARE                          │
│  ═════════════════════════════════════     │
│                                             │
│  ┌─────────────────────┐                   │
│  │   QR CODE HERE      │                   │
│  │   (transaction data │                   │
│  │    + buyer sig)     │                   │
│  └─────────────────────┘                   │
│                                             │
│  [COPY LINK]  [SHARE QR]                   │
│                                             │
│  ═════════════════════════════════════     │
│                                             │
│  ✅ WHEN READY TO SETTLE:                  │
│  Once both have signed, you'll be able     │
│  to submit to blockchain                   │
│                                             │
│  [SUBMIT TO SETTLEMENT]  (disabled until 2/2)
│                                             │
└─────────────────────────────────────────────┘
```

**Code Structure:**
```dart
class AtomicSigningScreen extends StatefulWidget {
  final Transaction transaction;
  
  @override
  State<AtomicSigningScreen> createState() => _AtomicSigningScreenState();
}

class _AtomicSigningScreenState extends State<AtomicSigningScreen> {
  late Transaction transaction;
  bool isSigning = false;
  
  void _handleSignAsCurrentParty() async {
    setState(() => isSigning = true);
    
    try {
      // 1. Get current party's role (buyer/seller)
      final currentRole = _getCurrentUserRole();
      
      // 2. Sign the transaction
      final signature = await CryptoService.signTransaction(
        jsonEncode(transaction.toJson()),
        currentUserPrivateKey
      );
      
      // 3. Add signature to transaction
      transaction.requiredSignatures.add(signature);
      
      // 4. Update status
      if (transaction.isFullySigned) {
        transaction.signingStatus = 'FULLY_SIGNED';
        _showFullySignedDialog();
      } else {
        transaction.signingStatus = 'PARTIALLY_SIGNED';
        _showGenerateQRDialog();
      }
      
      setState(() {});
    } catch (e) {
      _showError('Signing failed: $e');
    } finally {
      setState(() => isSigning = false);
    }
  }
  
  Widget _buildSignatureProgress() {
    return Column(
      children: [
        // Show each party and their signature status
        for (var role in ['buyer', 'seller'])
          _buildPartySignatureCard(role, transaction)
      ],
    );
  }
  
  Widget _buildPartySignatureCard(String role, Transaction tx) {
    final hasSigned = tx.requiredSignatures.isNotEmpty;
    final address = tx.participants[role] ?? '';
    
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Text(role == 'buyer' ? '🛍️' : '📦'),
            title: Text('PARTY ${role == 'buyer' ? '1' : '2'}: ${role.toUpperCase()}'),
            trailing: hasSigned 
              ? Icon(Icons.check_circle, color: Colors.green)
              : Icon(Icons.pending, color: Colors.orange),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Address: $address'),
                SizedBox(height: 8),
                if (hasSigned)
                  Text('✅ SIGNED', style: TextStyle(color: Colors.green))
                else
                  Text('❌ NOT SIGNED', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

### **Screen 3: Atomic Settlement Confirmation (New)**
**File:** `mobile/lib/screens/atomic_settlement_confirmation_screen.dart`

**Purpose:** Show final confirmation before submitting both signatures to blockchain

**UI Components:**
```
┌─────────────────────────────────────────────┐
│      ATOMIC SETTLEMENT - READY TO SEND      │
├─────────────────────────────────────────────┤
│                                             │
│  ✅ BOTH PARTIES HAVE SIGNED!              │
│                                             │
│  2/2 Signatures Collected                   │
│                                             │
│  ═════════════════════════════════════     │
│  DEAL SUMMARY                              │
│  ═════════════════════════════════════     │
│                                             │
│  Buyer:  0x7f2e8c9a...                     │
│  Seller: 0x9k2x1q...                       │
│                                             │
│  Amount: 50,000 USDC                       │
│  Category: Electronics (12% GST)           │
│                                             │
│  ═════════════════════════════════════     │
│  PAYMENT BREAKDOWN                         │
│  ═════════════════════════════════════     │
│                                             │
│  Merchant: 44,642 USDC (89.28%)            │
│  Tax: 5,358 USDC (10.72%)                  │
│  Loyalty: 0 USDC                           │
│                                             │
│  Total: 50,000 USDC                        │
│                                             │
│  ═════════════════════════════════════     │
│  SIGNATURES                                │
│  ═════════════════════════════════════     │
│                                             │
│  Buyer Signature:   ✅ 0x7f2e...           │
│  Seller Signature:  ✅ 0x9k2x...           │
│                                             │
│  ═════════════════════════════════════     │
│                                             │
│  ⚠️  IMPORTANT: Both signatures prove      │
│  that both parties agreed to this deal.    │
│  Once submitted, it cannot be changed.     │
│                                             │
│  [GO BACK]  [SUBMIT & SETTLE]              │
│                                             │
└─────────────────────────────────────────────┘
```

**Code Structure:**
```dart
class AtomicSettlementConfirmationScreen extends StatefulWidget {
  final Transaction transaction;
  
  @override
  State<AtomicSettlementConfirmationScreen> createState() => 
    _AtomicSettlementConfirmationScreenState();
}

class _AtomicSettlementConfirmationScreenState extends State<AtomicSettlementConfirmationScreen> {
  bool isSubmitting = false;
  
  void _handleSubmitAtomic() async {
    setState(() => isSubmitting = true);
    
    try {
      // 1. Verify both signatures are present
      if (transaction.requiredSignatures.length < 2) {
        throw Exception('Missing signatures');
      }
      
      // 2. Prepare payload with both signatures
      final payload = {
        'transaction': transaction.toJson(),
        'signatures': transaction.requiredSignatures,
        'participants': transaction.participants,
        'atomicMode': true,
      };
      
      // 3. Submit to backend
      final response = await http.post(
        Uri.parse('${TransactionService.baseUrl}/atomic-settle'),
        body: jsonEncode(payload),
      );
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        _showSuccessDialog(result);
      } else {
        throw Exception('Settlement failed');
      }
    } catch (e) {
      _showError('Submission failed: $e');
    } finally {
      setState(() => isSubmitting = false);
    }
  }
  
  void _showSuccessDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('✅ Settlement Successful!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transaction ID: ${result['transactionId']}'),
            SizedBox(height: 16),
            Text('Status: SETTLED'),
            SizedBox(height: 16),
            Text('Both parties have been settled atomically.'),
            SizedBox(height: 8),
            Text('Check blockchain for confirmation.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
```

---

## **3. Widgets to Create**

### **Widget 1: Signature Progress Indicator**
**File:** `mobile/lib/widgets/signature_progress_widget.dart`

```dart
class SignatureProgressWidget extends StatelessWidget {
  final int collected;
  final int required;
  final List<String> parties;
  
  const SignatureProgressWidget({
    required this.collected,
    required this.required,
    required this.parties,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress bar
        LinearProgressIndicator(
          value: collected / required,
          minHeight: 8,
        ),
        SizedBox(height: 8),
        
        // Text
        Text(
          '$collected/$required Signatures',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 16),
        
        // Party list
        for (var (index, party) in parties.indexed)
          _buildPartyRow(party, index < collected),
      ],
    );
  }
  
  Widget _buildPartyRow(String party, bool hasSigned) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            hasSigned ? Icons.check_circle : Icons.pending,
            color: hasSigned ? Colors.green : Colors.orange,
          ),
          SizedBox(width: 8),
          Text(party),
          Spacer(),
          Text(hasSigned ? '✅' : '⏳'),
        ],
      ),
    );
  }
}
```

---

### **Widget 2: Party Card**
**File:** `mobile/lib/widgets/party_card_widget.dart`

```dart
class PartyCardWidget extends StatelessWidget {
  final String role;        // 'buyer' or 'seller'
  final String address;
  final bool hasSigned;
  final String? description;
  
  const PartyCardWidget({
    required this.role,
    required this.address,
    required this.hasSigned,
    this.description,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  role == 'buyer' ? '🛍️ BUYER' : '📦 SELLER',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Spacer(),
                Icon(
                  hasSigned ? Icons.check_circle : Icons.pending,
                  color: hasSigned ? Colors.green : Colors.orange,
                ),
              ],
            ),
            SizedBox(height: 12),
            Text('Address: $address'),
            if (description != null) ...[
              SizedBox(height: 8),
              Text('Description: $description'),
            ],
            SizedBox(height: 12),
            Text(
              hasSigned ? '✅ SIGNED' : '⏳ PENDING',
              style: TextStyle(
                color: hasSigned ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## **4. Service Layer Updates**

### **Update TransactionService**
**File:** `mobile/lib/services/transaction_service.dart`

```dart
class TransactionService {
  // ... existing methods ...
  
  // NEW: Create atomic deal transaction
  static Map<String, dynamic> createAtomicDeal({
    required double amount,
    required String buyerAddress,
    required String sellerAddress,
    required String category,
  }) {
    return {
      'buyerAddress': buyerAddress,
      'sellerAddress': sellerAddress,
      'amount': amount,
      'category': category,
      'requiredSignatureCount': 2,
      'requiredSignatures': [],
      'participants': {
        'buyer': buyerAddress,
        'seller': sellerAddress,
      },
      'signingStatus': 'PENDING_SIGNATURES',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }
  
  // NEW: Add signature to atomic deal
  static Future<void> addSignatureToAtomic(
    Map<String, dynamic> atomicDeal,
    String signature,
    String role,
  ) async {
    atomicDeal['requiredSignatures'].add(signature);
    
    if (atomicDeal['requiredSignatures'].length >= atomicDeal['requiredSignatureCount']) {
      atomicDeal['signingStatus'] = 'FULLY_SIGNED';
    } else {
      atomicDeal['signingStatus'] = 'PARTIALLY_SIGNED';
    }
  }
  
  // NEW: Submit atomic settlement
  static Future<Map<String, dynamic>> submitAtomicSettlement(
    Map<String, dynamic> atomicDeal,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/atomic-settle'),
        body: jsonEncode(atomicDeal),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Settlement failed: ${response.body}');
      }
      
      return jsonDecode(response.body);
    } catch (e) {
      print('❌ Atomic settlement error: $e');
      rethrow;
    }
  }
}
```

---

## **5. Navigation Flow**

```
Payment Screen
     ↓
[Select "Atomic Mode"]
     ↓
Atomic Deal Screen
  (Enter buyer & seller info)
     ↓
[Create Atomic Deal]
     ↓
Atomic Signing Screen
  (Buyer signs first)
     ↓
[Generate QR / Share with Seller]
     ↓
Seller scans QR
     ↓
Seller Signing Screen
  (Seller signs)
     ↓
[Both Signed!]
     ↓
Atomic Settlement Confirmation
  (Shows both signatures)
     ↓
[Submit to Settlement]
     ↓
Backend processes with both sigs
     ↓
Success Screen
```

---

## **6. Key UI Principles**

### **Visual Clarity:**
- Always show how many signatures are needed (e.g., "2/2")
- Use clear icons (✅ for signed, ⏳ for pending, ❌ for missing)
- Color code: Green (signed), Orange (pending), Red (error)

### **Progress Indication:**
- Progress bar showing signature collection
- List of parties with their signature status
- Clear messaging about what's needed next

### **User Guidance:**
- Explain what "Atomic Settlement" means at each step
- Show which party needs to sign next
- Provide clear instructions on how to share with the other party

### **Error Handling:**
- Validate both parties filled in addresses
- Check signatures are valid before allowing submission
- Show clear errors if submission fails

---

## **7. Testing Checklist**

- [ ] Can create atomic deal with 2 parties
- [ ] Can sign as first party (buyer)
- [ ] QR code generated with buyer signature
- [ ] Second party (seller) can scan and sign
- [ ] UI updates to show "FULLY_SIGNED"
- [ ] Submit button is disabled until both signatures present
- [ ] Submit button works when both signatures present
- [ ] Backend receives both signatures and settles correctly
- [ ] Success screen shows transaction ID
- [ ] Error handling works for invalid signatures
- [ ] Error handling works for insufficient funds
- [ ] All text is clear and understandable

---

## **Summary**

For atomic settlement UI, you need:
1. **New Screen:** Create Atomic Deal (get both parties)
2. **New Screen:** Atomic Signing (collect signatures)
3. **New Screen:** Settlement Confirmation (both sigs ready)
4. **New Widgets:** Signature progress, Party card
5. **Service Updates:** Create deal, add sig, submit atomic
6. **Clear Visual Status:** Show who signed, who's pending

**Time Estimate:** 2-3 hours to implement all screens and widgets
