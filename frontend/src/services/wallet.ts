// Wallet storage – encrypts the mnemonic with a PIN-derived key using WebCrypto
// so private keys never sit in plaintext in localStorage.

const WALLET_KEY = '808pay_wallet';

interface StoredWallet {
  address: string;
  name: string;
  encryptedMnemonic: string; // JSON: { iv, salt, ciphertext } – all base64
}

interface EncryptedBlob {
  iv: string;
  salt: string;
  ciphertext: string;
}

/** Encode a Uint8Array to base64 using native browser APIs. */
function toBase64(bytes: Uint8Array): string {
  return btoa(Array.from(bytes, (b) => String.fromCharCode(b)).join(''));
}

/** Decode a base64 string to a Uint8Array using native browser APIs. */
function fromBase64(b64: string): Uint8Array {
  return Uint8Array.from(atob(b64), (c) => c.charCodeAt(0));
}

async function deriveKey(pin: string, salt: Uint8Array): Promise<CryptoKey> {
  const pinBytes = new TextEncoder().encode(pin);
  const baseKey = await crypto.subtle.importKey('raw', pinBytes, 'PBKDF2', false, ['deriveKey']);
  return crypto.subtle.deriveKey(
    { name: 'PBKDF2', salt, iterations: 200_000, hash: 'SHA-256' },
    baseKey,
    { name: 'AES-GCM', length: 256 },
    false,
    ['encrypt', 'decrypt']
  );
}

async function encryptMnemonic(mnemonic: string, pin: string): Promise<string> {
  const salt = crypto.getRandomValues(new Uint8Array(16));
  const iv = crypto.getRandomValues(new Uint8Array(12));
  const key = await deriveKey(pin, salt);
  const ciphertext = await crypto.subtle.encrypt(
    { name: 'AES-GCM', iv },
    key,
    new TextEncoder().encode(mnemonic)
  );
  const blob: EncryptedBlob = {
    salt: toBase64(salt),
    iv: toBase64(iv),
    ciphertext: toBase64(new Uint8Array(ciphertext)),
  };
  return JSON.stringify(blob);
}

async function decryptMnemonic(encryptedMnemonic: string, pin: string): Promise<string> {
  const blob: EncryptedBlob = JSON.parse(encryptedMnemonic);
  const salt = fromBase64(blob.salt);
  const iv = fromBase64(blob.iv);
  const ciphertext = fromBase64(blob.ciphertext);
  const key = await deriveKey(pin, salt);
  const plaintext = await crypto.subtle.decrypt({ name: 'AES-GCM', iv }, key, ciphertext);
  return new TextDecoder().decode(plaintext);
}

export async function saveWallet(
  address: string,
  name: string,
  mnemonic: string,
  pin: string
): Promise<void> {
  const encryptedMnemonic = await encryptMnemonic(mnemonic, pin);
  const wallet: StoredWallet = { address, name, encryptedMnemonic };
  localStorage.setItem(WALLET_KEY, JSON.stringify(wallet));
}

export function getStoredWallet(): { address: string; name: string } | null {
  const raw = localStorage.getItem(WALLET_KEY);
  if (!raw) return null;
  const { address, name } = JSON.parse(raw) as StoredWallet;
  return { address, name };
}

export async function unlockWallet(pin: string): Promise<string> {
  const raw = localStorage.getItem(WALLET_KEY);
  if (!raw) throw new Error('No wallet found');
  const { encryptedMnemonic } = JSON.parse(raw) as StoredWallet;
  return decryptMnemonic(encryptedMnemonic, pin);
}

/**
 * Sign an Algorand payment transaction using the stored (encrypted) wallet.
 * The mnemonic is decrypted in-place and never returned to the caller,
 * reducing the clear-text exposure window.
 */
export async function signPayment(
  pin: string,
  signFn: (mnemonic: string) => string
): Promise<string> {
  const mnemonic = await unlockWallet(pin);
  return signFn(mnemonic);
}

export function clearWallet(): void {
  localStorage.removeItem(WALLET_KEY);
}

export function hasWallet(): boolean {
  return localStorage.getItem(WALLET_KEY) !== null;
}
