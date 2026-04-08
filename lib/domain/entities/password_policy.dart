class PasswordPolicy {
  const PasswordPolicy({
    this.length = 20,
    this.includeUppercase = true,
    this.includeLowercase = true,
    this.includeDigits = true,
    this.includeSymbols = true,
  });

  final int length;
  final bool includeUppercase;
  final bool includeLowercase;
  final bool includeDigits;
  final bool includeSymbols;

  PasswordPolicy copyWith({
    int? length,
    bool? includeUppercase,
    bool? includeLowercase,
    bool? includeDigits,
    bool? includeSymbols,
  }) {
    return PasswordPolicy(
      length: length ?? this.length,
      includeUppercase: includeUppercase ?? this.includeUppercase,
      includeLowercase: includeLowercase ?? this.includeLowercase,
      includeDigits: includeDigits ?? this.includeDigits,
      includeSymbols: includeSymbols ?? this.includeSymbols,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'length': length,
      'includeUppercase': includeUppercase,
      'includeLowercase': includeLowercase,
      'includeDigits': includeDigits,
      'includeSymbols': includeSymbols,
    };
  }

  factory PasswordPolicy.fromJson(Map<String, dynamic> json) {
    return PasswordPolicy(
      length: json['length'] as int? ?? 20,
      includeUppercase: json['includeUppercase'] as bool? ?? true,
      includeLowercase: json['includeLowercase'] as bool? ?? true,
      includeDigits: json['includeDigits'] as bool? ?? true,
      includeSymbols: json['includeSymbols'] as bool? ?? true,
    );
  }
}
