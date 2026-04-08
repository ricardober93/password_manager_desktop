import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager_desktop/application/ports/clipboard_service.dart';
import 'package:password_manager_desktop/application/ports/clock.dart';
import 'package:password_manager_desktop/application/ports/crypto_service.dart';
import 'package:password_manager_desktop/application/ports/vault_repository.dart';
import 'package:password_manager_desktop/application/use_cases/add_credential_use_case.dart';
import 'package:password_manager_desktop/application/use_cases/copy_password_to_clipboard_use_case.dart';
import 'package:password_manager_desktop/application/use_cases/copy_username_to_clipboard_use_case.dart';
import 'package:password_manager_desktop/application/use_cases/delete_credential_use_case.dart';
import 'package:password_manager_desktop/application/use_cases/list_credentials_use_case.dart';
import 'package:password_manager_desktop/application/use_cases/search_credentials_use_case.dart';
import 'package:password_manager_desktop/application/use_cases/update_credential_use_case.dart';
import 'package:password_manager_desktop/domain/entities/credential_draft.dart';
import 'package:password_manager_desktop/domain/entities/credential_item.dart';
import 'package:password_manager_desktop/domain/entities/stored_vault_file.dart';
import 'package:password_manager_desktop/domain/entities/vault_access_key.dart';
import 'package:password_manager_desktop/domain/entities/vault_data.dart';
import 'package:password_manager_desktop/domain/entities/vault_session.dart';

void main() {
  group('credential use cases', () {
    late _FixedClock clock;
    late _RecordingVaultRepository repository;
    late _PassthroughCryptoService cryptoService;
    late VaultSession session;

    setUp(() {
      clock = _FixedClock(DateTime.utc(2026, 4, 8, 12));
      repository = _RecordingVaultRepository();
      cryptoService = _PassthroughCryptoService();
      session = VaultSession(
        accessKey: VaultAccessKey('master-key'.codeUnits),
        salt: const <int>[1, 2, 3],
        iterations: 150000,
        vaultData: VaultData(
          credentials: <CredentialItem>[
            CredentialItem(
              id: 'cred-1',
              title: 'GitHub',
              username: 'ricardo',
              password: 'secret',
              url: 'https://github.com',
              notes: 'personal',
              createdAt: clock.now(),
              updatedAt: clock.now(),
            ),
          ],
          createdAt: clock.now(),
          updatedAt: clock.now(),
        ),
        lastActivityAt: clock.now(),
      );
    });

    test('adds a credential and persists the updated vault', () async {
      final AddCredentialUseCase useCase = AddCredentialUseCase(
        repository: repository,
        cryptoService: cryptoService,
        clock: clock,
      );

      final updatedSession = await useCase.execute(
        session: session,
        draft: const CredentialDraft(
          title: 'Email',
          username: 'me@example.com',
          password: 'email-pass',
        ),
      );

      expect(updatedSession.vaultData.credentials, hasLength(2));
      expect(repository.writeCount, 1);
    });

    test('updates a credential and refreshes updatedAt', () async {
      final UpdateCredentialUseCase useCase = UpdateCredentialUseCase(
        repository: repository,
        cryptoService: cryptoService,
        clock: _FixedClock(DateTime.utc(2026, 4, 8, 13)),
      );

      final updatedSession = await useCase.execute(
        session: session,
        credentialId: 'cred-1',
        draft: const CredentialDraft(
          title: 'GitHub Work',
          username: 'ricardo-work',
          password: 'new-secret',
          url: 'https://github.com',
        ),
      );

      expect(updatedSession.vaultData.credentials.single.title, 'GitHub Work');
      expect(
        updatedSession.vaultData.credentials.single.updatedAt,
        DateTime.utc(2026, 4, 8, 13),
      );
    });

    test('deletes a credential and persists the updated vault', () async {
      final DeleteCredentialUseCase useCase = DeleteCredentialUseCase(
        repository: repository,
        cryptoService: cryptoService,
        clock: clock,
      );

      final updatedSession = await useCase.execute(
        session: session,
        credentialId: 'cred-1',
      );

      expect(updatedSession.vaultData.credentials, isEmpty);
      expect(repository.writeCount, 1);
    });

    test('lists credentials sorted by title', () {
      final ListCredentialsUseCase useCase = ListCredentialsUseCase();
      final VaultSession unsortedSession = session.copyWith(
        vaultData: session.vaultData.copyWith(
          credentials: <CredentialItem>[
            session.vaultData.credentials.single.copyWith(title: 'Zeta'),
            session.vaultData.credentials.single.copyWith(
              id: 'cred-2',
              title: 'Alpha',
            ),
          ],
        ),
      );

      final result = useCase.execute(unsortedSession);

      expect(result.map((item) => item.title), <String>['Alpha', 'Zeta']);
    });

    test('searches credentials by title, username, or url', () {
      final SearchCredentialsUseCase useCase = SearchCredentialsUseCase();

      expect(
        useCase.execute(session: session, query: 'hub').single.id,
        'cred-1',
      );
      expect(
        useCase.execute(session: session, query: 'ric').single.id,
        'cred-1',
      );
      expect(
        useCase.execute(session: session, query: 'github').single.id,
        'cred-1',
      );
    });
  });

  group('clipboard use cases', () {
    test('copies username without scheduling cleanup', () async {
      final _RecordingClipboardService clipboard = _RecordingClipboardService();
      final CopyUsernameToClipboardUseCase useCase =
          CopyUsernameToClipboardUseCase(clipboardService: clipboard);
      final CredentialItem credential = CredentialItem(
        id: 'cred-1',
        title: 'GitHub',
        username: 'ricardo',
        password: 'secret',
        createdAt: DateTime.utc(2026, 4, 8, 12),
        updatedAt: DateTime.utc(2026, 4, 8, 12),
      );

      await useCase.execute(credential);

      expect(clipboard.lastCopiedText, 'ricardo');
      expect(clipboard.scheduledClear, isNull);
    });

    test('copies password and schedules cleanup', () async {
      final _RecordingClipboardService clipboard = _RecordingClipboardService();
      final CopyPasswordToClipboardUseCase useCase =
          CopyPasswordToClipboardUseCase(clipboardService: clipboard);
      final CredentialItem credential = CredentialItem(
        id: 'cred-1',
        title: 'GitHub',
        username: 'ricardo',
        password: 'secret',
        createdAt: DateTime.utc(2026, 4, 8, 12),
        updatedAt: DateTime.utc(2026, 4, 8, 12),
      );

      await useCase.execute(
        credential: credential,
        clearAfter: const Duration(seconds: 20),
      );

      expect(clipboard.lastCopiedText, 'secret');
      expect(clipboard.scheduledClear, const Duration(seconds: 20));
    });
  });
}

