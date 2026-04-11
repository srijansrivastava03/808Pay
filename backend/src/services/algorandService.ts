import algosdk from 'algosdk';
import { v4 as uuidv4 } from 'uuid';

export interface SettlementPayload {
  buyerAddress: string;
  sellerAddress: string;
  amount: number;
  category: string;
  buyerSignature: string;
  sellerSignature?: string;
  merchantAmount: number;
  taxAmount: number;
  gstRate: number;
}

export interface AlgoTransaction {
  txId: string;
  blockNumber: number;
  confirmed: boolean;
}

export class AlgorandService {
  private algodClient: algosdk.Algodv2;
  private indexerClient: algosdk.Indexer;
  private appId: number;
  private creatorAddress: string;
  private creatorMnemonic: string;

  constructor() {
    // Get configuration from environment
    const network = process.env.ALGO_NETWORK || 'testnet';
    const token = process.env.ALGORAND_TOKEN || '';
    
    // Use AlgoKit testnet endpoints (matches Pera Wallet testnet)
    // https://lora.algokit.io/testnet/fund
    let server = 'https://lora1-api.algokit.io';
    let indexerServer = 'https://lora1-idx.algokit.io';

    // Initialize clients
    this.algodClient = new algosdk.Algodv2(token, server, '');
    this.indexerClient = new algosdk.Indexer(token, indexerServer, '');

    this.appId = parseInt(process.env.PAYMENT_APP_ID || '0');
    this.creatorAddress = process.env.CREATOR_ADDRESS || '';
    this.creatorMnemonic = process.env.CREATOR_MNEMONIC || '';

    // Log initialization status
    console.log(`✅ AlgorandService initialized (${network})`);
    console.log(`   Server: ${server}`);
    console.log(`   Indexer: ${indexerServer}`);
    console.log(`📝 Transaction Mode: User-signed (no backend credentials needed)`);
    console.log(`   Each user signs their own transactions with their Pera Wallet`);
  }

  /**
   * Submit settlement transaction to Algorand
   * Uses the user's pre-signed transaction (no backend signing needed)
   */
  async submitSettlement(payload: SettlementPayload): Promise<AlgoTransaction> {
    try {
      console.log('📤 Submitting user-signed settlement to Algorand...');
      console.log(`   Buyer: ${payload.buyerAddress}`);
      console.log(`   Seller: ${payload.sellerAddress}`);
      console.log(`   Amount: ₹${payload.amount} (Merchant: ₹${payload.merchantAmount}, Tax: ₹${payload.taxAmount})`);

      // Get network parameters for building transaction
      const params = await this.algodClient.getTransactionParams().do();

      // Create payment transaction FROM BUYER TO SELLER
      // This uses the user's address (not backend creator)
      const noteData = {
        type: '808PAY_SETTLEMENT',
        buyerAddress: payload.buyerAddress,
        sellerAddress: payload.sellerAddress,
        amount: payload.amount,
        category: payload.category,
        gstRate: payload.gstRate,
        merchantAmount: payload.merchantAmount,
        taxAmount: payload.taxAmount,
        timestamp: Date.now(),
      };

      const note = new TextEncoder().encode(JSON.stringify(noteData));

      // Build payment transaction from buyer to seller
      const txn = algosdk.makePaymentTxnWithSuggestedParams(
        payload.buyerAddress,  // ← USER's address (not backend creator)
        payload.sellerAddress,
        BigInt(payload.merchantAmount),
        undefined,
        note,
        params
      );

      // The transaction is already signed by the user's device
      // We use the signature provided by the user
      // Reconstruct the signed transaction from user's signature
      const encodedTxn = this._reconstructSignedTransaction(txn, payload.buyerSignature);

      console.log('📡 Broadcasting to Algorand network...');

      // Submit to network
      const response = await this.algodClient.sendRawTransaction(encodedTxn).do();

      console.log(`✅ Transaction submitted to Algorand: ${response.txId}`);

      // Wait for confirmation
      const confirmation = await algosdk.waitForConfirmation(
        this.algodClient,
        response.txId,
        4 // Wait up to 4 rounds
      );

      console.log(`✅ Transaction confirmed at block ${confirmation['confirmed-round']}`);

      return {
        txId: response.txId,
        blockNumber: confirmation['confirmed-round'] as number,
        confirmed: true,
      };
    } catch (error) {
      console.error('❌ Algorand submission error:', error);
      throw new Error(`Settlement submission failed: ${(error as Error).message}`);
    }
  }

  /**
   * Reconstruct signed transaction from hex-encoded signature
   * The user has already signed the transaction on their device
   */
  private _reconstructSignedTransaction(txn: algosdk.Transaction, signatureHex: string): Uint8Array {
    try {
      // Convert signature from hex to bytes
      const signatureBytes = this._hexToBytes(signatureHex);

      // Create signed transaction with the user's signature
      const txnWithSig = {
        txn: txn,
        sig: signatureBytes,
      };

      // Encode as msgpack
      return algosdk.encodeObj(txnWithSig);
    } catch (error) {
      console.error('Error reconstructing signed transaction:', error);
      throw error;
    }
  }

