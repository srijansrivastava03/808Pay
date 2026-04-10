import { v4 as uuidv4 } from 'uuid';
import { SettleTransactionRequest, SettlementResult, Transaction } from '../types';
import { transactionStore } from '../store/transactionStore';
import { verifySignature, isValidPublicKey } from './cryptoService';

class SettlementService {
  /**
   * Settle a transaction
   * 1. Verify signature
   * 2. Validate data
   * 3. Calculate splits
   * 4. Store transaction
   */
  async settle(request: SettleTransactionRequest): Promise<SettlementResult> {
    try {
      const { data, signature, publicKey } = request;

      // Validate public key format
      if (!isValidPublicKey(publicKey)) {
        throw new Error('Invalid public key format');
      }

      // Verify signature
      if (!verifySignature(data, signature, publicKey)) {
        throw new Error('Signature verification failed');
      }

      // Validate transaction data
      this.validateTransactionData(data);

      // Calculate payment splits
      const splits = this.calculateSplits(data.amount);

      // Create transaction record
      const transaction: Transaction = {
        id: uuidv4(),
        sender: publicKey,
        recipient: data.recipient,
        amount: data.amount,
        timestamp: data.timestamp,
        data,
        signature,
        publicKey,
        status: 'settled',
        createdAt: new Date(),
        settledAt: new Date(),
        splits,
      };

      // Store transaction
      transactionStore.add(transaction);

      console.log('💰 Settlement successful:', transaction.id);

      return {
        success: true,
        transactionId: transaction.id,
        message: 'Transaction settled successfully',
        splits,
      };
    } catch (error: any) {
      console.error('Settlement failed:', error.message);
      throw error;
    }
  }

  /**
   * Calculate payment splits
   * Merchant: 90%
   * Tax/Regulatory: 5%
   * Loyalty Points: 5%
   */
  private calculateSplits(amount: number): { merchant: number; tax: number; loyalty: number } {
    return {
      merchant: Math.round(amount * 0.9),
      tax: Math.round(amount * 0.05),
      loyalty: Math.round(amount * 0.05),
    };
  }

  /**
   * Validate transaction data structure
   */
  private validateTransactionData(data: any): void {
    if (!data.sender) throw new Error('Missing sender in transaction data');
    if (!data.recipient) throw new Error('Missing recipient in transaction data');
    if (typeof data.amount !== 'number' || data.amount <= 0) {
      throw new Error('Invalid amount in transaction data');
    }
    if (!data.timestamp) throw new Error('Missing timestamp in transaction data');
  }

  /**
   * Get settlement statistics (for debugging)
   */
  getStats() {
    const allTransactions = transactionStore.getAll();
    const settled = transactionStore.getByStatus('settled');

    const totalAmount = settled.reduce((sum, tx) => sum + tx.amount, 0);
    const totalMerchant = settled.reduce((sum, tx) => sum + (tx.splits?.merchant || 0), 0);

    return {
      totalTransactions: allTransactions.length,
      settledTransactions: settled.length,
      totalAmount,
      totalMerchantAmount: totalMerchant,
    };
  }
}

export const settlementService = new SettlementService();
