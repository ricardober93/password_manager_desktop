import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager_desktop/domain/entities/stored_vault_file.dart';
import 'package:password_manager_desktop/infrastructure/storage/local_vault_repository.dart';

void main() {
  test('writes and reads vault data from disk', () async {
    final Directory tempDir = await Directory.systemTemp.createTemp(
      'vault_repo_test',
    );
    final File file = File(
      '${tempDir.path}${Platform.pathSeparator}vault.json',
    );
    final LocalVaultRepository repository = LocalVaultRepository.forFile(file);
    final StoredVaultFile storedVaultFile = StoredVaultFile(
      version: 1,
      kdfAlgorithm: 'pbkdf2-sha256',
      iterations: 150000,
      salt: Uint8List.fromList(const <int>[1, 2, 3]),
      nonce: Uint8List.fromList(const <int>[4, 5, 6]),
      mac: Uint8List.fromList(const <int>[7, 8, 9]),
      cipherText: Uint8List.fromList(const <int>[10, 11, 12]),
      updatedAt: DateTime.utc(2026, 4, 8, 12),
    );

    await repository.write(storedVaultFile);
    final StoredVaultFile? readBack = await repository.read();

    expect(readBack, isNotNull);
    expect(readBack!.version, 1);
    expect(readBack.iterations, 150000);

    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('replaces an existing vault atomically', () async {
    final Directory tempDir = await Directory.systemTemp.createTemp(
      'vault_repo_test',
    );
    final File file = File(
      '${tempDir.path}${Platform.pathSeparator}vault.json',
    );
    final LocalVaultRepository repository = LocalVaultRepository.forFile(file);

    await repository.write(
      StoredVaultFile(
        version: 1,
        kdfAlgorithm: 'pbkdf2-sha256',
        iterations: 150000,
        salt: Uint8List.fromList(const <int>[1]),
        nonce: Uint8List.fromList(const <int>[2]),
        mac: Uint8List.fromList(const <int>[3]),
        cipherText: Uint8List.fromList(const <int>[4]),
        updatedAt: DateTime.utc(2026, 4, 8, 12),
      ),
    );
    await repository.write(
      StoredVaultFile(
        version: 2,
        kdfAlgorithm: 'pbkdf2-sha256',
        iterations: 150000,
        salt: Uint8List.fromList(const <int>[5]),
        nonce: Uint8List.fromList(const <int>[6]),
        mac: Uint8List.fromList(const <int>[7]),
        cipherText: Uint8List.fromList(const <int>[8]),
        updatedAt: DateTime.utc(2026, 4, 8, 13),
      ),
    );

    final StoredVaultFile? readBack = await repository.read();
    expect(readBack!.version, 2);

    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });
}
