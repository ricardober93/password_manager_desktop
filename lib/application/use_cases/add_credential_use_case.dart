import '../../domain/entities/credential_draft.dart';
import '../../domain/entities/credential_item.dart';
import '../../domain/entities/vault_session.dart';
import '../../domain/exceptions/vault_exception.dart';
import '../ports/clock.dart';
import '../ports/crypto_service.dart';
import '../ports/vault_repository.dart';

class AddCredentialUseCase {
  const AddCredentialUseCase({
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
    required CredentialDraft draft,
  }) async {
    if (draft.title.trim().isEmpty || draft.password.isEmpty) {
      throw const VaultException('Title and password are required.');
    }

    final DateTime now = _clock.now();
    final CredentialItem item = CredentialItem(
      id: '${now.microsecondsSinceEpoch}-${draft.title.hashCode.abs()}',
      title: draft.title.trim(),
      username: draft.username.trim(),
      password: draft.password,
      url: draft.url.trim(),
      notes: draft.notes.trim(),
      createdAt: now,
      updatedAt: now,
    );

    final updatedVault = session.vaultData.copyWith(
      credentials: <CredentialItem>[...session.vaultData.credentials, item],
      updatedAt: now,
    );
    return _persist(session: session, updatedVault: updatedVault, now: now);
  }

  Future<VaultSession> _persist({
    required VaultSession session,
    required updatedVault,
    required DateTime now,
  }) async {
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
