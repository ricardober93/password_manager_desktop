import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager_desktop/application/ports/clock.dart';
import 'package:password_manager_desktop/application/ports/crypto_service.dart';
import 'package:password_manager_desktop/application/ports/vault_repository.dart';
import 'package:password_manager_desktop/application/use_cases/create_vault_use_case.dart';
import 'package:password_manager_desktop/application/use_cases/lock_vault_use_case.dart';
import 'package:password_manager_desktop/application/use_cases/unlock_vault_use_case.dart';
import 'package:password_manager_desktop/domain/entities/stored_vault_file.dart';
import 'package:password_manager_desktop/domain/entities/vault_access_key.dart';
import 'package:password_manager_desktop/domain/entities/vault_data.dart';
import 'package:password_manager_desktop/domain/exceptions/vault_exception.dart';

void main() {
  group('CreateVaultUseCase', () {
    test('creates an empty vault session when passwords match', () async {
      final _InMemoryVaultRepository repository = _InMemoryVaultRepository();
      final _FakeCryptoService crypto = _FakeCryptoService();
      final _FixedClock clock = _FixedClock(DateTime.utc(2026, 4, 8, 12));

      final CreateVaultUseCase useCase = CreateVaultUseCase(
        repository: repository,
        cryptoService: crypto,
        clock: clock,
      );

      final session = await useCase.execute(
        masterPassword: 'correct horse battery staple',
        confirmPassword: 'correct horse battery staple',
      );

      expect(session.vaultData.credentials, isEmpty);
      expect(session.vaultData.createdAt, clock.now());
      expect(await repository.exists(), isTrue);
    });

    test('rejects mismatched master password confirmation', () async {
      final CreateVaultUseCase useCase = CreateVaultUseCase(
        repository: _InMemoryVaultRepository(),
        cryptoService: _FakeCryptoService(),
        clock: _FixedClock(DateTime.utc(2026, 4, 8, 12)),
      );

      expect(
        () => useCase.execute(
          masterPassword: 'password-123',
          confirmPassword: 'different',
        ),
        throwsA(isA<VaultException>()),
      );
    });
  });

  group('UnlockVaultUseCase', () {
    test('unlocks an existing vault with the correct password', () async {
      final _InMemoryVaultRepository repository = _InMemoryVaultRepository();
      final _FakeCryptoService crypto = _FakeCryptoService();
      final _FixedClock clock = _FixedClock(DateTime.utc(2026, 4, 8, 12));
      final CreateVaultUseCase createVaultUseCase = CreateVaultUseCase(
        repository: repository,
        cryptoService: crypto,
        clock: clock,
      );

      await createVaultUseCase.execute(
        masterPassword: 'password-123',
        confirmPassword: 'password-123',
      );

      final UnlockVaultUseCase useCase = UnlockVaultUseCase(
        repository: repository,
        cryptoService: crypto,
        clock: clock,
      );

      final session = await useCase.execute(masterPassword: 'password-123');

      expect(session.vaultData.credentials, isEmpty);
      expect(session.lastActivityAt, clock.now());
    });

    test('rejects an incorrect password', () async {
      final _InMemoryVaultRepository repository = _InMemoryVaultRepository();
      final _FakeCryptoService crypto = _FakeCryptoService();
      final _FixedClock clock = _FixedClock(DateTime.utc(2026, 4, 8, 12));
      final CreateVaultUseCase createVaultUseCase = CreateVaultUseCase(
        repository: repository,
        cryptoService: crypto,
        clock: clock,
      );

      await createVaultUseCase.execute(
        masterPassword: 'password-123',
        confirmPassword: 'password-123',
      );

      final UnlockVaultUseCase useCase = UnlockVaultUseCase(
        repository: repository,
        cryptoService: crypto,
        clock: clock,
      );

      expect(
        () => useCase.execute(masterPassword: 'wrong-password'),
        throwsA(isA<VaultException>()),
      );
    });
  });

  group('LockVaultUseCase', () {
    test('returns the lock timestamp', () {
      final _FixedClock clock = _FixedClock(DateTime.utc(2026, 4, 8, 12));
      final LockVaultUseCase useCase = LockVaultUseCase(clock: clock);

      final lockedAt = useCase.execute();

      expect(lockedAt, clock.now());
    });
  });
}

class _FixedClock implements Clock {
  _FixedClock(this._now);

  final DateTime _now;

  @override
  DateTime now() => _now;
}

class _InMemoryVaultRepository implements VaultRepository {
  StoredVaultFile? _file;

  @override
  Future<bool> exists() async => _file != null;

  @override
  Future<StoredVaultFile?> read() async => _file;

  @override
  Future<void> write(StoredVaultFile vaultFile) async {
    _file = vaultFile;
  }
}

class _FakeCryptoService implements CryptoService {
  @override
  Future<VaultData> decrypt({
    required StoredVaultFile storedVaultFile,
    required VaultAccessKey accessKey,
  }) async {
    final String password = String.fromCharCodes(accessKey.bytes);
    if (password != storedVaultFile.kdfAlgorithm) {
      throw const VaultException('Vault integrity check failed.');
    }

    return VaultData(
      credentials: const [],
      createdAt: storedVaultFile.updatedAt,
      updatedAt: storedVaultFile.updatedAt,
    );
  }

  @override
  Future<VaultAccessKey> deriveKey({
    required String password,
    required List<int> salt,
    required int iterations,
  }) async {
    return VaultAccessKey(password.codeUnits);
  }

  @override
  Future<StoredVaultFile> encrypt({
    required VaultData vaultData,
    required VaultAccessKey accessKey,
    required List<int> salt,
    required int iterations,
    required DateTime updatedAt,
  }) async {
    return StoredVaultFile(
      version: 1,
      kdfAlgorithm: String.fromCharCodes(accessKey.bytes),
      iterations: iterations,
      salt: Uint8List.fromList(salt),
      nonce: Uint8List.fromList(const <int>[1, 2, 3]),
      mac: Uint8List.fromList(const <int>[4, 5, 6]),
      cipherText: Uint8List.fromList(const <int>[7, 8, 9]),
      updatedAt: updatedAt,
    );
  }

  @override
  List<int> generateSalt() => const <int>[1, 2, 3, 4];
}
