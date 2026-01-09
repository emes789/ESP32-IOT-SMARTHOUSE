import 'package:flutter/material.dart';
import '../core/utils/color_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/platform_utils.dart';
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? title;
  final IconData? icon;
  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.title,
    this.icon,
  });
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(context.responsivePadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlphaFromOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon ?? Icons.error_outline_rounded,
                    size: 60,
                    color: AppColors.error,
                  ),
                )
                    .animate()
                    .scale(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(),
                const SizedBox(height: 32),
                Text(
                  title ?? 'Wystąpił błąd',
                  style: GoogleFonts.inter(
                    fontSize: context.isMobile ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate(delay: const Duration(milliseconds: 200))
                    .fadeIn(duration: const Duration(milliseconds: 600))
                    .slideY(begin: 0.3, end: 0),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlphaFromOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.error.withAlphaFromOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    message,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
                    .animate(delay: const Duration(milliseconds: 400))
                    .fadeIn(duration: const Duration(milliseconds: 600))
                    .slideY(begin: 0.3, end: 0),
                const SizedBox(height: 32),
                if (onRetry != null) ...[
                  SizedBox(
                    width: context.isMobile ? double.infinity : 200,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        PlatformUtils.hapticFeedback();
                        onRetry!();
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Spróbuj ponownie'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  )
                      .animate(delay: const Duration(milliseconds: 600))
                      .fadeIn(duration: const Duration(milliseconds: 600))
                      .slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 16),
                ],
                Text(
                  'Sprawdź połączenie internetowe\ni spróbuj ponownie za chwilę',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate(delay: const Duration(milliseconds: 800))
                    .fadeIn(duration: const Duration(milliseconds: 600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class CompactErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final EdgeInsets? padding;
  const CompactErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.padding,
  });
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Błąd',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Ponów'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                textStyle: GoogleFonts.inter(fontSize: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
