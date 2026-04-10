# 808Pay - Project Documentation

## Overview
**808Pay** is a blockchain-based offline payment settlement engine built for Algorand using:
- **AlgoKit** - Algorand Development Kit
- **VibeKit** - UI Component Library  
- **Boiler Template** - Project scaffolding
- **Pera Wallet** - User wallet integration
- **Flutter** - Mobile frontend
- **Node.js Express** - Backend (already built)

---

## Tech Stack

### Backend (COMPLETED ✅)
- **Express.js** - REST API server
- **Node.js** - Runtime
- **TypeScript** - Type safety
- **tweetnacl** - Ed25519 cryptography
- **Docker** - Containerization
- **Port**: 3000

### Smart Contract (TO BUILD)
- **AlgoKit** - Algorand SDK & tools
- **PyTeal** - Python smart contract language
- **Algorand Testnet** - Deployment target
- **Docker** - Containerized environment

### Frontend (TO BUILD)
- **Flutter** - Mobile app framework
- **VibeKit** - UI components
- **Pera Wallet** - Wallet integration
- **QR Code** - Payment encoding

### DevOps (NEW)
- **Docker** - Container platform
- **Docker Compose** - Multi-container orchestration
- **nginx** - Reverse proxy
- **Docker Hub** - Image registry

---

## Architecture

```
┌──────────────────────────────────────┐
│  Pera Wallet Integration             │
│  (User funds & account)              │
└────────┬─────────────────────────────┘
         │
┌────────▼─────────────────────────────┐
│  Flutter Frontend (VibeKit)          │
│  - Payment creation                  │
│  - QR generation                     │
│  - Transaction signing (offline)     │
│  - Pera Wallet connection            │
└────────┬─────────────────────────────┘
         │ HTTPS
┌────────▼─────────────────────────────┐
│  Backend (Express + TypeScript)      │
│  - Signature verification            │
│  - Payment splitting (90/5/5)        │
│  - Transaction storage               │
│  - Smart contract calls              │
└────────┬─────────────────────────────┘
         │ algosdk
┌────────▼─────────────────────────────┐
│  Smart Contract (PyTeal + AlgoKit)   │
│  - Validate signatures               │
│  - Execute payment splits            │
│  - Mint loyalty tokens               │
│  - Record on blockchain              │
└────────┬─────────────────────────────┘
         │
┌────────▼─────────────────────────────┐
│  Algorand Testnet                    │
│  - Transaction settlement            │
│  - Account state changes             │
│  - Immutable records                 │
└──────────────────────────────────────┘
```

---

## Docker Setup

### Docker Architecture

```
┌─────────────────────────────────────────┐
│  Docker Compose (docker-compose.yml)    │
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────────┐  ┌──────────────┐    │
│  │   Backend    │  │  AlgoKit     │    │
│  │  Container   │  │  Container   │    │
│  │ (Node.js)    │  │ (Python)     │    │
│  │ Port 3000    │  │ Port 4001    │    │
│  └──────────────┘  └──────────────┘    │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │      nginx (Reverse Proxy)       │  │
│  │      Port 80/443                 │  │
│  └──────────────────────────────────┘  │
│                                         │
└─────────────────────────────────────────┘
         │
    Volumes (persistent storage)
    Networks (internal communication)
```

### Docker Files to Create

#### 1. Backend Dockerfile
- Image: Node.js 18
- Build TypeScript
- Expose port 3000
- Health check

#### 2. Smart Contract Dockerfile
- Image: Python 3.9
- Install AlgoKit, PyTeal
- Setup Algorand sandbox
- Expose port 4001

#### 3. docker-compose.yml
- Define backend service
- Define smart contract service
- Define nginx service
- Environment variables
- Volume management
- Network configuration

#### 4. nginx.conf
- Reverse proxy configuration
- Load balancing (optional)
- SSL/TLS support
- CORS headers

### Docker Commands

```bash
# Build all images
docker-compose build

# Start all containers
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all containers
docker-compose down

# Rebuild and restart
docker-compose up --build

# Execute command in container
docker-compose exec backend npm run dev

# SSH into container
docker-compose exec backend bash
```

### Benefits of Docker

✅ **Consistency** - Same environment everywhere  
✅ **Isolation** - Services don't interfere  
✅ **Easy deployment** - Just run docker-compose up  
✅ **Scalability** - Easy to add more services  
✅ **CI/CD** - Automated testing & deployment  
✅ **Hackathon** - Everyone uses same setup  

---

