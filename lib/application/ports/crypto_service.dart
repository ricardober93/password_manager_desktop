import '../../domain/entities/stored_vault_file.dart';
import '../../domain/entities/vault_access_key.dart';
import '../../domain/entities/vault_data.dart';

abstract interface class CryptoService {
  List<int> generateSalt();

  Future<VaultAccessKey> deriveKey({
    required String password,
    required List<int> salt,
    required int iterations,
  });

  Future<StoredVaultFile> encrypt({
    required VaultData vaultData,
    required VaultAccessKey accessKey,
    required List<int> salt,
    required int iterations,
    required DateTime updatedAt,
  });

  Future<VaultData> decrypt({
    required StoredVaultFile storedVaultFile,
    required VaultAccessKey accessKey,
  });
}
