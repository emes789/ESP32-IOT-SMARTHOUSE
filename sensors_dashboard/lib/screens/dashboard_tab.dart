import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/utils/platform_utils.dart';
import '../providers/sensors_provider.dart';
import '../widgets/sensor_status_card.dart';
import '../widgets/sensor_chart_widget.dart';
import '../widgets/quick_stats_card.dart';
import '../widgets/recent_alerts_card.dart';
import '../widgets/connection_status_card.dart';
import '../widgets/compact_readings_list.dart';
import '../widgets/translated_text.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});
  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  late ScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<SensorsProvider>(
      builder: (context, sensorsProvider, child) {
        return RefreshIndicator(
          onRefresh: sensorsProvider.forceRefresh,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(context.responsivePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopSection(sensorsProvider),
                const SizedBox(height: 20),
                _buildSensorStatusSection(sensorsProvider),
                const SizedBox(height: 24),
                _buildChartsSection(sensorsProvider),
                const SizedBox(height: 24),
                _buildBottomSection(sensorsProvider),
                SizedBox(height: context.isMobile ? 80 : 32),
              ],
            ),
          ),
        );
      },
    );
  }
  Widget _buildTopSection(SensorsProvider provider) {
    if (context.isDesktop) {
      return Row(
        children: [
          Expanded(flex: 2, child: ConnectionStatusCard(provider: provider)),
          const SizedBox(width: 16),
          Expanded(flex: 3, child: QuickStatsCard(provider: provider)),
        ],
      ).animate().fadeIn(duration: const Duration(milliseconds: 600));
    } else {
      return Column(
        children: [
          ConnectionStatusCard(provider: provider),
          const SizedBox(height: 16),
          QuickStatsCard(provider: provider),
        ],
      ).animate().fadeIn(duration: const Duration(milliseconds: 600));
    }
  }
  Widget _buildSensorStatusSection(SensorsProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
      TranslatedText(
        text: 'Status Czujników',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
      const SizedBox(height: 20),
      // Uproszczony widok statusu
      Column(
        children: [
          SensorStatusCard(reading: provider.latestTemperature, sensorType: 'temperature'),
          const SizedBox(height: 12),
          SensorStatusCard(reading: provider.latestHumidity, sensorType: 'humidity'),
          const SizedBox(height: 12),
          SensorStatusCard(reading: provider.latestMotion, sensorType: 'motion'),
        ],
      ),
    ],
    ).animate().fadeIn();
  }
  Widget _buildChartsSection(SensorsProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
      TranslatedText(text: 'Wykresy', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 16),
      SensorChartWidget(title: 'Temperatura', readings: provider.temperatureReadings, sensorType: 'temperature'),
      const SizedBox(height: 16),
      SensorChartWidget(title: 'Wilgotność', readings: provider.humidityReadings, sensorType: 'humidity'),
    ],
    );
  }
  Widget _buildBottomSection(SensorsProvider provider) {
    return Column(
      children: [
        RecentAlertsCard(alerts: provider.recentAlerts),
        const SizedBox(height: 16),
        CompactReadingsList(readings: provider.allReadings.take(8).toList()),
      ],
    );
  }
}