```
808Pay/
├── src/                          # Backend (DONE ✅)
│   ├── index.ts                 # Express server
│   ├── services/
│   │   ├── cryptoService.ts     # Ed25519 verification
│   │   └── settlementService.ts # Payment settlement
│   ├── routes/transactions.ts   # API endpoints
│   ├── store/transactionStore.ts # In-memory DB
│   └── types/index.ts           # TypeScript interfaces
│
├── contracts/                    # Smart Contracts (TO BUILD)
│   ├── payment_settlement.py    # PyTeal smart contract
│   ├── artifacts/               # Compiled TEAL
│   └── tests/                   # Contract tests
│
├── mobile/                       # Flutter App (TO BUILD)
│   ├── lib/
│   │   ├── screens/             # Payment, QR, History
│   │   ├── services/            # Pera Wallet, API calls
│   │   └── widgets/             # VibeKit components
│   ├── pubspec.yaml             # Flutter dependencies
│   └── android/ios/             # Platform configs
│
├── algokit.yaml                 # AlgoKit config (TO CREATE)
├── package.json                 # Backend deps
├── .env                         # Environment config
└── README.md                    # Documentation
```

---

## Development Flow

### Phase 1: Backend (✅ COMPLETE)
- Express server running on port 3000
- Crypto utilities implemented
- Settlement endpoints ready
- Error handling in place

### Phase 2: Smart Contract (TO DO)
**Duration**: 2-3 hours

#### 2.1 Setup AlgoKit Environment
```bash
Prerequisites:
- Python 3.9+
- AlgoKit CLI installed
- Algorand Testnet wallet funded
```

#### 2.2 Create PyTeal Smart Contract
**Contract Functions**:
1. `verify_payment()` - Validate Ed25519 signature
2. `split_payment()` - Distribute funds (90/5/5)
3. `record_settlement()` - Store on-chain
4. `mint_loyalty()` - Create loyalty tokens (ASA)

**Contract Features**:
- Stateful contract (state management)
- Argument validation
- Payment splitting logic
- Loyalty token minting

#### 2.3 Deploy to Testnet
```bash
Steps:
1. Test locally with AlgoKit
2. Deploy to Algorand Testnet
3. Get app ID from deployment
4. Store in backend .env
```

### Phase 3: Flutter Frontend (TO DO)
**Duration**: 3-4 hours

#### 3.1 Setup Flutter Project
```bash
flutter create --template=package mobile_808pay
```

#### 3.2 Pera Wallet Integration
**Functions**:
- Connect wallet
- Get user address
- Sign transactions
- Handle wallet events

#### 3.3 Payment Creation Screen
**UI Components (VibeKit)**:
- Amount input field
- Merchant selector
- Payment preview
- Confirm button

#### 3.4 QR Generation & Display
**Features**:
- Generate QR code with payment data
- Display with transaction details
- Share/screenshot options
- Tap to copy to clipboard

#### 3.5 QR Scanning
**Features**:
- Camera permission
- QR detection
- Payment verification
- Offline storage

#### 3.6 Transaction History
**Display**:
- Pending transactions
- Settled transactions
- Settlement status
- Transaction details

### Phase 4: Integration & Testing (TO DO)
**Duration**: 2-3 hours

#### 4.1 Connect Frontend to Backend
- API endpoint configuration
- Authentication (if needed)
- Error handling
- Loading states

#### 4.2 End-to-End Testing
- Create offline payment
- Verify signature
- Send to backend
- Settlement confirmation
- Blockchain verification

#### 4.3 Demo Scenario
1. User creates ₹50 payment offline
2. Signs with private key (Pera Wallet)
3. QR code displayed
4. Merchant scans QR
5. Backend receives & verifies
6. Smart contract validates
7. Payment splits:
   - Merchant: ₹45
   - Tax: ₹2.50
   - Loyalty: ₹2.50
8. Confirmation sent back

---

## Key Technologies Explained

### AlgoKit
**What it provides**:
- PyTeal smart contract framework
- Local testing environment (Algorand sandbox)
- Deployment tools
- Contract templates
- Testing utilities

**Why we use it**:
- Faster smart contract development
- Built-in testing
- Easy deployment
- Best practices scaffolding

### VibeKit
**What it provides**:
- Pre-built UI components
- Design system
- Accessibility features
- Theme management
- Animation library

**Components we'll use**:
- Buttons
- Input fields
- Cards
- Transaction lists
- QR display widget

### Pera Wallet
**What it provides**:
- Wallet connection
- Transaction signing
- Account management
- Multi-signature support
- Secure key storage

**Integration points**:
- Sign payment transactions
- Get user address
- Approve smart contract calls
- Manage account balance

### Boiler Template
**What it provides**:
- Project scaffold
- Build configuration
- Deployment setup
- CI/CD pipeline
- Testing framework

---

## API Endpoints (Backend - Already Implemented)

