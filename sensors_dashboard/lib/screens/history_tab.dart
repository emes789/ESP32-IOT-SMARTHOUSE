import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/platform_utils.dart';
import '../providers/sensors_provider.dart';
import '../widgets/sensor_chart_widget.dart';
import '../widgets/loading_view.dart';
import '../widgets/filterable_readings_list.dart';
import '../models/sensor_reading.dart';
import '../services/translation_service.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});
  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = '24h';
  String _selectedSensorType = 'all';
  bool _isLoadingHistorical = false;
  List<SensorReading> _historicalData = [];
  
  final Map<String, String> _periods = {
    '1h': 'Ostatnia godzina',
    '24h': 'Ostatnie 24h',
    '7d': 'Ostatni tydzień',
    '30d': 'Ostatni miesiąc',
  };
  
  final Map<String, String> _sensorTypes = {
    'all': 'Wszystkie czujniki',
    'temperature': 'Temperatura',
    'humidity': 'Wilgotność',
    'motion': 'Ruch',
  };
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<SensorsProvider>(
      builder: (context, sensorsProvider, child) {
        return Column(
          children: [
            _buildTabBar(context),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildChartsView(sensorsProvider),
                  _buildDataView(sensorsProvider),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildTabBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(context.responsivePadding),
      child: Column(
        children: [
          _buildPeriodSelector(isDark),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                width: 1,
              ),
            ),            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              labelColor: Colors.white,
              unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              padding: const EdgeInsets.all(3),              tabs: [
                Tab(
                  icon: Icon(Icons.show_chart, size: 18),
                  text: Provider.of<TranslationService>(context).translateTextSync('Wykresy'),
                  height: 54,
                  iconMargin: EdgeInsets.zero,
                ),
                Tab(
                  icon: Icon(Icons.table_chart_outlined, size: 18),
                  text: Provider.of<TranslationService>(context).translateTextSync('Dane'),
                  height: 54,
                  iconMargin: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPeriodSelector(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _periods.entries.map((entry) {
          final isSelected = _selectedPeriod == entry.key;          final translatedLabel = Provider.of<TranslationService>(context).translateTextSync(entry.value);
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(translatedLabel),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedPeriod = entry.key;
                  });
                  _loadHistoricalData();
                }
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
              labelStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildChartsView(SensorsProvider provider) {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadHistoricalData();
        await provider.forceRefresh();
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(context.responsivePadding),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChartsSummaryCard(provider),
            const SizedBox(height: 24),
            if (provider.temperatureReadings.isNotEmpty)
              SensorChartWidget(
                title: Provider.of<TranslationService>(context).translateTextSync('Historia Temperatury'),
                readings: provider.temperatureReadings,
                sensorType: AppConstants.temperatureSensor,
                height: context.chartHeight,
              )
                  .animate()
                  .fadeIn(duration: const Duration(milliseconds: 600))
                  .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 16),
            if (provider.humidityReadings.isNotEmpty)
              SensorChartWidget(
                title: Provider.of<TranslationService>(context).translateTextSync('Historia Wilgotności'),
                readings: provider.humidityReadings,
                sensorType: AppConstants.humiditySensor,
                height: context.chartHeight,
              )
                  .animate()
                  .fadeIn(
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 600),
                  )
                  .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 16),
            if (provider.motionReadings.isNotEmpty)
              SensorChartWidget(
                title: Provider.of<TranslationService>(context).translateTextSync('Historia Ruchu'),
                readings: provider.motionReadings,
                sensorType: AppConstants.motionSensor,
                height: context.chartHeight * 0.7, 
              )
                  .animate()
                  .fadeIn(
                    delay: const Duration(milliseconds: 400),
                    duration: const Duration(milliseconds: 600),
                  )
                  .slideY(begin: 0.1, end: 0),
            SizedBox(height: context.isMobile ? 100 : 32),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDataView(SensorsProvider provider) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: context.responsivePadding),
          child: _buildSensorTypeFilter(),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await provider.forceRefresh();
            },            child: _isLoadingHistorical
                ? CompactLoadingView(
                    message: Provider.of<TranslationService>(context).translateTextSync('Ładowanie danych historycznych...'),
                  )
                : FilterableReadingsList(
                    readings: _getFilteredReadings(provider),
                    onFilterChanged: (filter) {
                      setState(() {
                        _selectedSensorType = filter;
                      });
                    },
                  ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildChartsSummaryCard(SensorsProvider provider) {
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
                        'Podsumowanie ${_periods[_selectedPeriod]}',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${stats.totalReadings} odczytów z czujników',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildStatsGrid(stats, isDark),
          ],
        ),
      ),
    );
  }
  
  // Fix: Updated to take SensorStatistics type
  Widget _buildStatsGrid(SensorStatistics stats, bool isDark) {
    final items = [
      _StatItem(
        'Średnia temperatura',
        '${(stats.avgTemperature).toStringAsFixed(1)}°C',
        Icons.thermostat_rounded,
        AppColors.temperature,
      ),
      _StatItem(
        'Średnia wilgotność',
        '${(stats.avgHumidity).toStringAsFixed(1)}%',
        Icons.water_drop_rounded,
        AppColors.humidity,
      ),
      _StatItem(
        'Min. temperatura',
        '${(stats.minTemperature).toStringAsFixed(1)}°C',
        Icons.trending_down_rounded,
        AppColors.info,
      ),
      _StatItem(
        'Max. temperatura',
        '${(stats.maxTemperature).toStringAsFixed(1)}°C',
        Icons.trending_up_rounded,
        AppColors.error,
      ),
    ];
    
    if (context.isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildStatCard(items[0], isDark)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard(items[1], isDark)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard(items[2], isDark)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard(items[3], isDark)),
            ],
          ),
        ],
      );
    } else {
      return Row(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < items.length - 1 ? 12 : 0),
              child: _buildStatCard(item, isDark),
            ),
          );
        }).toList(),
      );
    }
  }
  
  Widget _buildStatCard(_StatItem item, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: item.color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            item.icon,
            color: item.color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            item.value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: item.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSensorTypeFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _sensorTypes.entries.map((entry) {
          final isSelected = _selectedSensorType == entry.key;          final translatedLabel = Provider.of<TranslationService>(context).translateTextSync(entry.value);
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(translatedLabel),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedSensorType = entry.key;
                  });
                }
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
            ),
          );
        }).toList(),
      ),
    );
  }
  
  List<SensorReading> _getFilteredReadings(SensorsProvider provider) {
    List<SensorReading> allReadings = provider.allReadings;
    if (_selectedSensorType != 'all') {
      allReadings = allReadings.where((reading) => reading.type == _selectedSensorType).toList();
    }
    final now = DateTime.now();
    DateTime cutoffTime;
    switch (_selectedPeriod) {
      case '1h':
        cutoffTime = now.subtract(const Duration(hours: 1));
        break;
      case '24h':
        cutoffTime = now.subtract(const Duration(hours: 24));
        break;
      case '7d':
        cutoffTime = now.subtract(const Duration(days: 7));
        break;
      case '30d':
        cutoffTime = now.subtract(const Duration(days: 30));
        break;
      default:
        cutoffTime = now.subtract(const Duration(hours: 24));
    }
    return allReadings.where((reading) => reading.timestamp.isAfter(cutoffTime)).toList();
  }
  
  Future<void> _loadHistoricalData() async {
    setState(() {
      _isLoadingHistorical = true;
    });
    try {
      final provider = Provider.of<SensorsProvider>(context, listen: false);
      final now = DateTime.now();
      DateTime startDate;
      switch (_selectedPeriod) {
        case '1h':
          startDate = now.subtract(const Duration(hours: 1));
          break;
        case '24h':
          startDate = now.subtract(const Duration(hours: 24));
          break;
        case '7d':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case '30d':
          startDate = now.subtract(const Duration(days: 30));
          break;
        default:
          startDate = now.subtract(const Duration(hours: 24));
      }
      final futures = [
        provider.getHistoricalData(AppConstants.temperatureSensor, startDate, now),
        provider.getHistoricalData(AppConstants.humiditySensor, startDate, now),
        provider.getHistoricalData(AppConstants.motionSensor, startDate, now),
      ];
      final results = await Future.wait(futures);
      setState(() {
        _historicalData = [
          ...results[0], 
          ...results[1], 
          ...results[2], 
        ];
        _historicalData.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      });
    } catch (e) {
      debugPrint('Error loading historical data: $e');
    } finally {
      setState(() {
        _isLoadingHistorical = false;
      });
    }
  }
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatItem(this.label, this.value, this.icon, this.color);
}