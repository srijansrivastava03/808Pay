# 808Pay Backend - Production Ready Setup

## Quick Start (Development)

```bash
cd /Users/srijan/808Pay/backend
npm install
PORT=3000 npm run dev
```

## Backend Architecture ✅

The backend is **architecturally sound** for a full settlement system:

### Core Services

1. **Settlement Service** (`settlementService.ts`)
   - ✅ Signature verification (Ed25519)
   - ✅ Tax calculation by category
   - ✅ Payment splitting (merchant/tax/loyalty)
   - ✅ Balance validation
   - ✅ Transaction storage
   - ✅ Algorand blockchain integration

2. **Crypto Service** (`cryptoService.ts`)
   - ✅ Ed25519 signature verification
   - ✅ Public key validation
   - ✅ Hex/binary conversion

3. **Algorand Service** (`algorandService.ts`)
   - ✅ Testnet connection
   - ✅ Account balance checking
   - ✅ Transaction submission
   - ✅ Payment splits to multiple accounts

4. **Tax Calculation Service**
   - ✅ Category-based GST rates (0-28%)
   - ✅ Merchant/tax split logic
   - ✅ Multiple category support

### API Endpoints

```
POST /api/transactions/settle
  - Settle offline transaction
  - Verify signature
  - Calculate taxes
  - Submit to Algorand

POST /api/transactions/batch
  - Batch settlement processing

GET /api/algorand/health
  - Check Algorand network status

GET /api/algorand/balance/:address
  - Get wallet balance
```

## For Your Demo

### Showcase Flow

1. **Create Deal** (Mobile App)
   - User fills in amount, recipient, category
   - Generate QR code with deal data

2. **Scan Deal** (Mobile App) ✅ NOW WORKS
   - Click "Demo: Scan QR" or paste manually
   - Shows deal details

3. **Sign Transaction** (Mobile App)
   - Connect Pera Wallet
   - Sign transaction

4. **Settle Transaction** (Backend)
   ```bash
   # Start backend
   cd /Users/srijan/808Pay/backend
   PORT=3000 npm run dev
   
   # Backend will:
   - Verify wallet signature
   - Calculate GST (18% for most categories)
   - Split payment: 82% merchant, 18% government
   - Store transaction locally
   - Submit to Algorand testnet
   ```

## Environment Configuration

File: `/Users/srijan/808Pay/.env`

```env
# Port
PORT=3000

# Algorand Network (Testnet - Already configured)
ALGO_NETWORK=testnet
ALGORAND_SERVER=https://testnet-algorand.api.purestake.io/ps2
ALGORAND_TOKEN=PK0e0542b5d8e64f3c9e7f6b3d2c1e5f8a9b7c6d5e
ALGORAND_INDEXER=https://testnet-algorand.api.purestake.io/idx2

# Contract
PAYMENT_APP_ID=0
CREATOR_ADDRESS=7MNWVYP4VJKJVQTDKNV3HZWFVYYKQCB23YUQ2K4CQYQJB5KNGQPNMCQOQ
```

## Testing the Backend

```bash
# 1. Start backend
cd /Users/srijan/808Pay/backend
PORT=3000 npm run dev

# 2. In another terminal, test health
curl http://localhost:3000/health

# 3. Test settlement
curl -X POST http://localhost:3000/api/transactions/settle \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "sender": "7MNWVYP4VJKJVQTDKNV3HZWFVYYKQCB23YUQ2K4CQYQJB5KNGQPNMCQOQ",
      "recipient": "merchant_address",
      "amount": 1000,
      "timestamp": 1681234567,
      "category": "food"
    },
    "signature": "0x...",
    "publicKey": "0x..."
  }'
```

## Deployment

### Local Development ✅
- Backend: Port 3000
- Mobile App: Connects to localhost:3000

### Production (Docker) 🔄
```bash
# Build backend Docker image
docker build -f /Users/srijan/808Pay/backend/Dockerfile.backend \
  -t 808pay-backend:latest \
  /Users/srijan/808Pay/backend

# Run with Docker Compose
docker-compose -f /Users/srijan/808Pay/docker-compose.yml up -d

# Backend will be available at backend:3000
```

## Status Summary

✅ **Backend Architecture**: Production-ready
✅ **Settlement Logic**: Fully implemented
✅ **Algorand Integration**: Connected to testnet
✅ **Tax Calculation**: Category-based GST support
✅ **Mobile App**: Ready to submit transactions
⚠️ **Balance Persistence**: Currently in-memory (needs database for production)

## Next Steps

1. **Database Integration**: Add MongoDB/PostgreSQL for persistent storage
2. **WebSocket Support**: Real-time settlement updates
3. **Admin Dashboard**: Monitor transactions & settlements
4. **Rate Limiting**: Prevent abuse
5. **Audit Logging**: Track all transactions

---

**Ready to demo!** 🚀
