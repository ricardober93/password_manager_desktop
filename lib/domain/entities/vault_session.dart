import 'vault_access_key.dart';
import 'vault_data.dart';

class VaultSession {
  const VaultSession({
    required this.accessKey,
    required this.salt,
    required this.iterations,
    required this.vaultData,
    required this.lastActivityAt,
  });

  final VaultAccessKey accessKey;
  final List<int> salt;
  final int iterations;
  final VaultData vaultData;
  final DateTime lastActivityAt;

  VaultSession copyWith({
    VaultAccessKey? accessKey,
    List<int>? salt,
    int? iterations,
    VaultData? vaultData,
    DateTime? lastActivityAt,
  }) {
    return VaultSession(
      accessKey: accessKey ?? this.accessKey,
      salt: salt ?? this.salt,
      iterations: iterations ?? this.iterations,
      vaultData: vaultData ?? this.vaultData,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    );
  }
}
