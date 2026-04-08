class CredentialItem {
  const CredentialItem({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
    this.url = '',
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String username;
  final String password;
  final String url;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  CredentialItem copyWith({
    String? id,
    String? title,
    String? username,
    String? password,
    String? url,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CredentialItem(
      id: id ?? this.id,
      title: title ?? this.title,
      username: username ?? this.username,
      password: password ?? this.password,
      url: url ?? this.url,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'username': username,
      'password': password,
      'url': url,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CredentialItem.fromJson(Map<String, dynamic> json) {
    return CredentialItem(
      id: json['id'] as String,
      title: json['title'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      url: json['url'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
