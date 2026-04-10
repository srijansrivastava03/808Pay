#!/usr/bin/env node

/**
 * 808Pay Demo Script
 * Demonstrates the full offline-to-online payment flow
 */

import axios from 'axios';
import { createTestPayload } from './utils/crypto';

const API_BASE = 'http://localhost:5000';

async function runDemo() {
  console.log('\n╔════════════════════════════════════════════════════════╗');
  console.log('║         808PAY - OFFLINE PAYMENT DEMO                 ║');
  console.log('╚════════════════════════════════════════════════════════╝\n');

  try {
    // Step 1: Health check
    console.log('📡 Checking backend connectivity...');
    const health = await axios.get(`${API_BASE}/health`);
    console.log('✅ Backend online\n');

    // Step 2: Generate test payload
    console.log('🔑 Step 1: Generating cryptographic keys...');
    const payload = createTestPayload();
    console.log(`   Public Key:  ${payload.publicKey.slice(0, 30)}...`);
    console.log(`   Signature:   ${payload.signature.slice(0, 30)}...\n`);

    // Step 3: Display transaction
    console.log('💳 Step 2: Transaction Details');
    console.log(`   Sender:      ${payload.data.sender}`);
    console.log(`   Recipient:   ${payload.data.recipient}`);
    console.log(`   Amount:      ₹${payload.data.amount / 100}`);
    console.log(`   Timestamp:   ${new Date(payload.data.timestamp * 1000).toISOString()}\n`);

    // Step 4: Settle transaction
    console.log('🚀 Step 3: Settling transaction...');
    const settlementResponse = await axios.post(`${API_BASE}/api/transactions/settle`, payload);

    if (settlementResponse.data.success) {
      console.log(`✅ Settlement successful`);
      console.log(`   Transaction ID: ${settlementResponse.data.transactionId}\n`);

      // Step 5: Show splits
      console.log('💰 Step 4: Payment Splits');
      const splits = settlementResponse.data.splits;
      console.log(`   Merchant:  ₹${splits.merchant / 100} (90%)`);
      console.log(`   Tax:       ₹${splits.tax / 100} (5%)`);
      console.log(`   Loyalty:   ₹${splits.loyalty / 100} (5%)\n`);

      // Step 6: Get transaction status
      console.log('📋 Step 5: Retrieving transaction status...');
      const statusResponse = await axios.get(
        `${API_BASE}/api/transactions/${settlementResponse.data.transactionId}`
      );

      const transaction = statusResponse.data;
      console.log(`   Status:    ${transaction.status}`);
      console.log(`   Created:   ${new Date(transaction.createdAt).toISOString()}`);
      console.log(`   Settled:   ${new Date(transaction.settledAt).toISOString()}\n`);

      // Step 7: List all transactions
      console.log('📊 Step 6: All transactions in store...');
      const listResponse = await axios.get(`${API_BASE}/api/transactions`);
      console.log(`   Total transactions: ${listResponse.data.count}\n`);

      console.log('╔════════════════════════════════════════════════════════╗');
      console.log('║           ✅ DEMO COMPLETED SUCCESSFULLY            ║');
      console.log('╚════════════════════════════════════════════════════════╝\n');
    }
  } catch (error: any) {
    console.error('❌ Error:', error.response?.data || error.message);
    process.exit(1);
  }
}

// Run demo
runDemo();
