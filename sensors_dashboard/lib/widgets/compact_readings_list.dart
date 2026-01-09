import 'package:flutter/material.dart';
import '../core/utils/color_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/platform_utils.dart';
import '../models/sensor_reading.dart';
import '../widgets/translated_text.dart';
class CompactReadingsList extends StatelessWidget {
  final List<SensorReading> readings;
  final VoidCallback? onSeeAll;
  final String? title;
  final int maxItems;
  const CompactReadingsList({
    super.key,
    required this.readings,
    this.onSeeAll,
    this.title,
    this.maxItems = 10,
  });
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayedReadings = readings.take(maxItems).toList();
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
            _buildHeader(isDark),
            const SizedBox(height: 20),
            if (displayedReadings.isEmpty)
              _buildEmptyState(isDark)
            else
              _buildReadingsList(displayedReadings, isDark),
          ],
        ),
      ),
    ).animate()
      .fadeIn(duration: const Duration(milliseconds: 600))
      .slideY(begin: 0.1, end: 0);
  }
  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlphaFromOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.timeline_rounded,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TranslatedText(
                text: title ?? 'Ostatnie Odczyty',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Builder(
                builder: (context) {
                  final readingsCount = readings.length;
                  final text = readings.isEmpty ? 'Brak danych' : '$readingsCount odczytów';
                  return TranslatedText(
                    text: text,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  );
                }
              ),
            ],
          ),
        ),
        if (readings.length > maxItems && onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: TranslatedText(
              text: 'Zobacz wszystkie',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
              overflow: TextOverflow.ellipsis,
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
              color: AppColors.primary.withAlphaFromOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sensors_off_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          TranslatedText(
            text: 'Brak odczytów',
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
            text: 'Czekamy na dane z czujników IoT',
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
    ).animate()
      .fadeIn(duration: const Duration(milliseconds: 800))
      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0));
  }
  Widget _buildReadingsList(List<SensorReading> displayedReadings, bool isDark) {
    return Column(
      children: displayedReadings.asMap().entries.map((entry) {
        final index = entry.key;
        final reading = entry.value;
        return Container(
          margin: EdgeInsets.only(bottom: index < displayedReadings.length - 1 ? 8 : 0),
          child: _buildReadingItem(reading, isDark, index),
        );
      }).toList(),
    );
  }
  Widget _buildReadingItem(SensorReading reading, bool isDark, int index) {
    return InkWell(
      onTap: () => PlatformUtils.hapticFeedback(),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: reading.typeColor.withAlphaFromOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: reading.typeColor.withAlphaFromOpacity(0.1),
            width: 1,
          ),
        ),          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: reading.typeColor.withAlphaFromOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  reading.typeIcon,
                  color: reading.typeColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [                  
                    Row(
                      children: [
                        Flexible(
                          flex: 3,
                          child: TranslatedText(
                            text: reading.typeDisplayName,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: reading.statusColor.withAlphaFromOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: TranslatedText(
                            text: reading.statusText,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: reading.statusColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),                  
                    Row(
                      children: [
                        Flexible(
                          flex: 2,
                          child: TranslatedText(
                            text: 'Sensor: ${reading.sensorId}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          reading.formattedTimestamp,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              constraints: const BoxConstraints(minWidth: 65),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    reading.formattedValue,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: reading.typeColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: reading.statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(
        delay: Duration(milliseconds: index * 50),
        duration: const Duration(milliseconds: 400),
      )
      .slideX(
        begin: 0.2,
        end: 0,
        delay: Duration(milliseconds: index * 50),
        duration: const Duration(milliseconds: 400),
      );
  }
}
