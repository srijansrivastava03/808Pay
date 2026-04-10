# 808Pay - Team Guide

## 4-Person Hackathon Team Structure

Welcome to the 808Pay team! This is your roadmap for the 24-hour hackathon.

---

## Team Members & Roles

| Member | Role | Key Tasks | Guide |
|--------|------|-----------|-------|
| Member 1 | Smart Contract Dev | Deploy contract, test locally, deploy to testnet | [SMART_CONTRACT_GUIDE.md](./SMART_CONTRACT_GUIDE.md) |
| Member 2 | Backend Integration | Connect backend to contract, implement settlement | [BACKEND_INTEGRATION_GUIDE.md](./BACKEND_INTEGRATION_GUIDE.md) |
| Member 3 | Frontend Lead | Create Flutter app, UI screens, API integration | [FRONTEND_SETUP.md](./FRONTEND_SETUP.md) |
| Member 4 | Mobile + Wallet | Pera Wallet, QR code, transaction signing | [WALLET_INTEGRATION_GUIDE.md](./WALLET_INTEGRATION_GUIDE.md) |

---

## Quick Start Checklist

### Before You Start
- [ ] All team members have GitHub access
- [ ] Docker installed and running
- [ ] Local Algorand sandbox started (`algokit localnet status` shows "Running")
- [ ] Backend running (`npm run dev`)
- [ ] All guides read

### For Smart Contract Dev
- [ ] Contract compiling successfully
- [ ] Test on local sandbox
- [ ] Deploy to testnet
- [ ] Get App ID and processor address

### For Backend Dev
- [ ] Waiting for App ID from SC dev
- [ ] Create contract service module
- [ ] Update settlement service
- [ ] Test contract calls

### For Frontend Lead
- [ ] Flutter project initialized
- [ ] Pubspec.yaml updated
- [ ] Basic screens created
- [ ] Connect to backend API

### For Wallet + Mobile Dev
- [ ] Pera Wallet app installed on simulator
- [ ] QR packages added
- [ ] Wallet connection tested
- [ ] QR generation working

---

## Critical Dependencies & Blocking Points

```
┌─────────────────────────────┐
│  Smart Contract Deploy      │ ← BLOCKER for Backend
│  (Hours 0-2)                │
└──────────────┬──────────────┘
               │ (Provides App ID)
         ┌─────▼──────────────┐
         │ Backend Integration│ ← BLOCKER for Frontend
         │ (Hours 2-3)        │
         └──────┬─────────────┘
                │ (API Ready)
         ┌──────▼──────────────┐
         │ Frontend + Wallet   │
         │ (Hours 3-6)         │
         └─────────────────────┘
```

**Key Points:**
1. Start SC deployment FIRST (critical path)
2. Backend waits for contract App ID
3. Frontend can start in parallel but needs backend running
4. Integration testing happens after all parts ready

---

## Daily Timeline (24-Hour Hackathon)

### Hours 0-2: Setup & SC Deployment
- **SC Dev**: Deploy contract to testnet, get App ID
- **Backend Dev**: Prepare contract service skeleton
- **Frontend Dev**: Initialize Flutter project
- **Wallet Dev**: Test Pera Wallet connection

### Hours 2-4: Backend Integration
- **SC Dev**: Debug any contract issues, help backend test
- **Backend Dev**: Integrate contract calls, test settlement
- **Frontend Dev**: Build payment screen, API integration
- **Wallet Dev**: Implement Pera wallet signing

### Hours 4-6: Frontend Development
- **SC Dev**: Optimize contract, prepare for demo
- **Backend Dev**: Finish integration, full testing
- **Frontend Dev**: Build QR display, history screens
- **Wallet Dev**: QR scanning, error handling

### Hours 6-10: Integration & Testing
- **All**: Connect all pieces together
- End-to-end testing
- Bug fixes
- Demo preparation

### Hours 10-12: Polish & Demo
- **All**: Final testing
- Demo scenario walkthrough
- Presentation preparation
- Submit!

---

## File Structure

```
808Pay/
├── README.md                        # This file
├── SMART_CONTRACT_GUIDE.md         # For Member 1
├── BACKEND_INTEGRATION_GUIDE.md    # For Member 2
├── FRONTEND_SETUP.md               # For Member 3
├── WALLET_INTEGRATION_GUIDE.md     # For Member 4
├── 808Pay_Documentation.txt        # Full project docs
│
├── src/                             # Backend (Express.js) ✅
│   ├── index.ts
│   ├── services/
│   ├── routes/
│   └── types/
│
├── contracts/                       # Smart Contracts 🔄
│   ├── payment_settlement/
│   │   └── contract.py
│   └── requirements.txt
│
├── mobile/                          # Flutter Frontend ⏳
│   ├── lib/
│   ├── android/
│   ├── ios/
│   └── pubspec.yaml
│
├── package.json                     # Backend deps
├── algokit.yaml                     # AlgoKit config
├── docker-compose.yml               # Docker setup
├── Dockerfile.backend               # Backend container
├── Dockerfile.algokit              # AlgoKit container
├── nginx.conf                       # Reverse proxy
└── .env                             # Environment vars
```

