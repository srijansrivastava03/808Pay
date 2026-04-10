import { Transaction } from '../types';

class TransactionStore {
  private transactions: Map<string, Transaction> = new Map();

  add(transaction: Transaction): void {
    this.transactions.set(transaction.id, transaction);
    console.log(`✅ Transaction stored: ${transaction.id}`);
  }

  get(id: string): Transaction | undefined {
    return this.transactions.get(id);
  }

  update(id: string, updates: Partial<Transaction>): void {
    const transaction = this.transactions.get(id);
    if (transaction) {
      const updated = { ...transaction, ...updates };
      this.transactions.set(id, updated);
      console.log(`✏️ Transaction updated: ${id}`);
    }
  }

  getAll(): Transaction[] {
    return Array.from(this.transactions.values());
  }

  getByStatus(status: 'pending' | 'settled' | 'failed'): Transaction[] {
    return Array.from(this.transactions.values()).filter(
      (tx) => tx.status === status
    );
  }

  clear(): void {
    this.transactions.clear();
    console.log('🗑️ Transaction store cleared');
  }
}

// Export singleton instance
export const transactionStore = new TransactionStore();
