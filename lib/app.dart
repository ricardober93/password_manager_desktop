import 'package:flutter/material.dart';

import 'domain/entities/credential_draft.dart';
import 'domain/entities/credential_item.dart';
import 'domain/entities/password_policy.dart';
import 'presentation/app_controller.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/widgets/app_primitives.dart';

class PasswordManagerApp extends StatelessWidget {
  const PasswordManagerApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return MaterialApp(
          title: 'Password Manager Desktop',
          theme: AppTheme.light(),
          home: _AppScaffold(controller: controller),
        );
      },
    );
  }
}

class _AppScaffold extends StatefulWidget {
  const _AppScaffold({required this.controller});

  final AppController controller;

  @override
  State<_AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<_AppScaffold> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppController controller = widget.controller;
    return Scaffold(
      body: AppShell(
        child: SafeArea(
          child: switch (controller.stage) {
            AppStage.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            AppStage.setup => _SetupView(controller: controller),
            AppStage.locked => _UnlockView(controller: controller),
            AppStage.unlocked => _VaultView(controller: controller),
          },
        ),
      ),
    );
  }
}

class _SetupView extends StatefulWidget {
  const _SetupView({required this.controller});

  final AppController controller;

  @override
  State<_SetupView> createState() => _SetupViewState();
}

class _SetupViewState extends State<_SetupView> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AccessScreen(
      eyebrow: 'Local security',
      title: 'Create your local vault',
      subtitle:
          'Set a master password to encrypt the vault file stored on this device.',
      asideTitle: 'Quiet by default',
      asideDescription:
          'A minimal desktop vault with local-first encryption, calm states, and no account ceremony.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _FieldLabel('Master password'),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Master password',
              hintText: 'Enter a strong password',
            ),
          ),
          const SizedBox(height: 16),
          const _FieldLabel('Confirm password'),
          TextField(
            controller: _confirmController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Confirm password',
              hintText: 'Repeat the password',
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () async {
              await widget.controller.createVault(
                masterPassword: _passwordController.text,
                confirmPassword: _confirmController.text,
              );
            },
            child: const Text('Create vault'),
          ),
          const SizedBox(height: 16),
          _MessageDock(controller: widget.controller),
        ],
      ),
    );
  }
}

class _UnlockView extends StatefulWidget {
  const _UnlockView({required this.controller});

  final AppController controller;

  @override
  State<_UnlockView> createState() => _UnlockViewState();
}

class _UnlockViewState extends State<_UnlockView> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AccessScreen(
      eyebrow: 'Locked vault',
      title: 'Unlock vault',
      subtitle: 'Enter the master password to decrypt your local vault.',
      asideTitle: 'One action, no noise',
      asideDescription:
          'Unlock, review, copy, and edit credentials from one desktop workspace designed to stay out of the way.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _FieldLabel('Master password'),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Master password',
              hintText: 'Enter your master password',
            ),
            onSubmitted: (_) =>
                widget.controller.unlockVault(_passwordController.text),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () =>
                widget.controller.unlockVault(_passwordController.text),
            child: const Text('Unlock'),
          ),
          const SizedBox(height: 16),
          _MessageDock(controller: widget.controller),
        ],
      ),
    );
  }
}

class _VaultView extends StatefulWidget {
  const _VaultView({required this.controller});

  final AppController controller;

  @override
  State<_VaultView> createState() => _VaultViewState();
}

class _VaultViewState extends State<_VaultView> {
  String? _selectedCredentialId;
  CredentialItem? _editingCredential;
  bool _creatingNew = false;

  bool get _isEditing => _creatingNew || _editingCredential != null;

  void _openCreateEditor() {
    setState(() {
      _creatingNew = true;
      _editingCredential = null;
    });
  }

  void _openEditEditor(CredentialItem credential) {
    setState(() {
      _selectedCredentialId = credential.id;
      _creatingNew = false;
      _editingCredential = credential;
    });
  }

  void _selectCredential(String credentialId) {
    setState(() {
      _selectedCredentialId = credentialId;
      _creatingNew = false;
      _editingCredential = null;
    });
  }

  void _closeEditor(List<CredentialItem> credentials) {
    setState(() {
      _creatingNew = false;
      _editingCredential = null;
      _selectedCredentialId ??= credentials.isEmpty
          ? null
          : credentials.first.id;
    });
  }

