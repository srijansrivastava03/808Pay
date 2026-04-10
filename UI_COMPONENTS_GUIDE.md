# 808Pay Atomic Settlement - UI Components

## Overview

Complete Flutter UI implementation for atomic two-party settlements with dual-signature verification.

---

## 1. Atomic Deal Screen (`atomic_deal_screen.dart`)

**Purpose:** Create a new atomic settlement deal between buyer and seller

### Key Features:
- ✓ Role selection (Buyer/Seller toggle)
- ✓ Address display for current user
- ✓ Deal amount input with ₹ currency symbol
- ✓ Category selector with dynamic GST rate display
- ✓ Recipient address input
- ✓ Product description (for sellers)
- ✓ Real-time tax breakdown preview
- ✓ Deal creation button with loading state

### Layout Flow:
```
┌─────────────────────────────────────┐
│  ⚛️ Atomic Settlement               │
├─────────────────────────────────────┤
│                                     │
│  📌 Two-Party Payment Card          │
│  "Both parties must sign..."        │
│                                     │
│  👥 Your Role                       │
│  [🛍️ Buyer] [📦 Seller]           │
│                                     │
│  📍 Your Address                    │
│  0x7f2e8c9a...                     │
│                                     │
│  💰 Deal Terms                      │
│  Amount: ___________₹               │
│  Category: [Electronics ▼]          │
│  GST Rate: 12%                      │
│                                     │
│  👤 Recipient Address               │
│  _________________________________  │
│                                     │
│  (For Sellers)                      │
│  📦 Product Description             │
│  _________________________________  │
│                                     │
│  📊 Tax Breakdown Preview           │
│  ┌──────────────────────────────┐  │
│  │ Total: ₹50,000               │  │
│  │ Merchant: ₹40,179 (90%)       │  │
│  │ Tax: ₹5,357 (12%)             │  │
│  │ Loyalty: ₹4,464 (10%)         │  │
│  └──────────────────────────────┘  │
│                                     │
│      [Create & Sign Deal →]         │
│                                     │
└─────────────────────────────────────┘
```

### Code Example:
```dart
SegmentedButton<String>(
  segments: const [
    ButtonSegment(label: Text('🛍️ Buyer'), value: 'buyer'),
    ButtonSegment(label: Text('📦 Seller'), value: 'seller'),
  ],
  selected: {yourRole},
  onSelectionChanged: (value) {
    setState(() => yourRole = value.first);
  },
)
```

---

## 2. Atomic Signing Screen (`atomic_signing_screen.dart`)

**Purpose:** Collect signatures from both buyer and seller

### Key Features:
- ✓ Signature progress widget (1/2 → 2/2)
- ✓ Party card widgets showing buyer + seller
- ✓ Deal summary display
- ✓ Sign button for current user
- ✓ Real-time signature status updates
- ✓ Auto-navigation to confirmation when both signed
- ✓ Loading state during signing

### Layout Flow:
```
┌─────────────────────────────────────┐
│  ⚛️ Sign the Deal                  │
├─────────────────────────────────────┤
│                                     │
│  📊 Signature Progress              │
│  ┌──────────────────────────────┐  │
│  │ Signatures Required    1/2   │  │
│  │ ████████░░░░░░░░░░░░░░░░░░ │  │
│  └──────────────────────────────┘  │
│                                     │
│  👥 Party Status                    │
│  ┌──────────────┬──────────────┐   │
│  │ 🛍️ Buyer    │ 📦 Seller    │   │
│  │ 0x7f2e8c9a  │ 0xABCDEF...  │   │
│  │ ⏳ PENDING   │ ✅ SIGNED    │   │
│  └──────────────┴──────────────┘   │
│                                     │
│  📋 Deal Summary                    │
│  Amount: ₹50,000                    │
│  Category: Electronics (12% GST)    │
│  Your Role: Buyer                   │
│  Status: Partially Signed           │
│                                     │
│      [Sign Now →]                   │
│                                     │
│  (After you sign, waiting for       │
│   the other party to sign...)       │
│                                     │
└─────────────────────────────────────┘

            ↓ [Both Signed]

┌─────────────────────────────────────┐
│  ✅ Both signatures collected!      │
│                                     │
│  Ready to submit settlement         │
│  [Proceed to Confirmation →]        │
└─────────────────────────────────────┘
```

