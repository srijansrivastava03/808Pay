import nacl from 'tweetnacl';
import { verifySignature, hexToBytes, bytesToHex } from '../services/cryptoService';

/**
 * Test utilities for 808Pay crypto
 * Generates keys and signatures for testing
 */

export function generateTestKeyPair() {
  const keyPair = nacl.sign.keyPair();
  return {
    publicKey: bytesToHex(keyPair.publicKey),
    secretKey: bytesToHex(keyPair.secretKey),
  };
}

export function signTransactionData(data: any, secretKeyHex: string): string {
  const dataString = typeof data === 'string' ? data : JSON.stringify(data);
  const dataBytes = new TextEncoder().encode(dataString);
  const secretKeyBytes = hexToBytes(secretKeyHex);

  const signature = nacl.sign.detached(dataBytes, secretKeyBytes);
  return bytesToHex(signature);
}

export function createTestPayload() {
  const { publicKey, secretKey } = generateTestKeyPair();

  const transactionData = {
    sender: 'user_001',
    recipient: 'merchant_coffee_001',
    amount: 5000, // ₹50
    timestamp: Math.floor(Date.now() / 1000),
  };

  const signature = signTransactionData(transactionData, secretKey);

  return {
    data: transactionData,
    signature,
    publicKey,
  };
}

// Export for testing
export { verifySignature, hexToBytes, bytesToHex };
