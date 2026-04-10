/// Tax calculation service for dynamic GST by category
/// Implements real-world India GST rates (0%, 5%, 12%, 18%, 28%)
class TaxCalculationService {
  
  /// GST rates by category (India-specific)
  static const Map<String, double> gstRates = {
    'food': 5.0,           // Food & Groceries - 5% GST
    'medicine': 0.0,       // Healthcare & Medicine - 0% GST (essential)
    'electronics': 12.0,   // Gadgets & Electronics - 12% GST
    'services': 18.0,      // Professional Services - 18% GST
    'luxury': 28.0,        // Premium/Luxury Goods - 28% GST (highest)
  };

  /// Category display names
  static const Map<String, String> categoryNames = {
    'food': '🍔 Food & Groceries',
    'medicine': '💊 Medicine & Healthcare',
    'electronics': '⚡ Electronics',
    'services': '💼 Services',
    'luxury': '👜 Luxury Goods',
  };

  /// Get GST rate for category
  static double getGstRate(String category) {
    final key = category.toLowerCase();
    return gstRates[key] ?? 18.0; // Default to 18% if unknown
  }

  /// Calculate tax for amount using INCLUSIVE model
  /// Tax included in total amount (not added on top)
  /// Formula: tax = (amount * rate) / (100 + rate)
  static double calculateInclusiveTax({
    required double amount,
    required String category,
  }) {
    final rate = getGstRate(category);
    return (amount * rate) / (100 + rate);
  }

  /// Calculate base amount (excluding tax) for INCLUSIVE model
  /// Formula: base = amount - tax
  static double calculateBaseAmount({
    required double amount,
    required String category,
  }) {
    final tax = calculateInclusiveTax(amount: amount, category: category);
    return amount - tax;
  }

  /// Calculate payment breakdown for amount
  /// Returns: merchant (90%), tax (government), loyalty (10% of base)
  static Map<String, double> calculateBreakdown({
    required double amount,
    required String category,
  }) {
    final tax = calculateInclusiveTax(amount: amount, category: category);
    final baseAmount = amount - tax;
    
    // Split base amount: 90% merchant, 5% loyalty (from backend re-split)
    final merchant = baseAmount * 0.90;
    final loyalty = baseAmount * 0.10;
    
    return {
      'total': amount,
      'merchant': merchant,      // Goes to merchant
      'tax': tax,                // Goes to government
      'loyalty': loyalty,        // Loyalty points
      'baseAmount': baseAmount,  // Pre-tax base
      'gstRate': getGstRate(category),
    };
  }

  /// Format amount in Indian Rupees
  static String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  /// Get all available categories
  static List<String> getAllCategories() {
    return gstRates.keys.toList();
  }

  /// Validate category
  static bool isValidCategory(String category) {
    return gstRates.containsKey(category.toLowerCase());
  }

  /// Calculate total tax collected across multiple transactions
  static double calculateTotalTax(List<Map<String, dynamic>> transactions) {
    double total = 0;
    for (final tx in transactions) {
      final amount = (tx['amount'] ?? 0).toDouble();
      final category = (tx['category'] ?? 'services') as String;
      total += calculateInclusiveTax(amount: amount, category: category);
    }
    return total;
  }

  /// Generate tax breakdown report for analytics
  static Map<String, dynamic> generateTaxReport(
    List<Map<String, dynamic>> transactions,
  ) {
    final breakdown = <String, double>{};
    
    for (final category in gstRates.keys) {
      breakdown[category] = 0;
    }
    
    for (final tx in transactions) {
      final amount = (tx['amount'] ?? 0).toDouble();
      final category = (tx['category'] ?? 'services').toString().toLowerCase();
      final tax = calculateInclusiveTax(amount: amount, category: category);
      breakdown[category] = (breakdown[category] ?? 0) + tax;
    }
    
    return {
      'totalTaxCollected': calculateTotalTax(transactions),
      'byCategory': breakdown,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
