# **Algorand Integration Implementation Plan**

## **Overview**

This document outlines the complete integration of Algorand blockchain into 808Pay for permanent, immutable transaction settlement.

**Current Status:**
- ✅ Backend settlement service (Express.js)
- ✅ Offline signing (Dart cryptography)
- ✅ Tax calculation (5 GST categories)
- ✅ Balance tracking (in-memory)
- ⏳ **TODO:** Algorand integration (blockchain settlement)

**Goal:** Every settled transaction gets stored on Algorand blockchain with both signatures attached.

---

## **Architecture Overview**

```
┌─────────────────────────────────────────────────────────┐
│                    FLUTTER MOBILE                       │
│  (Create Deal → Sign Offline → Generate QR)             │
└──────────────────────┬──────────────────────────────────┘
                       │
                       │ POST /api/settle
                       ↓
┌─────────────────────────────────────────────────────────┐
│                    NODEJS BACKEND                       │
│ (Verify Signatures → Calculate Tax → Check Balance)    │
└──────────────────────┬──────────────────────────────────┘
                       │
                       │ Submit Transaction
                       ↓
┌─────────────────────────────────────────────────────────┐
│                  ALGORAND BLOCKCHAIN                    │
│ (Store: Transaction + Both Signatures + Tax Data)      │
│ Network: Testnet/Localnet                              │
│ Transaction Type: Application Call or Payment          │
└─────────────────────────────────────────────────────────┘
```

---

## **Phase 1: Backend Algorand SDK Setup**

### **1.1 Install Algorand SDK**

```bash
cd /Users/srijan/808Pay/backend

# Install Algorand JavaScript SDK
npm install algosdk
npm install --save-dev @types/algosdk
```

### **1.2 Create `.env` Configuration**

Add to `.env`:
```env
# Algorand Network Configuration
ALGO_NETWORK=testnet                    # Options: testnet, mainnet, localnet
ALGO_API_TOKEN=<YOUR_TESTNET_TOKEN>     # From AlgoExplorer or Purestake
ALGO_SERVER=https://testnet-algorand.api.purestake.io/ps2
ALGO_INDEXER=https://testnet-algorand.api.purestake.io/idx2

# For Localnet (Docker)
ALGO_LOCALNET_SERVER=http://localhost:4001
ALGO_LOCALNET_INDEXER=http://localhost:8980

# Contract/App Configuration
PAYMENT_APP_ID=0                        # Will be set after deployment
CREATOR_ADDRESS=<YOUR_WALLET_ADDRESS>
CREATOR_MNEMONIC=<YOUR_MNEMONIC_24_WORDS>  # DO NOT COMMIT

# Demo/Test Configuration
DEMO_BUYER_MNEMONIC=<TEST_BUYER_MNEMONIC>
DEMO_SELLER_MNEMONIC=<TEST_SELLER_MNEMONIC>
SETTLEMENT_MIN_BALANCE=1000000          # 1 ALGO in microAlgos
```

---

## **Phase 2: Smart Contract Development**

### **2.1 Create PyTeal Smart Contract**

**File:** `/Users/srijan/808Pay/contracts/payment_settlement/contract.py`

