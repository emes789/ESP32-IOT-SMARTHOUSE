import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/platform_utils.dart';
import '../providers/theme_provider.dart';
import '../services/translation_service.dart';
import '../widgets/translated_text.dart';
import './device_setup_screen.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  int _refreshInterval = 30;
  
  // Controllers for WiFi dialog
  final TextEditingController _wifiSsidController = TextEditingController();
  final TextEditingController _wifiPassController = TextEditingController();

  @override
  void dispose() {
    _wifiSsidController.dispose();
    _wifiPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.responsivePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildDeviceConnectionSection(), // Nowa sekcja WiFi/BT
            const SizedBox(height: 20),
            _buildAppearanceSection(),       // Sekcja wyglądu i języka
            const SizedBox(height: 20),
            _buildNotificationsSection(),
            const SizedBox(height: 20),
            _buildDataSection(),
            const SizedBox(height: 20),
            _buildAboutSection(),
            const SizedBox(height: 100), // Padding na dole
          ],
        ),
      ),
    );
  }

  // --- SEKCJ 1: PROFIL ---
  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Icon(Icons.person_rounded, size: 32, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Systemu',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Online',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  // --- SEKCJA 2: URZĄDZENIA (WiFi + Bluetooth) ---
  Widget _buildDeviceConnectionSection() {
    return _buildSectionContainer(
      title: 'Konfiguracja Urządzeń',
      icon: Icons.router_rounded,
      color: AppColors.info,
      children: [
        _buildActionTile(
          title: 'Dodaj nowe urządzenie',
          subtitle: 'Skonfiguruj przez WiFi lub Bluetooth',
          icon: Icons.add_link_rounded,
          onTap: () => _showConnectionDialog(context),
        ),
        const Divider(height: 1),
        _buildActionTile(
          title: 'Zarządzaj czujnikami',
          subtitle: 'Kalibracja i ustawienia sensorów',
          icon: Icons.tune_rounded,
          onTap: () {},
        ),
      ],
    );
  }

  // --- SEKCJA 3: WYGLĄD I JĘZYK ---
  Widget _buildAppearanceSection() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return _buildSectionContainer(
          title: 'Wygląd i Język',
          icon: Icons.palette_rounded,
          color: AppColors.primary,
          children: [
            _buildThemeToggle(themeProvider),
            const Divider(height: 1),
            _buildLanguageTile(),
          ],
        );
      },
    );
  }

  // --- POZOSTAŁE SEKCJE ---
  Widget _buildNotificationsSection() {
    return _buildSectionContainer(
      title: 'Powiadomienia',
      icon: Icons.notifications_rounded,
      color: AppColors.warning,
      children: [
        _buildSwitchTile(
          'Powiadomienia Push',
          'Alerty w czasie rzeczywistym',
          _notificationsEnabled,
          (val) => setState(() => _notificationsEnabled = val),
        ),
        const Divider(height: 1),
        _buildSwitchTile(
          'Dźwięki',
          'Sygnał dźwiękowy przy alercie',
          _soundEnabled,
          (val) => setState(() => _soundEnabled = val),
        ),
      ],
    );
  }

  Widget _buildDataSection() {
    return _buildSectionContainer(
      title: 'Dane i Synchronizacja',
      icon: Icons.sync_rounded,
      color: AppColors.success,
      children: [
        ListTile(
          title: const TranslatedText(text: 'Interwał odświeżania'),
          subtitle: Text('${_refreshInterval}s', style: GoogleFonts.inter(color: AppColors.textSecondary)),
          trailing: SizedBox(
            width: 120,
            child: Slider(
              value: _refreshInterval.toDouble(),
              min: 10,
              max: 120,
              divisions: 11,
              activeColor: AppColors.success,
              onChanged: (val) => setState(() => _refreshInterval = val.round()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _buildSectionContainer(
      title: 'O Aplikacji',
      icon: Icons.info_outline_rounded,
      color: AppColors.secondary,
      children: [
        _buildInfoTile('Wersja', AppConstants.appVersion),
        const Divider(height: 1),
        _buildActionTile(
          title: 'Sprawdź aktualizacje',
          subtitle: 'Ostatnie sprawdzenie: Dzisiaj',
          icon: Icons.system_update_rounded,
          onTap: () {},
        ),
      ],
    );
  }

  // --- ELEMENTY UI ---

  Widget _buildSectionContainer({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              TranslatedText(
                text: title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.darkDivider : AppColors.divider,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildActionTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: isDark ? Colors.white : AppColors.textPrimary, size: 20),
      ),
      title: TranslatedText(
        text: title,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null ? TranslatedText(
        text: subtitle,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
      ) : null,
      trailing: Icon(Icons.chevron_right_rounded, color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary),
    );
  }

  Widget _buildThemeToggle(ThemeProvider themeProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      onTap: () => themeProvider.toggleTheme(),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          themeProvider.currentThemeIcon,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: const TranslatedText(text: 'Ciemny motyw'),
      trailing: Switch(
        value: isDark,
        activeThumbColor: AppColors.primary,
        onChanged: (_) => themeProvider.toggleTheme(),
      ),
    );
  }

  Widget _buildLanguageTile() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLang = Provider.of<TranslationService>(context).currentLanguage;
    
    return ListTile(
      onTap: () => _showLanguageDialog(context),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.language_rounded, color: AppColors.secondary, size: 20),
      ),
      title: const TranslatedText(text: 'Język aplikacji'),
      subtitle: Text(
        AppConstants.languageNames[currentLang] ?? 'Polski',
        style: GoogleFonts.inter(
          fontSize: 12,
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return ListTile(
      title: TranslatedText(text: title, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
      subtitle: TranslatedText(text: subtitle, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
      trailing: Switch(
        value: value,
        activeThumbColor: AppColors.warning,
        onChanged: onChanged,
      ),
    );
  }
  
  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      title: TranslatedText(text: title),
      trailing: Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
    );
  }

  // --- DIALOGI ---

  void _showConnectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DefaultTabController(
        length: 2,
        child: AlertDialog(
          title: const TranslatedText(text: 'Połącz urządzenie'),
          content: SizedBox(
            height: 300,
            width: 300,
            child: Column(
              children: [
                const TabBar(
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(icon: Icon(Icons.wifi), text: "WiFi"),
                    Tab(icon: Icon(Icons.bluetooth), text: "Bluetooth"),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TabBarView(
                    children: [
                      // WiFi Tab
                      Column(
                        children: [
                          TextField(
                            controller: _wifiSsidController,
                            decoration: const InputDecoration(
                              labelText: 'Nazwa sieci (SSID)',
                              prefixIcon: Icon(Icons.wifi),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _wifiPassController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Hasło',
                              prefixIcon: Icon(Icons.lock_outline),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: TranslatedText(text: 'Próba połączenia przez WiFi...')),
                                );
                              },
                              child: const TranslatedText(text: 'Połącz'),
                            ),
                          ),
                        ],
                      ),
                      // Bluetooth Tab
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.bluetooth_searching, size: 60, color: AppColors.info),
                          const SizedBox(height: 16),
                          const TranslatedText(text: 'Konfiguracja przez Bluetooth'),
                          const SizedBox(height: 8),
                          Text(
                            'Podłącz urządzenie ESP32 i skonfiguruj WiFi',
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const DeviceSetupScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.bluetooth),
                              label: const TranslatedText(text: 'Skanuj urządzenia BLE'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.info,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final translationService = Provider.of<TranslationService>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TranslatedText(
                text: 'Wybierz język',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...AppConstants.languageNames.entries.map((entry) {
                return ListTile(
                  leading: Text(
                    _getFlag(entry.key),
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(entry.value),
                  trailing: translationService.currentLanguage == entry.key
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    translationService.changeLanguage(entry.key);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  String _getFlag(String code) {
    switch (code) {
      case 'pl': return '🇵🇱';
      case 'en': return '🇬🇧';
      case 'es': return '🇪🇸';
      case 'de': return '🇩🇪';
      case 'fr': return '🇫🇷';
      default: return '🏳️';
    }
  }
}