import '../../domain/entities/credential_item.dart';
import '../ports/clipboard_service.dart';

class CopyPasswordToClipboardUseCase {
  const CopyPasswordToClipboardUseCase({
    required ClipboardService clipboardService,
  }) : _clipboardService = clipboardService;

  final ClipboardService _clipboardService;

  Future<void> execute({
    required CredentialItem credential,
    required Duration clearAfter,
  }) async {
    await _clipboardService.copyText(credential.password);
    _clipboardService.scheduleClear(clearAfter);
  }
}
