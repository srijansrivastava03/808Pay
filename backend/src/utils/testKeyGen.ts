import nacl from 'tweetnacl';

/**
 * Test utility to generate test keys and signatures
 * This is used for testing and demos
 */

/**
 * Generate a new Ed25519 key pair
 */
export function generateKeyPair() {
  const keyPair = nacl.sign.keyPair();
  return {
    publicKey: bytesToHex(keyPair.publicKey),
    secretKey: bytesToHex(keyPair.secretKey),
  };
}

/**
 * Sign transaction data with a secret key
 */
export function signTransaction(data: any, secretKeyHex: string): string {
  const dataString = typeof data === 'string' ? data : JSON.stringify(data);
  const dataBytes = new TextEncoder().encode(dataString);
  const secretKeyBytes = hexToBytes(secretKeyHex);

  const signature = nacl.sign.detached(dataBytes, secretKeyBytes);
  return bytesToHex(signature);
}

/**
 * Convert hex string to Uint8Array
 */
export function hexToBytes(hex: string): Uint8Array {
  const cleanHex = hex.startsWith('0x') ? hex.slice(2) : hex;
  const bytes = new Uint8Array(cleanHex.length / 2);
  for (let i = 0; i < cleanHex.length; i += 2) {
    bytes[i / 2] = parseInt(cleanHex.substr(i, 2), 16);
  }
  return bytes;
}

/**
 * Convert Uint8Array to hex string
 */
export function bytesToHex(bytes: Uint8Array): string {
  return '0x' + Array.from(bytes).map((b) => b.toString(16).padStart(2, '0')).join('');
}

/**
 * Create a test transaction payload
 */
export function createTestTransaction(overrides: any = {}) {
  return {
    sender: '0xSENDER_ADDRESS',
    recipient: 'cafe_123',
    amount: 5000, // ₹50 in paise
    timestamp: Math.floor(Date.now() / 1000),
    ...overrides,
  };
}

/**
 * Full test workflow
 */
export function runFullTest() {
  console.log('\n🧪 CRYPTO TEST WORKFLOW\n');

  // 1. Generate keys
  console.log('1️⃣ Generating Ed25519 key pair...');
  const { publicKey, secretKey } = generateKeyPair();
  console.log(`   Public Key:  ${publicKey.slice(0, 20)}...`);
  console.log(`   Secret Key:  ${secretKey.slice(0, 20)}...`);

  // 2. Create transaction
  console.log('\n2️⃣ Creating transaction...');
  const transaction = createTestTransaction({
    amount: 5000, // ₹50
    recipient: 'coffee_shop_001',
  });
  console.log('   Transaction:', JSON.stringify(transaction, null, 2));

  // 3. Sign transaction
  console.log('\n3️⃣ Signing transaction...');
  const signature = signTransaction(transaction, secretKey);
  console.log(`   Signature: ${signature.slice(0, 20)}...`);

  // 4. Verify signature
  console.log('\n4️⃣ Verifying signature (using backend crypto service)...');
  const { verifySignature } = require('./cryptoService');
  const isValid = verifySignature(transaction, signature, publicKey);
  console.log(`   Verification: ${isValid ? '✅ VALID' : '❌ INVALID'}`);

  // 5. Show settlement splits
  console.log('\n5️⃣ Payment splits (₹50 total)...');
  console.log(`   Merchant:  ₹${transaction.amount * 0.9 / 100} (90%)`);
  console.log(`   Tax:       ₹${transaction.amount * 0.05 / 100} (5%)`);
  console.log(`   Loyalty:   ₹${transaction.amount * 0.05 / 100} (5%)`);

  console.log('\n✅ TEST COMPLETE\n');

  return {
    publicKey,
    secretKey,
    transaction,
    signature,
    isValid,
  };
}

// Run if called directly
if (require.main === module) {
  runFullTest();
}
