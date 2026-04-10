/**
 * Tax Calculation Service
 * Handles dynamic GST calculation based on product categories
 */

export interface TaxBreakdown {
  baseAmount: number;
  taxAmount: number;
  loyaltyAmount: number;
  totalAmount: number;
  gstRate: number;
  merchantAmount: number;
}

class TaxCalculationService {
  // Category to GST rate mapping
  private categoryRates: Record<string, number> = {
    food: 5,
    medicine: 0,
    electronics: 12,
    services: 18,
    luxury: 28,
  };

  /**
   * Get GST rate for a category
   * @param category Payment category
   * @returns GST rate (0-28%)
   */
  getGstRate(category?: string): number {
    if (!category || !this.categoryRates[category.toLowerCase()]) {
      return 12; // Default to electronics (12%)
    }
    return this.categoryRates[category.toLowerCase()];
  }

  /**
   * Get category name
   */
  getCategoryName(category?: string): string {
    if (!category) return 'electronics';
    return category.toLowerCase();
  }

  /**
   * Validate category
   */
  isValidCategory(category?: string): boolean {
    if (!category) return true; // Optional, defaults to electronics
    return category.toLowerCase() in this.categoryRates;
  }

  /**
   * Calculate inclusive tax breakdown
   * Using INCLUSIVE tax model: tax is already included in the amount
   *
   * Formula for inclusive tax:
   * baseAmount = amount × (100 / (100 + gstRate))
   * taxAmount = amount - baseAmount
   * loyaltyAmount = baseAmount × 0.075 (7.5% of merchant amount)
   * merchantAmount = baseAmount - loyaltyAmount
   *
   * @param totalAmount Total amount (including tax)
   * @param category Payment category for tax calculation
   * @returns Tax breakdown with splits
   */
  calculateTaxBreakdown(totalAmount: number, category?: string): TaxBreakdown {
    const gstRate = this.getGstRate(category);

    // Calculate base amount (excluding tax)
    const baseAmount = Math.round((totalAmount * 100) / (100 + gstRate));

    // Calculate tax amount
    const taxAmount = totalAmount - baseAmount;

    // Calculate loyalty amount (7.5% of merchant amount)
    const loyaltyAmount = Math.round(baseAmount * 0.075);

    // Merchant gets the remaining amount
    const merchantAmount = baseAmount - loyaltyAmount;

    return {
      baseAmount,
      taxAmount,
      loyaltyAmount,
      totalAmount,
      gstRate,
      merchantAmount,
    };
  }

  /**
   * Calculate payment splits
   * Returns splits optimized for blockchain settlement
   */
  calculateSplits(totalAmount: number, category?: string) {
    const breakdown = this.calculateTaxBreakdown(totalAmount, category);

    return {
      merchant: breakdown.merchantAmount,
      tax: breakdown.taxAmount,
      loyalty: breakdown.loyaltyAmount,
    };
  }

  /**
   * Get all category rates
   */
  getAllCategories() {
    return Object.entries(this.categoryRates).map(([name, rate]) => ({
      name,
      rate,
    }));
  }

  /**
   * Format tax report for logging
   */
  formatTaxReport(breakdown: TaxBreakdown): string {
    return `
Tax Report:
- Total: ₹${breakdown.totalAmount}
- Base Amount: ₹${breakdown.baseAmount}
- GST (${breakdown.gstRate}%): ₹${breakdown.taxAmount}
- Merchant: ₹${breakdown.merchantAmount}
- Loyalty: ₹${breakdown.loyaltyAmount}
    `.trim();
  }
}

export const taxCalculationService = new TaxCalculationService();
