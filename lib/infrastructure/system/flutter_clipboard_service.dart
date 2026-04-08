import 'dart:async';

import 'package:flutter/services.dart';

import '../../application/ports/clipboard_service.dart';

class FlutterClipboardService implements ClipboardService {
  Timer? _clearTimer;

  @override
  Future<void> clear() async {
    _clearTimer?.cancel();
    await Clipboard.setData(const ClipboardData(text: ''));
  }

  @override
  Future<void> copyText(String text) {
    _clearTimer?.cancel();
    return Clipboard.setData(ClipboardData(text: text));
  }

  @override
  void scheduleClear(Duration delay) {
    _clearTimer?.cancel();
    _clearTimer = Timer(delay, () {
      clear();
    });
  }
}
