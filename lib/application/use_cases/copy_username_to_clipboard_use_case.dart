import '../../domain/entities/credential_item.dart';
import '../ports/clipboard_service.dart';

class CopyUsernameToClipboardUseCase {
  const CopyUsernameToClipboardUseCase({
    required ClipboardService clipboardService,
  }) : _clipboardService = clipboardService;

  final ClipboardService _clipboardService;

  Future<void> execute(CredentialItem credential) {
    return _clipboardService.copyText(credential.username);
  }
}
