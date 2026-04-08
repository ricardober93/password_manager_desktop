abstract interface class ClipboardService {
  Future<void> copyText(String text);

  Future<void> clear();

  void scheduleClear(Duration delay);
}
