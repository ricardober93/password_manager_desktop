import 'dart:typed_data';

import 'package:password_manager_desktop/application/ports/clipboard_service.dart';
import 'package:password_manager_desktop/application/ports/clock.dart';
import 'package:password_manager_desktop/application/ports/crypto_service.dart';
import 'package:password_manager_desktop/application/ports/vault_repository.dart';
import 'package:password_manager_desktop/domain/entities/credential_item.dart';
import 'package:password_manager_desktop/domain/entities/stored_vault_file.dart';
import 'package:password_manager_desktop/domain/entities/vault_access_key.dart';
import 'package:password_manager_desktop/domain/entities/vault_data.dart';
import 'package:password_manager_desktop/domain/exceptions/vault_exception.dart';

class FixedClock implements Clock {
  FixedClock(this.current);

  final DateTime current;

  @override
  DateTime now() => current;
}

class InMemoryVaultRepository implements VaultRepository {
  StoredVaultFile? file;
  int writeCount = 0;

  @override
  Future<bool> exists() async => file != null;

  @override
  Future<StoredVaultFile?> read() async => file;

  @override
  Future<void> write(StoredVaultFile vaultFile) async {
    writeCount++;
    file = vaultFile;
  }
}

class FakeCryptoService implements CryptoService {
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

class RecordingClipboardService implements ClipboardService {
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
