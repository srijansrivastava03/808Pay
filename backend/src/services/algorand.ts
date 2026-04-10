import algosdk from 'algosdk';
import dotenv from 'dotenv';

dotenv.config();

const nodeUrl = process.env.ALGORAND_NODE_URL || 'https://testnet-api.algonode.cloud';
const indexerUrl = process.env.ALGORAND_INDEXER_URL || 'https://testnet-idx.algonode.cloud';
const token = process.env.ALGORAND_TOKEN || '';

export const algodClient = new algosdk.Algodv2(token, nodeUrl, '');
export const indexerClient = new algosdk.Indexer(token, indexerUrl, '');

export async function getTransactionParams(): Promise<algosdk.SuggestedParams & { minFee?: number }> {
  return await algodClient.getTransactionParams().do() as algosdk.SuggestedParams & { minFee?: number };
}

export async function submitSignedTransaction(signedTxnBytes: Uint8Array): Promise<string> {
  const { txid } = await algodClient.sendRawTransaction(signedTxnBytes).do();
  return txid as string;
}

export async function submitSignedTransactionBatch(
  signedTxns: Uint8Array[]
): Promise<string[]> {
  const txIds: string[] = [];
  for (const signedTxn of signedTxns) {
    const txId = await submitSignedTransaction(signedTxn);
    txIds.push(txId);
  }
  return txIds;
}

export async function waitForConfirmation(txId: string, rounds = 4): Promise<object> {
  return await algosdk.waitForConfirmation(algodClient, txId, rounds);
}

export async function getAccountInfo(address: string): Promise<object> {
  return await algodClient.accountInformation(address).do();
}

export async function getTransactionStatus(txId: string): Promise<object | null> {
  try {
    const result = await indexerClient.lookupTransactionByID(txId).do();
    return result;
  } catch {
    return null;
  }
}
