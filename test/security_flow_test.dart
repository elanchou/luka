import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:vault_app/models/secret_model.dart';
import 'package:vault_app/providers/sault_provider.dart';
import 'package:vault_app/services/master_key_service.dart';

class _FakeSecureStoragePlatform extends FlutterSecureStoragePlatform {
  _FakeSecureStoragePlatform(this._data);

  final Map<String, String> _data;

  @override
  Future<bool> containsKey({
    required String key,
    required Map<String, String> options,
  }) async {
    return _data.containsKey(key);
  }

  @override
  Future<void> delete({
    required String key,
    required Map<String, String> options,
  }) async {
    _data.remove(key);
  }

  @override
  Future<void> deleteAll({required Map<String, String> options}) async {
    _data.clear();
  }

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) async {
    return _data[key];
  }

  @override
  Future<Map<String, String>> readAll({
    required Map<String, String> options,
  }) async {
    return Map<String, String>.from(_data);
  }

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async {
    _data[key] = value;
  }
}

class _FakePathProviderPlatform extends PathProviderPlatform {
  _FakePathProviderPlatform(this.rootPath);

  final String rootPath;

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return rootPath;
  }

  @override
  Future<String?> getTemporaryPath() async {
    return rootPath;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FlutterSecureStoragePlatform originalSecureStorage;
  late PathProviderPlatform originalPathProvider;
  late Directory tempDir;
  late Map<String, String> secureStorageData;

  setUp(() async {
    originalSecureStorage = FlutterSecureStoragePlatform.instance;
    originalPathProvider = PathProviderPlatform.instance;
    tempDir = await Directory.systemTemp.createTemp('vault_security_test_');
    secureStorageData = <String, String>{};

    FlutterSecureStoragePlatform.instance =
        _FakeSecureStoragePlatform(secureStorageData);
    PathProviderPlatform.instance = _FakePathProviderPlatform(tempDir.path);
  });

  tearDown(() async {
    FlutterSecureStoragePlatform.instance = originalSecureStorage;
    PathProviderPlatform.instance = originalPathProvider;
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('verifyPassword rejects the wrong master password', () async {
    final masterKeyService = MasterKeyService();

    await masterKeyService.setMasterPassword(
      'correct-horse-battery-staple',
      SecurityLevel.standard,
    );

    expect(
      await masterKeyService.verifyPassword('correct-horse-battery-staple'),
      isTrue,
    );
    expect(
      await masterKeyService.verifyPassword('wrong-password'),
      isFalse,
    );
  });

  test('changing the master password re-encrypts existing vault data', () async {
    final provider = SaultProvider();
    final masterKeyService = MasterKeyService();

    await masterKeyService.setMasterPassword(
      'old-password-123',
      SecurityLevel.standard,
    );

    await provider.init(masterPassword: 'old-password-123');
    expect(provider.isInitialized, isTrue);

    final secret = Secret.create(
      name: 'Main Wallet',
      network: 'Ethereum',
      content: 'abandon ability able about above absent absorb abstract absurd abuse access accident',
      type: SecretType.seedPhrase,
    );

    expect(await provider.addSecret(secret), isTrue);
    expect(provider.secretCount, 1);

    expect(
      await provider.changeMasterPassword(
        oldPassword: 'old-password-123',
        newPassword: 'new-password-456',
        securityLevel: SecurityLevel.enhanced,
      ),
      isTrue,
    );

    expect(await masterKeyService.verifyPassword('old-password-123'), isFalse);
    expect(await masterKeyService.verifyPassword('new-password-456'), isTrue);

    final reloadedProvider = SaultProvider();
    await reloadedProvider.init(masterPassword: 'new-password-456');

    expect(reloadedProvider.isInitialized, isTrue);
    expect(reloadedProvider.secretCount, 1);
    expect(reloadedProvider.secrets.single.name, 'Main Wallet');
    expect(reloadedProvider.secrets.single.content, secret.content);

    final stalePasswordProvider = SaultProvider();
    await stalePasswordProvider.init(masterPassword: 'old-password-123');

    expect(stalePasswordProvider.isInitialized, isFalse);
  });
}
