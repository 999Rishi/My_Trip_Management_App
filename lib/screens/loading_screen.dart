import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            Image.asset(
              'assets/app_logo.png',
              width: 100,
              height: 100,
            ), // Reduced size
            SizedBox(height: 20), // Reduced spacing
            // App name
            Text(
              'Trip Expense Manager',
              style: TextStyle(
                fontSize: 20, // Reduced font size
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 20), // Reduced spacing
            // Loading indicator
            SizedBox(
              width: 24, // Fixed size for consistent layout
              height: 24,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                strokeWidth: 3, // Thinner stroke for cleaner look
              ),
            ),
            SizedBox(height: 15), // Reduced spacing
            // Loading text
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ), // Smaller font
            ),
          ],
        ),
      ),
    );
  }
}
