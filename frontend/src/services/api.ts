const API_BASE = process.env.REACT_APP_API_URL || 'http://localhost:3001/api';

export interface SuggestedParams {
  fee: number;
  flatFee: boolean;
  firstValid: number;
  lastValid: number;
  genesisID: string;
  genesisHash: string;
  minFee: number;
}

export async function fetchParams(): Promise<SuggestedParams> {
  const res = await fetch(`${API_BASE}/params`);
  if (!res.ok) throw new Error('Failed to fetch params from node');
  return res.json() as Promise<SuggestedParams>;
}

export async function submitTransaction(signedTxnBase64: string): Promise<{ txId: string }> {
  const res = await fetch(`${API_BASE}/submit`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ signedTxn: signedTxnBase64 }),
  });
  if (!res.ok) {
    const err = (await res.json()) as { error: string; detail?: string };
    throw new Error(err.detail || err.error);
  }
  return res.json() as Promise<{ txId: string }>;
}

export async function submitBatch(
  signedTxns: string[]
): Promise<Array<{ index: number; txId?: string; error?: string }>> {
  const res = await fetch(`${API_BASE}/submit-batch`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ signedTxns }),
  });
  if (!res.ok) {
    const err = (await res.json()) as { error: string };
    throw new Error(err.error);
  }
  const body = (await res.json()) as {
    results: Array<{ index: number; txId?: string; error?: string }>;
  };
  return body.results;
}

export async function getAccountInfo(address: string): Promise<{
  amount: number;
  'min-balance': number;
  address: string;
}> {
  const res = await fetch(`${API_BASE}/account/${address}`);
  if (!res.ok) throw new Error('Failed to fetch account info');
  return res.json() as Promise<{ amount: number; 'min-balance': number; address: string }>;
}

export async function checkHealth(): Promise<boolean> {
  try {
    const res = await fetch(`${API_BASE}/health`, { signal: AbortSignal.timeout(5000) });
    return res.ok;
  } catch {
    return false;
  }
}
