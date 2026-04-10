/**
 * Atomic Settlement Smart Contract Integration
 * 
 * POST /api/transactions/atomic-settle-sc
 * 
 * Submits dual-signature settlement to smart contract
 */

import { Router, Request, Response } from "express";
import {
  submitAtomicSettlement,
  verifySignature,
  getContractInfo,
  verifySettlementOnChain,
} from "../services/smartContract";
import { taxCalculationService } from "../src/services/taxCalculationService";

const router = Router();

interface AtomicSettleRequest {
  dealId: string;
  buyerAddress: string;
  buyerPublicKey: string; // base64
  buyerSignature: string; // base64
  sellerAddress: string;
  sellerPublicKey: string; // base64
  sellerSignature: string; // base64
  amount: number;
  category: string;
  settlingPartyAddress: string;
}

/**
 * POST /api/transactions/atomic-settle-sc
 * 
 * Submit atomic settlement with dual signatures to smart contract
 * 
 * Request:
 * {
 *   dealId: "DEAL_123",
 *   buyerAddress: "BUYERXXXXXXXXXX",
 *   buyerPublicKey: "base64_encoded_pubkey",
 *   buyerSignature: "base64_encoded_signature",
 *   sellerAddress: "SELLERXXXXXXXXX",
 *   sellerPublicKey: "base64_encoded_pubkey",
 *   sellerSignature: "base64_encoded_signature",
 *   amount: 50000,
 *   category: "electronics",
 *   settlingPartyAddress: "address_submitting_txn"
 * }
 * 
 * Response:
 * {
 *   success: true,
 *   contractAppId: 12345,
 *   transactionId: "TXID...",
 *   blockNumber: 45123,
 *   settleId: "SETTLE_...",
 *   timestamp: 1234567890,
 *   breakdown: {
 *     total: 50000,
 *     merchant: 40179,
 *     tax: 5357,
 *     loyalty: 4464
 *   }
 * }
 */
router.post("/atomic-settle-sc", async (req: Request, res: Response) => {
  try {
    const payload = req.body as AtomicSettleRequest;

    console.log("[AtomicSettlementSC] Received request");
    console.log(`  • Deal ID: ${payload.dealId}`);
    console.log(`  • Amount: ${payload.amount}`);
    console.log(`  • Category: ${payload.category}`);

    // ========== Validation ==========
    if (!payload.dealId || !payload.amount || !payload.category) {
      return res.status(400).json({
        error: "Missing required fields: dealId, amount, category",
      });
    }

    if (!payload.buyerAddress || !payload.sellerAddress) {
      return res.status(400).json({
        error: "Missing required fields: buyerAddress, sellerAddress",
      });
    }

    if (!payload.buyerSignature || !payload.sellerSignature) {
      return res.status(400).json({
        error: "Missing signatures from both parties",
      });
    }

    // ========== Decode Base64 Signatures ==========
    let buyerSig: Buffer, buyerPubKey: Buffer;
    let sellerSig: Buffer, sellerPubKey: Buffer;

    try {
      buyerSig = Buffer.from(payload.buyerSignature, "base64");
      buyerPubKey = Buffer.from(payload.buyerPublicKey, "base64");
      sellerSig = Buffer.from(payload.sellerSignature, "base64");
      sellerPubKey = Buffer.from(payload.sellerPublicKey, "base64");
    } catch (error) {
      return res.status(400).json({
        error: "Invalid base64 encoding for signatures or public keys",
      });
    }

    // ========== Signature Verification ==========
    console.log("[AtomicSettlementSC] Verifying signatures...");

    // Create transaction hash for verification
    const txnHash = Buffer.from(
      JSON.stringify({
        dealId: payload.dealId,
        buyerAddress: payload.buyerAddress,
        sellerAddress: payload.sellerAddress,
        amount: payload.amount,
        category: payload.category,
      })
    );

    // Verify buyer signature
    if (!verifySignature(txnHash, buyerSig, buyerPubKey)) {
      console.warn("[AtomicSettlementSC] Buyer signature verification failed");
      return res.status(400).json({
        error: "Buyer signature verification failed",
      });
    }

    console.log("  ✓ Buyer signature verified");

    // Verify seller signature
    if (!verifySignature(txnHash, sellerSig, sellerPubKey)) {
      console.warn("[AtomicSettlementSC] Seller signature verification failed");
      return res.status(400).json({
        error: "Seller signature verification failed",
      });
    }

    console.log("  ✓ Seller signature verified");

    // ========== Tax Calculation ==========
    console.log("[AtomicSettlementSC] Calculating tax breakdown...");

    const breakdown = taxCalculationService.calculateTaxBreakdown(
      payload.amount,
      payload.category
    );

    console.log(`  • Merchant: ${breakdown.merchantAmount}`);
    console.log(`  • Tax: ${breakdown.taxAmount}`);
    console.log(`  • Loyalty: ${breakdown.loyaltyAmount}`);

    // ========== Smart Contract Submission ==========
    console.log("[AtomicSettlementSC] Submitting to smart contract...");

    const settlementResult = await submitAtomicSettlement({
      dealId: payload.dealId,
      buyerAddress: payload.buyerAddress,
      sellerAddress: payload.sellerAddress,
      buyerSignature: buyerSig,
      buyerPublicKey: buyerPubKey,
      sellerSignature: sellerSig,
      sellerPublicKey: sellerPubKey,
      amount: payload.amount,
      category: payload.category,
      settlingPartyAddress: payload.settlingPartyAddress,
    });

    if (!settlementResult.success) {
      console.error(
        "[AtomicSettlementSC] Smart contract submission failed:",
        settlementResult.error
      );
      return res.status(500).json({
        error: "Smart contract submission failed",
        details: settlementResult.error,
      });
    }

    // ========== Verify On-Chain ==========
    console.log("[AtomicSettlementSC] Verifying on-chain...");

    const isVerified = await verifySettlementOnChain(
      settlementResult.transactionId
    );

    if (!isVerified) {
      console.warn("[AtomicSettlementSC] On-chain verification pending...");
      // Don't fail - transaction may still be confirming
    } else {
      console.log("  ✓ Settlement verified on-chain");
    }

    // ========== Success Response ==========
    console.log("[AtomicSettlementSC] Settlement successful!");

    return res.status(200).json({
      success: true,
      transactionId: settlementResult.transactionId,
      contractAppId: settlementResult.contractAppId,
      blockNumber: settlementResult.blockNumber,
      settleId: settlementResult.settleId,
      timestamp: settlementResult.timestamp,
      breakdown: {
        total: breakdown.totalAmount,
        merchant: breakdown.merchantAmount,
        tax: breakdown.taxAmount,
        loyalty: breakdown.loyaltyAmount,
      },
      verifiedOnChain: isVerified,
    });
  } catch (error) {
    console.error("[AtomicSettlementSC] Error:", error);
    return res.status(500).json({
      error: "Internal server error",
      message: error instanceof Error ? error.message : "Unknown error",
    });
  }
});

/**
 * GET /api/transactions/contract-info
 * 
 * Get smart contract statistics
 */
router.get("/contract-info", async (req: Request, res: Response) => {
  try {
    const info = await getContractInfo();

    return res.status(200).json({
      success: true,
      ...info,
    });
  } catch (error) {
    console.error("[SmartContract] Failed to get contract info:", error);
    return res.status(500).json({
      error: "Failed to retrieve contract info",
      message: error instanceof Error ? error.message : "Unknown error",
    });
  }
});

export default router;