```python
from pyteal import *

class PaymentSettlement:
    """
    Smart contract for atomic settlement on Algorand
    
    Features:
    - Store transaction data (buyer, seller, amount, category)
    - Store dual signatures (buyer + seller)
    - Tax calculation integration
    - Immutable settlement record
    """
    
    # App state keys
    class Keys:
        transaction_id = Bytes("txn_id")
        buyer_address = Bytes("buyer")
        seller_address = Bytes("seller")
        amount = Bytes("amt")
        category = Bytes("cat")
        gst_rate = Bytes("gst")
        buyer_signature = Bytes("buyer_sig")
        seller_signature = Bytes("seller_sig")
        settled_at = Bytes("settled_at")
        merchant_amount = Bytes("merchant_amt")
        tax_amount = Bytes("tax_amt")
    
    @staticmethod
    def create_contract():
        """Create the contract"""
        
        program = Return(Int(1))  # Allow all for now, will add logic
        
        return program
    
    @staticmethod
    def settlement_method():
        """
        Main settlement method
        Called after both signatures verified
        
        Args:
        - txn_id: Unique transaction identifier
        - buyer: Buyer's public address
        - seller: Seller's public address
        - amount: Total amount in microAlgos
        - category: Product category (food, medicine, etc)
        - buyer_sig: Buyer's Ed25519 signature
        - seller_sig: Seller's Ed25519 signature
        - merchant_amt: Amount merchant receives
        - tax_amt: Amount government receives
        """
        
        txn_id = Txn.application_args[0]          # String
        buyer = Txn.application_args[1]           # Address
        seller = Txn.application_args[2]          # Address
        amount = Btoi(Txn.application_args[3])    # Integer
        category = Txn.application_args[4]        # String
        buyer_sig = Txn.application_args[5]       # Bytes
        seller_sig = Txn.application_args[6]      # Bytes
        merchant_amt = Btoi(Txn.application_args[7])
        tax_amt = Btoi(Txn.application_args[8])
        
        program = Seq([
            # Store transaction data
            App.globalPut(PaymentSettlement.Keys.transaction_id, txn_id),
            App.globalPut(PaymentSettlement.Keys.buyer_address, buyer),
            App.globalPut(PaymentSettlement.Keys.seller_address, seller),
            App.globalPut(PaymentSettlement.Keys.amount, amount),
            App.globalPut(PaymentSettlement.Keys.category, category),
            App.globalPut(PaymentSettlement.Keys.gst_rate, Btoi(Txn.application_args[9])),
            App.globalPut(PaymentSettlement.Keys.buyer_signature, buyer_sig),
            App.globalPut(PaymentSettlement.Keys.seller_signature, seller_sig),
            App.globalPut(PaymentSettlement.Keys.settled_at, Global.latest_confirmed_block()),
            App.globalPut(PaymentSettlement.Keys.merchant_amount, merchant_amt),
            App.globalPut(PaymentSettlement.Keys.tax_amount, tax_amt),
            
            # Return success
            Return(Int(1))
        ])
        
        return program
```

### **2.2 Build & Deploy Contract**

```bash
cd /Users/srijan/808Pay/contracts

# Initialize AlgoKit project
algokit init . --template=pure_python

# Build contract
algokit compile contract.py

# Deploy to testnet
algokit deploy testnet
```

---

## **Phase 3: Backend Algorand Service**

### **3.1 Create AlgorandService**

**File:** `/Users/srijan/808Pay/backend/src/services/algorandService.ts`

