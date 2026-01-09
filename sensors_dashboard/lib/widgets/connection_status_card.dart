import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/platform_utils.dart';
import '../core/utils/color_utils.dart';
import '../providers/sensors_provider.dart';
class ConnectionStatusCard extends StatelessWidget {
  final SensorsProvider provider;
  const ConnectionStatusCard({
    super.key,
    required this.provider,
  });
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasConnection = provider.hasInternetConnection;
    final isLoaded = provider.isLoaded;
    final isLoading = provider.isLoading;
    final hasError = provider.hasError;
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: _getStatusGradient(hasConnection, isLoaded, hasError),
        ),
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
                    _getStatusIcon(hasConnection, isLoaded, hasError, isLoading),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const Spacer(),
                _buildStatusIndicator(hasConnection, isLoaded, hasError, isLoading),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _getStatusTitle(hasConnection, isLoaded, hasError, isLoading),
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getStatusDescription(hasConnection, isLoaded, hasError, isLoading),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withAlphaFromOpacity(0.9),
              ),
            ),
            const SizedBox(height: 16),
            _buildConnectionDetails(hasConnection, isLoaded, isDark),
            if (hasError) ...[
              const SizedBox(height: 16),
              _buildErrorActions(context),
            ],
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideY(begin: 0.1, end: 0);
  }
  Widget _buildStatusIndicator(bool hasConnection, bool isLoaded, bool hasError, bool isLoading) {
    Color color;
    if (hasError) {
      color = Colors.red;
    } else if (isLoading) {
      color = Colors.orange;
    } else if (hasConnection && isLoaded) {
      color = Colors.green;
    } else {
      color = Colors.red;
    }
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withAlphaFromOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),    )
        .animate(
          onPlay: (controller) => controller.repeat(reverse: true),
          autoPlay: true, 
        )
        .scale(
          duration: const Duration(milliseconds: 1000),
          begin: Offset(0.8, 0.8),
          end: Offset(1.2, 1.2),
        );
  }
  Widget _buildConnectionDetails(bool hasConnection, bool isLoaded, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withAlphaFromOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withAlphaFromOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            'Internet',
            hasConnection ? 'Połączono' : 'Brak połączenia',
            hasConnection ? Icons.wifi_rounded : Icons.wifi_off_rounded,
            hasConnection ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            'MongoDB',
            isLoaded ? 'Połączono' : 'Brak połączenia',
            isLoaded ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
            isLoaded ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            'Platforma',
            PlatformUtils.platformName,
            _getPlatformIcon(),
            Colors.blue,
          ),
        ],
      ),
    );
  }
  Widget _buildDetailRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white.withAlphaFromOpacity(0.8),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
  Widget _buildErrorActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              PlatformUtils.hapticFeedback();
              provider.retry();
            },
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Ponów'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withAlphaFromOpacity(0.2),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              PlatformUtils.hapticFeedback();
              provider.clearError();
            },
            icon: const Icon(Icons.clear_rounded, size: 16),
            label: const Text('Zamknij'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withAlphaFromOpacity(0.1),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: Colors.white.withAlphaFromOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  Gradient _getStatusGradient(bool hasConnection, bool isLoaded, bool hasError) {
    if (hasError) {
      return const LinearGradient(
        colors: [AppColors.error, Color(0xFFD32F2F)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (hasConnection && isLoaded) {
      return const LinearGradient(
        colors: [AppColors.success, Color(0xFF388E3C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      return const LinearGradient(
        colors: [AppColors.warning, Color(0xFFF57C00)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }
  IconData _getStatusIcon(bool hasConnection, bool isLoaded, bool hasError, bool isLoading) {
    if (hasError) {
      return Icons.error_rounded;
    } else if (isLoading) {
      return Icons.sync_rounded;
    } else if (hasConnection && isLoaded) {
      return Icons.check_circle_rounded;
    } else {
      return Icons.warning_rounded;
    }
  }
  String _getStatusTitle(bool hasConnection, bool isLoaded, bool hasError, bool isLoading) {
    if (hasError) {
      return 'Błąd Połączenia';
    } else if (isLoading) {
      return 'Łączenie...';
    } else if (hasConnection && isLoaded) {
      return 'System Online';
    } else {
      return 'System Offline';
    }
  }
  String _getStatusDescription(bool hasConnection, bool isLoaded, bool hasError, bool isLoading) {
    if (hasError) {
      return 'Wystąpił problem z połączeniem do systemu monitorowania';
    } else if (isLoading) {
      return 'Nawiązywanie połączenia z serwerami';
    } else if (hasConnection && isLoaded) {
      return 'Wszystkie systemy działają prawidłowo';
    } else if (!hasConnection) {
      return 'Brak połączenia z internetem';
    } else {
      return 'Problem z połączeniem do serwera';
    }
  }
  IconData _getPlatformIcon() {
    if (PlatformUtils.isWeb) return Icons.web_rounded;
    if (PlatformUtils.isAndroid) return Icons.android_rounded;
    if (PlatformUtils.isIOS) return Icons.phone_iphone_rounded;
    if (PlatformUtils.isWindows) return Icons.desktop_windows_rounded;
    if (PlatformUtils.isMacOS) return Icons.laptop_mac_rounded;
    return Icons.devices_rounded;
  }
}
