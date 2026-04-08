import 'dart:async';

typedef TimerStarter =
    Timer Function(Duration duration, void Function() callback);

class InactivitySessionMonitor {
  InactivitySessionMonitor({
    required this.timeout,
    required this.onTimeout,
    TimerStarter? timerStarter,
  }) : _timerStarter =
           timerStarter ?? ((duration, callback) => Timer(duration, callback));

  final Duration timeout;
  final void Function() onTimeout;
  final TimerStarter _timerStarter;

  Timer? _timer;

  void start() {
    _reset();
  }

  void markActivity() {
    _reset();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _reset() {
    _timer?.cancel();
    _timer = _timerStarter(timeout, onTimeout);
  }
}
