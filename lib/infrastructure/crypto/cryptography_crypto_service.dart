import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../../application/ports/crypto_service.dart';
import '../../domain/entities/stored_vault_file.dart';
import '../../domain/entities/vault_access_key.dart';
import '../../domain/entities/vault_data.dart';
import '../../domain/exceptions/vault_exception.dart';

class CryptographyCryptoService implements CryptoService {
  CryptographyCryptoService({AesGcm? cipher, Random? random})
    : _cipher = cipher ?? AesGcm.with256bits(),
      _random = random ?? Random.secure();

  final AesGcm _cipher;
  final Random _random;

  @override
  Future<VaultData> decrypt({
    required StoredVaultFile storedVaultFile,
    required VaultAccessKey accessKey,
  }) async {
    try {
      final SecretBox secretBox = SecretBox(
        storedVaultFile.cipherText,
        nonce: storedVaultFile.nonce,
        mac: Mac(storedVaultFile.mac),
      );
      final List<int> clearBytes = await _cipher.decrypt(
        secretBox,
        secretKey: SecretKey(accessKey.bytes),
      );
      final Map<String, dynamic> decoded =
          jsonDecode(utf8.decode(clearBytes)) as Map<String, dynamic>;
      return VaultData.fromJson(decoded);
    } on SecretBoxAuthenticationError {
      throw const VaultException('Vault integrity check failed.');
    } catch (error) {
      throw VaultException('Failed to decrypt vault: $error');
    }
  }

  @override
  Future<VaultAccessKey> deriveKey({
    required String password,
    required List<int> salt,
    required int iterations,
  }) async {
    final Pbkdf2 pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: 256,
    );

    final SecretKey secretKey = await pbkdf2.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );
    final List<int> extracted = await secretKey.extractBytes();
    return VaultAccessKey(extracted);
  }

  @override
  Future<StoredVaultFile> encrypt({
    required VaultData vaultData,
    required VaultAccessKey accessKey,
    required List<int> salt,
    required int iterations,
    required DateTime updatedAt,
  }) async {
    final List<int> nonce = _randomBytes(12);
    final List<int> clearText = utf8.encode(jsonEncode(vaultData.toJson()));
    final SecretBox secretBox = await _cipher.encrypt(
      clearText,
      secretKey: SecretKey(accessKey.bytes),
      nonce: nonce,
    );
    return StoredVaultFile(
      version: 1,
      kdfAlgorithm: 'pbkdf2-sha256',
      iterations: iterations,
      salt: Uint8List.fromList(salt),
      nonce: Uint8List.fromList(secretBox.nonce),
      mac: Uint8List.fromList(secretBox.mac.bytes),
      cipherText: Uint8List.fromList(secretBox.cipherText),
      updatedAt: updatedAt,
    );
  }

  @override
  List<int> generateSalt() => _randomBytes(16);

  List<int> _randomBytes(int length) {
    return List<int>.generate(length, (_) => _random.nextInt(256));
  }
}