  /**
   * Convert hex string to bytes
   */
  private _hexToBytes(hex: string): Uint8Array {
    const cleanHex = hex.startsWith('0x') ? hex.slice(2) : hex;
    const bytes = new Uint8Array(cleanHex.length / 2);
    for (let i = 0; i < bytes.length; i++) {
      bytes[i] = parseInt(cleanHex.substr(i * 2, 2), 16);
    }
    return bytes;
  }

  /**
   * Submit as app call transaction (when contract deployed)
   */
  private async _submitAppCallTransaction(
    payload: SettlementPayload,
    params: algosdk.SuggestedParams
  ): Promise<AlgoTransaction> {
    try {
      // Create app call transaction with settlement data
      const txn = algosdk.makeApplicationCallTxnFromObject({
        from: this.creatorAddress,
        appIndex: this.appId,
        onComplete: 0, // NoOp
        appArgs: [
          new Uint8Array(Buffer.from('SETTLE')),
          new Uint8Array(Buffer.from(`tx_${uuidv4()}`)),
          new Uint8Array(Buffer.from(payload.buyerAddress)),
          new Uint8Array(Buffer.from(payload.sellerAddress)),
          algosdk.encodeUint64(payload.amount),
          new Uint8Array(Buffer.from(payload.category)),
          new Uint8Array(Buffer.from(payload.buyerSignature, 'hex')),
          new Uint8Array(Buffer.from(payload.sellerSignature || '', 'hex')),
          algosdk.encodeUint64(payload.merchantAmount),
          algosdk.encodeUint64(payload.taxAmount),
          algosdk.encodeUint64(payload.gstRate),
        ],
        suggestedParams: params,
      });

      // Sign and submit
      const creatorAccount = algosdk.mnemonicToSecretKey(this.creatorMnemonic);
      const signedTxn = algosdk.signTransaction(txn, creatorAccount.sk);
      const response = await this.algodClient.sendRawTransaction(signedTxn.blob).do();

      // Wait for confirmation
      const confirmation = await algosdk.waitForConfirmation(
        this.algodClient,
        response.txId,
        4
      );

      return {
        txId: response.txId,
        blockNumber: confirmation['confirmed-round'] as number,
        confirmed: true,
      };
    } catch (error) {
      console.error('❌ App call transaction error:', error);
      throw error;
    }
  }

  /**
   * Get account balance on Algorand
   */
  async getAccountBalance(address: string): Promise<number> {
    try {
      const account = await this.algodClient.accountInformation(address).do();
      return account.amount; // In microAlgos
    } catch (error) {
      console.error('❌ Balance query error:', error);
      throw new Error(`Failed to get balance for ${address}`);
    }
  }

  /**
   * Get transaction details
   */
  async getTransaction(txnId: string): Promise<any> {
    try {
      const txn = await this.indexerClient.searchForTransactions().txid(txnId).do();
      return txn.transactions?.[0] || null;
    } catch (error) {
      console.error('❌ Transaction query error:', error);
      throw new Error(`Failed to get transaction ${txnId}`);
    }
  }

  /**
   * Get transaction history for address
   */
  async getTransactionHistory(address: string, limit: number = 10): Promise<any[]> {
    try {
      const response = await this.indexerClient
        .searchForTransactions()
        .address(address)
        .limit(limit)
        .do();

      return response.transactions || [];
    } catch (error) {
      console.error('❌ History query error:', error);
      throw new Error(`Failed to get transaction history for ${address}`);
    }
  }

  /**
   * Check network health
   */
  async getNetworkStatus(): Promise<{
    network: string;
    status: string;
    latestRound: number;
    genesisTxnId: string;
  }> {
    try {
      const status = await this.algodClient.status().do();
      const genesis = await this.algodClient.genesis().do();

      return {
        network: process.env.ALGO_NETWORK || 'testnet',
        status: 'healthy',
        latestRound: status['last-round'],
        genesisTxnId: genesis.genesisID,
      };
    } catch (error) {
      console.error('❌ Status check error:', error);
      throw new Error('Network is unhealthy');
    }
  }

  /**
   * Get explorer URL for transaction
   */
  getExplorerUrl(txnId: string): string {
    const network = process.env.ALGO_NETWORK || 'testnet';
    if (network === 'mainnet') {
      return `https://algoexplorer.io/tx/${txnId}`;
    }
    return `https://testnet.algoexplorer.io/tx/${txnId}`;
  }
}

// Export singleton instance
export const algorandService = new AlgorandService();
