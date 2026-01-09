import 'package:flutter/material.dart';
import '../core/utils/color_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../models/sensor_reading.dart';
import '../widgets/translated_text.dart';
class FilterableReadingsList extends StatefulWidget {
  final List<SensorReading> readings;
  final Function(String) onFilterChanged;
  const FilterableReadingsList({
    super.key,
    required this.readings,
    required this.onFilterChanged,
  });
  @override
  State<FilterableReadingsList> createState() => _FilterableReadingsListState();
}
class _FilterableReadingsListState extends State<FilterableReadingsList> {
  String _selectedFilter = 'all';
  final List<Map<String, dynamic>> _filters = [
    {'id': 'all', 'label': 'Wszystkie', 'icon': Icons.sensors_rounded},
    {'id': 'temperature', 'label': 'Temperatura', 'icon': Icons.thermostat_rounded},
    {'id': 'humidity', 'label': 'Wilgotność', 'icon': Icons.water_drop_rounded},
    {'id': 'motion', 'label': 'Ruch', 'icon': Icons.directions_run_rounded},
  ];
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    selected: isSelected,
                    selectedColor: AppColors.primary.withAlphaFromOpacity(0.2),
                    backgroundColor: isDark ? AppColors.darkSurfaceVariant : Colors.grey[200],
                    checkmarkColor: AppColors.primary,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                    avatar: Icon(
                      filter['icon'],
                      size: 18,
                      color: isSelected
                          ? AppColors.primary
                          : isDark ? Colors.white70 : Colors.grey[700],
                    ),
                    label: TranslatedText(
                      text: filter['label'],
                      style: GoogleFonts.inter(
                        color: isSelected
                            ? AppColors.primary
                            : isDark ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedFilter = filter['id'];
                        });
                        widget.onFilterChanged(filter['id']);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Expanded(
          child: widget.readings.isEmpty
              ? _buildEmptyState(isDark)
              : _buildReadingsList(isDark),
        ),
      ],
    );
  }
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          TranslatedText(
            text: 'Brak wyników dla wybranego filtra',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          TranslatedText(
            text: 'Spróbuj zmienić filtr lub zakres czasowy',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  Widget _buildReadingsList(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: widget.readings.length,
      itemBuilder: (context, index) {
        final reading = widget.readings[index];
        return _buildReadingItem(reading, isDark, index);
      },
    );
  }
  Widget _buildReadingItem(SensorReading reading, bool isDark, int index) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: reading.typeColor.withAlphaFromOpacity(0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: reading.typeColor.withAlphaFromOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            reading.typeIcon,
            color: reading.typeColor,
            size: 20,
          ),
        ),        title: TranslatedText(
          text: reading.typeDisplayName,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          reading.formattedTimestamp,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          constraints: const BoxConstraints(minWidth: 80),
          decoration: BoxDecoration(
            color: reading.typeColor.withAlphaFromOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            reading.formattedValue,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: reading.typeColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    ).animate()
      .fadeIn(
        delay: Duration(milliseconds: index * 30),
        duration: const Duration(milliseconds: 300),
      )
      .slideX(
        begin: 0.1,
        end: 0,
        delay: Duration(milliseconds: index * 30),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
  }
}
