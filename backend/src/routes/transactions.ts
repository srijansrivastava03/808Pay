import { Router, Request, Response } from 'express';
import algosdk from 'algosdk';
import {
  algodClient,
  getTransactionParams,
  submitSignedTransaction,
  submitSignedTransactionBatch,
  waitForConfirmation,
  getAccountInfo,
  getTransactionStatus,
} from '../services/algorand';

const router = Router();

// GET /api/params - get suggested transaction params for offline signing
router.get('/params', async (_req: Request, res: Response) => {
  try {
    const params = await getTransactionParams();
    res.json({
      fee: params.fee,
      flatFee: params.flatFee,
      firstValid: params.firstRound,
      lastValid: params.lastRound,
      genesisID: params.genesisID,
      genesisHash: Buffer.from(params.genesisHash).toString('base64'),
      minFee: (params as algosdk.SuggestedParams & { minFee?: number }).minFee ?? 1000,
    });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : String(err);
    res.status(503).json({ error: 'Failed to fetch transaction params', detail: message });
  }
});

// POST /api/submit - submit a single base64-encoded signed transaction
router.post('/submit', async (req: Request, res: Response) => {
  const { signedTxn } = req.body as { signedTxn?: string };
  if (!signedTxn) {
    res.status(400).json({ error: 'signedTxn (base64) is required' });
    return;
  }
  try {
    const bytes = Uint8Array.from(Buffer.from(signedTxn, 'base64'));
    const txId = await submitSignedTransaction(bytes);
    const confirmation = await waitForConfirmation(txId);
    res.json({ txId, confirmation });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : String(err);
    res.status(500).json({ error: 'Transaction submission failed', detail: message });
  }
});

// POST /api/submit-batch - submit multiple base64-encoded signed transactions
router.post('/submit-batch', async (req: Request, res: Response) => {
  const { signedTxns } = req.body as { signedTxns?: string[] };
  if (!signedTxns || !Array.isArray(signedTxns) || signedTxns.length === 0) {
    res.status(400).json({ error: 'signedTxns (array of base64) is required' });
    return;
  }
  const results: Array<{ txId?: string; error?: string; index: number }> = [];
  for (let i = 0; i < signedTxns.length; i++) {
    try {
      const bytes = Uint8Array.from(Buffer.from(signedTxns[i], 'base64'));
      const txId = await submitSignedTransaction(bytes);
      await waitForConfirmation(txId);
      results.push({ index: i, txId });
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : String(err);
      results.push({ index: i, error: message });
    }
  }
  res.json({ results });
});

// GET /api/account/:address - get account information
router.get('/account/:address', async (req: Request, res: Response) => {
  const { address } = req.params;
  if (!algosdk.isValidAddress(address)) {
    res.status(400).json({ error: 'Invalid Algorand address' });
    return;
  }
  try {
    const info = await getAccountInfo(address);
    res.json(info);
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : String(err);
    res.status(500).json({ error: 'Failed to fetch account info', detail: message });
  }
});

// GET /api/transaction/:txId - get transaction status
router.get('/transaction/:txId', async (req: Request, res: Response) => {
  const { txId } = req.params;
  try {
    const status = await getTransactionStatus(txId);
    if (!status) {
      res.status(404).json({ error: 'Transaction not found' });
      return;
    }
    res.json(status);
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : String(err);
    res.status(500).json({ error: 'Failed to fetch transaction status', detail: message });
  }
});

// GET /api/health - health check
router.get('/health', async (_req: Request, res: Response) => {
  try {
    const status = await algodClient.status().do();
    res.json({ status: 'ok', network: status });
  } catch {
    res.status(503).json({ status: 'degraded', error: 'Cannot reach Algorand node' });
  }
});

export default router;