```typescript
import algosdk from 'algosdk';
import { v4 as uuidv4 } from 'uuid';

export class AlgorandService {
  private algodClient: algosdk.Algodv2;
  private indexerClient: algosdk.Indexer;
  private appId: number;
  
  constructor() {
    const token = process.env.ALGO_API_TOKEN || '';
    const server = process.env.ALGO_SERVER || '';
    const indexerServer = process.env.ALGO_INDEXER || '';
    
    this.algodClient = new algosdk.Algodv2(token, server, '');
    this.indexerClient = new algosdk.Indexer(token, indexerServer, '');
    this.appId = parseInt(process.env.PAYMENT_APP_ID || '0');
  }
  
  /**
   * Submit settlement transaction to Algorand
   */
  async submitSettlement(data: {
    buyerAddress: string;
    sellerAddress: string;
    amount: number;
    category: string;
    buyerSignature: string;
    sellerSignature: string;
    merchantAmount: number;
    taxAmount: number;
    gstRate: number;
  }): Promise<{
    txnId: string;
    algoTxnId: string;
    blockNumber: number;
    confirmed: boolean;
  }> {
    try {
      // Generate unique transaction ID
      const txnId = `tx_${uuidv4()}`;
      
      // Get current network params
      const params = await this.algodClient.getTransactionParams().do();
      
      // Create app call transaction
      const txn = algosdk.makeApplicationCallTxnFromObject({
        from: process.env.CREATOR_ADDRESS || '',
        index: this.appId,
        onComplete: algosdk.OnComplete.NoOpOC,
        appArgs: [
          new Uint8Array(Buffer.from('SETTLE')),
          new Uint8Array(Buffer.from(txnId)),
          new Uint8Array(Buffer.from(data.buyerAddress)),
          new Uint8Array(Buffer.from(data.sellerAddress)),
          algosdk.encodeUint64(data.amount),
          new Uint8Array(Buffer.from(data.category)),
          new Uint8Array(Buffer.from(data.buyerSignature, 'hex')),
          new Uint8Array(Buffer.from(data.sellerSignature, 'hex')),
          algosdk.encodeUint64(data.merchantAmount),
          algosdk.encodeUint64(data.taxAmount),
          algosdk.encodeUint64(data.gstRate),
        ],
        foreignAccounts: [data.buyerAddress, data.sellerAddress],
        suggestedParams: params,
      });
      
      // Sign transaction
      const creatorMnemonic = process.env.CREATOR_MNEMONIC || '';
      const creatorAccount = algosdk.mnemonicToSecretKey(creatorMnemonic);
      
      const signedTxn = algosdk.signTransaction(txn, creatorAccount.sk);
      const encodedTxn = signedTxn.blob;
      
      // Submit to network
      const response = await this.algodClient
        .sendRawTransaction(encodedTxn)
        .do();
      
      console.log('✅ Transaction submitted to Algorand');
      console.log(`   Algo Txn ID: ${response.txId}`);
      
      // Wait for confirmation
      const confirmation = await algosdk.waitForConfirmation(
        this.algodClient,
        response.txId,
        4  // Wait up to 4 rounds
      );
      
      return {
        txnId,
        algoTxnId: response.txId,
        blockNumber: confirmation['confirmed-round'],
        confirmed: true,
      };
    } catch (error) {
      console.error('❌ Algorand settlement error:', error);
      throw error;
    }
  }
  
  /**
   * Query settlement from blockchain
   */
  async getSettlement(txnId: string): Promise<any> {
    try {
      // Query app state for transaction
      const appInfo = await this.algodClient
        .getApplicationByID(this.appId)
        .do();
      
      return appInfo;
    } catch (error) {
      console.error('❌ Query error:', error);
      throw error;
    }
  }
  
  /**
   * Get account balance on Algorand
   */
  async getAccountBalance(address: string): Promise<number> {
    try {
      const account = await this.algodClient.accountInformation(address).do();
      return account.amount;  // In microAlgos
    } catch (error) {
      console.error('❌ Balance query error:', error);
      throw error;
    }
  }
  
  /**
   * Get transaction history for address
   */
  async getTransactionHistory(
    address: string,
    limit: number = 10
  ): Promise<any[]> {
    try {
      const response = await this.indexerClient
        .searchForTransactions()
        .address(address)
        .limit(limit)
        .do();
      
      return response.transactions || [];
    } catch (error) {
      console.error('❌ History query error:', error);
      throw error;
    }
  }
}

export const algorandService = new AlgorandService();
```

### **3.2 Update Settlement Service**

**File:** `/Users/srijan/808Pay/backend/src/services/settlementService.ts`

Update existing settlement logic to include Algorand:

```typescript
import { algorandService } from './algorandService';

export class SettlementService {
  // ... existing code ...
  
  async settle(request: SettleTransactionRequest): Promise<SettlementResult> {
    try {
      // 1. Validate signatures (existing code)
      // ...
      
      // 2. Check balance (existing code)
      // ...
      
      // 3. Calculate tax (existing code)
      const taxInfo = this.taxCalculationService.calculateTaxBreakdown(
        request.amount,
        request.category || 'services'
      );
      
      // 4. NEW: Submit to Algorand blockchain
      const algoResult = await algorandService.submitSettlement({
        buyerAddress: request.data.senderAddress,
        sellerAddress: request.data.recipientAddress,
        amount: request.amount,
        category: request.category || 'services',
        buyerSignature: request.signature,
        sellerSignature: request.sellerSignature || '',  // For atomic
        merchantAmount: taxInfo.merchantAmount,
        taxAmount: taxInfo.taxAmount,
        gstRate: taxInfo.gstRate,
      });
      
      // 5. Deduct balance from sender
      this.deductBalance(request.data.senderAddress, request.amount);
      
      // 6. Add balance to recipient
      this.addBalance(request.data.recipientAddress, taxInfo.merchantAmount);
      
      // 7. Return result with Algo transaction
      return {
        success: true,
        transactionId: algoResult.txnId,
        message: 'Settlement successful',
        algoTransaction: {
          txId: algoResult.algoTxnId,
          blockNumber: algoResult.blockNumber,
          confirmed: algoResult.confirmed,
        },
        balanceAfter: this.getUserBalance(request.data.senderAddress),
        recipientBalanceAfter: this.getUserBalance(request.data.recipientAddress),
      };
    } catch (error) {
      console.error('❌ Settlement error:', error);
      throw error;
    }
  }
}
```

