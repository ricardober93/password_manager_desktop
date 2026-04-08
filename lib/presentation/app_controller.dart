import 'package:flutter/foundation.dart';

import '../application/services/inactivity_session_monitor.dart';
import '../application/use_cases/add_credential_use_case.dart';
import '../application/use_cases/copy_password_to_clipboard_use_case.dart';
import '../application/use_cases/copy_username_to_clipboard_use_case.dart';
import '../application/use_cases/create_vault_use_case.dart';
import '../application/use_cases/delete_credential_use_case.dart';
import '../application/use_cases/generate_password_use_case.dart';
import '../application/use_cases/list_credentials_use_case.dart';
import '../application/use_cases/lock_vault_use_case.dart';
import '../application/use_cases/search_credentials_use_case.dart';
import '../application/use_cases/unlock_vault_use_case.dart';
import '../application/use_cases/update_credential_use_case.dart';
import '../domain/entities/credential_draft.dart';
import '../domain/entities/credential_item.dart';
import '../domain/entities/password_policy.dart';
import '../domain/entities/vault_session.dart';
import '../domain/exceptions/vault_exception.dart';

enum AppStage { loading, setup, locked, unlocked }

class AppController extends ChangeNotifier {
  AppController({
    required Future<bool> Function() vaultExists,
    required CreateVaultUseCase createVaultUseCase,
    required UnlockVaultUseCase unlockVaultUseCase,
    required LockVaultUseCase lockVaultUseCase,
    required AddCredentialUseCase addCredentialUseCase,
    required UpdateCredentialUseCase updateCredentialUseCase,
    required DeleteCredentialUseCase deleteCredentialUseCase,
    required ListCredentialsUseCase listCredentialsUseCase,
    required SearchCredentialsUseCase searchCredentialsUseCase,
    required CopyUsernameToClipboardUseCase copyUsernameToClipboardUseCase,
    required CopyPasswordToClipboardUseCase copyPasswordToClipboardUseCase,
    required GeneratePasswordUseCase generatePasswordUseCase,
  }) : _vaultExists = vaultExists,
       _createVaultUseCase = createVaultUseCase,
       _unlockVaultUseCase = unlockVaultUseCase,
       _lockVaultUseCase = lockVaultUseCase,
       _addCredentialUseCase = addCredentialUseCase,
       _updateCredentialUseCase = updateCredentialUseCase,
       _deleteCredentialUseCase = deleteCredentialUseCase,
       _listCredentialsUseCase = listCredentialsUseCase,
       _searchCredentialsUseCase = searchCredentialsUseCase,
       _copyUsernameToClipboardUseCase = copyUsernameToClipboardUseCase,
       _copyPasswordToClipboardUseCase = copyPasswordToClipboardUseCase,
       _generatePasswordUseCase = generatePasswordUseCase;

  final Future<bool> Function() _vaultExists;
  final CreateVaultUseCase _createVaultUseCase;
  final UnlockVaultUseCase _unlockVaultUseCase;
  final LockVaultUseCase _lockVaultUseCase;
  final AddCredentialUseCase _addCredentialUseCase;
  final UpdateCredentialUseCase _updateCredentialUseCase;
  final DeleteCredentialUseCase _deleteCredentialUseCase;
  final ListCredentialsUseCase _listCredentialsUseCase;
  final SearchCredentialsUseCase _searchCredentialsUseCase;
  final CopyUsernameToClipboardUseCase _copyUsernameToClipboardUseCase;
  final CopyPasswordToClipboardUseCase _copyPasswordToClipboardUseCase;
  final GeneratePasswordUseCase _generatePasswordUseCase;

  AppStage _stage = AppStage.loading;
  VaultSession? _session;
  String _query = '';
  String? _errorMessage;
  String? _noticeMessage;
  InactivitySessionMonitor? _monitor;

  AppStage get stage => _stage;
  VaultSession? get session => _session;
  String get query => _query;
  String? get errorMessage => _errorMessage;
  String? get noticeMessage => _noticeMessage;
  PasswordPolicy get defaultPolicy =>
      _session?.vaultData.defaultPasswordPolicy ?? const PasswordPolicy();

