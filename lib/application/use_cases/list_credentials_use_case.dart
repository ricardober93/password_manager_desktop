import '../../domain/entities/credential_item.dart';
import '../../domain/entities/vault_session.dart';

class ListCredentialsUseCase {
  const ListCredentialsUseCase();

  List<CredentialItem> execute(VaultSession session) {
    final List<CredentialItem> items = List<CredentialItem>.from(
      session.vaultData.credentials,
    );
    items.sort(
      (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    );
    return items;
  }
}