### **3.3 Add Algorand Routes**

**File:** `/Users/srijan/808Pay/backend/src/routes/algorand.ts`

```typescript
import { Router } from 'express';
import { algorandService } from '../services/algorandService';

const router = Router();

/**
 * GET /api/algorand/balance/:address
 * Get account balance on Algorand
 */
router.get('/balance/:address', async (req, res) => {
  try {
    const balance = await algorandService.getAccountBalance(req.params.address);
    res.json({
      address: req.params.address,
      balance,
      balanceAlgo: balance / 1_000_000,  // Convert to ALGO
      currency: 'ALGO',
    });
  } catch (error: any) {
    res.status(500).json({
      error: error.message,
    });
  }
});

/**
 * GET /api/algorand/transaction/:txnId
 * Get settlement transaction from blockchain
 */
router.get('/transaction/:txnId', async (req, res) => {
  try {
    const settlement = await algorandService.getSettlement(req.params.txnId);
    res.json(settlement);
  } catch (error: any) {
    res.status(500).json({
      error: error.message,
    });
  }
});

/**
 * GET /api/algorand/history/:address
 * Get transaction history for address
 */
router.get('/history/:address', async (req, res) => {
  try {
    const limit = parseInt(req.query.limit as string) || 10;
    const history = await algorandService.getTransactionHistory(
      req.params.address,
      limit
    );
    res.json({
      address: req.params.address,
      transactions: history,
      total: history.length,
    });
  } catch (error: any) {
    res.status(500).json({
      error: error.message,
    });
  }
});

/**
 * POST /api/algorand/health
 * Check Algorand network status
 */
router.post('/health', async (req, res) => {
  try {
    const status = await algorandService.algodClient.status().do();
    res.json({
      network: process.env.ALGO_NETWORK || 'testnet',
      status: 'healthy',
      latestRound: status['last-round'],
      syncTime: status['time-since-last-round'],
    });
  } catch (error: any) {
    res.status(500).json({
      network: process.env.ALGO_NETWORK || 'testnet',
      status: 'unhealthy',
      error: error.message,
    });
  }
});

export default router;
```

### **3.4 Register Routes in Main App**

**File:** `/Users/srijan/808Pay/backend/src/index.ts`

```typescript
import algorandRoutes from './routes/algorand';

// ... existing app setup ...

app.use('/api/algorand', algorandRoutes);

// ... rest of app ...
```

---

## **Phase 4: Flutter Integration**

### **4.1 Add Algorand SDK to Flutter**

**File:** `/Users/srijan/808Pay/mobile/pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  # ... existing dependencies ...
  algosdk: ^2.4.0          # Algorand SDK for Dart
  http: ^1.1.0
```

Run: `flutter pub get`

### **4.2 Create Flutter Algorand Service**

