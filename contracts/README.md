# Algorand Smart Contract - Deployment Guide

## Overview

This guide walks through deploying the 808Pay smart contract to Algorand.

## Prerequisites

- Python 3.9+
- AlgoKit installed (`algokit`)
- Local Algorand node running (`algokit localnet start`)
- All dependencies installed:
  ```bash
  pip install algorand-sdk pyteal python-dotenv
  ```

## Project Structure

```
contracts/
├── payment_settlement/
│   ├── contract.py          # PyTeal smart contract code
│   └── __init__.py
├── requirements.txt         # Python dependencies
├── algokit.yaml            # AlgoKit configuration
├── deploy.py               # Deployment script
└── README.md               # This file
```

## Smart Contract Functions

### `approval_program()`
Main contract logic handling:
- **On Create**: Initialize contract state
- **On Call**: Verify Ed25519 signatures and settle payments
- **On Opt-In**: Allow users to opt-in

### `clear_state_program()`
Clean up user local state when opting out.

## Deployment Steps

### Step 1: Verify Local Algorand is Running

```bash
# Check if localnet is running
docker ps | grep algod

# If not running, start it
cd /Users/srijan/808Pay/contracts
algokit localnet start
```

Expected output: 4 containers running (algod, indexer, conduit, postgres)

### Step 2: Deploy the Contract

```bash
# Navigate to contracts directory
cd /Users/srijan/808Pay/contracts

# Run deployment script
python deploy.py
```

Expected output:
```
============================================================
808Pay Smart Contract Deployment
============================================================

1. Connecting to Algorand node...
   ✓ Connected! Round: 12345

2. Compiling smart contract...
   ✓ Contract compiled successfully!

3. Using test account...
   Test account: ACCOUNT_ADDRESS_HERE

4. Deploying contract to Algorand...
   ✓ DEPLOYMENT SUCCESSFUL!
   App ID: 1234567890
   Account: ACCOUNT_ADDRESS_HERE
```

### Step 3: Save App ID

The deployment script automatically saves the App ID to `.env.local`:

```bash
cat .env.local
# Output: ALGORAND_APP_ID=1234567890
```

**Important**: Share this App ID with the backend integration team!

## Testing the Contract

### Test 1: Check Contract State

```bash
# Use algokit to inspect contract
algokit app info --app-id 1234567890
```

### Test 2: Call Contract Function

Create a test transaction to verify the contract is callable:

```python
# test_contract.py
from algosdk.v2client import algod
from algosdk.future import transaction

client = algod.AlgodClient("", "http://localhost:4001")

# Get the app info
app_id = 1234567890  # Replace with your App ID
app_info = client.application_info(app_id)
print(json.dumps(app_info, indent=2))
```

## Deployment to Testnet

Once local testing is complete:

### Step 1: Create Testnet Account

```bash
# Generate new account
python3 -c "from algosdk import account; pk, addr = account.generate_account(); print(f'Private Key: {pk}\nAddress: {addr}')"
```

### Step 2: Fund Account

Get testnet ALGO from: https://testnet.algoexplorer.io/dispenser

### Step 3: Deploy to Testnet

Modify `deploy.py` to connect to testnet:

```python
# Change this:
def get_algod_client(host: str = "http://localhost", port: int = 4001):

# To this for testnet:
def get_algod_client(host: str = "https://testnet-api.algonode.cloud", port: int = 443):
```

Then run deployment with testnet account:

```bash
python deploy.py
```

## Environment Variables

Create `.env.local` with deployment details:

```env
# Smart Contract
ALGORAND_APP_ID=1234567890
ALGORAND_NETWORK=localnet

# Account (for testnet deployment)
ALGORAND_ACCOUNT_ADDRESS=YOUR_ADDRESS
ALGORAND_ACCOUNT_PRIVATE_KEY=YOUR_PRIVATE_KEY

# Node
ALGORAND_NODE_URL=http://localhost:4001
```

## Troubleshooting

### Issue: Connection refused (localhost:4001)

**Solution**: Start the local Algorand node
```bash
algokit localnet start
```

### Issue: Python module not found

**Solution**: Install dependencies
```bash
pip install -r requirements.txt
```

### Issue: Transaction failed

**Solution**: Check account balance (must have ALGO to pay transaction fees)
```bash
# In Python:
from algosdk.v2client import algod
client = algod.AlgodClient("", "http://localhost:4001")
account_info = client.account_info("YOUR_ADDRESS")
print(f"Balance: {account_info['amount']} microAlgo")
```

### Issue: Invalid contract syntax

**Solution**: Verify PyTeal syntax
```bash
python -c "from payment_settlement.contract import approval_program; print(approval_program())"
```

## Next Steps

1. ✅ Deploy to local sandbox
2. ⏳ Get App ID from deployment
3. ⏳ Share App ID with backend team
4. ⏳ Test contract integration with backend
5. ⏳ Deploy to Algorand testnet
6. ⏳ Create deployment documentation
7. ⏳ Prepare for mainnet deployment

## File Reference

- **contract.py** - Smart contract source code
- **deploy.py** - Deployment script
- **requirements.txt** - Python dependencies
- **.env.local** - Local configuration (generated after deploy)

## Support

For issues:
1. Check SMART_CONTRACT_GUIDE.md for contract details
2. Review BACKEND_INTEGRATION_GUIDE.md for integration steps
3. Check Algorand docs: https://developer.algorand.org/

## Useful Commands

```bash
# Check localnet status
algokit localnet status

# Stop localnet
algokit localnet stop

# View localnet logs
algokit localnet logs

# Reset localnet
algokit localnet reset

# Get algod logs
docker logs algokit_algod_1

# Query account info
algokit account info
```

---

**Created**: April 10, 2026  
**Project**: 808Pay - Offline Algorand Payments
