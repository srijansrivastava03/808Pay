#!/usr/bin/env python3
"""
Deploy 808Pay smart contract to Algorand network
"""

import json
import sys
import base64
from pathlib import Path

from algosdk import account, mnemonic
from algosdk.v2client import algod
from algosdk.future import transaction
from pyteal import *

# Import the contract
from payment_settlement.contract import approval_program, clear_state_program


def get_algod_client(host: str = "http://localhost", port: int = 4001) -> algod.AlgodClient:
    """Connect to Algorand node"""
    return algod.AlgodClient("", f"{host}:{port}")


def compile_program(client: algod.AlgodClient, program: Expr) -> str:
    """Compile PyTeal program to TEAL"""
    teal_code = compileTeal(program, Mode.Application, version=10)
    response = client.compile(teal_code)
    return response["result"]


def create_app(
    client: algod.AlgodClient,
    sender_address: str,
    sender_private_key: str,
    approval_program_bytes: str,
    clear_program_bytes: str,
) -> int:
    """Create new app on Algorand"""
    
    # Get suggested params
    params = client.suggested_params()
    
    # Create app creation transaction
    txn = transaction.ApplicationCreateTxn(
        sender=sender_address,
        index=0,
        approval_program=base64.b64decode(approval_program_bytes),
        clear_program=base64.b64decode(clear_program_bytes),
        global_schema=transaction.StateSchema(num_uints=2, num_byte_slices=2),
        local_schema=transaction.StateSchema(num_uints=1, num_byte_slices=1),
        sp=params,
    )
    
    # Sign transaction
    signed_txn = txn.sign(sender_private_key)
    
    # Submit transaction
    tx_id = client.send_transactions([signed_txn])
    print(f"Submitted transaction: {tx_id}")
    
    # Wait for confirmation
    result = transaction.wait_for_confirmation(client, tx_id, 4)
    
    # Get app ID from result
    app_id = result["application-index"]
    print(f"App created successfully! App ID: {app_id}")
    
    return app_id


def save_app_id(app_id: int, filename: str = ".env.local"):
    """Save App ID to environment file"""
    content = f"ALGORAND_APP_ID={app_id}\n"
    
    with open(filename, "w") as f:
        f.write(content)
    
    print(f"App ID saved to {filename}")


def main():
    """Main deployment function"""
    
    print("=" * 60)
    print("808Pay Smart Contract Deployment")
    print("=" * 60)
    
    # Connect to Algorand
    print("\n1. Connecting to Algorand node...")
    try:
        client = get_algod_client()
        status = client.status()
        print(f"   ✓ Connected! Round: {status['last-round']}")
    except Exception as e:
        print(f"   ✗ Failed to connect: {e}")
        print("   Make sure 'algokit localnet start' is running!")
        sys.exit(1)
    
    # Compile programs
    print("\n2. Compiling smart contract...")
    try:
        approval_bytes = compile_program(client, approval_program())
        clear_bytes = compile_program(client, clear_state_program())
        print("   ✓ Contract compiled successfully!")
    except Exception as e:
        print(f"   ✗ Compilation failed: {e}")
        sys.exit(1)
    
    # Get test account (from localnet)
    print("\n3. Using test account...")
    # For local testing, we can use any account from the localnet
    # In production, you would use a real account from Pera Wallet
    
    # Create a test account for demo purposes
    test_private_key, test_address = account.generate_account()
    print(f"   Test account: {test_address}")
    
    # In real deployment, fund the account first
    print("   (In production, ensure account is funded)")
    
    # Deploy contract
    print("\n4. Deploying contract to Algorand...")
    try:
        app_id = create_app(
            client,
            test_address,
            test_private_key,
            approval_bytes,
            clear_bytes,
        )
        
        # Save App ID
        save_app_id(app_id)
        
        print("\n" + "=" * 60)
        print(f"✓ DEPLOYMENT SUCCESSFUL!")
        print(f"  App ID: {app_id}")
        print(f"  Account: {test_address}")
        print("=" * 60)
        print("\nNext steps:")
        print(f"1. Update backend with App ID: {app_id}")
        print("2. Update BACKEND_INTEGRATION_GUIDE.md with contract details")
        print("3. Test contract functions with backend")
        print("4. Deploy to testnet when ready")
        
        return 0
        
    except Exception as e:
        print(f"   ✗ Deployment failed: {e}")
        print(f"   Error details: {e}")
        sys.exit(1)


if __name__ == "__main__":
    sys.exit(main())
