import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/color_utils.dart';
import '../models/sensor_reading.dart';
import '../core/utils/platform_utils.dart';
import '../services/translation_service.dart';
import 'package:provider/provider.dart';
class SensorChartWidget extends StatefulWidget {
  final String title;
  final List<SensorReading> readings;
  final String sensorType;
  final double? height;
  const SensorChartWidget({
    super.key,
    required this.title,
    required this.readings,
    required this.sensorType,
    this.height,
  });
  @override
  State<SensorChartWidget> createState() => _SensorChartWidgetState();
}
class _SensorChartWidgetState extends State<SensorChartWidget> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chartHeight = widget.height ?? context.chartHeight;
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
        height: chartHeight + 100, 
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isDark),
            const SizedBox(height: 20),
            Expanded(
              child: widget.readings.isEmpty
                  ? _buildEmptyState(isDark)
                  : _buildChart(isDark),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideY(begin: 0.1, end: 0);
  }
  Widget _buildHeader(bool isDark) {
    final latest = widget.readings.isNotEmpty ? widget.readings.first : null;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getTypeColor().withAlphaFromOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getTypeIcon(),
            color: _getTypeColor(),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [              Text(
                widget.title, 
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              if (latest != null)
                Text(
                  'Ostatni odczyt: ${latest.formattedValue}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        if (widget.readings.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getTypeColor().withAlphaFromOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${widget.readings.length} punktów',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _getTypeColor(),
              ),
            ),
          ),
      ],
    );
  }
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _getTypeColor().withAlphaFromOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.show_chart_rounded,
              size: 40,
              color: _getTypeColor().withAlphaFromOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),          Text(
            Provider.of<TranslationService>(context).translateTextSync('Brak danych do wyświetlenia'),
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Provider.of<TranslationService>(context).translateTextSync('Wykres zostanie wyświetlony po otrzymaniu danych z czujnika'),
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  Widget _buildChart(bool isDark) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: _getHorizontalInterval(),
          verticalInterval: _getVerticalInterval(),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: isDark ? AppColors.darkDivider : AppColors.divider,
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: isDark ? AppColors.darkDivider : AppColors.divider,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: _getVerticalInterval(),
              getTitlesWidget: (value, meta) => _buildBottomTitle(value, meta, isDark),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _getHorizontalInterval(),
              reservedSize: 50,
              getTitlesWidget: (value, meta) => _buildLeftTitle(value, meta, isDark),
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: isDark ? AppColors.darkDivider : AppColors.divider,
            width: 1,
          ),
        ),
        minX: 0,
        maxX: (widget.readings.length - 1).toDouble(),
        minY: _getMinY(),
        maxY: _getMaxY(),
        lineBarsData: [
          LineChartBarData(
            spots: _getSpots(),
            isCurved: true,
            color: _getTypeColor(),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: false,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: _getTypeColor(),
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  _getTypeColor().withAlphaFromOpacity(0.3),
                  _getTypeColor().withAlphaFromOpacity(0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            shadow: Shadow(
              color: _getTypeColor().withAlphaFromOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
            setState(() {
              if (touchResponse != null && touchResponse.lineBarSpots != null) {
              } else {
              }
            });
          },
          touchTooltipData: LineTouchTooltipData(
            tooltipBorder: BorderSide(
              color: isDark ? AppColors.darkDivider : AppColors.divider,
            ),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final reading = widget.readings[barSpot.spotIndex];
                return LineTooltipItem(
                  '${reading.formattedValue}\n${reading.formattedTimestamp}',
                  GoogleFonts.inter(
                    color: _getTypeColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
      duration: const Duration(milliseconds: 300),
    );
  }
  Widget _buildBottomTitle(double value, TitleMeta meta, bool isDark) {
    if (value.toInt() >= 0 && value.toInt() < widget.readings.length) {
      if (value.toInt() % 5 == 0) {
        return Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            '${widget.readings.length - value.toInt()}',
            style: GoogleFonts.inter(
              color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
              fontSize: 12,
            ),
          ),
        );
      }
    }
    return const SizedBox.shrink();
  }
  Widget _buildLeftTitle(double value, TitleMeta meta, bool isDark) {
    String text;
    switch (widget.sensorType) {
      case AppConstants.temperatureSensor:
        text = '${value.toInt()}°C';
        break;
      case AppConstants.humiditySensor:
        text = '${value.toInt()}%';
        break;
      case AppConstants.motionSensor:
        text = value == 1 ? 'Tak' : 'Nie';
        break;
      default:
        text = value.toStringAsFixed(1);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
          fontSize: 12,
        ),
      ),
    );
  }
  List<FlSpot> _getSpots() {
    List<FlSpot> spots = [];
    for (int i = 0; i < widget.readings.length; i++) {
      final reverseIndex = widget.readings.length - 1 - i;
      spots.add(FlSpot(reverseIndex.toDouble(), widget.readings[i].value));
    }
    return spots;
  }
  double _getMinY() {
    if (widget.readings.isEmpty) return 0;
    if (widget.sensorType == AppConstants.motionSensor) return 0;
    final min = widget.readings.map((r) => r.value).reduce((a, b) => a < b ? a : b);
    return (min - (min * 0.1)).floorToDouble();
  }
  double _getMaxY() {
    if (widget.readings.isEmpty) return 100;
    if (widget.sensorType == AppConstants.motionSensor) return 1;
    final max = widget.readings.map((r) => r.value).reduce((a, b) => a > b ? a : b);
    return (max + (max * 0.1)).ceilToDouble();
  }
  double _getHorizontalInterval() {
    if (widget.readings.isEmpty) return 10;
    final range = _getMaxY() - _getMinY();
    if (range <= 10) return 2;
    if (range <= 50) return 10;
    if (range <= 100) return 20;
    return 50;
  }
  double _getVerticalInterval() {
    if (widget.readings.isEmpty) return 10;
    return (widget.readings.length / 5).ceilToDouble();
  }
  Color _getTypeColor() {
    switch (widget.sensorType) {
      case AppConstants.temperatureSensor:
        return AppColors.temperature;
      case AppConstants.humiditySensor:
        return AppColors.humidity;
      case AppConstants.motionSensor:
        return AppColors.motion;
      default:
        return AppColors.primary;
    }
  }
  IconData _getTypeIcon() {
    switch (widget.sensorType) {
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
}
