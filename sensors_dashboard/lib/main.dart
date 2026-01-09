import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/auth_service.dart';
import 'providers/sensors_provider.dart';
import 'providers/theme_provider.dart';
import 'services/translation_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
    print('✅ Environment variables loaded');
    print('📡 API URL: ${dotenv.env['API_BASE_URL']}');
  } catch (e) {
    print('⚠️ Warning: Could not load .env file: $e');
  }

  // Inicjalizacja AuthService
  await AuthService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider
        StreamProvider<AppUser?>(
          create: (_) => AuthService().authStateChanges,
          initialData: AuthService().currentUser,
        ),

        // Translation Service
        ChangeNotifierProvider(
          create: (_) => TranslationService()..initialize(),
        ),

        // Theme Provider
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),

        // Sensors Provider - Fixed: Constructor takes no arguments
        ChangeNotifierProvider(
          create: (_) => SensorsProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          // Use theme provider if you have custom theme logic, 
          // otherwise fallback to standard MaterialApp
          return MaterialApp(
            title: 'Smart House IoT',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}