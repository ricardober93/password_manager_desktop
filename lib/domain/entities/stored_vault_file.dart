import 'dart:convert';
import 'dart:typed_data';

class StoredVaultFile {
  const StoredVaultFile({
    required this.version,
    required this.kdfAlgorithm,
    required this.iterations,
    required this.salt,
    required this.nonce,
    required this.mac,
    required this.cipherText,
    required this.updatedAt,
  });

  final int version;
  final String kdfAlgorithm;
  final int iterations;
  final Uint8List salt;
  final Uint8List nonce;
  final Uint8List mac;
  final Uint8List cipherText;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'version': version,
      'kdfAlgorithm': kdfAlgorithm,
      'iterations': iterations,
      'salt': base64Encode(salt),
      'nonce': base64Encode(nonce),
      'mac': base64Encode(mac),
      'cipherText': base64Encode(cipherText),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory StoredVaultFile.fromJson(Map<String, dynamic> json) {
    return StoredVaultFile(
      version: json['version'] as int,
      kdfAlgorithm: json['kdfAlgorithm'] as String,
      iterations: json['iterations'] as int,
      salt: Uint8List.fromList(base64Decode(json['salt'] as String)),
      nonce: Uint8List.fromList(base64Decode(json['nonce'] as String)),
      mac: Uint8List.fromList(base64Decode(json['mac'] as String)),
      cipherText: Uint8List.fromList(
        base64Decode(json['cipherText'] as String),
      ),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
