class CredentialDraft {
  const CredentialDraft({
    required this.title,
    required this.username,
    required this.password,
    this.url = '',
    this.notes = '',
  });

  final String title;
  final String username;
  final String password;
  final String url;
  final String notes;
}
