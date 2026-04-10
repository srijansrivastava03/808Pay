# 808Pay - Algorand Offline Payment Settlement Engine

## Overview

**808Pay** is a blockchain-based offline payment system that enables secure transactions without internet connectivity. Users can generate cryptographically signed payment QR codes offline, and merchants can settle them when online using Algorand smart contracts.

## 🚀 Team Getting Started?

**New to the project?** Start here:

- **[TEAM_SETUP_GUIDE.md](./TEAM_SETUP_GUIDE.md)** - Complete step-by-step setup (5-15 min)
- **[QUICK_COMMANDS.md](./QUICK_COMMANDS.md)** - Copy-paste ready commands

Choose your path:
- **Local Development** (easiest) - Run Algorand in Docker on your machine
- **Testnet** (for testing with real ALGO) - Use Algorand public testnet

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│  BACKEND (Express.js + Node.js)                         │
│  - Transaction Settlement                              │
│  - Signature Verification (Ed25519)                     │
│  - Payment Splitting Logic                              │
│  - In-Memory Transaction Store                          │
└─────────────────────────────────────────────────────────┘
         ↑
         │ HTTP REST API
         ↓
┌─────────────────────────────────────────────────────────┐
│  FRONTEND (Flutter Mobile / React Web)                  │
│  - Offline Payment Creation                             │
│  - QR Code Generation                                   │
│  - Cryptographic Signing                                │
│  - Transaction History                                  │
└─────────────────────────────────────────────────────────┘
         ↑
         │ Settlement
         ↓
┌─────────────────────────────────────────────────────────┐
│  BLOCKCHAIN (Algorand)                                  │
│  - Smart Contract Validation                            │
│  - Payment Splits (90/5/5)                              │
│  - Loyalty Points Minting                               │
│  - Immutable Settlement Records                         │
└─────────────────────────────────────────────────────────┘
```

## Quick Start

### Prerequisites
- Node.js v18+
- npm or yarn
- Port 5000 available

### Installation

```bash
cd /Users/srijan/808Pay

# Install dependencies
npm install

# Build TypeScript
npm run build
```

### Running

```bash
# Development (with hot reload)
npm run dev

# Demo (test the full flow)
npm run demo

# Production
npm run start
```

The backend will start on `http://localhost:5000`

## API Endpoints

### Health Check
```bash
GET /health

Response:
{
  "status": "ok",
  "timestamp": "2026-04-09T..."
}
```

### Settle Transaction
```bash
POST /api/transactions/settle

Request Body:
{
  "data": {
    "sender": "user_address",
    "recipient": "merchant_001",
    "amount": 5000,
    "timestamp": 1712689200
  },
  "signature": "0x...",
  "publicKey": "0x..."
}

Response:
{
  "success": true,
  "transactionId": "uuid-string",
  "message": "Transaction settled successfully",
  "splits": {
    "merchant": 4500,
    "tax": 250,
    "loyalty": 250
  }
}
```

### Get Transaction Status
```bash
GET /api/transactions/:id

Response:
{
  "id": "uuid-string",
  "status": "settled",
  "sender": "0x...",
  "recipient": "merchant_001",
  "amount": 5000,
  "createdAt": "2026-04-09T...",
  "settledAt": "2026-04-09T...",
  "splits": {
    "merchant": 4500,
    "tax": 250,
    "loyalty": 250
  }
}
```

### List All Transactions
```bash
GET /api/transactions

Response:
{
  "count": 5,
  "transactions": [...]
}
```

## Project Structure

```
808Pay/
├── src/
│   ├── index.ts                 # Express server entry point
│   ├── demo.ts                  # Demo script
│   ├── types/
│   │   └── index.ts             # TypeScript interfaces
│   ├── services/
│   │   ├── cryptoService.ts     # Ed25519 signature verification
│   │   └── settlementService.ts # Payment settlement logic
│   ├── store/
│   │   └── transactionStore.ts  # In-memory transaction storage
│   ├── routes/
│   │   └── transactions.ts      # API route handlers
│   ├── middleware/
│   │   └── errorHandler.ts      # Global error handling
│   └── utils/
│       ├── crypto.ts            # Crypto utilities for testing
│       └── testKeyGen.ts        # Test key generation
├── dist/                        # Compiled JavaScript
├── package.json
├── tsconfig.json
└── .env                         # Environment variables
```

