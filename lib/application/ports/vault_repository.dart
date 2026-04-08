import '../../domain/entities/stored_vault_file.dart';

abstract interface class VaultRepository {
  Future<bool> exists();

  Future<StoredVaultFile?> read();

  Future<void> write(StoredVaultFile vaultFile);
}
