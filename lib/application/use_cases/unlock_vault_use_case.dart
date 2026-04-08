import '../../domain/entities/vault_session.dart';
import '../../domain/exceptions/vault_exception.dart';
import '../ports/clock.dart';
import '../ports/crypto_service.dart';
import '../ports/vault_repository.dart';

class UnlockVaultUseCase {
  const UnlockVaultUseCase({
    required VaultRepository repository,
    required CryptoService cryptoService,
    required Clock clock,
  }) : _repository = repository,
       _cryptoService = cryptoService,
       _clock = clock;

  final VaultRepository _repository;
  final CryptoService _cryptoService;
  final Clock _clock;

  Future<VaultSession> execute({required String masterPassword}) async {
    final storedVaultFile = await _repository.read();
    if (storedVaultFile == null) {
      throw const VaultException('No local vault exists yet.');
    }
    final accessKey = await _cryptoService.deriveKey(
      password: masterPassword,
      salt: storedVaultFile.salt,
      iterations: storedVaultFile.iterations,
    );
    final vaultData = await _cryptoService.decrypt(
      storedVaultFile: storedVaultFile,
      accessKey: accessKey,
    );
    return VaultSession(
      accessKey: accessKey,
      salt: storedVaultFile.salt,
      iterations: storedVaultFile.iterations,
      vaultData: vaultData,
      lastActivityAt: _clock.now(),
    );
  }
}