class _FixedClock implements Clock {
  _FixedClock(this._current);

  final DateTime _current;

  @override
  DateTime now() => _current;
}

class _RecordingClipboardService implements ClipboardService {
  String? lastCopiedText;
  Duration? scheduledClear;

  @override
  Future<void> clear() async {
    lastCopiedText = '';
  }

  @override
  Future<void> copyText(String text) async {
    lastCopiedText = text;
  }

  @override
  void scheduleClear(Duration delay) {
    scheduledClear = delay;
  }
}

class _RecordingVaultRepository implements VaultRepository {
  int writeCount = 0;
  StoredVaultFile? lastFile;

  @override
  Future<bool> exists() async => lastFile != null;

  @override
  Future<StoredVaultFile?> read() async => lastFile;

  @override
  Future<void> write(StoredVaultFile vaultFile) async {
    writeCount++;
    lastFile = vaultFile;
  }
}

class _PassthroughCryptoService implements CryptoService {
  @override
  Future<VaultData> decrypt({
    required StoredVaultFile storedVaultFile,
    required VaultAccessKey accessKey,
  }) async {
    return VaultData(
      credentials: const <CredentialItem>[],
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
      kdfAlgorithm: 'pbkdf2-sha256',
      iterations: iterations,
      salt: Uint8List.fromList(salt),
      nonce: Uint8List.fromList(const <int>[1, 2, 3]),
      mac: Uint8List.fromList(const <int>[4, 5, 6]),
      cipherText: Uint8List.fromList(const <int>[7, 8, 9]),
      updatedAt: updatedAt,
    );
  }

  @override
  List<int> generateSalt() => const <int>[1, 2, 3];
}