**File:** `/Users/srijan/808Pay/mobile/lib/services/algorand_service.dart`

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class AlgorandService {
  static const String baseUrl = 'http://localhost:3000/api/algorand';
  
  /**
   * Get account balance on Algorand
   */
  static Future<Map<String, dynamic>> getBalance(String address) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/balance/$address'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get balance: ${response.body}');
      }
    } catch (e) {
      print('❌ Balance error: $e');
      rethrow;
    }
  }
  
  /**
   * Get settlement transaction from blockchain
   */
  static Future<Map<String, dynamic>> getTransaction(String txnId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transaction/$txnId'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get transaction: ${response.body}');
      }
    } catch (e) {
      print('❌ Transaction error: $e');
      rethrow;
    }
  }
  
  /**
   * Get transaction history for address
   */
  static Future<List<dynamic>> getHistory(
    String address, {
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/history/$address?limit=$limit'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['transactions'] ?? [];
      } else {
        throw Exception('Failed to get history: ${response.body}');
      }
    } catch (e) {
      print('❌ History error: $e');
      rethrow;
    }
  }
  
  /**
   * Check Algorand network status
   */
  static Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/health'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Network unhealthy');
      }
    } catch (e) {
      print('❌ Health check error: $e');
      return {'status': 'error', 'error': e.toString()};
    }
  }
}
```

### **4.3 Create Settlement Result Widget**

**File:** `/Users/srijan/808Pay/mobile/lib/widgets/settlement_result_widget.dart`

```dart
import 'package:flutter/material.dart';

class SettlementResultWidget extends StatelessWidget {
  final Map<String, dynamic> result;
  final VoidCallback? onClose;
  
  const SettlementResultWidget({
    required this.result,
    this.onClose,
  });
  
