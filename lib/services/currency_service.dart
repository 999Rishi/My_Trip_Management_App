class CurrencyService {
  // Mock exchange rates (in a real app, these would come from an API)
  static final Map<String, Map<String, double>> _exchangeRates = {
    'USD': {
      'EUR': 0.85,
      'GBP': 0.73,
      'JPY': 110.0,
      'CAD': 1.25,
      'AUD': 1.35,
      'CHF': 0.92,
      'CNY': 6.45,
      'INR': 73.5,
    },
    'EUR': {
      'USD': 1.18,
      'GBP': 0.86,
      'JPY': 129.0,
      'CAD': 1.47,
      'AUD': 1.59,
      'CHF': 1.08,
      'CNY': 7.59,
      'INR': 86.5,
    },
    // Add more currencies as needed
  };

  // Convert amount from one currency to another
  static double convertCurrency(
    double amount,
    String fromCurrency,
    String toCurrency,
  ) {
    // If same currency, no conversion needed
    if (fromCurrency == toCurrency) {
      return amount;
    }

    // Check if we have exchange rate for this conversion
    final rates = _exchangeRates[fromCurrency];
    if (rates == null) {
      throw Exception('Exchange rates not available for $fromCurrency');
    }

    final rate = rates[toCurrency];
    if (rate == null) {
      throw Exception(
        'Exchange rate not available for $fromCurrency to $toCurrency',
      );
    }

    return amount * rate;
  }

  // Format currency amount with rupee symbol instead of dollar sign
  static String formatCurrency(double amount, String currency) {
    // Format with rupee symbol for all currencies (as per user request)
    switch (currency.toUpperCase()) {
      case 'INR':
        return '₹${amount.toStringAsFixed(2)}';
      case 'USD':
        return '₹${amount.toStringAsFixed(2)}'; // Changed from $ to ₹
      case 'EUR':
        return '₹${amount.toStringAsFixed(2)}'; // Changed from € to ₹
      case 'GBP':
        return '₹${amount.toStringAsFixed(2)}'; // Changed from £ to ₹
      case 'JPY':
        return '₹${amount.round()}'; // Changed from ¥ to ₹
      case 'CAD':
        return '₹${amount.toStringAsFixed(2)}'; // Changed from CA$ to ₹
      case 'AUD':
        return '₹${amount.toStringAsFixed(2)}'; // Changed from AU$ to ₹
      case 'CHF':
        return '₹${amount.toStringAsFixed(2)}'; // Changed from CHF to ₹
      case 'CNY':
        return '₹${amount.toStringAsFixed(2)}'; // Changed from ¥ to ₹
      default:
        // For any other currency, use rupee symbol
        return '₹${amount.toStringAsFixed(2)}';
    }
  }

  // Get list of supported currencies
  static List<String> getSupportedCurrencies() {
    return ['USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD', 'CHF', 'CNY', 'INR'];
  }
}
