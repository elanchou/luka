import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/vault_provider.dart';
import 'screens/app_splash_screen.dart';
import 'screens/vault_onboarding_screen.dart';
import 'screens/biometric_auth_screen.dart';
import 'screens/main_vault_dashboard.dart';
import 'screens/add_secret_step_1.dart';
import 'screens/add_secret_step_2.dart';
import 'screens/seed_phrase_detail_view.dart';
import 'screens/activity_log_screen.dart';
import 'screens/system_settings_screen.dart';
import 'screens/export_progress_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Initialize VaultProvider early or lazily
  final vaultProvider = VaultProvider();
  await vaultProvider.init(); // In a real app, might want to show loading screen while this happens

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: vaultProvider),
      ],
      child: const VaultApp(),
    ),
  );
}

class VaultApp extends StatelessWidget {
  const VaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vault',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF101d22),
        primaryColor: const Color(0xFF13b6ec),
        textTheme: GoogleFonts.spaceGroteskTextTheme(
          ThemeData.dark().textTheme,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AppSplashScreen(),
        '/onboarding': (context) => const VaultOnboardingScreen(),
        '/biometric-auth': (context) => const BiometricAuthScreen(),
        '/dashboard': (context) => const MainVaultDashboard(),
        '/add-secret-1': (context) => const AddSecretStep1(),
        '/add-secret-2': (context) => const AddSecretStep2(),
        '/seed-detail': (context) => const SeedPhraseDetailView(),
        '/activity-log': (context) => const ActivityLogScreen(),
        '/settings': (context) => const SystemSettingsScreen(),
        '/export-progress': (context) => const ExportProgressScreen(),
      },
    );
  }
}
