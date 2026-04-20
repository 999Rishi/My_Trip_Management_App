import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/common_widgets.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated logo
            Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 30,
                        offset: Offset(0, 15),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/app_logo.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(delay: 200.ms, duration: 400.ms),
            SizedBox(height: 32),
            // App name
            Text(
                  'Trip Expense Manager',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 300.ms)
                .slideY(begin: 0.3, end: 0, duration: 600.ms),
            SizedBox(height: 8),
            Text(
              'Track, Split, Settle',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
            SizedBox(height: 48),
            // Modern loading indicator
            SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                    strokeWidth: 3,
                  ),
                )
                .animate()
                .fadeIn(duration: 400.ms, delay: 500.ms)
                .scale(delay: 500.ms, duration: 300.ms),
            SizedBox(height: 16),
            Text(
              'Loading...',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 600.ms),
          ],
        ),
      ),
    );
  }
}
