/**
 * 808Pay Smart Contract Integration
 * 
 * Handles:
 * - App ID management
 * - Atomic settlement contract calls
 * - Settlement recording on Algorand
 */

import { Algodv2, AtomicTransactionComposer } from "algosdk";
import { getAlgodClient } from "../utils/algorand";
import crypto from "crypto";

export interface AtomicSettlementPayload {
  dealId: string;
  buyerAddress: string;
  sellerAddress: string;
  buyerSignature: Buffer;
  buyerPublicKey: Buffer;
  sellerSignature: Buffer;
  sellerPublicKey: Buffer;
  amount: number;
  category: string;
  settlingPartyAddress: string;
}

export interface SettlementResult {
  success: boolean;
  contractAppId: number;
  transactionId: string;
  blockNumber: number;
  settleId: string;
  timestamp: number;
  error?: string;
}

/**
 * Get the deployed smart contract App ID
 */
export function getPaymentAppId(): number {
  const appId = parseInt(process.env.PAYMENT_APP_ID || "0", 10);
  if (appId === 0) {
    throw new Error(
      "PAYMENT_APP_ID not set. Run: python3 contracts/deploy.py"
    );
  }
  return appId;
}

/**
 * Verify Ed25519 signature (client-side)
 * 
 * @param message - The message that was signed
 * @param signature - The Ed25519 signature
 * @param publicKey - The public key (32 bytes)
 * @returns true if signature is valid
 */
export function verifySignature(
  message: Buffer,
  signature: Buffer,
  publicKey: Buffer
): boolean {
  try {
    // Create public key object
    const keyObject = crypto.createPublicKey({
      key: publicKey,
      format: "raw",
      type: "ed25519",
    });

    // Verify signature
    return crypto.verify("ed25519", message, keyObject, signature);
  } catch (error) {
    console.error("Signature verification failed:", error);
    return false;
  }
}

/**
 * Submit atomic settlement to smart contract
 * 
 * @param payload - Settlement transaction details
 * @returns Settlement result with blockchain confirmation
 */
export async function submitAtomicSettlement(
  payload: AtomicSettlementPayload
): Promise<SettlementResult> {
  try {
    const client = getAlgodClient();
    const appId = getPaymentAppId();

    // Generate settlement ID
    const settleId = `SETTLE_${Date.now()}_${Math.random().toString(36).substring(7)}`;

    // Prepare transaction hash for verification
    const txnHash = crypto
      .createHash("sha256")
      .update(
        JSON.stringify({
          dealId: payload.dealId,
          buyerAddress: payload.buyerAddress,
          sellerAddress: payload.sellerAddress,
          amount: payload.amount,
          category: payload.category,
          timestamp: Date.now(),
        })
      )
      .digest();

    console.log("[SmartContract] Settlement details:");
    console.log(`  • Settlement ID: ${settleId}`);
    console.log(`  • Contract App ID: ${appId}`);
    console.log(`  • Amount: ${payload.amount} microALGO`);
    console.log(`  • Category: ${payload.category}`);
    console.log(`  • Buyer: ${payload.buyerAddress.substring(0, 10)}...`);
    console.log(`  • Seller: ${payload.sellerAddress.substring(0, 10)}...`);

    // Get suggested params
    const params = await client.getTransactionParams().do();

    // Build atomic transaction composer
    const atc = new AtomicTransactionComposer();

    // Add app call transaction for settle-atomic
    atc.addMethodCall({
      appID: appId,
      method: {
        name: "settle_atomic",
        args: [
          {
            type: "byte[]",
            value: txnHash, // transaction_hash
          },
          {
            type: "byte[]",
            value: payload.buyerSignature, // buyer_signature
          },
          {
            type: "byte[]",
            value: payload.buyerPublicKey, // buyer_public_key
          },
          {
            type: "byte[]",
            value: payload.sellerSignature, // seller_signature
          },
          {
            type: "byte[]",
            value: payload.sellerPublicKey, // seller_public_key
          },
          {
            type: "uint64",
            value: payload.amount, // amount
          },
          {
            type: "string",
            value: payload.category, // category
          },
          {
            type: "string",
            value: settleId, // settlement_id
          },
        ],
        returns: { type: "void" },
      },
      sender: payload.settlingPartyAddress,
      suggestedParams: params,
    });

    console.log("[SmartContract] Executing atomic settlement...");

    // Send transaction group
    const result = await atc.execute(client, 4);

    console.log("[SmartContract] Settlement executed:");
    console.log(`  • Transaction ID: ${result.txIDs[0]}`);
    console.log(`  • Confirmed: true`);

    // Get block number (simplified - in practice would query indexer)
    const status = await client.status().do();
    const blockNumber = status["last-round"];

    return {
      success: true,
      contractAppId: appId,
      transactionId: result.txIDs[0],
      blockNumber,
      settleId,
      timestamp: Date.now(),
    };
  } catch (error) {
    console.error("[SmartContract] Settlement failed:", error);

    return {
      success: false,
      contractAppId: getPaymentAppId(),
      transactionId: "",
      blockNumber: 0,
      settleId: "",
      timestamp: Date.now(),
      error: error instanceof Error ? error.message : "Unknown error",
    };
  }
}

/**
 * Get contract information (read-only)
 * 
 * @returns Settlement statistics from contract state
 */
export async function getContractInfo(): Promise<{
  appId: number;
  settlementCount: number;
  totalVolume: number;
}> {
  try {
    const client = getAlgodClient();
    const appId = getPaymentAppId();

    // Get app state
    const appState = await client.getApplicationByID(appId).do();
    const globalState = appState.params["global-state"] || [];

    // Parse state
    let settlementCount = 0;
    let totalVolume = 0;

    for (const entry of globalState) {
      const key = Buffer.from(entry.key, "base64").toString("utf8");
      const value = entry.value;

      if (key === "settlement_counter" && value.type === 2) {
        settlementCount = value.uint;
      } else if (key === "total_volume" && value.type === 2) {
        totalVolume = value.uint;
      }
    }

    return {
      appId,
      settlementCount,
      totalVolume,
    };
  } catch (error) {
    console.error("[SmartContract] Failed to get contract info:", error);
    throw error;
  }
}

/**
 * Verify settlement was recorded on-chain
 * 
 * @param transactionId - Transaction ID to verify
 * @returns true if transaction confirmed on-chain
 */
export async function verifySettlementOnChain(transactionId: string): Promise<boolean> {
  try {
    const client = getAlgodClient();

    // Query indexer or transaction status
    const status = await client.pendingTransactionInformation(transactionId).do();

    // Check if transaction is confirmed (has block number)
    return status["confirmed-round"] !== undefined && status["confirmed-round"] > 0;
  } catch (error) {
    console.error("[SmartContract] Failed to verify settlement:", error);
    return false;
  }
}

/**
 * Prepare offline settlement data for signing
 * 
 * Used by mobile app to sign transactions offline
 */
export function prepareDealForSigning(dealData: {
  dealId: string;
  buyerAddress: string;
  sellerAddress: string;
  amount: number;
  category: string;
}): Buffer {
  // Create consistent hash for signing
  const message = JSON.stringify({
    dealId: dealData.dealId,
    buyerAddress: dealData.buyerAddress,
    sellerAddress: dealData.sellerAddress,
    amount: dealData.amount,
    category: dealData.category,
    timestamp: Date.now(),
  });

  return crypto.createHash("sha256").update(message).digest();
}
