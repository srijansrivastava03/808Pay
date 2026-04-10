// Algorand account management and transaction building for offline use
import algosdk from 'algosdk';

export interface AlgorandAccount {
  address: string;
  mnemonic: string;
}

/**
 * Generate a new Algorand account (key pair).
 */
export function generateAccount(): AlgorandAccount {
  const account = algosdk.generateAccount();
  const mnemonic = algosdk.secretKeyToMnemonic(account.sk);
  return { address: account.addr.toString(), mnemonic };
}

/**
 * Restore an account from a 25-word mnemonic.
 */
export function restoreAccount(mnemonic: string): AlgorandAccount {
  const account = algosdk.mnemonicToSecretKey(mnemonic);
  return { address: account.addr.toString(), mnemonic };
}

/**
 * Derive the Algorand address from a mnemonic.
 */
export function getAddressFromMnemonic(mnemonic: string): string {
  const account = algosdk.mnemonicToSecretKey(mnemonic);
  return account.addr.toString();
}

/**
 * Validate an Algorand address.
 */
export function isValidAddress(address: string): boolean {
  return algosdk.isValidAddress(address);
}

export interface SuggestedParams {
  fee: number;
  flatFee: boolean;
  firstValid: number;
  lastValid: number;
  genesisID: string;
  genesisHash: string; // base64
  minFee: number;
}

/** Decode a base64 string to a Uint8Array using native browser APIs. */
function base64ToUint8Array(b64: string): Uint8Array {
  return Uint8Array.from(atob(b64), (c) => c.charCodeAt(0));
}

/** Encode a Uint8Array to a base64 string using native browser APIs. */
function uint8ArrayToBase64(bytes: Uint8Array): string {
  return btoa(Array.from(bytes, (b) => String.fromCharCode(b)).join(''));
}

/**
 * Build and sign an Algorand payment transaction offline.
 * Returns the signed transaction bytes as a base64 string.
 */
export function buildAndSignPayment(
  senderMnemonic: string,
  receiverAddress: string,
  amountMicroAlgos: number,
  params: SuggestedParams,
  note?: string
): string {
  const senderAccount = algosdk.mnemonicToSecretKey(senderMnemonic);

  const genesisHashBytes = base64ToUint8Array(params.genesisHash);

  const txnParams: algosdk.SuggestedParams = {
    fee: params.minFee,
    flatFee: true,
    firstValid: params.firstValid,
    lastValid: params.lastValid,
    genesisID: params.genesisID,
    genesisHash: genesisHashBytes,
    minFee: params.minFee,
  };

  const noteBytes = note ? new TextEncoder().encode(note) : undefined;

  const txn = algosdk.makePaymentTxnWithSuggestedParamsFromObject({
    sender: senderAccount.addr.toString(),
    receiver: receiverAddress,
    amount: amountMicroAlgos,
    note: noteBytes,
    suggestedParams: txnParams,
  });

  const signedTxn = txn.signTxn(senderAccount.sk);
  return uint8ArrayToBase64(signedTxn);
}

/**
 * Convert ALGO to microALGO.
 */
export function algoToMicroAlgo(algo: number): number {
  return Math.round(algo * 1_000_000);
}

/**
 * Convert microALGO to ALGO.
 */
export function microAlgoToAlgo(microAlgo: number): number {
  return microAlgo / 1_000_000;
}
