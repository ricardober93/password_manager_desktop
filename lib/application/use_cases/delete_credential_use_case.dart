import '../../domain/entities/vault_session.dart';
import '../../domain/exceptions/vault_exception.dart';
import '../ports/clock.dart';
import '../ports/crypto_service.dart';
import '../ports/vault_repository.dart';

class DeleteCredentialUseCase {
  const DeleteCredentialUseCase({
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
    required VaultSession session,
    required String credentialId,
  }) async {
    final updatedCredentials = session.vaultData.credentials
        .where((item) => item.id != credentialId)
        .toList();
    if (updatedCredentials.length == session.vaultData.credentials.length) {
      throw const VaultException('Credential not found.');
    }
    final DateTime now = _clock.now();
    final updatedVault = session.vaultData.copyWith(
      credentials: updatedCredentials,
      updatedAt: now,
    );
    final encryptedVault = await _cryptoService.encrypt(
      vaultData: updatedVault,
      accessKey: session.accessKey,
      salt: session.salt,
      iterations: session.iterations,
      updatedAt: now,
    );
    await _repository.write(encryptedVault);
    return session.copyWith(vaultData: updatedVault, lastActivityAt: now);
  }
}
