import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/translation_service.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/color_utils.dart';
import '../widgets/translated_text.dart';
class ApiStatusIndicator extends StatelessWidget {
  const ApiStatusIndicator({super.key});
  @override
  Widget build(BuildContext context) {
    final translationService = Provider.of<TranslationService>(context);
    final statusInfo = translationService.getApiStatus();
    // Ensure we have a strongly-typed Color so extension methods resolve correctly.
    final Color statusColor = (statusInfo['color'] is Color) ? statusInfo['color'] as Color : AppColors.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
      return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withAlphaFromOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withAlphaFromOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withAlphaFromOpacity(0.2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),      child: Row(
        children: [          
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withAlphaFromOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusInfo['icon'],
              color: statusColor,
              size: 20,
            ),          )
          .animate(
            onPlay: (controller) => controller.repeat(reverse: true),
            autoPlay: true, 
            target: statusInfo['status'] != 'ok' ? 1 : 0, 
          )          .scale(
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            begin: const Offset(0.9, 0.9),
            end: const Offset(1.1, 1.1),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [                TranslatedText(
                  text: statusInfo['message'],
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,                ),TranslatedText(
                  text: statusInfo['details'],
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),          ),
          if (statusInfo['status'] != 'ok') ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                if (statusInfo['status'] == 'error') {
                  translationService.resetApiErrorState();
                } else if (statusInfo['status'] == 'not_configured') {
                }
              },
              icon: Icon(
                statusInfo['status'] == 'error' ? Icons.refresh : Icons.settings,
                color: statusColor,
                size: 20,
              ),
              tooltip: statusInfo['status'] == 'error' ? 'Spróbuj ponownie' : 'Konfiguruj',
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 300));
  }
}
