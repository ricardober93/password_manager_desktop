import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager_desktop/domain/entities/vault_data.dart';
import 'package:password_manager_desktop/domain/exceptions/vault_exception.dart';
import 'package:password_manager_desktop/infrastructure/crypto/cryptography_crypto_service.dart';

void main() {
  test('derives a key and encrypts/decrypts a vault round-trip', () async {
    final CryptographyCryptoService service = CryptographyCryptoService();
    final List<int> salt = service.generateSalt();
    final accessKey = await service.deriveKey(
      password: 'password-123',
      salt: salt,
      iterations: 150000,
    );
    final VaultData vault = VaultData(
      credentials: const [],
      createdAt: DateTime.utc(2026, 4, 8, 12),
      updatedAt: DateTime.utc(2026, 4, 8, 12),
    );

    final encrypted = await service.encrypt(
      vaultData: vault,
      accessKey: accessKey,
      salt: salt,
      iterations: 150000,
      updatedAt: vault.updatedAt,
    );
    final decrypted = await service.decrypt(
      storedVaultFile: encrypted,
      accessKey: accessKey,
    );

    expect(decrypted.createdAt, vault.createdAt);
    expect(decrypted.credentials, isEmpty);
  });

  test('rejects decrypting with the wrong password-derived key', () async {
    final CryptographyCryptoService service = CryptographyCryptoService();
    final List<int> salt = service.generateSalt();
    final correctKey = await service.deriveKey(
      password: 'password-123',
      salt: salt,
      iterations: 150000,
    );
    final wrongKey = await service.deriveKey(
      password: 'wrong-password',
      salt: salt,
      iterations: 150000,
    );
    final VaultData vault = VaultData(
      credentials: const [],
      createdAt: DateTime.utc(2026, 4, 8, 12),
      updatedAt: DateTime.utc(2026, 4, 8, 12),
    );
    final encrypted = await service.encrypt(
      vaultData: vault,
      accessKey: correctKey,
      salt: salt,
      iterations: 150000,
      updatedAt: vault.updatedAt,
    );

    expect(
      () => service.decrypt(storedVaultFile: encrypted, accessKey: wrongKey),
      throwsA(isA<VaultException>()),
    );
  });
}
