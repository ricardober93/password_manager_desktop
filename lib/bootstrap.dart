import 'app.dart';
import 'application/use_cases/add_credential_use_case.dart';
import 'application/use_cases/copy_password_to_clipboard_use_case.dart';
import 'application/use_cases/copy_username_to_clipboard_use_case.dart';
import 'application/use_cases/create_vault_use_case.dart';
import 'application/use_cases/delete_credential_use_case.dart';
import 'application/use_cases/generate_password_use_case.dart';
import 'application/use_cases/list_credentials_use_case.dart';
import 'application/use_cases/lock_vault_use_case.dart';
import 'application/use_cases/search_credentials_use_case.dart';
import 'application/use_cases/unlock_vault_use_case.dart';
import 'application/use_cases/update_credential_use_case.dart';
import 'infrastructure/crypto/cryptography_crypto_service.dart';
import 'infrastructure/storage/local_vault_repository.dart';
import 'infrastructure/system/flutter_clipboard_service.dart';
import 'infrastructure/system/system_clock.dart';
import 'presentation/app_controller.dart';

Future<PasswordManagerApp> buildApp() async {
  final LocalVaultRepository repository = await LocalVaultRepository.create();
  final CryptographyCryptoService cryptoService = CryptographyCryptoService();
  const SystemClock clock = SystemClock();
  final FlutterClipboardService clipboardService = FlutterClipboardService();

  final AppController controller = AppController(
    vaultExists: repository.exists,
    createVaultUseCase: CreateVaultUseCase(
      repository: repository,
      cryptoService: cryptoService,
      clock: clock,
    ),
    unlockVaultUseCase: UnlockVaultUseCase(
      repository: repository,
      cryptoService: cryptoService,
      clock: clock,
    ),
    lockVaultUseCase: LockVaultUseCase(clock: clock),
    addCredentialUseCase: AddCredentialUseCase(
      repository: repository,
      cryptoService: cryptoService,
      clock: clock,
    ),
    updateCredentialUseCase: UpdateCredentialUseCase(
      repository: repository,
      cryptoService: cryptoService,
      clock: clock,
    ),
    deleteCredentialUseCase: DeleteCredentialUseCase(
      repository: repository,
      cryptoService: cryptoService,
      clock: clock,
    ),
    listCredentialsUseCase: const ListCredentialsUseCase(),
    searchCredentialsUseCase: const SearchCredentialsUseCase(),
    copyUsernameToClipboardUseCase: CopyUsernameToClipboardUseCase(
      clipboardService: clipboardService,
    ),
    copyPasswordToClipboardUseCase: CopyPasswordToClipboardUseCase(
      clipboardService: clipboardService,
    ),
    generatePasswordUseCase: GeneratePasswordUseCase(),
  );

  return PasswordManagerApp(controller: controller);
}
