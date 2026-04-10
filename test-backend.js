#!/usr/bin/env node

/**
 * Quick test script for 808Pay backend
 * Tests all endpoints without complex crypto setup
 */

const http = require('http');

function makeRequest(method, path, data = null) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'localhost',
      port: 5000,
      path: path,
      method: method,
      headers: {
        'Content-Type': 'application/json',
      },
    };

    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => (body += chunk));
      res.on('end', () => {
        try {
          resolve({
            status: res.statusCode,
            data: JSON.parse(body),
          });
        } catch {
          resolve({
            status: res.statusCode,
            data: body,
          });
        }
      });
    });

    req.on('error', reject);
    if (data) req.write(JSON.stringify(data));
    req.end();
  });
}

async function runTests() {
  console.log('\n╔════════════════════════════════════════╗');
  console.log('║   808PAY BACKEND TEST SUITE            ║');
  console.log('╚════════════════════════════════════════╝\n');

  try {
    // Test 1: Health check
    console.log('📡 Test 1: Health Check');
    const health = await makeRequest('GET', '/health');
    console.log(`   Status: ${health.status}`);
    console.log(`   Response: ${JSON.stringify(health.data)}\n`);

    // Test 2: List transactions (should be empty)
    console.log('📋 Test 2: List Transactions (Empty)');
    const list1 = await makeRequest('GET', '/api/transactions');
    console.log(`   Status: ${list1.status}`);
    console.log(`   Count: ${list1.data.count}\n`);

    // Test 3: Try to settle with invalid data
    console.log('❌ Test 3: Invalid Settlement (Missing data)');
    const invalid = await makeRequest('POST', '/api/transactions/settle', {
      signature: 'test',
      publicKey: 'test',
    });
    console.log(`   Status: ${invalid.status}`);
    console.log(`   Error: ${invalid.data.error}\n`);

    // Test 4: Test endpoint info
    console.log('ℹ️  Test 4: Test Endpoint Info');
    const testInfo = await makeRequest('POST', '/api/transactions/test');
    console.log(`   Status: ${testInfo.status}`);
    console.log(`   Message: ${testInfo.data.message}\n`);

    // Test 5: 404 error
    console.log('🚫 Test 5: 404 Not Found');
    const notFound = await makeRequest('GET', '/api/nonexistent');
    console.log(`   Status: ${notFound.status}`);
    console.log(`   Error: ${notFound.data.error}\n`);

    console.log('╔════════════════════════════════════════╗');
    console.log('║   ✅ ALL TESTS COMPLETED            ║');
    console.log('╚════════════════════════════════════════╝\n');
  } catch (error) {
    console.error('❌ Test failed:', error.message);
    console.log('\nMake sure backend is running:');
    console.log('  npm run dev');
    process.exit(1);
  }
}

runTests();
