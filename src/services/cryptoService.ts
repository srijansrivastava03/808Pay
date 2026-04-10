import nacl from 'tweetnacl';

/**
 * Verify Ed25519 signature
 * @param data - The original data (as object or string)
 * @param signature - Signature in hex format
 * @param publicKey - Public key in hex format
 * @returns true if signature is valid
 */
export function verifySignature(
  data: any,
  signature: string,
  publicKey: string
): boolean {
  try {
    // Convert data to JSON string for consistent hashing
    const dataString =
      typeof data === 'string' ? data : JSON.stringify(data);
    const dataBytes = new TextEncoder().encode(dataString);

    // Convert hex strings to Uint8Array
    const signatureBytes = hexToBytes(signature);
    const publicKeyBytes = hexToBytes(publicKey);

    // Verify signature
    const isValid = nacl.sign.detached.verify(
      dataBytes,
      signatureBytes,
      publicKeyBytes
    );

    if (isValid) {
      console.log('✅ Signature verified successfully');
    } else {
      console.log('❌ Signature verification failed');
    }

    return isValid;
  } catch (error) {
    console.error('Error verifying signature:', error);
    return false;
  }
}

/**
 * Convert hex string to Uint8Array
 */
export function hexToBytes(hex: string): Uint8Array {
  // Remove '0x' prefix if present
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
 * Validate public key format
 */
export function isValidPublicKey(publicKey: string): boolean {
  try {
    const bytes = hexToBytes(publicKey);
    // Ed25519 public key should be 32 bytes
    return bytes.length === 32;
  } catch {
    return false;
  }
}
