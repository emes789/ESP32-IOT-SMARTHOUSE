import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/platform_utils.dart';
import '../models/alert.dart';
import '../widgets/translated_text.dart';

class RecentAlertsCard extends StatelessWidget {
  final List<Alert> alerts;
  final int maxAlerts;
  final VoidCallback? onSeeAll;

  const RecentAlertsCard({
    super.key,
    required this.alerts,
    this.maxAlerts = 5,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recentAlerts = alerts.take(maxAlerts).toList();
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? AppColors.darkDivider : AppColors.divider,
          width: 1,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isDark, context),
            const SizedBox(height: 20),
            if (recentAlerts.isEmpty)
              _buildEmptyState(isDark)
            else
              _buildAlertsList(recentAlerts, isDark),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildHeader(bool isDark, BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.warning.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.warning_rounded,
            color: AppColors.warning,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TranslatedText(
                text: 'Ostatnie Alerty',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              Text(
                alerts.isEmpty ? 'Brak alertów' : '${alerts.length} alertów',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (alerts.length > maxAlerts && onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: Text(
              'Zobacz wszystkie',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              size: 40,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 16),
          TranslatedText(
            text: 'Brak alertów',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 8),
          TranslatedText(
            text: 'Wszystkie systemy działają prawidłowo',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 800))
        .scale(begin: Offset(0.8, 0.8), end: Offset(1.0, 1.0));
  }

  Widget _buildAlertsList(List<Alert> recentAlerts, bool isDark) {
    return Column(
      children: recentAlerts.asMap().entries.map((entry) {
        final index = entry.key;
        final alert = entry.value;
        return Container(
          margin: EdgeInsets.only(bottom: index < recentAlerts.length - 1 ? 12 : 0),
          child: _buildAlertItem(alert, isDark, index),
        );
      }).toList(),
    );
  }

  Widget _buildAlertItem(Alert alert, bool isDark, int index) {
    return InkWell(
      onTap: () => PlatformUtils.hapticFeedback(),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: alert.categoryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: alert.categoryColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: alert.categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    alert.typeIcon,
                    color: alert.categoryColor,
                    size: 20,
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: alert.categoryColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.darkSurface : AppColors.surface,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          alert.typeDisplayName,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: alert.categoryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          alert.categoryDisplayName,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: alert.categoryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert.original ?? alert.message ?? '',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        alert.formattedTimestamp,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Sensor: ${alert.sensorId}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: alert.categoryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: alert.categoryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: index * 100),
          duration: const Duration(milliseconds: 600),
        )
        .slideX(
          begin: 0.3,
          end: 0,
          delay: Duration(milliseconds: index * 100),
          duration: const Duration(milliseconds: 600),
        );
  }
}

class CompactAlertsCard extends StatelessWidget {
  final List<Alert> alerts;
  final VoidCallback? onTap;

  const CompactAlertsCard({
    super.key,
    required this.alerts,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final urgentAlerts = alerts.where((a) => a.isUrgent).length;
    final totalAlerts = alerts.length;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: urgentAlerts > 0 
              ? AppColors.error.withValues(alpha: 0.05)
              : AppColors.success.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: urgentAlerts > 0 
                ? AppColors.error.withValues(alpha: 0.2)
                : AppColors.success.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: urgentAlerts > 0 
                    ? AppColors.error.withValues(alpha: 0.1)
                    : AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                urgentAlerts > 0 
                    ? Icons.warning_rounded
                    : Icons.check_circle_rounded,
                color: urgentAlerts > 0 
                    ? AppColors.error
                    : AppColors.success,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    urgentAlerts > 0 
                        ? '$urgentAlerts pilnych alertów'
                        : 'Brak alertów',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Łącznie: $totalAlerts alertów',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}