## Key Features

### 1. Offline Transaction Creation
- Users can create payments without internet
- Transactions are signed with Ed25519 private keys
- QR codes contain complete transaction data + signature

### 2. Signature Verification
- Backend verifies Ed25519 signatures
- Uses tweetnacl.js for cryptography
- Ensures transactions haven't been tampered with

### 3. Payment Splitting
- **Merchant**: 90% of payment
- **Tax/Regulatory**: 5%
- **Loyalty Points**: 5%

Example: ₹50 payment → ₹45 merchant, ₹2.50 tax, ₹2.50 loyalty

### 4. In-Memory Store
- Fast transaction storage
- Perfect for hackathon demos
- Can be replaced with database later

## How It Works

### Offline Flow
1. User enters payment amount (₹50)
2. App creates transaction object
3. App signs with private key (offline - no internet needed)
4. QR code generated with signed transaction data

### Online Settlement Flow
1. Merchant scans QR → backend receives data
2. Backend verifies signature with user's public key
3. Backend validates transaction structure
4. Payment splits calculated automatically
5. Transaction marked as "settled"
6. Response sent back with confirmation

### Verification Without Internet
```
User's Transaction Data
         ↓
User's Private Key (on device)
         ↓
Create Signature (offline math)
         ↓
Anyone Can Verify:
  - Transaction Data
  - Signature
  - User's Public Key
  = Mathematical Proof of Authenticity
  (No internet needed for verification!)
```

## Crypto Details

### Ed25519
- Modern public-key signature algorithm
- 32-byte keys (256-bit)
- Secure, efficient, widely used
- Used by Bitcoin, Algorand, and many others

### Key Format
- Public Key: 32 bytes → 64 hex characters → `0x...`
- Signature: 64 bytes → 128 hex characters → `0x...`

### How Verification Works
```typescript
verifySignature(data, signature, publicKey)
  ↓
1. Hash transaction data
2. Use public key + signature to verify hash
3. If math checks out → Signature is valid
4. If not → Signature is forged
```

## Testing

### Run Demo
```bash
npm run demo
```

This will:
1. Generate test Ed25519 keys
2. Create a sample payment
3. Sign it cryptographically
4. Settle it on the backend
5. Verify settlement
6. Show payment splits

### Manual Testing with cURL

```bash
# Get test payload instructions
curl http://localhost:5000/api/transactions/test

# Create test keys and sign (use frontend or crypto utility)
# Then settle:
curl -X POST http://localhost:5000/api/transactions/settle \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "sender": "user_001",
      "recipient": "merchant_001",
      "amount": 5000,
      "timestamp": 1712689200
    },
    "signature": "0x...",
    "publicKey": "0x..."
  }'
```

## Environment Variables

```env
PORT=5000                                    # Server port
NODE_ENV=development                         # Environment
ALGORAND_SERVER=https://testnet-algorand... # Algorand API (future)
ALGORAND_TOKEN=your-api-key-here            # API token (future)
```

## Next Steps (For Production)

1. **Algorand Smart Contract**
   - Deploy PyTeal contract to testnet/mainnet
   - Handle settlement on-chain
   - Mint loyalty tokens (ASA)

2. **Flutter Frontend**
   - Mobile app for payment creation
   - QR scanning with camera
   - Offline transaction storage

3. **Database**
   - Replace in-memory store with PostgreSQL
   - Add transaction history persistence
   - Add merchant/user management

4. **Security**
   - Secure key storage in device enclave
   - Rate limiting on API endpoints
   - Transaction amount limits
   - KYC/AML compliance

5. **Deployment**
   - Deploy backend to cloud (Heroku, Railway, etc.)
   - Publish Flutter app to stores
   - Deploy smart contract to mainnet

## Dependencies

- **express**: Web framework
- **tweetnacl**: Ed25519 crypto library
- **cors**: Cross-origin resource sharing
- **dotenv**: Environment variable management
- **uuid**: Unique ID generation
- **typescript**: Type-safe JavaScript
- **axios**: HTTP client (for demo)

## License

MIT

## Contact

For questions about 808Pay, reach out to the development team.

---

**Built for Hackathon with ❤️**
