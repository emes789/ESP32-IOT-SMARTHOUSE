import 'package:flutter/material.dart';
import '../core/utils/color_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/platform_utils.dart';
class LoadingView extends StatelessWidget {
  final String? message;
  final bool showMessage;
  const LoadingView({
    super.key,
    this.message,
    this.showMessage = true,
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
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlphaFromOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary.withAlphaFromOpacity(0.3),
                          ),
                        ),
                      )
                          .animate(
                            onPlay: (controller) => controller.repeat(),
                          )
                          .rotate(duration: const Duration(seconds: 2)),
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      )
                          .animate(
                            onPlay: (controller) => controller.repeat(),
                          )
                          .rotate(
                            duration: const Duration(milliseconds: 1500),
                            begin: 1,
                            end: 0,
                          ),
                      Icon(
                        Icons.sensors_rounded,
                        size: 24,
                        color: AppColors.primary,                      )
                          .animate(
                            onPlay: (controller) => controller.repeat(reverse: true),
                            autoPlay: true, 
                          )
                          .scale(
                            duration: const Duration(milliseconds: 1000),
                            begin: Offset(0.8, 0.8),
                            end: Offset(1.2, 1.2),
                          ),
                    ],
                  ),
                ),
                if (showMessage) ...[
                  const SizedBox(height: 32),
                  Text(
                    message ?? 'Ładowanie danych...',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,                  )
                      .animate(
                        onPlay: (controller) => controller.repeat(reverse: true),
                        autoPlay: true, 
                      )
                      .fadeIn(
                        duration: const Duration(milliseconds: 1500),
                        begin: 0.5,
                      ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),                      )
                          .animate(
                            onPlay: (controller) => controller.repeat(),
                            autoPlay: true, 
                          )
                          .scale(
                            delay: Duration(milliseconds: index * 200),
                            duration: const Duration(milliseconds: 600),
                            begin: Offset(0.5, 0.5),
                            end: Offset(1.0, 1.0),
                          )
                          .then()
                          .scale(
                            duration: const Duration(milliseconds: 600),
                            begin: Offset(1.0, 1.0),
                            end: Offset(0.5, 0.5),
                          ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class CompactLoadingView extends StatelessWidget {
  final String? message;
  final double? size;
  final EdgeInsets? padding;
  const CompactLoadingView({
    super.key,
    this.message,
    this.size,
    this.padding,
  });
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loadingSize = size ?? 40.0;
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: loadingSize,
            height: loadingSize,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),            Text(
              message!,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ],
      ),
    );
  }
}
class LoadingButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final ButtonStyle? style;
  const LoadingButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.text,
    this.icon,
    this.style,
  });
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: isLoading
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(text),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon),
                  const SizedBox(width: 8),
                ],
                Text(text),
              ],
            ),
    );
  }
}
class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        color: isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBase,
      ),    )
        .animate(
          onPlay: (controller) => controller.repeat(),
          autoPlay: true, 
        )
        .shimmer(
          duration: const Duration(milliseconds: 1500),
          colors: [
            isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBase,
            isDark ? AppColors.shimmerHighlightDark : AppColors.shimmerHighlight,
            isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBase,
          ],
        );
  }
}
