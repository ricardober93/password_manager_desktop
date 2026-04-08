import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../application/ports/vault_repository.dart';
import '../../domain/entities/stored_vault_file.dart';
import '../../domain/exceptions/vault_exception.dart';

class LocalVaultRepository implements VaultRepository {
  LocalVaultRepository(this._vaultFile);

  final File _vaultFile;

  static Future<LocalVaultRepository> create({
    String filename = 'password_manager_vault.json',
  }) async {
    final Directory directory = await getApplicationSupportDirectory();
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
    return LocalVaultRepository(
      File('${directory.path}${Platform.pathSeparator}$filename'),
    );
  }

  factory LocalVaultRepository.forFile(File file) {
    return LocalVaultRepository(file);
  }

  @override
  Future<bool> exists() => _vaultFile.exists();

  @override
  Future<StoredVaultFile?> read() async {
    if (!await exists()) {
      return null;
    }
    final String content = await _vaultFile.readAsString();
    return StoredVaultFile.fromJson(
      jsonDecode(content) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> write(StoredVaultFile vaultFile) async {
    final Directory parent = _vaultFile.parent;
    if (!await parent.exists()) {
      await parent.create(recursive: true);
    }

    final File tempFile = File('${_vaultFile.path}.tmp');
    await tempFile.writeAsString(jsonEncode(vaultFile.toJson()), flush: true);

    File? backupFile;
    if (await _vaultFile.exists()) {
      backupFile = File('${_vaultFile.path}.bak');
      if (await backupFile.exists()) {
        await backupFile.delete();
      }
      await _vaultFile.rename(backupFile.path);
    }

    try {
      await tempFile.rename(_vaultFile.path);
      if (backupFile != null && await backupFile.exists()) {
        await backupFile.delete();
      }
    } catch (error) {
      if (backupFile != null && await backupFile.exists()) {
        await backupFile.rename(_vaultFile.path);
      }
      throw VaultException('Failed to atomically write vault file: $error');
    }
  }
}
