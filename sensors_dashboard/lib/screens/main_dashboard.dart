import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/platform_utils.dart';
import '../providers/sensors_provider.dart';
import '../providers/theme_provider.dart';
import '../services/translation_service.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/demo_mode_indicator.dart';
import '../widgets/data_source_indicator.dart';
import 'dashboard_tab.dart';
import 'history_tab.dart';
import 'alerts_tab.dart' as alerts_page; // Alias to prevent naming conflicts
import 'settings_tab.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;
  late PageController _pageController;
  
  static const List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.dashboard_rounded,
      selectedIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    NavigationItem(
      icon: Icons.history_rounded,
      selectedIcon: Icons.history_rounded,
      label: 'Historia',
    ),
    NavigationItem(
      icon: Icons.warning_rounded,
      selectedIcon: Icons.warning_rounded,
      label: 'Alerty',
    ),
    NavigationItem(
      icon: Icons.settings_rounded,
      selectedIcon: Icons.settings_rounded,
      label: 'Ustawienia',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      
      // Haptic feedback on mobile
      PlatformUtils.hapticFeedback();
    }
  }

  void _onPageChanged(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SensorsProvider, ThemeProvider>(
      builder: (context, sensorsProvider, themeProvider, child) {
        // Handle loading and error states
        if (sensorsProvider.isLoading) {
          return const LoadingView();
        }

        if (sensorsProvider.hasError) {
          return ErrorView(
            message: sensorsProvider.errorMessage ?? 'Wystąpił nieznany błąd',
            onRetry: sensorsProvider.retry,
          );
        }

        return Scaffold(
          body: Row(
            children: [
              // Navigation Rail for desktop
              if (context.isDesktop)
                _buildNavigationRail(themeProvider.isCurrentlyDark(context)),
              
              // Main content
              Expanded(
                child: Column(
                  children: [
                    // App Bar
                    _buildAppBar(context, themeProvider.isCurrentlyDark(context)),
                    
                    // Page content
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: _onPageChanged,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          DashboardTab(key: const ValueKey('dashboard')),
                          HistoryTab(key: const ValueKey('history')),
                          alerts_page.AlertsTab(key: const ValueKey('alerts')), // Use explicit alias
                          SettingsTab(key: const ValueKey('settings')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Bottom Navigation for mobile/tablet
          bottomNavigationBar: _buildBottomNavigationBar(themeProvider.isCurrentlyDark(context)),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    // Removed fixed height to prevent overflow. Container will size itself to fit content.
    return Container(
      padding: EdgeInsets.only(
        top: PlatformUtils.getStatusBarHeight(context) + 8, // Ensure dynamic status bar clearance + spacing
        left: context.responsivePadding,
        right: context.responsivePadding,
        bottom: 12, // Comfortable bottom padding
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkDivider : AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Title and subtitle
          Expanded(
            flex: 3, // Give more space to the title
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FutureBuilder<String>(
                  future: Provider.of<TranslationService>(context).translateText(_getPageTitle()),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ?? _getPageTitle(),
                      style: GoogleFonts.inter(
                        fontSize: context.isMobile ? 18 : 20, // Slightly smaller title
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    );
                  }
                ),
                if (_getPageSubtitle() != null) ...[
                  const SizedBox(height: 2),
                  FutureBuilder<String>(
                    future: Provider.of<TranslationService>(context).translateText(_getPageSubtitle()!),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? _getPageSubtitle()!,
                        style: GoogleFonts.inter(
                          fontSize: 12, // Reduced subtitle
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      );
                    }
                  ),
                ],
              ],
            ),
          ),
          
          // Connection status, data source and demo mode
          Flexible(
            flex: 2, // Less space than title
            child: Consumer<SensorsProvider>(
              builder: (context, provider, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!provider.isDemoMode)
                      const Padding(
                        padding: EdgeInsets.only(right: 4.0),
                        child: DataSourceIndicator(compact: true),
                      ),
                    if (provider.isDemoMode)
                      const Padding(
                        padding: EdgeInsets.only(right: 4.0),
                        child: DemoModeIndicator(),
                      ),
                    SizedBox(
                      width: 55, // Even more constrained width
                      child: _buildConnectionStatus(provider, isDark),
                    ),
                  ],
                );
              },
            ),
          ),
          
          const SizedBox(width: 4),
          
          // Theme toggle button (minimized)
          Builder(
            builder: (context) {
              return SizedBox(
                width: 24, 
                height: 24,
                child: InkWell(
                  onTap: () => context.read<ThemeProvider>().toggleTheme(),
                  child: Tooltip(
                    message: Provider.of<TranslationService>(context).translateTextSync('Zmień motyw'),
                    child: Icon(
                      context.read<ThemeProvider>().currentThemeIcon,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      size: 16, // Smallest icon
                    ),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildConnectionStatus(SensorsProvider provider, bool isDark) {
    final hasConnection = provider.hasInternetConnection;
    final isLoaded = provider.isLoaded;
    final translationService = Provider.of<TranslationService>(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6, // Smaller indicator
          height: 6, // Smaller indicator
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasConnection && isLoaded 
                ? AppColors.success 
                : AppColors.error,
          ),
        ),
        const SizedBox(width: 4), // Less spacing
        FutureBuilder<String>(
          future: translationService.translateText(hasConnection && isLoaded ? 'Online' : 'Offline'),
          builder: (context, snapshot) {
            return Text(
              snapshot.data ?? (hasConnection && isLoaded ? 'Online' : 'Offline'),
              style: GoogleFonts.inter(
                fontSize: 10, // Smaller text
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildNavigationRail(bool isDark) {
    final translationService = Provider.of<TranslationService>(context);
    
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onItemTapped,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      indicatorColor: AppColors.primary.withValues(alpha: 0.1),
      selectedIconTheme: const IconThemeData(
        color: AppColors.primary,
        size: 24,
      ),
      unselectedIconTheme: IconThemeData(
        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        size: 24,
      ),
      selectedLabelTextStyle: GoogleFonts.inter(
        color: AppColors.primary,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelTextStyle: GoogleFonts.inter(
        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
      ),
      labelType: NavigationRailLabelType.all,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.sensors_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
      
      destinations: _navigationItems
          .map(
            (item) => NavigationRailDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selectedIcon),
              label: FutureBuilder<String>(
                future: translationService.translateText(item.label),
                builder: (context, snapshot) {
                  return Text(snapshot.data ?? item.label);
                },
              ),
            ),
          )
          .toList(),
    );
  }
  
  Widget _buildBottomNavigationBar(bool isDark) {
    if (MediaQuery.of(context).size.width >= 900) {
      return const SizedBox.shrink();
    }

    final translationService = Provider.of<TranslationService>(context);
    
    return FutureBuilder<List<String>>(
      future: translationService.translateTexts(_navigationItems.map((item) => item.label).toList()),
      builder: (context, snapshot) {
        final translatedLabels = snapshot.data ?? 
            _navigationItems.map((item) => item.label).toList();
            
        return BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          selectedLabelStyle: GoogleFonts.inter(
            fontSize: 8,  // Minimum font size to fix overflow
            fontWeight: FontWeight.w500,
            height: 1.1, // Tighter line height
            letterSpacing: -0.2, // Tight letter spacing
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 8,  // Minimum font size to fix overflow
            height: 1.1, // Tighter line height
            letterSpacing: -0.2, // Tight letter spacing
          ),
          iconSize: 16, // Minimum icon size to fix overflow
          showUnselectedLabels: false, // Hide labels for unselected items to save space
          items: List.generate(_navigationItems.length, (index) {
            final item = _navigationItems[index];
            return BottomNavigationBarItem(
              icon: Icon(item.icon, size: 16), // Explicitly set smaller icon size
              activeIcon: Icon(item.selectedIcon, size: 16), // Explicitly set smaller icon size
              label: translatedLabels[index],
            );
          }),
        );
      },
    );
  }
  
  String _getPageTitle() {
    // Get original title (will be translated in the UI via FutureBuilder)
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Historia';
      case 2:
        return 'Alerty';
      case 3:
        return 'Ustawienia';
      default:
        return 'Dashboard';
    }
  }
  
  String? _getPageSubtitle() {
    // Get original subtitle (will be translated in the UI via FutureBuilder)
    switch (_selectedIndex) {
      case 0:
        return 'Status i dane w czasie rzeczywistym';
      case 1:
        return 'Historia odczytów z czujników';
      case 2:
        return 'Powiadomienia i alerty systemowe';
      case 3:
        return 'Konfiguracja aplikacji';
      default:
        return null;
    }
  }
}

class NavigationItem {
  const NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}