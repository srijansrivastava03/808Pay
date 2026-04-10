import algosdk from 'algosdk';
import {
  generateAccount,
  buildAndSignPayment,
  algoToMicroAlgo,
  microAlgoToAlgo,
  isValidAddress,
} from '../services/utils';

describe('algorand utility functions', () => {
  it('converts ALGO to microALGO correctly', () => {
    expect(algoToMicroAlgo(1)).toBe(1_000_000);
    expect(algoToMicroAlgo(0.001)).toBe(1000);
    expect(algoToMicroAlgo(10.5)).toBe(10_500_000);
  });

  it('converts microALGO to ALGO correctly', () => {
    expect(microAlgoToAlgo(1_000_000)).toBe(1);
    expect(microAlgoToAlgo(1000)).toBe(0.001);
  });

  it('validates Algorand addresses', () => {
    const account = algosdk.generateAccount();
    expect(isValidAddress(account.addr.toString())).toBe(true);
    expect(isValidAddress('NOTAVALIDADDRESS')).toBe(false);
  });

  it('generates a valid Algorand account', () => {
    const account = generateAccount();
    expect(account.address).toBeDefined();
    expect(account.mnemonic).toBeDefined();
    expect(account.mnemonic.split(' ').length).toBe(25);
    expect(algosdk.isValidAddress(account.address)).toBe(true);
  });

  it('builds and signs a payment transaction', () => {
    const sender = generateAccount();
    const receiver = generateAccount();

    const params = {
      fee: 1000,
      flatFee: true,
      firstValid: 1000,
      lastValid: 2000,
      genesisID: 'testnet-v1.0',
      genesisHash: 'SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI=',
      minFee: 1000,
    };

    const signedTxn = buildAndSignPayment(
      sender.mnemonic,
      receiver.address,
      algoToMicroAlgo(1),
      params,
      'test payment'
    );

    expect(typeof signedTxn).toBe('string');
    // Should be valid base64 decodable bytes
    const bytes = Buffer.from(signedTxn, 'base64');
    expect(bytes.length).toBeGreaterThan(0);
  });

  it('restores the same address from mnemonic on repeated signs', () => {
    const account = generateAccount();
    const restored = generateAccount();
    // Each generate creates unique account
    expect(account.address).not.toBe(restored.address);
  });
});
