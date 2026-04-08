import '../ports/clock.dart';

class LockVaultUseCase {
  const LockVaultUseCase({required Clock clock}) : _clock = clock;

  final Clock _clock;

  DateTime execute() => _clock.now();
}
