import { Router, Request, Response } from 'express';
import { SettleTransactionRequest, SettlementResult, TransactionStatus } from '../types';
import { transactionStore } from '../store/transactionStore';
import { settlementService } from '../services/settlementService';

const router = Router();

/**
 * POST /api/transactions/settle
 * Settle an offline transaction with optional category for tax calculation
 *
 * Request body:
 * {
 *   "data": {
 *     "sender": "user_address",
 *     "recipient": "merchant_address",
 *     "amount": 5000,
 *     "timestamp": 1234567890,
 *     "category": "electronics" // Optional: food, medicine, electronics, services, luxury
 *   },
 *   "signature": "0x...",
 *   "publicKey": "0x..."
 * }
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

    // Validate category format if provided
    const validCategories = ['food', 'medicine', 'electronics', 'services', 'luxury'];
    if (data.category && !validCategories.includes(data.category.toLowerCase())) {
      return res.status(400).json({
        error: `Invalid category: ${data.category}. Must be one of: ${validCategories.join(', ')}`,
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
 * Get transaction status including category and GST rate
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
      category: transaction.category,
      gstRate: transaction.gstRate,
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
 * Test endpoint for generating test keys and signatures with category support
 */
router.post('/test', (req: Request, res: Response) => {
  try {
    // This is a test endpoint - should only be available in dev mode
    if (process.env.NODE_ENV === 'production') {
      return res.status(403).json({ error: 'Test endpoint not available in production' });
    }

    // For now, just return instructions
    res.json({
      message: 'Test endpoint for 808Pay - Offline Payment Settlement',
      availableCategories: [
        { name: 'food', gst: 5 },
        { name: 'medicine', gst: 0 },
        { name: 'electronics', gst: 12 },
        { name: 'services', gst: 18 },
        { name: 'luxury', gst: 28 },
      ],
      instructions: {
        step1: 'Generate a key pair (use frontend or crypto utility)',
        step2: 'Create a transaction with sender, recipient, amount, timestamp, and optional category',
        step3: 'Sign the transaction with your private key',
        step4: 'POST to /api/transactions/settle with data, signature, and publicKey',
      },
      example_payload: {
        data: {
          sender: 'user_address',
          recipient: 'merchant_001',
          amount: 5000,
          timestamp: Math.floor(Date.now() / 1000),
          category: 'electronics', // Optional - determines GST rate
        },
        signature: '0x...',
        publicKey: '0x...',
      },
      tax_calculation: {
        note: 'Tax is INCLUSIVE - calculated and deducted from the amount',
        formula:
          'baseAmount = amount × (100 / (100 + gstRate)) | taxAmount = amount - baseAmount',
        example: {
          amount: 10000,
          category: 'electronics',
          gstRate: '12%',
          baseAmount: 8928,
          taxAmount: 1072,
          merchantAmount: 8281, // baseAmount - 7.5% loyalty
          loyaltyAmount: 647,
        },
      },
    });
  } catch (error: any) {
    res.status(500).json({
      error: error.message || 'Test failed',
    });
  }
});

export default router;
