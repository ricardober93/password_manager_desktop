import 'credential_item.dart';
import 'password_policy.dart';

class VaultData {
  const VaultData({
    required this.credentials,
    required this.createdAt,
    required this.updatedAt,
    this.clipboardClearSeconds = 20,
    this.inactivityTimeoutSeconds = 300,
    this.defaultPasswordPolicy = const PasswordPolicy(),
  });

  final List<CredentialItem> credentials;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int clipboardClearSeconds;
  final int inactivityTimeoutSeconds;
  final PasswordPolicy defaultPasswordPolicy;

  VaultData copyWith({
    List<CredentialItem>? credentials,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? clipboardClearSeconds,
    int? inactivityTimeoutSeconds,
    PasswordPolicy? defaultPasswordPolicy,
  }) {
    return VaultData(
      credentials: credentials ?? this.credentials,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      clipboardClearSeconds:
          clipboardClearSeconds ?? this.clipboardClearSeconds,
      inactivityTimeoutSeconds:
          inactivityTimeoutSeconds ?? this.inactivityTimeoutSeconds,
      defaultPasswordPolicy:
          defaultPasswordPolicy ?? this.defaultPasswordPolicy,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'credentials': credentials.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'clipboardClearSeconds': clipboardClearSeconds,
      'inactivityTimeoutSeconds': inactivityTimeoutSeconds,
      'defaultPasswordPolicy': defaultPasswordPolicy.toJson(),
    };
  }

  factory VaultData.fromJson(Map<String, dynamic> json) {
    return VaultData(
      credentials: (json['credentials'] as List<dynamic>? ?? <dynamic>[])
          .map((item) => CredentialItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      clipboardClearSeconds: json['clipboardClearSeconds'] as int? ?? 20,
      inactivityTimeoutSeconds: json['inactivityTimeoutSeconds'] as int? ?? 300,
      defaultPasswordPolicy: PasswordPolicy.fromJson(
        json['defaultPasswordPolicy'] as Map<String, dynamic>? ??
            const <String, dynamic>{},
      ),
    );
  }
}
