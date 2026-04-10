# 808Pay Smart Contract Developer Guide

## Quick Start for Smart Contract Developer

This guide is for the member developing and deploying the Algorand smart contract.

### Prerequisites
- ✅ AlgoKit CLI installed
- ✅ Python 3.9+ installed
- ✅ PyTeal library installed
- ✅ Local Algorand Sandbox running (on port 4001)
- Algorand Testnet account with test ALGO funded

### Current Status ✅
- Smart contract skeleton created: `contracts/payment_settlement/contract.py`
- Compiles to TEAL bytecode successfully
- Local sandbox running and ready for testing
- Backend ready to integrate with contract

---

## Your Tasks

### Phase 1: Test Locally (Hours 0-2)
1. ✅ Contract created and compiling
2. Create deployment script
3. Deploy to local sandbox
4. Create test accounts
5. Test Ed25519 signature verification
6. Test payment splitting logic

### Phase 2: Deploy to Testnet (Hours 2-4)
1. Create Algorand testnet account
2. Fund with test ALGO (faucet)
3. Deploy contract to testnet
4. Get contract App ID
5. Update `.env` with Contract App ID
6. Notify backend developer

### Phase 3: Integration (Hours 4+)
1. Work with backend developer to integrate
2. Test full settlement flow
3. Debug any issues

---

## Smart Contract Structure

### File: `contracts/payment_settlement/contract.py`

**Current Functions:**
- `on_create()` - Initialize contract on deployment
- `on_verify_and_settle()` - Verify signature and settle payment
- `on_opt_in()` - User opt-in for local state

**Contract State:**
```python
# Global State
processor: String          # Backend wallet address
fee_rate: UInt64          # Percentage (e.g., 5 for 5%)
loyalty_token: UInt64     # ASA ID for loyalty tokens

# Local State (per account)
total_paid: UInt64        # Total amount user paid
loyalty_balance: UInt64   # Loyalty points earned
```

**Contract Methods:**
1. `verify_and_settle(data, signature, pubkey, amount, merchant)` - Main settlement
2. `opt_in()` - User joins contract
3. `close_out()` - User leaves contract

---

## Deployment Workflow

### Step 1: Local Testing

Create deployment script: `contracts/deploy_local.py`

```python
from algosdk.v2client import algod
from pyteal import compileTeal, Mode
from contracts.payment_settlement.contract import approval_program, clear_state_program

# Connect to local sandbox
client = algod.AlgodClient("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", "http://localhost:4001")

# Compile contract
approval_teal = compileTeal(approval_program(), Mode.Application, version=10)
clear_teal = compileTeal(clear_state_program(), Mode.Application, version=10)

# Deploy (implementation details in next section)
```

### Step 2: Create Test Accounts

```bash
# Generate test account
goal account new

# Export mnemonic for testing
goal account export
```

### Step 3: Deploy to Local Sandbox

```bash
python3 contracts/deploy_local.py
```

### Step 4: Test Settlement

```bash
# Create test transaction
# Sign with test key
# Submit to contract
# Verify splits (90/5/5)
```

---

## Testnet Deployment

### Step 1: Create Testnet Account

Option A: Using Pera Wallet
- Download Pera Wallet app
- Create new wallet
- Switch to Testnet
- Copy address

Option B: Using AlgoKit
```bash
algokit account new --alias testnet-808pay
algokit account fund --alias testnet-808pay 10
```

### Step 2: Fund with Test ALGO

```bash
# Get testnet account from Pera Wallet
# Go to: https://dispenser.testnet.algorand.network/
# Paste your address
# Get test ALGO
```

### Step 3: Deploy to Testnet

Create deployment script: `contracts/deploy_testnet.py`

```python
# Similar to local deploy, but:
# 1. Connect to testnet (not local sandbox)
# 2. Use funded testnet account
# 3. Get App ID from transaction
# 4. Save App ID to .env file
```

### Step 4: Verify Deployment

```bash
# Check app on testnet explorer
# https://testnet.algoexplorer.io/
# Search for your App ID
```

---

## Integration with Backend

### Update Backend `.env`

```env
CONTRACT_APP_ID=123456789          # Your deployed app ID
PAYMENT_PROCESSOR_ADDRESS=YOUR_ADDRESS
ALGORAND_NETWORK=testnet
ALGORAND_SERVER=https://testnet-algorand.api.purestake.io/ps2
ALGORAND_TOKEN=your-api-token
```

### Backend Integration

Backend developer will:
1. Use `algosdk` to call your contract
2. Send signed transactions to contract
3. Verify settlement on-chain
4. Return results to frontend

---

## Testing Checklist

### Local Sandbox Tests
- [ ] Contract deploys successfully
- [ ] App ID generated
- [ ] Test accounts can opt-in
- [ ] Signature verification works
- [ ] Payment splitting correct (90/5/5)
- [ ] Transaction settles
- [ ] State updates correctly

### Testnet Tests
- [ ] Contract deploys to testnet
- [ ] App ID accessible on explorer
- [ ] Testnet account has sufficient ALGO
- [ ] Settlement transactions succeed
- [ ] Backend can call contract
- [ ] Frontend can sign and submit

---

## Useful Commands

```bash
# Check local sandbox status
algokit localnet status

# View logs
algokit localnet logs -f

# Stop sandbox
algokit localnet stop

# Reset sandbox (clear all data)
algokit localnet reset

# Compile contract
python3 contracts/payment_settlement/contract.py
```

---

## Contract Bytecode Output

When you run the contract, it outputs TEAL bytecode:

```
#pragma version 10
txn ApplicationID
int 0
==
bnz main_l6
...
```

This is what gets deployed to Algorand. Save this if needed for debugging.

---

## Key Resources

- PyTeal Docs: https://pyteal.readthedocs.io/
- Algorand Testnet: https://testnet.algoexplorer.io/
- AlgoKit Docs: https://github.com/algorandfoundation/algokit-cli
- Algorand SDK: https://github.com/algorand/py-algorand-sdk

---

## Important Notes

⚠️ **Network:** Always test on testnet before mainnet

⚠️ **Keys:** Never commit private keys to git

⚠️ **Contract Logic:** Payment splitting happens on-chain, backend verifies

⚠️ **Signature:** Use Ed25519 signatures from Pera Wallet, contract verifies

---

## Timeline

| Time | Task | Output |
|------|------|--------|
| 0-1h | Test locally | Contract deployment script |
| 1-2h | Deploy to testnet | App ID + testnet address |
| 2-3h | Provide to backend | Integration ready |
| 3-4h | Debug with backend | Working settlement |

---

## Questions?

Contact the backend developer if there are issues with integration.

Good luck! 🚀
