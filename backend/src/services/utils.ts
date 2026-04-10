// Shared Algorand utility functions (used by tests and can be used in backend logic)
import algosdk from 'algosdk';

export interface AlgorandAccount {
  address: string;
  mnemonic: string;
}

export function generateAccount(): AlgorandAccount {
  const account = algosdk.generateAccount();
  const mnemonic = algosdk.secretKeyToMnemonic(account.sk);
  return { address: account.addr.toString(), mnemonic };
}

export function restoreAccount(mnemonic: string): AlgorandAccount {
  const account = algosdk.mnemonicToSecretKey(mnemonic);
  return { address: account.addr.toString(), mnemonic };
}

export function isValidAddress(address: string): boolean {
  return algosdk.isValidAddress(address);
}

export interface OfflineParams {
  fee: number;
  flatFee: boolean;
  firstValid: number;
  lastValid: number;
  genesisID: string;
  genesisHash: string;
  minFee: number;
}

export function buildAndSignPayment(
  senderMnemonic: string,
  receiverAddress: string,
  amountMicroAlgos: number,
  params: OfflineParams,
  note?: string
): string {
  const senderAccount = algosdk.mnemonicToSecretKey(senderMnemonic);

  const txnParams: algosdk.SuggestedParams = {
    fee: params.minFee,
    flatFee: true,
    firstRound: params.firstValid,
    lastRound: params.lastValid,
    genesisID: params.genesisID,
    genesisHash: params.genesisHash, // algosdk v2 expects base64 string
  };

  const noteBytes = note ? new TextEncoder().encode(note) : undefined;

  const txn = algosdk.makePaymentTxnWithSuggestedParamsFromObject({
    from: senderAccount.addr.toString(),
    to: receiverAddress,
    amount: amountMicroAlgos,
    note: noteBytes,
    suggestedParams: txnParams,
  });

  const signedTxn = txn.signTxn(senderAccount.sk);
  return Buffer.from(signedTxn).toString('base64');
}

export function algoToMicroAlgo(algo: number): number {
  return Math.round(algo * 1_000_000);
}

export function microAlgoToAlgo(microAlgo: number): number {
  return microAlgo / 1_000_000;
}
