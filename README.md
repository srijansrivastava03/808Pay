# 808Pay — Offline Digital Payment System

> An offline-first digital payment system inspired by UPI, powered by the **Algorand** blockchain.

## Overview

808Pay enables users to send and receive crypto payments even without an internet connection — ideal for metro tunnels, rural areas, or network outages. When connectivity is restored, all queued transactions are automatically submitted to the Algorand blockchain.

### How It Works

```
Receiver                         Sender
  │                                │
  ├── Generates QR code            │
  │   (address + name)             │
  │                                ├── Scans QR code
  │                                ├── Enters amount + PIN
  │                                ├── Signs Algorand tx offline
  │                                │   (stored in local queue)
  │                                │
  │◄───── QR / NFC / Bluetooth ────┤  (optionally share intent)
  │                                │
  └── ─ ─ ─ ─ Internet restored ─ ─│
                                   ├── Auto-submits queued txns
                                   └── Confirmed on Algorand blockchain
```

### Key Features

| Feature | Description |
|---|---|
| **Offline payments** | Create & sign transactions without internet |
| **QR code receiver** | Instant QR code generation for payment addresses |
| **QR code scanner** | Camera-based QR scanning on the sender side |
| **Digital signatures** | Every payment intent is cryptographically signed using Algorand's Ed25519 keys |
| **Encrypted wallet** | Mnemonic encrypted with AES-256-GCM (PIN-derived PBKDF2 key) |
| **Auto-sync** | Queued payments submitted automatically when back online |
| **Algorand blockchain** | Fast, secure, and low-cost settlement |
| **Payment history** | Full local history with status tracking |

---

## Project Structure

```
808Pay/
├── backend/          # Node.js + Express API for Algorand
│   ├── src/
│   │   ├── index.ts              # Express server entry point
│   │   ├── routes/
│   │   │   └── transactions.ts   # API routes
│   │   └── services/
│   │       ├── algorand.ts       # Algorand client
│   │       └── utils.ts          # Shared crypto utilities
│   ├── package.json
│   └── tsconfig.json
│
└── frontend/         # React + TypeScript PWA
    └── src/
        ├── App.tsx
        ├── pages/
        │   └── Dashboard.tsx     # Main dashboard
        ├── components/
        │   ├── SetupWallet.tsx   # Wallet creation/restore
        │   ├── QRGenerator.tsx   # Receiver QR code
        │   ├── QRScanner.tsx     # Camera QR scanner
        │   ├── PaymentForm.tsx   # Send payment form
        │   └── PaymentQueue.tsx  # History & sync
        ├── services/
        │   ├── algorand.ts       # Offline tx building
        │   ├── wallet.ts         # Encrypted wallet storage
        │   ├── offlineQueue.ts   # Local payment queue
        │   └── api.ts            # Backend API client
        └── hooks/
            └── useAutoSync.ts    # Auto-sync hook
```

---

## Setup

### Prerequisites

- Node.js ≥ 18
- npm ≥ 9

### 1. Backend

```bash
cd backend
cp .env.example .env    # configure Algorand node URL if needed
npm install
npm run build
npm start               # runs on port 3001
```

**Available API endpoints:**

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/health` | Node connectivity check |
| `GET` | `/api/params` | Fetch tx params for offline signing |
| `POST` | `/api/submit` | Submit a single signed transaction |
| `POST` | `/api/submit-batch` | Submit multiple signed transactions |
| `GET` | `/api/account/:address` | Get account balance |
| `GET` | `/api/transaction/:txId` | Get transaction status |

### 2. Frontend

```bash
cd frontend
REACT_APP_API_URL=http://localhost:3001/api npm start
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

---

## Usage

### First Launch — Wallet Setup

1. Click **Create New Wallet** to generate a fresh Algorand account
2. **Back up your 25-word mnemonic** — this is the only recovery method
3. Set a PIN (≥ 4 digits) to protect your wallet

Or **Restore Existing Wallet** with your mnemonic.

### Receiving Payments

1. Go to the **📥 Receive** tab
2. Share the displayed QR code with the sender

### Sending Payments (Online or Offline)

1. Go to the **📤 Send** tab
2. Click **Scan QR Code** and point your camera at the receiver's QR
3. Enter the amount (in ALGO) and your PIN
4. Click **Pay Now**
   - **If online**: Transaction is signed and submitted immediately
   - **If offline**: Transaction is signed and stored in the local queue — it will be submitted automatically when connectivity returns

### Payment History & Manual Sync

- Go to the **📋 History** tab to see all payments
- Click **⬆ Sync Now** to manually submit pending payments

---

## Security

- **Private keys never leave the device unencrypted** — the mnemonic is encrypted with AES-256-GCM using a PBKDF2-derived key from your PIN (200,000 iterations, SHA-256)
- **All transactions are signed offline** using Algorand's Ed25519 digital signatures before being stored or transmitted
- **No server ever sees your private key** — only the signed transaction bytes are sent to the backend for submission
- **Tamper-proof** — signed transactions cannot be modified; any alteration invalidates the signature

---

## Development

### Running Tests

```bash
# Backend unit tests
cd backend && npm test

# Frontend tests
cd frontend && npm test
```

### Environment Variables

| Variable | Default | Description |
|---|---|---|
| `PORT` | `3001` | Backend server port |
| `ALGORAND_NODE_URL` | `https://testnet-api.algonode.cloud` | Algorand node URL |
| `ALGORAND_INDEXER_URL` | `https://testnet-idx.algonode.cloud` | Algorand indexer URL |
| `REACT_APP_API_URL` | `http://localhost:3001/api` | Backend API URL |

---

## Algorand TestNet

By default, 808Pay connects to the **Algorand TestNet**. To get test ALGO for development, visit the [TestNet Dispenser](https://dispenser.testnet.aws.algodev.network/).

For production, update `ALGORAND_NODE_URL` and `ALGORAND_INDEXER_URL` to MainNet endpoints.

---

## License

MIT