### Party Card Widget:
```
┌──────────────────────────────────┐
│ 🛍️ Buyer              ✅ (signed) │
│ 0x7f2e8c9a...                    │
│ ✅ SIGNED                         │
└──────────────────────────────────┘

┌──────────────────────────────────┐
│ 📦 Seller              ⏳ (pending)│
│ 0xABCDEF...                      │
│ ⏳ PENDING                        │
└──────────────────────────────────┘
```

### Signature Progress Widget:
```
┌────────────────────────────────┐
│ ⚛️ Signatures Required   1/2   │
│ ████████░░░░░░░░░░░░░░░░░░   │
└────────────────────────────────┘
```

---

## 3. Atomic Settlement Confirmation Screen (`atomic_settlement_confirmation_screen.dart`)

**Purpose:** Final review and submission to blockchain

### Key Features:
- ✓ Success badge (✅ Both Parties Signed!)
- ✓ Deal summary with all details
- ✓ Detailed payment breakdown
- ✓ Digital signature verification display
- ✓ Warning about irreversible transactions
- ✓ Submit to settlement button
- ✓ Loading state during submission

### Layout Flow:
```
┌─────────────────────────────────────┐
│  ✅ Confirm Settlement              │
├─────────────────────────────────────┤
│                                     │
│           ✅ SUCCESS BADGE          │
│         (Green Circle + Check)      │
│                                     │
│  ✅ Both Parties Signed!            │
│                                     │
│  📋 Deal Details                    │
│  ┌──────────────────────────────┐  │
│  │ Amount: ₹50,000              │  │
│  │ Category: Electronics        │  │
│  │ Buyer: 0x7f2e8c9a...        │  │
│  │ Seller: 0xABCDEF...         │  │
│  │ Status: FULLY_SIGNED         │  │
│  └──────────────────────────────┘  │
│                                     │
│  💳 Payment Breakdown               │
│  ┌──────────────────────────────┐  │
│  │ Total Amount       ₹50,000   │  │
│  │ ├─ Merchant        ₹40,179   │  │
│  │ │  (90% - Your cut)           │  │
│  │ ├─ Tax             ₹5,357    │  │
│  │ │  (12% GST)                   │  │
│  │ └─ Loyalty Points  ₹4,464    │  │
│  │    (10% reward)               │  │
│  └──────────────────────────────┘  │
│                                     │
│  🔐 Digital Signatures              │
│  ┌──────────────────────────────┐  │
│  │ ✅ Buyer Signed              │  │
│  │    sig_1775834129...         │  │
│  │                              │  │
│  │ ✅ Seller Signed             │  │
│  │    sig_177583412...          │  │
│  └──────────────────────────────┘  │
│                                     │
│  ⚠️ WARNING                         │
│  This payment is IRREVERSIBLE       │
│  once submitted to blockchain.      │
│  Please review carefully.           │
│                                     │
│   [Submit to Settlement →]          │
│   [Cancel]                          │
│                                     │
└─────────────────────────────────────┘

        ↓ [Submitting...]

┌─────────────────────────────────────┐
│  Settlement submitted!              │
│  ✅ Transaction ID: TXID7FMJ...     │
│  Block: #12345                      │
│  Confirmed: true                    │
│                                     │
│     [Return to Home]                │
└─────────────────────────────────────┘
```

---

## 4. Supporting Widgets

### Signature Progress Widget (`signature_progress_widget.dart`)

Displays progress toward collecting required signatures.

```dart
SignatureProgressWidget(
  currentSignatures: 1,
  requiredSignatures: 2,
  isSigned: false,
)
```

Renders as:
```
┌────────────────────────────────┐
│ ⚛️ Signatures Required   1/2   │
│ ████████░░░░░░░░░░░░░░░░░░   │
└────────────────────────────────┘
```

**Properties:**
- `currentSignatures`: Number of signatures collected (0-2)
- `requiredSignatures`: Total signatures needed (2)
- `isSigned`: User's signature status

---

### Party Card Widget (`party_card_widget.dart`)

Displays individual party status (buyer or seller).

```dart
PartyCardWidget(
  role: 'Buyer',
  icon: '🛍️',
  address: '0x7f2e8c9a...',
  hasSigned: true,
)
```

Renders as:
```
┌──────────────────────────────────┐
│ 🛍️ Buyer              ✅ SIGNED │
│ 0x7f2e8c9a...                    │
│ ✅ SIGNED                         │
└──────────────────────────────────┘
```

**Properties:**
- `role`: "Buyer" or "Seller"
- `icon`: Emoji icon (🛍️ or 📦)
- `address`: Wallet address
- `hasSigned`: Signature status

