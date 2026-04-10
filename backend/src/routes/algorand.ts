import { Router, Request, Response } from 'express';
import { algorandService } from '../services/algorandService';

const router = Router();

/**
 * GET /api/algorand/health
 * Check Algorand network status
 */
router.get('/health', async (req: Request, res: Response) => {
  try {
    const status = await algorandService.getNetworkStatus();
    res.json({
      ...status,
      message: 'Network is healthy',
    });
  } catch (error: any) {
    res.status(503).json({
      network: process.env.ALGO_NETWORK || 'testnet',
      status: 'unhealthy',
      error: error.message,
    });
  }
});

/**
 * GET /api/algorand/balance/:address
 * Get account balance on Algorand
 */
router.get('/balance/:address', async (req: Request, res: Response) => {
  try {
    const balance = await algorandService.getAccountBalance(req.params.address);
    res.json({
      address: req.params.address,
      balance,
      balanceAlgo: balance / 1_000_000, // Convert to ALGO
      currency: 'ALGO',
      message: 'Balance retrieved successfully',
    });
  } catch (error: any) {
    res.status(400).json({
      error: error.message,
      address: req.params.address,
    });
  }
});

/**
 * GET /api/algorand/transaction/:txnId
 * Get settlement transaction details
 */
router.get('/transaction/:txnId', async (req: Request, res: Response) => {
  try {
    const txn = await algorandService.getTransaction(req.params.txnId);
    if (!txn) {
      return res.status(404).json({
        error: 'Transaction not found',
        txnId: req.params.txnId,
      });
    }
    res.json({
      txnId: req.params.txnId,
      transaction: txn,
      explorerUrl: algorandService.getExplorerUrl(req.params.txnId),
    });
  } catch (error: any) {
    res.status(400).json({
      error: error.message,
      txnId: req.params.txnId,
    });
  }
});

/**
 * GET /api/algorand/history/:address
 * Get transaction history for address
 */
router.get('/history/:address', async (req: Request, res: Response) => {
  try {
    const limit = Math.min(parseInt(req.query.limit as string) || 10, 100);
    const history = await algorandService.getTransactionHistory(
      req.params.address,
      limit
    );
    res.json({
      address: req.params.address,
      transactions: history,
      total: history.length,
      limit,
    });
  } catch (error: any) {
    res.status(400).json({
      error: error.message,
      address: req.params.address,
    });
  }
});

export default router;