  Future<void> _confirmDelete(CredentialItem credential) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete credential'),
          content: Text(
            'Remove ${credential.title} from the vault? This cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }
    await widget.controller.deleteCredential(credential.id);
    if (!mounted) {
      return;
    }
    setState(() {
      if (_selectedCredentialId == credential.id) {
        _selectedCredentialId = null;
      }
      if (_editingCredential?.id == credential.id) {
        _editingCredential = null;
      }
      _creatingNew = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppController controller = widget.controller;
    final List<CredentialItem> credentials = controller.visibleCredentials;
    CredentialItem? selectedCredential;
    if (_selectedCredentialId != null) {
      for (final CredentialItem item in credentials) {
        if (item.id == _selectedCredentialId) {
          selectedCredential = item;
          break;
        }
      }
    }
    selectedCredential ??= credentials.isEmpty ? null : credentials.first;
    final CredentialItem? detailCredential = _isEditing
        ? _editingCredential
        : selectedCredential;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: <Widget>[
          _VaultHeader(controller: controller, onAdd: _openCreateEditor),
          const SizedBox(height: 18),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(width: 180, child: _VaultRail()),
                const SizedBox(width: 18),
                Expanded(
                  flex: 12,
                  child: AppPanel(
                    child: Column(
                      children: <Widget>[
                        TextField(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search_rounded),
                            hintText: 'Search by title, username, or URL',
                          ),
                          onChanged: controller.updateQuery,
                        ),
                        const SizedBox(height: 18),
                        Expanded(
                          child: credentials.isEmpty
                              ? AppEmptyState(
                                  title: 'No credentials yet',
                                  description:
                                      'Add the first one to start using the vault.',
                                  action: FilledButton(
                                    onPressed: _openCreateEditor,
                                    child: const Text('Add credential'),
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: credentials.length,
                                  separatorBuilder: (_, index) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    final CredentialItem credential =
                                        credentials[index];
                                    final bool selected =
                                        !_isEditing &&
                                        credential.id == selectedCredential?.id;
                                    return _CredentialListItem(
                                      credential: credential,
                                      selected: selected,
                                      onTap: () =>
                                          _selectCredential(credential.id),
                                      onCopyUsername: () =>
                                          controller.copyUsername(credential),
                                      onCopyPassword: () =>
                                          controller.copyPassword(credential),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  flex: 11,
                  child: _isEditing
                      ? CredentialEditorPanel(
                          controller: controller,
                          existingCredential: _creatingNew
                              ? null
                              : _editingCredential,
                          onCancel: () => _closeEditor(credentials),
                          onSaved: (String credentialId) {
                            setState(() {
                              _selectedCredentialId = credentialId;
                              _creatingNew = false;
                              _editingCredential = null;
                            });
                          },
                        )
                      : CredentialDetailPanel(
                          controller: controller,
                          credential: detailCredential,
                          onCreate: _openCreateEditor,
                          onEdit: detailCredential == null
                              ? null
                              : () => _openEditEditor(detailCredential),
                          onDelete: detailCredential == null
                              ? null
                              : () => _confirmDelete(detailCredential),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 420,
              child: _MessageDock(controller: controller),
            ),
          ),
        ],
      ),
    );
  }
}

class _VaultHeader extends StatelessWidget {
  const _VaultHeader({required this.controller, required this.onAdd});

  final AppController controller;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(
          child: AppSectionHeading(
            eyebrow: 'Password vault',
            title: 'Local Vault',
            subtitle:
                'Browse, inspect, and edit credentials without leaving the desktop workspace.',
          ),
        ),
        FilledButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add credential'),
        ),
        const SizedBox(width: 10),
        IconButton(
          tooltip: 'Lock vault',
          onPressed: controller.lockVault,
          icon: const Icon(Icons.lock_outline_rounded),
        ),
      ],
    );
  }
}

class _VaultRail extends StatelessWidget {
  const _VaultRail();

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      padding: const EdgeInsets.all(16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AppSectionHeading(
            eyebrow: 'Workspace',
            title: 'Overview',
            subtitle: 'A sparse navigation rail for daily vault work.',
          ),
          SizedBox(height: 18),
          AppRailItem(
            icon: Icons.apps_outage_rounded,
            label: 'All items',
            selected: true,
          ),
          SizedBox(height: 8),
          AppRailItem(icon: Icons.access_time_rounded, label: 'Recent'),
          SizedBox(height: 8),
          AppRailItem(icon: Icons.security_rounded, label: 'Vault health'),
        ],
      ),
    );
  }
}

class _CredentialListItem extends StatelessWidget {
  const _CredentialListItem({
    required this.credential,
    required this.selected,
    required this.onTap,
    required this.onCopyUsername,
    required this.onCopyPassword,
  });