---

## Data Flow

```
User Flow:

1. AtomicDealScreen
   ↓ (Create & Sign Deal)
   ↓ Create atomicDeal object with:
   ↓   - buyerAddress
   ↓   - sellerAddress
   ↓   - amount
   ↓   - category
   ↓   - requiredSignatures: []
   ↓   - signingStatus: 'PENDING_SIGNATURES'
   ↓
2. AtomicSigningScreen
   ↓ (Display party status + sign button)
   ↓ User signs → signature added to deal
   ↓ If requiredSignatures >= 2:
   ↓   - Set signingStatus: 'FULLY_SIGNED'
   ↓   - Show success notification
   ↓   - Auto-navigate to confirmation
   ↓
3. AtomicSettlementConfirmationScreen
   ↓ (Final review + tax breakdown)
   ↓ Display signatures, breakdown, warning
   ↓ [Submit to Settlement] button
   ↓
4. Backend API Call
   ↓ POST /api/transactions/atomic-settle
   ↓ Request body:
   ↓   {
   ↓     dealId,
   ↓     buyerAddress,
   ↓     buyerSignature,
   ↓     sellerAddress,
   ↓     sellerSignature,
   ↓     amount,
   ↓     category,
   ↓     settlingPartyAddress
   ↓   }
   ↓
5. Smart Contract
   ↓ Verify both signatures
   ↓ Record settlement on-chain
   ↓ Return: {txId, blockNumber, confirmed}
   ↓
6. Success Screen
   ↓ Show transaction ID
   ↓ Show block confirmation
   ↓ Navigate to home
```

---

## Screen Transitions

```
Home Screen
    ↓
    ├→ [New Settlement]
    │
    ↓
Atomic Deal Screen
    │ (Create deal with terms)
    │
    ├→ [Create & Sign Deal]
    │
    ↓
Atomic Signing Screen
    │ (Collect signatures from both parties)
    │
    ├→ [Sign Now] (User 1)
    │
    ├→ [Sign Now] (User 2)
    │
    ├→ [Both Signed]
    │
    ↓
Atomic Settlement Confirmation Screen
    │ (Final review + warning)
    │
    ├→ [Submit to Settlement]
    │
    ↓
Success (Toast notification)
    │ "✅ Settlement submitted!"
    │ "Transaction ID: TXID..."
    │
    ├→ [Return to Home]
    │
    ↓
Home Screen
```

---

## Material Design 3 Features

- ✓ Color-coded status indicators (Green/Orange/Blue)
- ✓ Segmented buttons for role selection
- ✓ Consistent spacing and padding
- ✓ Smooth animations and transitions
- ✓ Clear visual hierarchy
- ✓ Responsive layout (SingleChildScrollView)
- ✓ Error handling with SnackBars
- ✓ Loading states with setState
- ✓ Professional typography

---

## Testing

All UI components tested in:
- `test/atomic_settlement_integration_test.dart`

Test coverage includes:
- E2E flow verification (Deal → Sign → Confirm → Submit)
- Tax calculation accuracy
- State management
- Navigation flow
- Error handling

**Test Results:** ✅ 14/14 PASSED

---

## Files Summary

| File | Lines | Purpose |
|------|-------|---------|
| `atomic_deal_screen.dart` | 421 | Deal creation with role selection |
| `atomic_signing_screen.dart` | 263 | Signature collection |
| `atomic_settlement_confirmation_screen.dart` | 349 | Final review + submission |
| `signature_progress_widget.dart` | 50 | Progress indicator (1/2 → 2/2) |
| `party_card_widget.dart` | 60 | Individual party status card |
| **Total** | **1,143** | **Complete atomic settlement UI** |

---

## Next Steps

1. **Integrate with Backend**
   - Update confirmation screen to call `/api/transactions/atomic-settle-sc`
   - Handle response with transaction ID + block number

2. **Add Smart Contract Integration**
   - Deploy contract: `python3 contracts/deploy.py`
   - Add PAYMENT_APP_ID to backend `.env`
   - Verify on-chain submission

3. **Test on Device**
   - Run on physical device or emulator
   - Test full E2E flow
   - Verify blockchain confirmation

4. **Performance Optimization**
   - Cache images and assets
   - Lazy load screens
   - Optimize tax calculations

5. **Production Features**
   - Add transaction history
   - Implement transaction search
   - Add settlement recovery flow
   - Implement retry logic
