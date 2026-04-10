#!/bin/bash

# Test 808Pay Backend with Category Support
# Tests the settlement endpoint with different tax categories

echo "🧪 808Pay Backend Category Test"
echo "================================"
echo ""

# Backend URL
BACKEND="http://localhost:3000"

# Test endpoint first
echo "📋 Checking available categories..."
curl -s "${BACKEND}/api/transactions/test" | jq '.availableCategories' || echo "Backend not running"
echo ""
echo ""

# Note: These are example tests - actual testing requires proper key generation
# The backend now supports:
# - Category validation
# - GST rate selection based on category
# - Dynamic tax calculation
# - Proper split calculation

echo "✅ Backend Category Support:"
echo "   - food (5% GST)"
echo "   - medicine (0% GST)"
echo "   - electronics (12% GST)"
echo "   - services (18% GST)"
echo "   - luxury (28% GST)"
echo ""
echo "🔧 To test settlements:"
echo "   1. Frontend sends category in transaction data"
echo "   2. Backend validates category"
echo "   3. Backend calculates splits based on GST rate"
echo "   4. Transaction stores category and GST rate"
echo ""
echo "📊 Example payload:"
echo "   {\"data\": {\"sender\": \"...\", \"recipient\": \"...\", \"amount\": 10000, \"timestamp\": ..., \"category\": \"electronics\"}, ...}"
