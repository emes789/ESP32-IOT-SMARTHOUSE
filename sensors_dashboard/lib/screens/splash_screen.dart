import 'package:flutter/material.dart';
import '../core/utils/color_utils.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../providers/sensors_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/auth_error_screen.dart';
import 'main_dashboard.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }
  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      final sensorsProvider = Provider.of<SensorsProvider>(context, listen: false);
      try {
        await sensorsProvider.initialize();
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const MainDashboard(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        }
      } catch (e) {
        if (mounted && e.toString().contains('Anonymous authentication is disabled')) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => AuthErrorScreen(
                errorMessage: e.toString(),
                onRetry: () async {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const SplashScreen()),
                  );
                },
              ),
            ),
          );
        }
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isCurrentlyDark(context);
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        AppColors.darkBackground,
                        AppColors.darkSurface,
                        AppColors.primary.withAlphaFromOpacity(0.1),
                      ]
                    : [
                        AppColors.background,
                        AppColors.surface,
                        AppColors.primary.withAlphaFromOpacity(0.1),
                      ],
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: AppColors.primaryGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withAlphaFromOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.sensors_rounded,
                              size: 60,
                              color: Colors.white,
                            ),
                          )
                              .animate()
                              .scale(
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.elasticOut,
                              )
                              .fadeIn(duration: const Duration(milliseconds: 600)),
                          const SizedBox(height: 32),
                          Text(
                            AppConstants.appName,
                            style: GoogleFonts.inter(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          )
                              .animate(delay: const Duration(milliseconds: 200))
                              .fadeIn(duration: const Duration(milliseconds: 800))
                              .slideY(
                                begin: 0.3,
                                end: 0,
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeOut,
                              ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              AppConstants.appDescription,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                              .animate(delay: const Duration(milliseconds: 400))
                              .fadeIn(duration: const Duration(milliseconds: 800))
                              .slideY(
                                begin: 0.3,
                                end: 0,
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeOut,
                              ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        )
                            .animate(
                              onPlay: (controller) => controller.repeat(),
                            )
                            .fadeIn(
                              delay: const Duration(milliseconds: 800),
                              duration: const Duration(milliseconds: 600),
                            ),
                        const SizedBox(height: 24),
                        Text(
                          'Inicjalizacja systemu...',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        )
                            .animate(delay: const Duration(milliseconds: 1000))
                            .fadeIn(duration: const Duration(milliseconds: 600)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStatusIndicator('MongoDB', true, isDark),
                            const SizedBox(width: 20),
                            _buildStatusIndicator('Sensory', true, isDark),
                            const SizedBox(width: 20),
                            _buildStatusIndicator('UI', true, isDark),
                          ],
                        )
                            .animate(delay: const Duration(milliseconds: 1200))
                            .fadeIn(duration: const Duration(milliseconds: 600))
                            .slideY(
                              begin: 0.2,
                              end: 0,
                              duration: const Duration(milliseconds: 600),
                            ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Text(
                      'v${AppConstants.appVersion}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                      ),
                    ),
                  )
                      .animate(delay: const Duration(milliseconds: 1400))
                      .fadeIn(duration: const Duration(milliseconds: 600)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _buildStatusIndicator(String label, bool isReady, bool isDark) {
    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isReady 
                ? AppColors.success 
                : (isDark ? AppColors.darkTextTertiary : AppColors.textTertiary),
          ),
        )
            .animate(
              delay: Duration(milliseconds: 1200 + (label.length * 100)),
            )
            .scale(
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
            ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
