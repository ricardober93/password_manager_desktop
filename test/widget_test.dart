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
  AppController buildController({
    required InMemoryVaultRepository repository,
    required FakeCryptoService cryptoService,
    required FixedClock clock,
    RecordingClipboardService? clipboard,
  }) {
    final RecordingClipboardService clipboardService =
        clipboard ?? RecordingClipboardService();
    return AppController(
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
  }

  Future<void> pumpDesktopApp(
    WidgetTester tester,
    AppController controller,
  ) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(PasswordManagerApp(controller: controller));
    await tester.pump();
    await tester.pumpAndSettle();
  }

  testWidgets('creates a vault and saves a credential from the UI', (
    WidgetTester tester,
  ) async {
    final InMemoryVaultRepository repository = InMemoryVaultRepository();
    final FakeCryptoService cryptoService = FakeCryptoService();
    final FixedClock clock = FixedClock(DateTime.utc(2026, 4, 8, 12));
    final AppController controller = buildController(
      repository: repository,
      cryptoService: cryptoService,
      clock: clock,
    );

    await pumpDesktopApp(tester, controller);

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

    await tester.tap(find.text('Add credential').last);
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
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('GitHub'), findsWidgets);
    expect(find.text('Copy password'), findsOneWidget);

    controller.lockVault();
    await tester.pumpAndSettle();
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

    final AppController controller = buildController(
      repository: repository,
      cryptoService: cryptoService,
      clock: clock,
    );

    await pumpDesktopApp(tester, controller);

    expect(find.text('Unlock vault'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Master password'), findsOneWidget);
  });

  testWidgets('supports search, selection, empty state, and locking', (
    WidgetTester tester,
  ) async {
    final InMemoryVaultRepository repository = InMemoryVaultRepository();
    final FakeCryptoService cryptoService = FakeCryptoService();
    final FixedClock clock = FixedClock(DateTime.utc(2026, 4, 8, 12));
    final AppController controller = buildController(
      repository: repository,
      cryptoService: cryptoService,
      clock: clock,
    );

    await pumpDesktopApp(tester, controller);

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

    expect(find.text('No credentials yet'), findsOneWidget);

    Future<void> addCredential(String title, String username) async {
      await tester.tap(find.text('Add credential').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Title'), title);
      await tester.enterText(
        find.widgetWithText(TextField, 'Username'),
        username,
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        '${title.toLowerCase()}-secret',
      );
      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
    }

    await addCredential('GitHub', 'ricardo');
    await addCredential('Notion', 'workspace');

    await tester.enterText(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is TextField &&
            widget.decoration?.hintText == 'Search by title, username, or URL',
      ),
      'Notion',
    );
    await tester.pumpAndSettle();

    expect(find.text('Notion'), findsWidgets);

    await tester.tap(find.text('Notion').first);
    await tester.pumpAndSettle();

    expect(find.text('CREDENTIAL DETAIL'), findsOneWidget);
    expect(find.text('workspace'), findsWidgets);

    await tester.tap(find.byTooltip('Lock vault'));
    await tester.pumpAndSettle();

    expect(find.text('Unlock vault'), findsOneWidget);
  });
}