  final CredentialItem credential;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onCopyUsername;
  final VoidCallback onCopyPassword;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Ink(
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.accentSoft
              : Colors.white.withValues(alpha: 0.52),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: selected ? AppTheme.accent : AppTheme.line),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      credential.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      credential.username.isEmpty
                          ? (credential.url.isEmpty
                                ? 'No username'
                                : credential.url)
                          : credential.username,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Copy username',
                onPressed: onCopyUsername,
                icon: const Icon(Icons.person_outline_rounded),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Copy password',
                onPressed: onCopyPassword,
                icon: const Icon(Icons.key_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CredentialDetailPanel extends StatelessWidget {
  const CredentialDetailPanel({
    super.key,
    required this.controller,
    required this.credential,
    required this.onCreate,
    this.onEdit,
    this.onDelete,
  });

  final AppController controller;
  final CredentialItem? credential;
  final VoidCallback onCreate;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final CredentialItem? item = credential;
    return AppPanel(
      child: item == null
          ? AppEmptyState(
              title: 'Select a credential',
              description:
                  'Choose an item from the list to inspect its details, or create a new one.',
              action: FilledButton(
                onPressed: onCreate,
                child: const Text('Add credential'),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AppSectionHeading(
                  eyebrow: 'Credential detail',
                  title: item.title,
                  subtitle: item.url.isEmpty ? 'No URL provided' : item.url,
                  trailing: TextButton(
                    onPressed: onEdit,
                    child: const Text('Edit'),
                  ),
                ),
                const SizedBox(height: 24),
                _DetailBlock(
                  label: 'Username',
                  value: item.username.isEmpty ? 'Not set' : item.username,
                  trailing: TextButton(
                    onPressed: () => controller.copyUsername(item),
                    child: const Text('Copy username'),
                  ),
                ),
                const SizedBox(height: 18),
                _DetailBlock(
                  label: 'Password',
                  value: item.password,
                  code: true,
                  trailing: TextButton(
                    onPressed: () => controller.copyPassword(item),
                    child: const Text('Copy password'),
                  ),
                ),
                const SizedBox(height: 18),
                _DetailBlock(
                  label: 'URL',
                  value: item.url.isEmpty ? 'Not set' : item.url,
                  code: true,
                ),
                const SizedBox(height: 18),
                _DetailBlock(
                  label: 'Notes',
                  value: item.notes.isEmpty ? 'No notes' : item.notes,
                ),
                const Spacer(),
                Row(
                  children: <Widget>[
                    if (onEdit != null)
                      FilledButton(
                        onPressed: onEdit,
                        child: const Text('Edit'),
                      ),
                    if (onEdit != null) const SizedBox(width: 10),
                    TextButton(
                      onPressed: onDelete,
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.danger,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class CredentialEditorPanel extends StatefulWidget {
  const CredentialEditorPanel({
    super.key,
    required this.controller,
    this.existingCredential,
    required this.onCancel,
    required this.onSaved,
  });

  final AppController controller;
  final CredentialItem? existingCredential;
  final VoidCallback onCancel;
  final ValueChanged<String> onSaved;

  @override
  State<CredentialEditorPanel> createState() => _CredentialEditorPanelState();
}

class _CredentialEditorPanelState extends State<CredentialEditorPanel> {
  late final TextEditingController _titleController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _urlController;
  late final TextEditingController _notesController;
  late PasswordPolicy _policy;

  @override
  void initState() {
    super.initState();
    final CredentialItem? credential = widget.existingCredential;
    _titleController = TextEditingController(text: credential?.title ?? '');
    _usernameController = TextEditingController(
      text: credential?.username ?? '',
    );
    _passwordController = TextEditingController(
      text: credential?.password ?? '',
    );
    _urlController = TextEditingController(text: credential?.url ?? '');
    _notesController = TextEditingController(text: credential?.notes ?? '');
    _policy = widget.controller.defaultPolicy;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _urlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AppSectionHeading(
              eyebrow: 'Editor',
              title: widget.existingCredential == null
                  ? 'Add credential'
                  : 'Edit credential',
              subtitle:
                  'Keep edits in context while preserving the vault workspace around you.',
            ),
            const SizedBox(height: 24),
            const _FieldLabel('Title'),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'GitHub',
              ),
            ),
            const SizedBox(height: 16),
            const _FieldLabel('Username'),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                hintText: 'ricardo@example.com',
              ),
            ),
            const SizedBox(height: 16),
            const _FieldLabel('Password'),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Enter or generate a password',
              ),
            ),
            const SizedBox(height: 20),
            AppPanel(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const AppSectionHeading(
                    eyebrow: 'Generator',
                    title: 'Password generator',
                    subtitle:
                        'Tune the policy, then insert a generated password.',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Slider(
                          value: _policy.length.toDouble(),
                          min: 8,
                          max: 32,
                          divisions: 24,
                          label: '${_policy.length}',
                          onChanged: (value) {
                            setState(() {
                              _policy = _policy.copyWith(length: value.round());
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 50,
                        child: Text(
                          '${_policy.length}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      FilledButton(
                        onPressed: () {
                          setState(() {
                            _passwordController.text = widget.controller
                                .generatePassword(_policy);
                          });
                        },
                        child: const Text('Generate'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      _PolicyChip(
                        label: 'Uppercase',
                        selected: _policy.includeUppercase,
                        onSelected: (value) {
                          setState(() {
                            _policy = _policy.copyWith(includeUppercase: value);
                          });
                        },
                      ),
                      _PolicyChip(
                        label: 'Lowercase',
                        selected: _policy.includeLowercase,
                        onSelected: (value) {
                          setState(() {
                            _policy = _policy.copyWith(includeLowercase: value);
                          });
                        },
                      ),
                      _PolicyChip(
                        label: 'Digits',
                        selected: _policy.includeDigits,
                        onSelected: (value) {
                          setState(() {
                            _policy = _policy.copyWith(includeDigits: value);
                          });
                        },
                      ),
                      _PolicyChip(
                        label: 'Symbols',
                        selected: _policy.includeSymbols,
                        onSelected: (value) {
                          setState(() {
                            _policy = _policy.copyWith(includeSymbols: value);
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _FieldLabel('URL'),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'URL',
                hintText: 'https://example.com',
              ),
            ),
            const SizedBox(height: 16),
            const _FieldLabel('Notes'),
            TextField(
              controller: _notesController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Add context or recovery notes',
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: <Widget>[
                TextButton(
                  onPressed: widget.onCancel,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: () async {
                    final String credentialId = await widget.controller
                        .saveCredential(
                          credentialId: widget.existingCredential?.id,
                          draft: CredentialDraft(
                            title: _titleController.text,
                            username: _usernameController.text,
                            password: _passwordController.text,
                            url: _urlController.text,
                            notes: _notesController.text,
                          ),
                        );
                    widget.onSaved(credentialId);
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AccessScreen extends StatelessWidget {
  const _AccessScreen({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.asideTitle,
    required this.asideDescription,
    required this.child,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final String asideTitle;
  final String asideDescription;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact = constraints.maxWidth < 980;

        final Widget brandPanel = AppPanel(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'PASSWORD\nMANAGER',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  height: 1.5,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Text(asideTitle, style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 12),
              Text(
                asideDescription,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.accentSoft,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Text(
                  'Stored locally. Unlocked in memory only while your session is active.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.accent),
                ),
              ),
            ],
          ),
        );

        final Widget formPanel = Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: AppPanel(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    eyebrow.toUpperCase(),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 32),
                  child,
                ],
              ),
            ),
          ),
        );

        return Padding(
          padding: const EdgeInsets.all(28),
          child: compact
              ? SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      brandPanel,
                      const SizedBox(height: 20),
                      formPanel,
                    ],
                  ),
                )
              : Row(
                  children: <Widget>[
                    Expanded(flex: 9, child: brandPanel),
                    const SizedBox(width: 24),
                    Expanded(flex: 10, child: formPanel),
                  ],
                ),
        );
      },
    );
  }
}

class _DetailBlock extends StatelessWidget {
  const _DetailBlock({
    required this.label,
    required this.value,
    this.trailing,
    this.code = false,
  });

  final String label;
  final String value;
  final Widget? trailing;
  final bool code;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            ...?trailing == null ? null : <Widget>[trailing!],
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(color: AppTheme.line),
          ),
          child: SelectableText(
            value.isEmpty ? 'Not set' : value,
            style: code
                ? AppTheme.codeText(context)
                : Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

class _MessageDock extends StatelessWidget {
  const _MessageDock({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final String? error = controller.errorMessage;
    final String? notice = controller.noticeMessage;
    final String? message = error ?? notice;
    if (message == null) {
      return const SizedBox.shrink();
    }
    return AppMessageSurface(message: message, isError: error != null);
  }
}

class _PolicyChip extends StatelessWidget {
  const _PolicyChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
    );
  }
}
