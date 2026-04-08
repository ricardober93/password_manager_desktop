import 'dart:typed_data';

class VaultAccessKey {
  VaultAccessKey(List<int> bytes) : bytes = Uint8List.fromList(bytes);

  final Uint8List bytes;
}
