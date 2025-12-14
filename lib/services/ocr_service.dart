import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class OCRService {
  static final OCRService _instance = OCRService._internal();
  factory OCRService() => _instance;
  OCRService._internal();

  // Process image and extract text
  Future<String> processImage(File imageFile) async {
    // Skip on web as Google ML Kit doesn't fully support web
    if (kIsWeb) {
      // Return mock extracted text for web
      await Future.delayed(Duration(seconds: 1)); // Simulate processing time

      return '''
      RESTAURANT NAME
      123 Main Street
      City, State 12345
      
      Table 5            Date: 11/28/2025
      Server: John        Time: 7:30 PM
      
      Item                Price
      ----------------------------
      Caesar Salad        \$12.99
      Grilled Salmon      \$24.99
      Garlic Bread        \$ 6.99
      ----------------------------
      Subtotal:          \$44.97
      Tax:               \$ 3.60
      Total:             \$48.57
      
      Payment Method: Credit Card
      Card Number: **** **** **** 1234
      
      Thank you for dining with us!
      ''';
    }

    // In a real app, this would use Google ML Kit or another OCR service
    // For now, we'll just simulate OCR processing
    await Future.delayed(Duration(seconds: 2)); // Simulate processing time

    // Return mock extracted text
    return '''
    RESTAURANT NAME
    123 Main Street
    City, State 12345
    
    Table 5            Date: 11/28/2025
    Server: John        Time: 7:30 PM
    
    Item                Price
    ----------------------------
    Caesar Salad        \$12.99
    Grilled Salmon      \$24.99
    Garlic Bread        \$ 6.99
    ----------------------------
    Subtotal:          \$44.97
    Tax:               \$ 3.60
    Total:             \$48.57
    
    Payment Method: Credit Card
    Card Number: **** **** **** 1234
    
    Thank you for dining with us!
    ''';
  }

  // Extract amount from OCR text
  double extractAmount(String ocrText) {
    // Simple regex to find amounts in format \$XX.XX
    final RegExp amountRegex = RegExp(r'\\\$(\d+\.\d{2})');
    final matches = amountRegex.allMatches(ocrText);

    if (matches.isNotEmpty) {
      // Return the largest amount found (likely the total)
      double maxAmount = 0.0;
      for (final match in matches) {
        final amount = double.tryParse(match.group(1) ?? '0');
        if (amount != null && amount > maxAmount) {
          maxAmount = amount;
        }
      }
      return maxAmount;
    }

    return 0.0;
  }

  // Extract date from OCR text
  DateTime? extractDate(String ocrText) {
    // Simple regex to find dates in format MM/DD/YYYY
    final RegExp dateRegex = RegExp(r'(\d{1,2}/\d{1,2}/\d{4})');
    final match = dateRegex.firstMatch(ocrText);

    if (match != null) {
      try {
        final parts = match.group(1)?.split('/');
        if (parts != null && parts.length == 3) {
          final month = int.parse(parts[0]);
          final day = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          return DateTime(year, month, day);
        }
      } catch (e) {
        // Invalid date format
        return null;
      }
    }

    return null;
  }

  // Extract merchant name from OCR text
  String extractMerchant(String ocrText) {
    // Simple approach: assume the first line is the merchant name
    final lines = ocrText.split('\n');
    if (lines.isNotEmpty) {
      final firstLine = lines[0].trim();
      if (firstLine.isNotEmpty &&
          !firstLine.contains('Date') &&
          !firstLine.contains('Time')) {
        return firstLine;
      }
    }

    return 'Unknown Merchant';
  }
}
