# 808Pay Backend Integration Guide

## Quick Start for Backend Integration Developer

This guide is for the member integrating the smart contract with the backend API.

### Prerequisites
- Node.js 18+ running
- Express backend running on port 3000
- Algorand SDK (algosdk) knowledge
- Python/PyTeal basics

### Current Status ✅
- ✅ Backend API fully built (Express.js)
- ✅ All endpoints working
- 🔄 Smart contract being deployed (waiting on smart contract developer)
- ⏳ Integration needed

---

## Your Tasks

### Phase 1: Prepare (Hours 0-1)
1. Install Algorand SDK dependencies
2. Create contract interaction module
3. Set up environment variables
4. Create test utilities

### Phase 2: Integration (Hours 1-3)
1. Connect backend to deployed contract
2. Update settlement logic
3. Implement transaction signing verification
4. Test settlement flow

### Phase 3: Testing (Hours 3-4)
1. Unit tests
2. Integration tests
3. Work with smart contract developer to debug

---

## Current Backend Structure

```
808Pay/src/
├── index.ts                    # Express server
├── services/
│   ├── cryptoService.ts        # Ed25519 verification ✅
│   └── settlementService.ts    # Payment settlement (NEEDS UPDATE)
├── routes/
│   └── transactions.ts         # API endpoints ✅
├── store/
│   └── transactionStore.ts     # In-memory DB ✅
└── types/
    └── index.ts                # TypeScript types ✅
```

---

## What Needs to Change

### 1. Add Algorand SDK to package.json

```bash
npm install algosdk
npm install --save-dev @types/algosdk
```

Already installed? Check:
```bash
npm list algosdk
```

### 2. Create Smart Contract Service

Create: `src/services/contractService.ts`

```typescript
import algosdk from "algosdk";

interface ContractConfig {
  appId: number;
  client: algosdk.Algodv2;
  indexerClient: algosdk.Indexer;
}

class ContractService {
  private config: ContractConfig;
  
  constructor(appId: number, algodToken: string, algodServer: string) {
    const client = new algosdk.Algodv2(algodToken, algodServer);
    const indexerClient = new algosdk.Indexer("", algodServer.replace("8080", "8980"));
    
    this.config = { appId, client, indexerClient };
  }
  
  async getAppInfo() {
    // Retrieve contract info from blockchain
    const appInfo = await this.config.client
      .getApplicationByID(this.config.appId)
      .do();
    return appInfo;
  }
  
  async callSettlePayment(
    sender: string,
    signature: Buffer,
    publicKey: Buffer,
    amount: number,
    merchant: string
  ) {
    // Create application call transaction
    // Call verify_and_settle method on contract
    // Return transaction result
  }
  
  async getTransactionInfo(txId: string) {
    // Get transaction details from blockchain
  }
}

export default ContractService;
```

### 3. Update Settlement Service

File: `src/services/settlementService.ts`

**Current Implementation:**
- Verifies Ed25519 signature ✅
- Calculates payment splits ✅
- Stores in memory ✅

**What to Add:**
```typescript
import ContractService from "./contractService";

class SettlementService {
  private contractService: ContractService;
  private transactionStore: TransactionStore;
  
  async settleTransaction(request: SettleTransactionRequest) {
    // 1. Verify signature (EXISTING) ✅
    const isValid = this.cryptoService.verifySignature(
      request.data,
      request.signature,
      request.publicKey
    );
    
    if (!isValid) {
      throw new Error("Invalid signature");
    }
    
    // 2. Parse transaction data
    const txData = JSON.parse(request.data);
    
    // 3. Calculate splits (EXISTING) ✅
    const splits = this.calculateSplits(txData.amount);
    
    // 4. Call smart contract (NEW)
    const contractResult = await this.contractService.callSettlePayment(
      txData.sender,
      request.signature,
      request.publicKey,
      txData.amount,
      txData.merchant
    );
    
    // 5. Verify contract result
    if (!contractResult.confirmed) {
      throw new Error("Contract settlement failed");
    }
    
    // 6. Store transaction (EXISTING) ✅
    const transaction: Transaction = {
      id: uuidv4(),
      sender: txData.sender,
      recipient: txData.merchant,
      amount: txData.amount,
      signature: request.signature,
      publicKey: request.publicKey,
      status: "settled",
      splits: splits,
      createdAt: new Date(),
      settledAt: new Date(),
      blockNumber: contractResult.blockNumber,
      txId: contractResult.txId,
    };
    
    this.transactionStore.add(transaction);
    
    return {
      success: true,
      transactionId: transaction.id,
      message: "Payment settled successfully",
      splits: splits,
      blockNumber: contractResult.blockNumber,
    };
  }
}
```

### 4. Update TypeScript Types

File: `src/types/index.ts`