  @override
  Widget build(BuildContext context) {
    final algoTxn = result['algoTransaction'] ?? {};
    final confirmed = algoTxn['confirmed'] ?? false;
    
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            confirmed ? Icons.check_circle : Icons.schedule,
            color: confirmed ? Colors.green : Colors.orange,
          ),
          SizedBox(width: 8),
          Text(confirmed ? '✅ Settled!' : '⏳ Processing'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transaction ID
            _buildInfoRow('Transaction ID', result['transactionId'] ?? 'N/A'),
            
            // Algorand Txn ID
            if (algoTxn['txId'] != null)
              _buildInfoRow(
                'Algo Txn ID',
                (algoTxn['txId'] as String).substring(0, 20) + '...',
              ),
            
            // Block Number
            if (algoTxn['blockNumber'] != null)
              _buildInfoRow('Block', '${algoTxn['blockNumber']}'),
            
            SizedBox(height: 16),
            
            // Status badge
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: confirmed ? Colors.green.shade100 : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                confirmed 
                  ? '✅ Confirmed on blockchain'
                  : '⏳ Waiting for confirmation',
                style: TextStyle(
                  color: confirmed ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Explorer link
            if (confirmed && algoTxn['txId'] != null)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'View on Blockchain:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'https://testnet.algoexplorer.io/tx/${algoTxn['txId']}',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        if (confirmed)
          TextButton(
            onPressed: onClose,
            child: Text('Done'),
          ),
        if (!confirmed)
          TextButton(
            onPressed: () {},
            child: Text('Checking...'),
          ),
      ],
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          SizedBox(height: 4),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## **Phase 5: Testing & Deployment**

### **5.1 Local Testing with Algokit**

```bash
# Start local Algorand network
algokit localnet start

# Deploy contract locally
cd /Users/srijan/808Pay/contracts
algokit deploy localnet --creator-mnemonic "<YOUR_MNEMONIC>"

# Run backend against local network
export ALGO_NETWORK=localnet
export ALGO_LOCALNET_SERVER=http://localhost:4001
cd /Users/srijan/808Pay/backend
npm run dev
```

### **5.2 Testnet Deployment**

```bash
# Get testnet API token from:
# - AlgoExplorer: https://testnet.algoexplorer.io/
# - Purestake: https://www.purestake.com/

# Set environment variables
export ALGO_NETWORK=testnet
export ALGO_API_TOKEN=<YOUR_TOKEN>

# Deploy to testnet
algokit deploy testnet

# Get testnet funds
# Visit: https://testnet-dispenser.algorand.org/
```

### **5.3 Test Endpoints**

```bash
# 1. Check network health
curl -X POST http://localhost:3000/api/algorand/health

# 2. Get account balance
curl http://localhost:3000/api/algorand/balance/<ADDRESS>

# 3. Submit settlement
curl -X POST http://localhost:3000/api/transactions/settle \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "senderAddress": "BUYER_ADDRESS",
      "recipientAddress": "SELLER_ADDRESS",
      "amount": 50000,
      "timestamp": '$(date +%s)'
    },
    "signature": "BUYER_SIGNATURE",
    "category": "electronics"
  }'

# 4. Get transaction history
curl http://localhost:3000/api/algorand/history/<ADDRESS>?limit=10
```

---

## **Phase 6: Update Types**

### **6.1 Add Algorand Types**

**File:** `/Users/srijan/808Pay/backend/src/types/index.ts`

```typescript
export interface AlgorandTransaction {
  txId: string;
  blockNumber: number;
  confirmed: boolean;
}

export interface SettlementResult {
  success: boolean;
  transactionId: string;
  message: string;
  balanceAfter?: number;
  recipientBalanceAfter?: number;
  errorCode?: 'INSUFFICIENT_FUNDS' | 'SIGNATURE_INVALID' | 'INVALID_CATEGORY';
  algoTransaction?: AlgorandTransaction;  // NEW
}

export interface SettleTransactionRequest {
  data: {
    senderAddress: string;
    recipientAddress: string;
    amount: number;
    timestamp: number;
  };
  signature: string;
  sellerSignature?: string;  // For atomic settlement
  category?: string;
}
```

---

## **Phase 7: Documentation & Demo**

### **7.1 Create Demo Script**

**File:** `/Users/srijan/808Pay/ALGORAND_DEMO.md`

```markdown
# Algorand Integration Demo

## Demo Scenario: Buying iPhone

### Step 1: Create Settlement Deal
- Buyer: Alice (address: ALICE...)
- Seller: Bob (address: BOB...)
- Amount: ₹80,000
- Category: Electronics (12% GST)

### Step 2: Sign Offline
- Alice signs transaction offline (no internet)
- Generates QR code with signature

### Step 3: Seller Verifies & Signs
- Bob scans QR code
- Bob signs transaction offline

### Step 4: Submit Settlement
- Both signatures present
- Submit to backend
- Backend verifies signatures
- Backend calculates tax (₹80,000 → ₹71,400 merchant + ₹8,600 tax)
- Backend submits to Algorand

### Step 5: Blockchain Confirmation
- Transaction appears on Algorand
- Both signatures stored immutably
- View on AlgoExplorer: https://testnet.algoexplorer.io/tx/<TXN_ID>

### Key Metrics:
- Time to sign: < 1 second (offline)
- Time to submit: < 5 seconds
- Time to confirm: 5-10 seconds (blockchain)
- Total end-to-end: ~15 seconds
```

---

## **Implementation Checklist**

- [ ] Install Algorand SDK in backend
- [ ] Create `.env` with Algorand config
- [ ] Write PyTeal smart contract
- [ ] Compile and deploy contract
- [ ] Create `AlgorandService` in backend
- [ ] Update `SettlementService` to use Algorand
- [ ] Add Algorand routes
- [ ] Update types with `AlgorandTransaction`
- [ ] Install Algorand SDK in Flutter
- [ ] Create `algorand_service.dart`
- [ ] Create `settlement_result_widget.dart`
- [ ] Test with Algokit localnet
- [ ] Deploy to testnet
- [ ] E2E test: Create deal → Sign → Submit → Confirm
- [ ] Update demo script
- [ ] Document Algorand integration

---

## **Success Metrics**

✅ **After Implementation:**
- Every settlement stored on Algorand blockchain
- Both signatures attached to transaction
- Transaction immutable and verifiable forever
- Demo can show blockchain confirmation
- Users can verify transaction on AlgoExplorer

---

## **Next Steps**

1. **Backend Setup** (30 mins)
   - Install SDK, create service, add routes

2. **Smart Contract** (1 hour)
   - Write PyTeal, compile, deploy

3. **Flutter Integration** (30 mins)
   - Add SDK, create service, add UI widget

4. **Testing** (1 hour)
   - Test with localnet, then testnet

5. **Demo Polish** (30 mins)
   - Add explorer links, status indicators

**Total Time: 3-4 hours**
