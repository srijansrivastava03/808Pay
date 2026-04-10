export interface Transaction {
  id: string;
  sender: string; // Public key (hex or base64)
  recipient: string; // Merchant address
  amount: number; // In microAlgos or cents
  timestamp: number; // Unix timestamp
  category?: string; // Payment category for tax calculation
  gstRate?: number; // GST rate applied (0-28%)
  data: any; // Original transaction data
  signature: string; // Hex-encoded signature
  publicKey: string; // Hex or base64 encoded public key
  status: 'pending' | 'settled' | 'failed';
  createdAt: Date;
  settledAt?: Date;
  splits?: {
    merchant: number;
    tax: number;
    loyalty: number;
  };
  error?: string;
}

export interface SettleTransactionRequest {
  data: {
    sender: string;
    recipient: string;
    amount: number;
    timestamp: number;
    category?: string; // Optional: food, medicine, electronics, services, luxury
  };
  signature: string;
  publicKey: string;
}

export interface AlgorandTransaction {
  txId: string;
  blockNumber: number;
  confirmed: boolean;
}

export interface SettlementResult {
  success: boolean;
  transactionId: string;
  message: string;
  splits?: {
    merchant: number;
    tax: number;
    loyalty: number;
  };
  balanceAfter?: number;
  recipientBalanceAfter?: number;
  error?: string;
  errorCode?: 'INSUFFICIENT_FUNDS' | 'SIGNATURE_INVALID' | 'INVALID_CATEGORY' | string;
  algoTransaction?: AlgorandTransaction; // NEW: Algorand blockchain transaction
}

export interface TransactionStatus {
  id: string;
  status: 'pending' | 'settled' | 'failed';
  sender: string;
  recipient: string;
  amount: number;
  category?: string;
  gstRate?: number;
  createdAt: Date;
  settledAt?: Date;
  splits?: {
    merchant: number;
    tax: number;
    loyalty: number;
  };
}
