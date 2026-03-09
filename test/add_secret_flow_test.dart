import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vault_app/models/secret_model.dart';
import 'package:vault_app/providers/sault_provider.dart';
import 'package:vault_app/screens/add_secret_step_1.dart';
import 'package:vault_app/screens/add_secret_step_2.dart';
import 'package:vault_app/screens/add_secret_step_3.dart';

class _RecordingSaultProvider extends SaultProvider {
  Secret? savedSecret;

  @override
  Future<bool> addSecret(Secret secret) async {
    savedSecret = secret;
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (_) async => null);
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('seed phrase flow preserves values from entry to save',
      (tester) async {
    final _RecordingSaultProvider provider = _RecordingSaultProvider();
    final List<String> phrase = <String>[
      'abandon',
      'ability',
      'able',
      'about',
      'above',
      'absent',
      'absorb',
      'abstract',
      'absurd',
      'abuse',
      'access',
      'accident',
    ];

    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(430, 1400);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ChangeNotifierProvider<SaultProvider>.value(
        value: provider,
        child: MaterialApp(
          initialRoute: '/add-secret-1',
          routes: <String, WidgetBuilder>{
            '/add-secret-1': (_) => const AddSecretStep1(),
            '/add-secret-2': (_) => const AddSecretStep2(),
            '/add-secret-3': (_) => const AddSecretStep3(),
            '/dashboard': (_) => const Scaffold(
                  body: Center(child: Text('Dashboard')),
                ),
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField).first,
      'Primary Wallet',
    );
    await tester.tap(find.text('Continue to seed phrase'));
    await tester.pumpAndSettle();

    expect(find.text('STEP 2/3'), findsOneWidget);

    final Finder stepTwoFields = find.byType(TextField);
    for (int index = 0; index < phrase.length; index++) {
      await tester.ensureVisible(stepTwoFields.at(index));
      await tester.enterText(stepTwoFields.at(index), phrase[index]);
      await tester.pump();
    }

    await tester.tap(find.text('Review and confirm'));
    await tester.pumpAndSettle();

    expect(find.text('STEP 3/3'), findsOneWidget);
    expect(find.text('Primary Wallet'), findsOneWidget);

    await tester.tap(find.text('Confirm and save'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(provider.savedSecret, isNotNull);
    expect(provider.savedSecret!.name, 'Primary Wallet');
    expect(provider.savedSecret!.network, 'Ethereum');
    expect(provider.savedSecret!.content, phrase.join(' '));
    expect(provider.savedSecret!.type, SecretType.seedPhrase);
    expect(provider.savedSecret!.metadata!['icon'], 'wallet');
  });
}
