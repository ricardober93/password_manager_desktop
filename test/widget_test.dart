import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager_desktop/app.dart';
import 'package:password_manager_desktop/application/use_cases/add_credential_use_case.dart';
import 'package:password_manager_desktop/application/use_cases/copy_password_to_clipboard_use_case.dart';
import 'package:password_manager_desktop/application/use_cases/copy_username_to_clipboard_use_case.dart';
import 'package:password_manager_desktop/application/use_cases/create_vault_use_case.dart';
import 'package:password_manager_desktop/application/use_cases/delete_credential_use_case.dart';
import 'package:password_manager_desktop/application/use_cases/generate_password_use_case.dart';
import 'package:password_manager_desktop/application/use_cases/list_credentials_use_case.dart';
import 'package:password_manager_desktop/application/use_cases/lock_vault_use_case.dart';
import 'package:password_manager_desktop/application/use_cases/search_credentials_use_case.dart';
import 'package:password_manager_desktop/application/use_cases/unlock_vault_use_case.dart';
import 'package:password_manager_desktop/application/use_cases/update_credential_use_case.dart';
import 'package:password_manager_desktop/presentation/app_controller.dart';

import 'support/test_doubles.dart';

void main() {
  testWidgets('creates a vault and saves a credential from the UI', (
    WidgetTester tester,
  ) async {
    final InMemoryVaultRepository repository = InMemoryVaultRepository();
    final FakeCryptoService cryptoService = FakeCryptoService();
    final FixedClock clock = FixedClock(DateTime.utc(2026, 4, 8, 12));
    final RecordingClipboardService clipboard = RecordingClipboardService();
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
        clipboardService: clipboard,
      ),
      copyPasswordToClipboardUseCase: CopyPasswordToClipboardUseCase(
        clipboardService: clipboard,
      ),
      generatePasswordUseCase: GeneratePasswordUseCase(),
    );

    await tester.pumpWidget(PasswordManagerApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('Create your local vault'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Master password'),
      'password-123',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Confirm password'),
      'password-123',
    );
    await tester.tap(find.text('Create vault'));
    await tester.pumpAndSettle();

    expect(find.text('Local Vault'), findsOneWidget);

    await tester.tap(find.text('Add credential'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Title'), 'GitHub');
    await tester.enterText(
      find.widgetWithText(TextField, 'Username'),
      'ricardo',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'secret',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('GitHub'), findsOneWidget);
  });

  testWidgets('shows unlock flow when a vault already exists', (
    WidgetTester tester,
  ) async {
    final InMemoryVaultRepository repository = InMemoryVaultRepository();
    final FakeCryptoService cryptoService = FakeCryptoService();
    final FixedClock clock = FixedClock(DateTime.utc(2026, 4, 8, 12));
    final CreateVaultUseCase createVaultUseCase = CreateVaultUseCase(
      repository: repository,
      cryptoService: cryptoService,
      clock: clock,
    );
    await createVaultUseCase.execute(
      masterPassword: 'password-123',
      confirmPassword: 'password-123',
    );

    final AppController controller = AppController(
      vaultExists: repository.exists,
      createVaultUseCase: createVaultUseCase,
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
        clipboardService: RecordingClipboardService(),
      ),
      copyPasswordToClipboardUseCase: CopyPasswordToClipboardUseCase(
        clipboardService: RecordingClipboardService(),
      ),
      generatePasswordUseCase: GeneratePasswordUseCase(),
    );

    await tester.pumpWidget(PasswordManagerApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('Unlock vault'), findsOneWidget);
  });
}
