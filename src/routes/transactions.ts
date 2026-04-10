import { Router, Request, Response } from 'express';
import { SettleTransactionRequest, SettlementResult, TransactionStatus } from '../types';
import { transactionStore } from '../store/transactionStore';
import { settlementService } from '../services/settlementService';

const router = Router();

/**
 * POST /api/transactions/settle
 * Settle an offline transaction
 */
router.post('/settle', async (req: Request, res: Response) => {
  try {
    const { data, signature, publicKey } = req.body as SettleTransactionRequest;

    // Validate input
    if (!data || !signature || !publicKey) {
      return res.status(400).json({
        error: 'Missing required fields: data, signature, publicKey',
      });
    }

    // Process settlement
    const result = await settlementService.settle({
      data,
      signature,
      publicKey,
    });

    res.json(result);
  } catch (error: any) {
    console.error('Settlement error:', error);
    res.status(500).json({
      success: false,
      error: error.message || 'Settlement failed',
    });
  }
});

/**
 * GET /api/transactions/:id
 * Get transaction status
 */
router.get('/:id', (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    const transaction = transactionStore.get(id);

    if (!transaction) {
      return res.status(404).json({
        error: `Transaction ${id} not found`,
      });
    }

    const status: TransactionStatus = {
      id: transaction.id,
      status: transaction.status,
      sender: transaction.sender,
      recipient: transaction.recipient,
      amount: transaction.amount,
      createdAt: transaction.createdAt,
      settledAt: transaction.settledAt,
      splits: transaction.splits,
    };

    res.json(status);
  } catch (error: any) {
    res.status(500).json({
      error: error.message || 'Failed to fetch transaction',
    });
  }
});

/**
 * GET /api/transactions
 * List all transactions (for debugging)
 */
router.get('/', (req: Request, res: Response) => {
  try {
    const transactions = transactionStore.getAll();
    res.json({
      count: transactions.length,
      transactions,
    });
  } catch (error: any) {
    res.status(500).json({
      error: error.message || 'Failed to fetch transactions',
    });
  }
});

/**
 * POST /api/transactions/test
 * Test endpoint for generating test keys and signatures
 */
router.post('/test', (req: Request, res: Response) => {
  try {
    // This is a test endpoint - should only be available in dev mode
    if (process.env.NODE_ENV === 'production') {
      return res.status(403).json({ error: 'Test endpoint not available in production' });
    }

    // For now, just return instructions
    res.json({
      message: 'Test endpoint for 808Pay',
      instructions: {
        step1: 'Generate a key pair (use frontend or crypto utility)',
        step2: 'Create a transaction with sender, recipient, amount, timestamp',
        step3: 'Sign the transaction with your private key',
        step4: 'POST to /api/transactions/settle with data, signature, and publicKey',
      },
      example_payload: {
        data: {
          sender: 'user_address',
          recipient: 'merchant_001',
          amount: 5000,
          timestamp: Math.floor(Date.now() / 1000),
        },
        signature: '0x...',
        publicKey: '0x...',
      },
    });
  } catch (error: any) {
    res.status(500).json({
      error: error.message || 'Test failed',
    });
  }
});

export default router;
