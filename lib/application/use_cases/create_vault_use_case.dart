import '../../domain/entities/vault_data.dart';
import '../../domain/entities/vault_session.dart';
import '../../domain/exceptions/vault_exception.dart';
import '../ports/clock.dart';
import '../ports/crypto_service.dart';
import '../ports/vault_repository.dart';

class CreateVaultUseCase {
  const CreateVaultUseCase({
    required VaultRepository repository,
    required CryptoService cryptoService,
    required Clock clock,
  }) : _repository = repository,
       _cryptoService = cryptoService,
       _clock = clock;

  final VaultRepository _repository;
  final CryptoService _cryptoService;
  final Clock _clock;

  Future<VaultSession> execute({
    required String masterPassword,
    required String confirmPassword,
  }) async {
    if (masterPassword != confirmPassword) {
      throw const VaultException(
        'Master password confirmation does not match.',
      );
    }
    if (masterPassword.trim().length < 8) {
      throw const VaultException(
        'Master password must be at least 8 characters long.',
      );
    }
    if (await _repository.exists()) {
      throw const VaultException('A vault already exists on this device.');
    }

    final DateTime now = _clock.now();
    final List<int> salt = _cryptoService.generateSalt();
    const int iterations = 150000;
    final accessKey = await _cryptoService.deriveKey(
      password: masterPassword,
      salt: salt,
      iterations: iterations,
    );
    final VaultData vaultData = VaultData(
      credentials: const [],
      createdAt: now,
      updatedAt: now,
    );
    final vaultFile = await _cryptoService.encrypt(
      vaultData: vaultData,
      accessKey: accessKey,
      salt: salt,
      iterations: iterations,
      updatedAt: now,
    );
    await _repository.write(vaultFile);
    return VaultSession(
      accessKey: accessKey,
      salt: salt,
      iterations: iterations,
      vaultData: vaultData,
      lastActivityAt: now,
    );
  }
}