---

## Communication & Coordination

### Daily Sync-Up (Every 3 Hours)
- **10 min standup**: What's done, what's next, blockers
- **Share progress**: Update .env with new info
- **Unblock issues**: Help teammates

### Critical Info to Share
1. **SC Dev → Backend Dev**: Contract App ID, processor address, method signatures
2. **Backend Dev → Frontend Dev**: API endpoint examples, error handling
3. **Wallet Dev → Frontend Dev**: QR format, signing expectations
4. **All → Team Lead**: Blockers, timeline concerns, help needed

### Slack/Discord Channels (Suggested)
- #general - announcements
- #backend - backend issues
- #contract - smart contract discussion
- #frontend - Flutter & UI
- #blockers - critical issues
- #demo - demo preparation

---

## Running Everything Locally

### Start Backend
```bash
cd /Users/srijan/808Pay
npm run dev
# Backend running on http://localhost:3000
```

### Start Local Sandbox
```bash
algokit localnet start
# Sandbox running on http://localhost:4001
# Check status: algokit localnet status
```

### Start Flutter
```bash
cd /Users/srijan/808Pay/mobile
flutter run
# iOS Simulator or Android Emulator
```

### Check All Services
```bash
# Backend
curl http://localhost:3000/health

# Sandbox
curl http://localhost:4001/v2/status

# Mobile
flutter devices
```

---

## Emergency Troubleshooting

### Backend Won't Start
```bash
# Kill process on port 3000
lsof -ti:3000 | xargs kill -9
npm run dev
```

### Sandbox Won't Start
```bash
# Reset sandbox
algokit localnet reset

# Start fresh
algokit localnet start
```

### Flutter Build Issues
```bash
flutter clean
flutter pub get
flutter run
```

### Git Issues
```bash
# Pull latest
git pull

# Discard local changes
git checkout -- .

# Reset to remote
git reset --hard origin/main
```

---

## Success Criteria for Demo

- [ ] User can connect Pera Wallet
- [ ] User can create payment (enter amount)
- [ ] User can see QR code
- [ ] Merchant can scan QR
- [ ] User can sign payment with Pera
- [ ] Backend receives & verifies signature
- [ ] Smart contract settles payment on-chain
- [ ] Frontend shows confirmation
- [ ] Splits are correct (90% merchant, 5% tax, 5% loyalty)
- [ ] Transaction appears in history
- [ ] Can repeat with multiple payments

---

## Presentation Structure (2 minutes)

1. **Problem** (15 sec): Offline payments are hard
2. **Solution** (15 sec): 808Pay - offline payment engine
3. **Tech** (15 sec): Algorand, smart contracts, Flutter
4. **Demo** (45 sec): Show live payment flow
5. **Impact** (15 sec): Scalable, secure, decentralized

---

## Key Resources

- **Algorand Docs**: https://docs.algorand.org/
- **PyTeal**: https://pyteal.readthedocs.io/
- **Flutter**: https://flutter.dev/docs
- **Pera Wallet**: https://www.perawallet.app/
- **AlgoKit**: https://github.com/algorandfoundation/algokit-cli

---

## Important Notes

### ✅ DO
- Communicate blockers immediately
- Review each other's code
- Test frequently
- Keep code clean
- Document changes
- Help teammates

### ❌ DON'T
- Modify others' code without asking
- Skip testing
- Leave unfinished work for others
- Work in silos
- Commit without testing
- Use mainnet (always testnet!)

---

## Final Checklist (Before Demo)

### Code Quality
- [ ] No console.errors
- [ ] All imports resolved
- [ ] TypeScript strict mode passing
- [ ] No hardcoded values (use .env)
- [ ] Error handling implemented

### Functionality
- [ ] Wallet connects
- [ ] QR generates and scans
- [ ] Payments sign and settle
- [ ] Contract called successfully
- [ ] Splits calculated correctly
- [ ] Transaction history shows

### Demo Flow
- [ ] Start fresh (no cached data)
- [ ] Test on real device/simulator
- [ ] Network connectivity tested
- [ ] Pera Wallet funded with test ALGO
- [ ] Backup demo video recorded

---

## Questions?

- **Technical**: Ask team lead or relevant person
- **Architecture**: Check documentation
- **Blockers**: Escalate immediately
- **Scope**: Ask project owner

---

**Let's build something amazing! 🚀**

Good luck team! Remember:
- **Start early**
- **Communicate constantly**
- **Test everything**
- **Help each other**
- **Have fun!**
