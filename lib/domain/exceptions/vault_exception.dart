class VaultException implements Exception {
  const VaultException(this.message);

  final String message;

  @override
  String toString() => message;
}
