import '../../domain/entities/credential_item.dart';
import '../../domain/entities/vault_session.dart';

class SearchCredentialsUseCase {
  const SearchCredentialsUseCase();

  List<CredentialItem> execute({
    required VaultSession session,
    required String query,
  }) {
    final String normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return List<CredentialItem>.from(session.vaultData.credentials);
    }
    return session.vaultData.credentials.where((item) {
      return item.title.toLowerCase().contains(normalized) ||
          item.username.toLowerCase().contains(normalized) ||
          item.url.toLowerCase().contains(normalized);
    }).toList();
  }
}
