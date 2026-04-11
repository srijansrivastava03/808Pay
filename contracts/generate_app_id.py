#!/usr/bin/env python3
"""
808Pay Smart Contract ID Generator
Generates a PAYMENT_APP_ID for the smart contract deployment.

In production:
1. Deploy contract to testnet using deploy.py
2. Extract APP_ID from deployment output
3. Add to backend/.env

For development:
This script generates a realistic demo APP_ID format.
"""

import random
import sys
from datetime import datetime

def generate_app_id():
    """Generate a realistic Algorand App ID"""
    # Algorand App IDs are uint64 integers
    # They start from 1 (0 is reserved for no app)
    # In testnet, IDs typically range from 1 to millions
    
    # Generate a realistic ID in testnet range
    app_id = random.randint(1000000, 9999999)
    return app_id

def main():
    print("\n" + "="*70)
    print("  808Pay Smart Contract ID Generator")
    print("="*70)
    
    print("\n📋 About Smart Contract Deployment:")
    print("   • Smart contract enables atomic pair-wise settlement")
    print("   • Requires testnet deployment to get real APP_ID")
    print("   • For development, you can use a demo ID below")
    
    choice = input("\nOperation:\n1. Generate demo ID for development\n2. Instructions for real deployment\n\nChoose (1/2): ").strip()
    
    if choice == "1":
        app_id = generate_app_id()
        
        print(f"\n✓ Generated Demo APP_ID: {app_id}")
        print(f"\n📝 To use this ID for development:")
        print(f"   1. Open: backend/.env")
        print(f"   2. Update: PAYMENT_APP_ID={app_id}")
        print(f"   3. Restart backend: npm run dev")
        print(f"\n⚠️  This is a DEMO ID only for development!")
        print(f"   For production, deploy the real contract to testnet.")
        
        # Save to file
        with open(".env.local", "w") as f:
            f.write(f"# Auto-generated demo APP_ID on {datetime.now()}\n")
            f.write(f"PAYMENT_APP_ID={app_id}\n")
            f.write(f"DEPLOY_STATUS=demo\n")
        
        print(f"\n✓ Saved to: .env.local")
        print(f"\nNext steps:")
        print(f"1. Copy the APP_ID: {app_id}")
        print(f"2. Add to backend/.env:")
        print(f"   PAYMENT_APP_ID={app_id}")
        print(f"3. Backend will use it for settlements")
        
    elif choice == "2":
        print("\n" + "="*70)
        print("  REAL SMART CONTRACT DEPLOYMENT")
        print("="*70)
        
        print("\nPrerequisites:")
        print("✓ Python 3.9+")
        print("✓ Algorand SDK: pip install py-algorand-sdk")
        print("✓ PyTeal: pip install pyteal")
        print("✓ Algo testnet account with funds")
        
        print("\nSteps:")
        print("\n1. Get testnet credentials from:")
        print("   https://www.purestake.com/ (API key)")
        print("   OR")
        print("   https://lora.algokit.io/testnet/fund (AlgoKit testnet)")
        
        print("\n2. Create .env file in contracts/ folder:")
        print("   ALGO_NETWORK=testnet")
        print("   ALGORAND_TOKEN=your-api-token")
        print("   ALGORAND_SERVER=https://testnet-algorand.api.purestake.io/ps2")
        print("   CREATOR_MNEMONIC=your-testnet-account-mnemonic")
        
        print("\n3. Run deployment:")
        print("   cd /Users/srijan/808Pay/contracts")
        print("   python3 deploy.py")
        
        print("\n4. Copy the generated APP_ID to backend/.env:")
        print("   PAYMENT_APP_ID=<app-id-from-deployment>")
        
        print("\n📚 Documentation:")
        print("   • Smart Contract: contracts/payment_settlement/contract.py")
        print("   • Deployment Script: contracts/deploy.py")
        print("   • Backend Integration: backend/src/services/algorandService.ts")
        
    else:
        print("Invalid choice. Exiting.")
        sys.exit(1)
    
    print("\n" + "="*70 + "\n")

if __name__ == "__main__":
    main()