```typescript
export interface Transaction {
  id: string;
  sender: string;
  recipient: string;
  amount: number;
  signature: string | Buffer;
  publicKey: string | Buffer;
  status: "pending" | "settled" | "failed";
  splits: {
    merchant: number;
    tax: number;
    loyalty: number;
  };
  createdAt: Date;
  settledAt?: Date;
  blockNumber?: number;
  txId?: string;  // Algorand transaction ID
}

export interface SettleTransactionRequest {
  data: string;  // JSON stringified transaction
  signature: string | Buffer;
  publicKey: string | Buffer;
}

export interface SettlementResult {
  success: boolean;
  transactionId: string;
  message: string;
  splits: {
    merchant: number;
    tax: number;
    loyalty: number;
  };
  blockNumber?: number;
}
```

### 5. Update .env File

```env
# Algorand Configuration
ALGORAND_SERVER=http://localhost:4001          # Local sandbox
ALGORAND_TOKEN=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa

# Smart Contract (filled by smart contract developer)
CONTRACT_APP_ID=                               # Will be provided
PAYMENT_PROCESSOR_ADDRESS=                     # Will be provided

# For Testnet deployment:
# ALGORAND_SERVER=https://testnet-algorand.api.purestake.io/ps2
# ALGORAND_TOKEN=your-purestake-token
```

---

## Integration Steps

### Step 1: Wait for Smart Contract Info

Before you can integrate, you need:
- ✅ Contract App ID (from smart contract developer)
- ✅ Processor wallet address (from smart contract developer)
- ✅ Contract ABI (method signatures)

### Step 2: Create Contract Client

```typescript
import algosdk from "algosdk";

const client = new algosdk.Algodv2(
  process.env.ALGORAND_TOKEN,
  process.env.ALGORAND_SERVER
);

const contractService = new ContractService(
  parseInt(process.env.CONTRACT_APP_ID!),
  process.env.ALGORAND_TOKEN!,
  process.env.ALGORAND_SERVER!
);
```

### Step 3: Test Contract Call

```bash
# Test local settlement
npm run test:settlement

# Should output:
# ✓ Contract called successfully
# ✓ Transaction settled on-chain
# ✓ Splits calculated correctly
```

### Step 4: Error Handling

Common errors:
```typescript
if (error.message.includes("app does not exist")) {
  // Contract not deployed yet
}

if (error.message.includes("invalid signature")) {
  // Signature verification failed
}

if (error.message.includes("insufficient funds")) {
  // Account doesn't have enough ALGO
}
```

---

## Testing Checklist

- [ ] Algorand SDK installed
- [ ] Contract service created
- [ ] Settlement service updated
- [ ] Environment variables set
- [ ] Can connect to contract
- [ ] Can call contract method
- [ ] Signature verification works
- [ ] Transaction settles on-chain
- [ ] Splits are correct (90/5/5)
- [ ] Transaction stored with blockchain info

---

## API Changes (for Frontend Developer)

The API endpoints remain the same, but now they interact with the blockchain:

```
POST /api/transactions/settle
- Takes signed transaction from frontend
- Verifies signature
- Calls smart contract
- Returns blockchain transaction ID + splits

GET /api/transactions/:id
- Returns on-chain settlement details
- Includes block number and blockchain confirmation

GET /api/transactions
- Lists all settlements
- Shows on-chain status
```

---

## Debugging

### Check Contract State
```bash
# Query contract global state
algokit localnet command goal app read --app-id APP_ID

# Check account balance
algokit localnet command goal account list
```

### View Transactions
```bash
# Get transaction details
curl http://localhost:4001/v2/transactions/TXID

# View indexer
curl http://localhost:8980/v2/transactions?application-id=APP_ID
```

### Common Issues

| Error | Cause | Solution |
|-------|-------|----------|
| "app does not exist" | Contract not deployed | Wait for SC developer |
| "invalid signature" | Wrong key format | Check Ed25519 encoding |
| "insufficient funds" | Not enough ALGO | Fund account via faucet |
| "txn not allowed" | Contract logic error | Check contract code |

---

## Timeline

| Time | Task | Output |
|------|------|--------|
| 0-1h | Setup & prepare | Contract service created |
| 1-2h | Integration | Settlement service updated |
| 2-3h | Testing | Integration tests passing |
| 3-4h | Debugging | Full E2E working |

---

## Key Files to Modify

1. `src/services/contractService.ts` - NEW
2. `src/services/settlementService.ts` - UPDATE
3. `src/types/index.ts` - UPDATE
4. `package.json` - UPDATE (algosdk)
5. `.env` - UPDATE (contract info)

---

## Communication

- **Smart Contract Developer**: Provide App ID and processor address
- **Frontend Developer**: Will call your API with signed transactions
- **Team**: Daily sync-ups to coordinate

---

## Resources

- Algorand SDK: https://github.com/algorand/py-algorand-sdk
- Application Calls: https://docs.algorand.org/get-details/dapps/
- Transaction Signing: https://docs.algorand.org/get-details/transactions/

Good luck! 🚀
