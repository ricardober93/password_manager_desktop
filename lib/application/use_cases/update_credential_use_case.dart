import '../../domain/entities/credential_draft.dart';
import '../../domain/entities/credential_item.dart';
import '../../domain/entities/vault_session.dart';
import '../../domain/exceptions/vault_exception.dart';
import '../ports/clock.dart';
import '../ports/crypto_service.dart';
import '../ports/vault_repository.dart';

class UpdateCredentialUseCase {
  const UpdateCredentialUseCase({
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
    required CredentialDraft draft,
  }) async {
    final CredentialItem? existing = session.vaultData.credentials
        .cast<CredentialItem?>()
        .firstWhere((item) => item?.id == credentialId, orElse: () => null);
    if (existing == null) {
      throw const VaultException('Credential not found.');
    }

    final DateTime now = _clock.now();
    final CredentialItem updated = existing.copyWith(
      title: draft.title.trim(),
      username: draft.username.trim(),
      password: draft.password,
      url: draft.url.trim(),
      notes: draft.notes.trim(),
      updatedAt: now,
    );
    final updatedVault = session.vaultData.copyWith(
      credentials: session.vaultData.credentials
          .map((item) => item.id == credentialId ? updated : item)
          .toList(),
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
