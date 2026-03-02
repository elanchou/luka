import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/sault_provider.dart';
import 'services/network_monitor_service.dart';
import 'services/icloud_backup_service.dart';
import 'screens/network_blocked_screen.dart';
import 'screens/app_splash_screen.dart';
import 'screens/sault_onboarding_screen.dart';
import 'screens/main_sault_dashboard.dart';
import 'screens/add_secret_step_1.dart';
import 'screens/add_secret_step_2.dart';
import 'screens/add_secret_step_3.dart';
import 'screens/seed_phrase_detail_view.dart';
import 'screens/decrypting_progress_screen.dart';
import 'screens/activity_log_screen.dart';
import 'screens/system_settings_screen.dart';
import 'screens/export_progress_screen.dart';
import 'screens/setup_master_password_screen.dart';
import 'screens/master_password_input_screen.dart';
import 'screens/change_master_password_screen.dart';
import 'screens/reset_sault_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final vaultProvider = SaultProvider();
  final networkMonitor = NetworkMonitorService();
  await networkMonitor.init();

  final icloudBackupService = ICloudBackupService();
  icloudBackupService.checkAvailability();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: vaultProvider),
        ChangeNotifierProvider.value(value: networkMonitor),
        ChangeNotifierProvider.value(value: icloudBackupService),
      ],
      child: const SaultApp(),
    ),
  );
}

class SaultApp extends StatelessWidget {
  const SaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sault',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF101d22),
        primaryColor: const Color(0xFF13b6ec),
        textTheme: GoogleFonts.spaceGroteskTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return Consumer<NetworkMonitorService>(
          builder: (context, network, _) {
            return Stack(
              children: [
                if (child != null) child,
                if (network.isConnected)
                  const NetworkBlockedScreen(),
              ],
            );
          },
        );
      },
      initialRoute: '/',
      routes: {
        '/': (context) => const AppSplashScreen(),
        '/onboarding': (context) => const SaultOnboardingScreen(),
        '/set-master-password': (context) => const SetupMasterPasswordScreen(),
        '/master-password-input': (context) => const MasterPasswordInputScreen(),
        '/change-master-password': (context) => const ChangeMasterPasswordScreen(),
        '/dashboard': (context) => const MainSaultDashboard(),
        '/add-secret-1': (context) => const AddSecretStep1(),
        '/add-secret-2': (context) => const AddSecretStep2(),
        '/add-secret-3': (context) => const AddSecretStep3(),
        '/seed-detail': (context) => const SeedPhraseDetailView(),
        '/activity-log': (context) => const ActivityLogScreen(),
        '/settings': (context) => const SystemSettingsScreen(),
        '/export-progress': (context) => const ExportProgressScreen(),
        '/decrypting-progress': (context) => const DecryptingProgressScreen(),
        '/reset-vault': (context) => const ResetSaultScreen(),
      },
    );
  }
}
