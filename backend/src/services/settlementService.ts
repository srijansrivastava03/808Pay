import { v4 as uuidv4 } from 'uuid';
import { SettleTransactionRequest, SettlementResult, Transaction } from '../types';
import { transactionStore } from '../store/transactionStore';
import { verifySignature, isValidPublicKey } from './cryptoService';
import { taxCalculationService } from './taxCalculationService';

class SettlementService {
  /**
   * Settle a transaction
   * 1. Verify signature
   * 2. Validate data
   * 3. Validate category
   * 4. Calculate splits based on category-specific tax
   * 5. Store transaction
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

      // ⭐ NEW: Check balance before settlement
      const userBalance = await this.getUserBalance(publicKey);
      if (userBalance < data.amount) {
        console.warn(`❌ Insufficient balance: User has ₹${userBalance}, needs ₹${data.amount}`);
        throw new Error(
          `Insufficient balance. Available: ₹${userBalance}, Required: ₹${data.amount}`
        );
      }

      // Validate category if provided
      if (data.category && !taxCalculationService.isValidCategory(data.category)) {
        throw new Error(
          `Invalid category: ${data.category}. Must be one of: ${taxCalculationService.getAllCategories().map((c) => c.name).join(', ')}`
        );
      }

      // Get GST rate for category
      const gstRate = taxCalculationService.getGstRate(data.category);

      // Calculate payment splits using category-based tax
      const splits = taxCalculationService.calculateSplits(data.amount, data.category);

      // Create transaction record
      const transaction: Transaction = {
        id: uuidv4(),
        sender: publicKey,
        recipient: data.recipient,
        amount: data.amount,
        timestamp: data.timestamp,
        category: data.category,
        gstRate,
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

      // ⭐ NEW: Deduct from sender's balance
      await this.deductBalance(publicKey, data.amount);
      // ⭐ NEW: Add to recipient's balance
      await this.addBalance(data.recipient, splits.merchant);

      console.log('💰 Settlement successful:', transaction.id);
      console.log(`📦 Category: ${data.category || 'default (electronics)'}`);
      console.log(`🏷️  GST Rate: ${gstRate}%`);
      console.log(`✂️  Splits - Merchant: ₹${splits.merchant}, Tax: ₹${splits.tax}, Loyalty: ₹${splits.loyalty}`);

      return {
        success: true,
        transactionId: transaction.id,
        message: `Transaction settled successfully with ${gstRate}% GST`,
        splits,
      };
    } catch (error: any) {
      console.error('Settlement failed:', error.message);
      throw error;
    }
  }

  /**
   * Get user's current balance
   * In production: Query from Algorand blockchain or payment processor
   * For demo: Use in-memory store
   */
  private userBalances: Map<string, number> = new Map();

  private async getUserBalance(publicKey: string): Promise<number> {
    // TODO: In production, query from:
    // - Algorand blockchain
    // - Payment processor API
    // - Database ledger

    // For demo/testing: Return from in-memory map
    // Initialize with 1000 USDC for testing
    if (!this.userBalances.has(publicKey)) {
      this.userBalances.set(publicKey, 1000); // Demo: 1000 USDC starting balance
    }
    return this.userBalances.get(publicKey) || 0;
  }

  /**
   * Deduct balance after successful settlement
   */
  private async deductBalance(publicKey: string, amount: number): Promise<void> {
    const currentBalance = await this.getUserBalance(publicKey);
    this.userBalances.set(publicKey, currentBalance - amount);
    console.log(`💳 Balance updated: ${publicKey} now has ₹${currentBalance - amount}`);
  }

  /**
   * Add balance (for incoming payments)
   */
  private async addBalance(publicKey: string, amount: number): Promise<void> {
    const currentBalance = await this.getUserBalance(publicKey);
    this.userBalances.set(publicKey, currentBalance + amount);
    console.log(`💳 Balance updated: ${publicKey} now has ₹${currentBalance + amount}`);
  }

  /**
   * Get balance statistics
   */
  getBalanceStats() {
    const users = Array.from(this.userBalances.entries());
    return {
      totalUsers: users.length,
      balances: users.map(([pk, balance]) => ({
        publicKey: pk.substring(0, 16) + '...', // Truncate for display
        balance,
      })),
      totalBalance: users.reduce((sum, [_, balance]) => sum + balance, 0),
    };
  }

  /**
   * Calculate payment splits (deprecated - use taxCalculationService instead)
   * Kept for backward compatibility
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