```
GET /health
- Health check
- Response: { status: "ok", timestamp: "..." }

POST /api/transactions/settle
- Settle a payment
- Body: { data: {...}, signature: "0x...", publicKey: "0x..." }
- Response: { success: true, transactionId: "...", splits: {...} }

GET /api/transactions/:id
- Get transaction status
- Response: { id: "...", status: "settled", ... }

GET /api/transactions
- List all transactions
- Response: { count: N, transactions: [...] }
```

---

## Smart Contract Specification (TO BUILD)

### Contract State
```python
# Global state
payment_processor_address: String  # Backend wallet
fee_rate: UInt64                  # Percentage
loyalty_token_id: UInt64          # ASA ID

# Local state (per account)
total_paid: UInt64                # Total amount paid
loyalty_balance: UInt64           # Loyalty points
```

### Contract Methods
```python
def verify_and_settle(
    transaction_data: bytes,      # Original transaction
    signature: bytes,             # Ed25519 signature
    public_key: bytes,           # User's public key
    amount: uint64,              # Payment amount
    merchant: String             # Merchant address
):
    # 1. Verify Ed25519 signature
    # 2. Validate amount
    # 3. Calculate splits
    # 4. Transfer funds
    # 5. Mint loyalty tokens
    # 6. Record settlement
```

---

## Environment Configuration

### .env file
```env
# Backend
PORT=3000
NODE_ENV=development

# Algorand
ALGORAND_SERVER=https://testnet-algorand.api.purestake.io/ps2
ALGORAND_TOKEN=your-api-token
ALGORAND_NETWORK=testnet

# Smart Contract
CONTRACT_APP_ID=your-app-id
PAYMENT_PROCESSOR_ADDRESS=your-wallet-address

# Pera Wallet
PERA_WALLET_CONNECT_ID=your-connect-id
```

---

## Deployment Checklist

### Pre-Launch
- [ ] Backend running without errors
- [ ] All API endpoints tested
- [ ] Smart contract deployed to testnet
- [ ] Contract app ID in .env
- [ ] Flutter app built for iOS/Android
- [ ] Pera Wallet integration tested
- [ ] Full E2E flow tested
- [ ] Error handling verified

### Hackathon Demo
- [ ] Backend server running
- [ ] Flutter app installed on device
- [ ] Pera Wallet configured
- [ ] Test transaction ready
- [ ] Presentation slides ready
- [ ] Demo script prepared

---

## Development Timeline (24-Hour Hackathon)

| Phase | Duration | Tasks |
|-------|----------|-------|
| Setup | 1 hour | Install AlgoKit, setup project structure |
| Smart Contract | 2.5 hours | Write PyTeal, test locally, deploy to testnet |
| Flutter Setup | 1 hour | Initialize Flutter, add dependencies, VibeKit setup |
| Pera Integration | 1 hour | Wallet connection, signing, testing |
| UI Development | 1.5 hours | Payment screen, QR generation, history |
| Integration | 1 hour | Connect frontend to backend |
| E2E Testing | 1 hour | Full flow testing, bug fixes |
| Polish & Demo | 1.5 hours | UI polish, demo preparation, presentation |
| **TOTAL** | **~10 hours** | *14 hours buffer for issues* |

---

## Dependencies to Install

### Backend (DONE ✅)
```json
{
  "dependencies": {
    "express": "^4.18.0",
    "tweetnacl": "^1.0.3",
    "algosdk": "^2.6.0",
    "cors": "^2.8.5",
    "dotenv": "^16.0.0"
  }
}
```

### Smart Contract (TO INSTALL)
```bash
pip install pyteal algokit algorand-python-sdk
```

### Flutter (TO INSTALL)
```yaml
dependencies:
  flutter:
    sdk: flutter
  vibekit: ^1.0.0
  pera_wallet_flutter: ^1.0.0
  qr_code_scanner: ^1.0.0
  qr_flutter: ^4.0.0
  http: ^1.0.0
  intl: ^0.19.0
```

---

## Key Decisions Made

1. ✅ **Backend**: Express.js (fast, lightweight)
2. ✅ **Crypto**: tweetnacl (Ed25519)
3. ✅ **Smart Contract Framework**: AlgoKit (scaffolding + testing)
4. ✅ **Language**: PyTeal (Python for contracts)
5. ✅ **Frontend Framework**: Flutter (cross-platform)
6. ✅ **UI Library**: VibeKit (pre-built components)
7. ✅ **Wallet**: Pera Wallet (standard Algorand wallet)
8. ✅ **Testing Network**: Algorand Testnet (free, fast)

---

## Next Steps

1. **Review this documentation**
2. **Confirm tech stack** (AlgoKit, VibeKit, Pera, Boiler)
3. **Start Phase 2**: Smart Contract development
4. **Proceed to Phase 3**: Flutter frontend
5. **Phase 4**: Integration testing

---

**Ready to proceed with implementation?**
