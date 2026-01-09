import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/platform_utils.dart';
import '../providers/sensors_provider.dart';
import '../models/alert.dart';
import '../widgets/loading_view.dart';
import '../widgets/translated_text.dart';

class AlertsTab extends StatefulWidget {
  const AlertsTab({super.key});

  @override
  State<AlertsTab> createState() => _AlertsTabState();
}

class _AlertsTabState extends State<AlertsTab> {
  String _selectedCategory = 'wszystkie';
  bool _isLoadingFiltered = false;

  final Map<String, String> _categories = {
    'wszystkie': 'Wszystkie',
    'pilny': 'Pilne',
    'informacyjny': 'Informacyjne',
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<SensorsProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            _buildFiltersSection(provider),
            Expanded(
              child: _buildAlertsList(provider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFiltersSection(SensorsProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(context.responsivePadding),
      child: Column(
        children: [
          _buildSummaryCards(provider, isDark),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TranslatedText(
                text: 'Kategoria',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark ? AppColors.darkDivider : AppColors.divider,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                      _loadFilteredAlerts(provider);
                    }
                  },
                  items: _categories.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: TranslatedText(
                        text: entry.value,
                        style: GoogleFonts.inter(fontSize: 14),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(SensorsProvider provider, bool isDark) {
    final totalAlerts = provider.alerts.length;
    final urgentAlerts = provider.urgentAlerts.length;
    final recentAlerts = provider.recentAlerts.length;

    final summaryItems = [
      _SummaryItem(
        'Łączne Alerty',
        totalAlerts.toString(),
        Icons.warning_rounded,
        AppColors.primary,
      ),
      _SummaryItem(
        'Pilne',
        urgentAlerts.toString(),
        Icons.error_rounded,
        AppColors.error,
      ),
      _SummaryItem(
        'Ostatnie 30 min',
        recentAlerts.toString(),
        Icons.schedule_rounded,
        AppColors.warning,
      ),
    ];

    if (context.isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildSummaryCard(summaryItems[0], isDark)),
              const SizedBox(width: 12),
              Expanded(child: _buildSummaryCard(summaryItems[1], isDark)),
            ],
          ),
          const SizedBox(height: 12),
          _buildSummaryCard(summaryItems[2], isDark),
        ],
      );
    } else {
      return Row(
        children: summaryItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < summaryItems.length - 1 ? 16 : 0),
              child: _buildSummaryCard(item, isDark),
            ),
          );
        }).toList(),
      );
    }
  }

  Widget _buildSummaryCard(_SummaryItem item, bool isDark) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: item.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              item.color.withValues(alpha: 0.08),
              item.color.withValues(alpha: 0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item.icon,
                color: item.color,
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item.value,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: item.color,
              ),
            ),
            const SizedBox(height: 4),
            TranslatedText( // Używamy TranslatedText dla etykiet
              text: item.label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
      delay: Duration(milliseconds: item.label.length * 10),
      duration: const Duration(milliseconds: 600),
    )
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildAlertsList(SensorsProvider provider) {
    final alerts = _getFilteredAlerts(provider);

    if (_isLoadingFiltered) {
      return const CompactLoadingView(
        message: 'Ładowanie alertów...',
      );
    }

    if (alerts.isEmpty) {
      // POPRAWKA: Dodano SingleChildScrollView, aby uniknąć błędu overflow
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.5, // Daje wystarczająco miejsca
          child: _buildEmptyState(),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await provider.forceRefresh();
      },
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: context.responsivePadding, vertical: 8),
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          final alert = alerts[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: _buildAlertCard(alert, index),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.responsivePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Ważne dla layoutu
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                size: 60,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 24),
            TranslatedText(
              text: _selectedCategory == 'wszystkie'
                  ? 'Brak alertów'
                  : 'Brak alertów w kategorii',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (_selectedCategory != 'wszystkie')
              TranslatedText(
                text: _categories[_selectedCategory] ?? '',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 12),
            TranslatedText(
              text: 'Wszystkie systemy monitorowania działają prawidłowo',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<SensorsProvider>().forceRefresh(),
              icon: const Icon(Icons.refresh_rounded),
              label: const TranslatedText(text: 'Odśwież'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 800))
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0));
  }

  Widget _buildAlertCard(Alert alert, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: alert.categoryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        leading: Stack(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: alert.categoryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: alert.categoryColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                alert.typeIcon,
                color: alert.categoryColor,
                size: 24,
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: alert.categoryColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.darkSurface : AppColors.surface,
                    width: 2,
                  ),
                ),
                child: Icon(
                  alert.categoryIcon,
                  color: Colors.white,
                  size: 8,
                ),
              ),
            ),
          ],
        ),
        title: TranslatedText(
          text: _getAlertText(alert),
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: alert.categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TranslatedText(
                    text: alert.categoryDisplayName,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: alert.categoryColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: alert.typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TranslatedText(
                    text: alert.typeDisplayName,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: alert.typeColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 14,
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
                    color: alert.typeColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          _buildAlertDetails(alert, isDark),
        ],
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

  Widget _buildAlertDetails(Alert alert, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alert.categoryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Czas utworzenia', alert.detailedTimestamp, Icons.schedule_rounded),
          const SizedBox(height: 12),
          _buildDetailRow('Priorytet', alert.severityText, Icons.priority_high_rounded),
          const SizedBox(height: 12),
          if (alert.triggerValue != null) ...[
            _buildDetailRow('Wartość wyzwalająca', alert.formattedTriggerValue, Icons.trending_up_rounded),
            const SizedBox(height: 12),
          ],
          if (alert.threshold != null) ...[
            _buildDetailRow('Próg alarmowy', alert.formattedThreshold, Icons.rule_rounded),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        TranslatedText(
          text: label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  List<Alert> _getFilteredAlerts(SensorsProvider provider) {
    List<Alert> alerts = provider.alerts;
    if (_selectedCategory != 'wszystkie') {
      alerts = alerts.where((alert) => alert.category == _selectedCategory).toList();
    }
    return alerts;
  }

  String _getAlertText(Alert alert) {
    // Prefer translation via TranslationService inside TranslatedText widget logic,
    // but pass a reasonable string here
    return alert.original ?? alert.message ?? '';
  }

  Future<void> _loadFilteredAlerts(SensorsProvider provider) async {
    setState(() {
      _isLoadingFiltered = true;
    });

    try {
      await provider.getAlertsByCategory(_selectedCategory);
      setState(() {
        // Filtered alerts are handled by the provider
      });
    } catch (e) {
      debugPrint('Error loading filtered alerts: $e');
    } finally {
      setState(() {
        _isLoadingFiltered = false;
      });
    }
  }
}

class _SummaryItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryItem(this.label, this.value, this.icon, this.color);
}