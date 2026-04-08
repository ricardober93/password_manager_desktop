import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager_desktop/application/services/inactivity_session_monitor.dart';

void main() {
  test('triggers timeout after inactivity', () {
    fakeAsync((async) {
      int timeoutCount = 0;
      final InactivitySessionMonitor monitor = InactivitySessionMonitor(
        timeout: const Duration(seconds: 5),
        onTimeout: () {
          timeoutCount++;
        },
      );

      monitor.start();
      async.elapse(const Duration(seconds: 4));
      expect(timeoutCount, 0);

      async.elapse(const Duration(seconds: 1));
      expect(timeoutCount, 1);
    });
  });

  test('resets the timer when activity is recorded', () {
    fakeAsync((async) {
      int timeoutCount = 0;
      final InactivitySessionMonitor monitor = InactivitySessionMonitor(
        timeout: const Duration(seconds: 5),
        onTimeout: () {
          timeoutCount++;
        },
      );

      monitor.start();
      async.elapse(const Duration(seconds: 3));
      monitor.markActivity();
      async.elapse(const Duration(seconds: 3));
      expect(timeoutCount, 0);

      async.elapse(const Duration(seconds: 2));
      expect(timeoutCount, 1);
    });
  });
}
