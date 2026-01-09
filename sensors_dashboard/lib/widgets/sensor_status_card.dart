import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/color_utils.dart';
import '../models/sensor_reading.dart';
import '../core/utils/platform_utils.dart';
import '../widgets/translated_text.dart';
class SensorStatusCard extends StatelessWidget {
  final SensorReading? reading;
  final String sensorType;
  const SensorStatusCard({
    super.key,
    this.reading,
    required this.sensorType,
  });
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: _getGradient(),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlphaFromOpacity(0.25),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlphaFromOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getIcon(),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  _buildStatusIndicator(),
                ],
              ),
              const SizedBox(height: 16),
              TranslatedText(
                text: _getSensorName(),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withAlphaFromOpacity(0.9),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                useShimmerEffect: false,
              ),
              const SizedBox(height: 8),
              if (reading != null) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: sensorType == AppConstants.motionSensor ?
                        TranslatedText(
                          text: _getCurrentValue(),
                          style: GoogleFonts.inter(
                            fontSize: context.isMobile ? 28 : 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ) :
                        Text(
                          _getCurrentValue(),
                          style: GoogleFonts.inter(
                            fontSize: context.isMobile ? 28 : 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        _getUnit(),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withAlphaFromOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withAlphaFromOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getStatusColor().withAlphaFromOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: TranslatedText(
                        text: reading!.statusText,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        useShimmerEffect: false,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      reading!.formattedTimestamp,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withAlphaFromOpacity(0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ] else ...[
                TranslatedText(
                  text: 'Brak danych',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withAlphaFromOpacity(0.8),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 8),
                TranslatedText(
                  text: 'Czekam na dane z czujnika...',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withAlphaFromOpacity(0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate()
     .fadeIn(duration: const Duration(milliseconds: 600))
     .slideY(begin: 0.1, end: 0)
     .then()
     .shimmer(
       duration: const Duration(milliseconds: 1500),
       colors: [
         Colors.transparent, 
         Colors.white.withAlphaFromOpacity(0.1), 
         Colors.transparent
       ],
     );
  }
  Widget _buildStatusIndicator() {
    if (reading == null) {
      return Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withAlphaFromOpacity(0.5),
        ),
      );
    }
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getStatusColor(),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor().withAlphaFromOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),    ).animate(
      onPlay: (controller) => controller.repeat(reverse: true),
      autoPlay: true, 
    ).scale(
      duration: const Duration(milliseconds: 1000),
      begin: const Offset(0.8, 0.8),
      end: const Offset(1.2, 1.2),
    );
  }
  Gradient _getGradient() {
    switch (sensorType) {
      case AppConstants.temperatureSensor:
        return AppColors.temperatureGradient;
      case AppConstants.humiditySensor:
        return AppColors.humidityGradient;
      case AppConstants.motionSensor:
        return AppColors.motionGradient;
      default:
        return AppColors.primaryGradient;
    }
  }
  IconData _getIcon() {
    switch (sensorType) {
      case AppConstants.temperatureSensor:
        return Icons.thermostat_rounded;
      case AppConstants.humiditySensor:
        return Icons.water_drop_rounded;
      case AppConstants.motionSensor:
        return Icons.directions_run_rounded;
      default:
        return Icons.sensors_rounded;
    }
  }
  String _getSensorName() {
    switch (sensorType) {
      case AppConstants.temperatureSensor:
        return 'Temperatura';
      case AppConstants.humiditySensor:
        return 'Wilgotność';
      case AppConstants.motionSensor:
        return 'Wykrywanie Ruchu';
      default:
        return 'Czujnik';
    }
  }
  String _getCurrentValue() {
    if (reading == null) return '--';
    switch (sensorType) {
      case AppConstants.temperatureSensor:
      case AppConstants.humiditySensor:
        return reading!.value.toStringAsFixed(1);
      case AppConstants.motionSensor:
        return reading!.value == 1.0 ? 'Wykryto' : 'Brak ruchu';
      default:
        return reading!.value.toStringAsFixed(1);
    }
  }
  String _getUnit() {
    switch (sensorType) {
      case AppConstants.temperatureSensor:
        return '°C';
      case AppConstants.humiditySensor:
        return '%';
      case AppConstants.motionSensor:
        return '';
      default:
        return '';
    }
  }
  Color _getStatusColor() {
    if (reading == null) return Colors.grey;
    if (reading!.isCritical) return Colors.red;
    if (reading!.isWarning) return Colors.orange;
    return Colors.green;
  }
}
