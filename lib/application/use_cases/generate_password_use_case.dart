import 'dart:math';

import '../../domain/entities/password_policy.dart';
import '../../domain/exceptions/vault_exception.dart';

class GeneratePasswordUseCase {
  GeneratePasswordUseCase({Random? random})
    : _random = random ?? Random.secure();

  final Random _random;

  static const String _uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _lowercase = 'abcdefghijklmnopqrstuvwxyz';
  static const String _digits = '0123456789';
  static const String _symbols = r'!@#$%^&*()-_=+[]{};:,.<>?';

  String execute({PasswordPolicy policy = const PasswordPolicy()}) {
    final List<String> pools = <String>[
      if (policy.includeUppercase) _uppercase,
      if (policy.includeLowercase) _lowercase,
      if (policy.includeDigits) _digits,
      if (policy.includeSymbols) _symbols,
    ];
    if (pools.isEmpty) {
      throw const VaultException(
        'At least one character class must be enabled.',
      );
    }
    if (policy.length < pools.length) {
      throw const VaultException(
        'Password length must be at least the number of enabled character classes.',
      );
    }

    final List<String> characters = <String>[];
    for (final pool in pools) {
      characters.add(pool[_random.nextInt(pool.length)]);
    }

    final String combined = pools.join();
    while (characters.length < policy.length) {
      characters.add(combined[_random.nextInt(combined.length)]);
    }
    characters.shuffle(_random);
    return characters.join();
  }
}