  List<CredentialItem> get visibleCredentials {
    final VaultSession? session = _session;
    if (session == null) {
      return const <CredentialItem>[];
    }
    final List<CredentialItem> result = _query.trim().isEmpty
        ? _listCredentialsUseCase.execute(session)
        : _searchCredentialsUseCase.execute(session: session, query: _query);
    result.sort(
      (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    );
    return result;
  }

  Future<void> initialize() async {
    _stage = AppStage.loading;
    notifyListeners();
    final bool exists = await _vaultExists();
    _stage = exists ? AppStage.locked : AppStage.setup;
    notifyListeners();
  }

  Future<bool> createVault({
    required String masterPassword,
    required String confirmPassword,
  }) async {
    try {
      _stage = AppStage.loading;
      notifyListeners();
      _session = await _createVaultUseCase.execute(
        masterPassword: masterPassword,
        confirmPassword: confirmPassword,
      );
      _query = '';
      _errorMessage = null;
      _noticeMessage = 'Vault created successfully.';
      _stage = AppStage.unlocked;
      _restartMonitor();
      notifyListeners();
      return true;
    } on VaultException catch (error) {
      _errorMessage = error.message;
      _stage = AppStage.setup;
      notifyListeners();
      return false;
    }
  }

  Future<bool> unlockVault(String masterPassword) async {
    try {
      _stage = AppStage.loading;
      notifyListeners();
      _session = await _unlockVaultUseCase.execute(
        masterPassword: masterPassword,
      );
      _query = '';
      _errorMessage = null;
      _noticeMessage = 'Vault unlocked.';
      _stage = AppStage.unlocked;
      _restartMonitor();
      notifyListeners();
      return true;
    } on VaultException catch (error) {
      _errorMessage = error.message;
      _stage = AppStage.locked;
      notifyListeners();
      return false;
    }
  }

  void lockVault({bool automatic = false}) {
    _lockVaultUseCase.execute();
    _monitor?.stop();
    _monitor = null;
    _session = null;
    _query = '';
    _stage = AppStage.locked;
    _noticeMessage = automatic
        ? 'Vault locked after inactivity.'
        : 'Vault locked.';
    notifyListeners();
  }

  void updateQuery(String value) {
    _query = value;
    _touch();
    notifyListeners();
  }

  Future<void> saveCredential({
    String? credentialId,
    required CredentialDraft draft,
  }) async {
    final VaultSession currentSession = _requireSession();
    _session = credentialId == null
        ? await _addCredentialUseCase.execute(
            session: currentSession,
            draft: draft,
          )
        : await _updateCredentialUseCase.execute(
            session: currentSession,
            credentialId: credentialId,
            draft: draft,
          );
    _noticeMessage = credentialId == null
        ? 'Credential added.'
        : 'Credential updated.';
    _errorMessage = null;
    _touch();
    notifyListeners();
  }

  Future<void> deleteCredential(String credentialId) async {
    _session = await _deleteCredentialUseCase.execute(
      session: _requireSession(),
      credentialId: credentialId,
    );
    _noticeMessage = 'Credential deleted.';
    _errorMessage = null;
    _touch();
    notifyListeners();
  }

  Future<void> copyUsername(CredentialItem credential) async {
    await _copyUsernameToClipboardUseCase.execute(credential);
    _noticeMessage = 'Username copied to clipboard.';
    _touch();
    notifyListeners();
  }

  Future<void> copyPassword(CredentialItem credential) async {
    final VaultSession session = _requireSession();
    await _copyPasswordToClipboardUseCase.execute(
      credential: credential,
      clearAfter: Duration(seconds: session.vaultData.clipboardClearSeconds),
    );
    _noticeMessage = 'Password copied. Clipboard cleanup scheduled.';
    _touch();
    notifyListeners();
  }

  String generatePassword([PasswordPolicy? policy]) {
    final String password = _generatePasswordUseCase.execute(
      policy: policy ?? defaultPolicy,
    );
    _touch();
    return password;
  }

  void clearMessages() {
    _errorMessage = null;
    _noticeMessage = null;
    notifyListeners();
  }

  VaultSession _requireSession() {
    final VaultSession? session = _session;
    if (session == null) {
      throw const VaultException('Vault is locked.');
    }
    return session;
  }

  void _touch() {
    _monitor?.markActivity();
  }

  void _restartMonitor() {
    _monitor?.stop();
    final VaultSession? session = _session;
    if (session == null) {
      return;
    }
    _monitor = InactivitySessionMonitor(
      timeout: Duration(seconds: session.vaultData.inactivityTimeoutSeconds),
      onTimeout: () {
        lockVault(automatic: true);
      },
    )..start();
  }
}
