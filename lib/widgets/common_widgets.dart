import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Spacing constants
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;
}

// Color constants
class AppColors {
  static const primary = Color(0xFF0EA5E9);
  static const primaryDark = Color(0xFF0284C7);
  static const accent = Color(0xFFF59E0B);
  static const background = Color(0xFFF8FAFC);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textMuted = Color(0xFF94A3B8);
  static const border = Color(0xFFE2E8F0);
  static const success = Color(0xFF10B981);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);

  // Gradient colors
  static const gradientPrimary = [Color(0xFF0EA5E9), Color(0xFF0284C7)];

  static const gradientAccent = [Color(0xFFF59E0B), Color(0xFFF97316)];
}

// Modern Card Widget
class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Gradient? gradient;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final double? elevation;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.gradient,
    this.backgroundColor,
    this.onTap,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        gradient: gradient,
        color:
            backgroundColor ??
            Theme.of(context).cardTheme.color ??
            Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: elevation != null
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: elevation! * 2,
                  offset: Offset(0, elevation!),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
        child: child,
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: card,
        ),
      );
    }

    return card;
  }
}

// Gradient Button Widget
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final List<Color>? gradient;
  final double? width;
  final bool isLoading;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.gradient,
    this.width,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient ?? AppColors.gradientPrimary,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: (gradient?.first ?? AppColors.primary).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  text,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}

// Empty State Widget
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

// Section Header Widget
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;

  const SectionHeader({super.key, required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

// Amount Display Widget
class AmountDisplay extends StatelessWidget {
  final double amount;
  final String currency;
  final Color? color;
  final double fontSize;

  const AmountDisplay({
    super.key,
    required this.amount,
    required this.currency,
    this.color,
    this.fontSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '$currency ${amount.toStringAsFixed(2)}',
      style: GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.success,
      ),
    );
  }
}

// Avatar Chip Widget
class AvatarChip extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback? onTap;
  final Widget? trailing;

  const AvatarChip({
    super.key,
    required this.name,
    this.isSelected = false,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: isSelected
                  ? AppColors.primary
                  : AppColors.border,
              child: Text(
                name.substring(0, 1).toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              name,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.xs),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
