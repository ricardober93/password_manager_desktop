import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager_desktop/application/use_cases/generate_password_use_case.dart';
import 'package:password_manager_desktop/domain/entities/password_policy.dart';

void main() {
  test('generates a password using the default policy', () {
    final GeneratePasswordUseCase useCase = GeneratePasswordUseCase(
      random: Random(42),
    );

    final String password = useCase.execute();

    expect(password, hasLength(20));
  });

  test('respects a custom password policy', () {
    final GeneratePasswordUseCase useCase = GeneratePasswordUseCase(
      random: Random(42),
    );

    final String password = useCase.execute(
      policy: const PasswordPolicy(
        length: 12,
        includeUppercase: false,
        includeLowercase: true,
        includeDigits: true,
        includeSymbols: false,
      ),
    );

    expect(password, hasLength(12));
    expect(RegExp(r'[A-Z]').hasMatch(password), isFalse);
    expect(RegExp(r'[a-z]').hasMatch(password), isTrue);
    expect(RegExp(r'\d').hasMatch(password), isTrue);
    expect(
      RegExp(r'[!@#$%^&*()\-_=+\[\]{};:,.<>?]').hasMatch(password),
      isFalse,
    );
  });
}
