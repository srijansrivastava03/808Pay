import React from 'react';
import { render, screen } from '@testing-library/react';
import App from './App';

// Mock the wallet service so we can control hasWallet() return
jest.mock('./services/wallet', () => ({
  hasWallet: jest.fn(() => false),
  getStoredWallet: jest.fn(() => null),
}));

test('renders SetupWallet screen when no wallet exists', () => {
  render(<App />);
  // The setup screen should show the app logo and setup options
  expect(screen.getByText('808Pay')).toBeInTheDocument();
  expect(screen.getByText('Create New Wallet')).toBeInTheDocument();
  expect(screen.getByText('Restore Existing Wallet')).toBeInTheDocument();
});
