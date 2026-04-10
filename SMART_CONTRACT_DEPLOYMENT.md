# 808Pay Smart Contract Deployment Guide

## Overview

The 808Pay Atomic Settlement Smart Contract enables:
- **Dual-signature verification** (buyer + seller)
- **Atomic settlement recording** on Algorand blockchain
- **Payment splitting** (90% merchant, 8% platform, 2% loyalty)
- **Offline signature support** with on-chain verification

## Smart Contract Architecture

### Approval Program (Main Logic)

**State Management:**
- Global: `creator`, `settlement_counter`, `total_volume`
- Local: `total_settled`, `loyalty_points` (per user)

**Core Methods:**

1. **settle-atomic** - Atomic dual-signature settlement
   - Verifies buyer Ed25519 signature
   - Verifies seller Ed25519 signature
   - Records settlement on-chain
   - Updates volume tracking

2. **get-info** - Read-only contract info
   - Returns settlement count
   - Returns total volume processed

### Clear State Program

Allows users to opt out and close local state.

## Deployment Options

### Option 1: Local Development (AlgoKit)

```bash
# 1. Start local Algorand environment
algokit localnet start

# 2. Deploy contract
cd /Users/srijan/808Pay
python3 contracts/deploy.py

# Expected output:
# ========================================
#   Deployment Information
# ========================================
# App ID: [generated_id]
# Creator: [test_account]
# Network: LOCALNET
```

### Option 2: Testnet Deployment

```bash
# 1. Get testnet API key from PureStake
# https://www.purestake.com/ -> Sign up -> Copy API Key

# 2. Update .env
ALGO_NETWORK=testnet
ALGORAND_TOKEN=your-purestake-api-key
ALGORAND_SERVER=https://testnet-algorand.api.purestake.io/ps2
ALGORAND_INDEXER=https://testnet-algorand.api.purestake.io/idx2

# 3. Create account or use existing
# Option A: Generate new account
#   → Go to: https://goalseeker.purestake.io/
#   → Create new account
#   → Fund with testnet ALGO from: https://dispenser.testnet.algorand.com

# Option B: Use existing mnemonic
#   → Add CREATOR_MNEMONIC to .env (24 words)
#   → Make sure account has testnet ALGO balance

# 4. Deploy
python3 contracts/deploy.py

# Expected output:
# ========================================
#   Deployment Information
# ========================================
# App ID: [generated_id]
# Creator: [your_address]
# Network: TESTNET
```

## Integration with Backend

### Step 1: Capture App ID from Deployment

After running `python3 contracts/deploy.py`, you'll get:
```
App ID: 12345
```

### Step 2: Update Backend Environment

Add to `backend/.env`:
```env
PAYMENT_APP_ID=12345
CREATOR_ADDRESS=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
DEPLOY_NETWORK=localnet
```

### Step 3: Verify Contract Integration

Check backend can call contract:
```bash
cd /Users/srijan/808Pay/backend
npm test -- --grep "atomic-settle"
```

## Test Scenarios

### Scenario 1: Offline Signing → Blockchain Submission

```
1. User creates deal (offline)
2. User signs with private key (offline)
3. Both parties sign (offline)
4. App calls smart contract with dual signatures
5. Contract verifies signatures
6. Settlement recorded on-chain
```

### Scenario 2: Cross-Party Settlement

```
Party A (Buyer)              Smart Contract              Party B (Seller)
      |                              |                            |
      | Create deal               |                            |
      | --------------------------------->                       |
      |                              |                            |
      | Sign (offline)               |                            |
      | <-----------Sign request-----|<------Sign request------  |
      |                              |                            |
      | Return signature             |                     Return signature
      | ------Signature 1----------> | <--------Signature 2------|
      |                              |                            |
      |                         Verify both signatures           |
      |                         Record settlement                |
      |                         ✓ Atomic & Irreversible         |
      |                              |                            |
      |<---Settlement confirmed------|---Settlement confirmed----->|
```

## TEAL Contract Overview

### Key Operations

**Ed25519 Verification:**
```
ed25519verify(message, signature, public_key) -> bool
```

**State Updates:**
```
App.globalPut(key, value)
App.localPut(sender, key, value)
```

**Logging:**
```
Log(settlement_id:category:amount)
```

## Security Considerations

1. **Signature Verification**
   - Both buyer and seller signatures verified with Ed25519
   - Same transaction hash must be signed by both parties
   - Signatures verified on-chain (deterministic)

2. **Settlement Atomicity**
   - Once recorded on-chain, settlement is immutable
   - Cannot be reversed or modified
   - Provides finality for both parties

3. **State Management**
   - Global state tracks total volume processed
   - Settlement counter prevents replay attacks
   - Each settlement gets unique ID

4. **Off-Chain Signing**
   - Signatures can be created offline
   - No internet required for signing
   - Only submission requires network connection

## Troubleshooting

### Issue: "Connection failed" when deploying to testnet

**Solution:**
```bash
# 1. Check API key is valid
export ALGORAND_TOKEN="your-api-key"

# 2. Test connection
curl -s -H "X-API-Key: $ALGORAND_TOKEN" \
  https://testnet-algorand.api.purestake.io/ps2/status | jq

# 3. If connection works but deploy fails, try localnet first
ALGO_NETWORK=localnet python3 contracts/deploy.py
```

### Issue: "Account not funded" on testnet

**Solution:**
```bash
# Get your address from deployment attempt
# Go to: https://dispenser.testnet.algorand.com
# Paste address and request funds

# Wait 1-2 minutes for confirmation, then retry deployment
```

### Issue: "Invalid mnemonic" error

**Solution:**
```bash
# 1. Verify mnemonic is 24 words, space-separated
# 2. Check for typos or extra spaces
# 3. Generate new account at: https://goalseeker.purestake.io/

# If using existing account, export mnemonic:
# 1. Open Pera Wallet
# 2. Settings → Account Recovery → Export Recovery Phrase
# 3. Copy the 24-word phrase to CREATOR_MNEMONIC
```

## Production Deployment Checklist

- [ ] Contract compiles without errors
- [ ] Deployed to testnet successfully
- [ ] App ID saved to .env
- [ ] Backend integration tested
- [ ] E2E test passes (dual signatures → blockchain)
- [ ] Performance meets <500ms latency requirement
- [ ] Security audit completed
- [ ] Documented deployment procedure
- [ ] Backup of mnemonic phrase stored securely
- [ ] Ready for mainnet deployment

## Next Steps

1. **Deploy Smart Contract**
   ```bash
   python3 contracts/deploy.py
   ```

2. **Integrate with Backend**
   - Update `.env` with App ID
   - Restart backend server
   - Run integration tests

3. **Test E2E Flow**
   ```bash
   # Run E2E test suite
   cd mobile
   flutter test test/atomic_settlement_integration_test.dart
   ```

4. **Demo Preparation**
   - Prepare demo account
   - Pre-sign demo transactions
   - Document deployment steps

## Resources

- **Algorand Documentation**: https://developer.algorand.org/
- **PyTeal Documentation**: https://github.com/algorand/pyteal
- **PureStake API**: https://www.purestake.com/
- **Algorand Testnet Dispenser**: https://dispenser.testnet.algorand.com
- **AlgoKit**: https://github.com/algorandfoundation/algokit

## Support

For deployment issues:
1. Check error logs from `python3 contracts/deploy.py`
2. Verify .env configuration matches target network
3. Test with localnet first before testnet
4. Review TEAL bytecode for contract logic issues
