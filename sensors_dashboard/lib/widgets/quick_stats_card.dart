import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/platform_utils.dart';
import '../providers/sensors_provider.dart';

class QuickStatsCard extends StatelessWidget {
  final SensorsProvider provider;
  const QuickStatsCard({
    super.key,
    required this.provider,
  });
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stats = provider.statistics;
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
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.analytics_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Szybkie Statystyki',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Podsumowanie danych z czujników',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (stats.lastUpdateTime != null)
                  Text(
                    'Aktualizacja: ${_formatTime(stats.lastUpdateTime!)}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            if (context.isMobile)
              _buildMobileLayout(isDark, stats)
            else
              _buildDesktopLayout(isDark, stats),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideY(begin: 0.1, end: 0);
  }
  
  // Fix: Updated to take SensorStatistics type
  Widget _buildMobileLayout(bool isDark, SensorStatistics stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatItem(
              'Odczyty',
              '${stats.totalReadings}',
              Icons.sensors_rounded,
              AppColors.primary,
              isDark,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildStatItem(
              'Alerty',
              // Using map-like access or direct getter if available in future updates to stats
              '${stats['criticalAlertsCount'] ?? 0}',
              Icons.warning_rounded,
              AppColors.error,
              isDark,
            )),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatItem(
              'Śr. Temp.',
              '${(stats.avgTemperature).toStringAsFixed(1)}°C',
              Icons.thermostat_rounded,
              AppColors.temperature,
              isDark,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildStatItem(
              'Śr. Wilg.',
              '${(stats.avgHumidity).toStringAsFixed(1)}%',
              Icons.water_drop_rounded,
              AppColors.humidity,
              isDark,
            )),
          ],
        ),
      ],
    );
  }
  
  // Fix: Updated to take SensorStatistics type
  Widget _buildDesktopLayout(bool isDark, SensorStatistics stats) {
    return Row(
      children: [
        Expanded(child: _buildStatItem(
          'Łączne Odczyty',
          '${stats.totalReadings}',
          Icons.sensors_rounded,
          AppColors.primary,
          isDark,
        )),
        const SizedBox(width: 16),
        Expanded(child: _buildStatItem(
          'Krytyczne Alerty',
          '${stats['criticalAlertsCount'] ?? 0}',
          Icons.warning_rounded,
          AppColors.error,
          isDark,
        )),
        const SizedBox(width: 16),
        Expanded(child: _buildStatItem(
          'Średnia Temperatura',
          '${(stats.avgTemperature).toStringAsFixed(1)}°C',
          Icons.thermostat_rounded,
          AppColors.temperature,
          isDark,
        )),
        const SizedBox(width: 16),
        Expanded(child: _buildStatItem(
          'Średnia Wilgotność',
          '${(stats.avgHumidity).toStringAsFixed(1)}%',
          Icons.water_drop_rounded,
          AppColors.humidity,
          isDark,
        )),
      ],
    );
  }
  
  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),              )
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                    autoPlay: true, 
                  )
                  .scale(
                    duration: const Duration(milliseconds: 1000),
                    begin: Offset(0.7, 0.7),
                    end: Offset(1.3, 1.3),
                  ),
            ],
          ),
          const SizedBox(height: 12),          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: _getAnimationDelay(label)),
          duration: const Duration(milliseconds: 600),
        )
        .slideY(begin: 0.2, end: 0);
  }
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
  int _getAnimationDelay(String label) {
    switch (label) {
      case 'Łączne Odczyty':
      case 'Odczyty':
        return 0;
      case 'Krytyczne Alerty':
      case 'Alerty':
        return 100;
      case 'Średnia Temperatura':
      case 'Śr. Temp.':
        return 200;
      case 'Średnia Wilgotność':
      case 'Śr. Wilg.':
        return 300;
      default:
        return 0;
    }
  }
}