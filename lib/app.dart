import 'package:flutter/material.dart';

import 'domain/entities/credential_draft.dart';
import 'domain/entities/credential_item.dart';
import 'domain/entities/password_policy.dart';
import 'presentation/app_controller.dart';

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
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0F766E),
            ),
            useMaterial3: true,
          ),
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
    widget.controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final AppController controller = widget.controller;
    return Scaffold(
      body: SafeArea(
        child: switch (controller.stage) {
          AppStage.loading => const Center(child: CircularProgressIndicator()),
          AppStage.setup => _SetupView(controller: controller),
          AppStage.locked => _UnlockView(controller: controller),
          AppStage.unlocked => _VaultView(controller: controller),
        },
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
    return _CenteredPanel(
      title: 'Create your local vault',
      subtitle:
          'Set a master password. It encrypts the vault file stored on this device.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Master password'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirmController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Confirm password'),
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
          _MessageBanner(controller: widget.controller),
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
    return _CenteredPanel(
      title: 'Unlock vault',
      subtitle: 'Enter the master password to decrypt your local vault.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Master password'),
            onSubmitted: (_) =>
                widget.controller.unlockVault(_passwordController.text),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () =>
                widget.controller.unlockVault(_passwordController.text),
            child: const Text('Unlock'),
          ),
          _MessageBanner(controller: widget.controller),
        ],
      ),
    );
  }
}

class _VaultView extends StatelessWidget {
  const _VaultView({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final List<CredentialItem> credentials = controller.visibleCredentials;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Local Vault',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              FilledButton.icon(
                onPressed: () => showDialog<bool>(
                  context: context,
                  builder: (context) =>
                      CredentialEditorDialog(controller: controller),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Add credential'),
              ),
              const SizedBox(width: 12),
              IconButton(
                tooltip: 'Lock vault',
                onPressed: controller.lockVault,
                icon: const Icon(Icons.lock),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Search by title, username, or URL',
            ),
            onChanged: controller.updateQuery,
          ),
          _MessageBanner(controller: controller),
          const SizedBox(height: 16),
          Expanded(
            child: credentials.isEmpty
                ? const Center(
                    child: Text(
                      'No credentials yet. Add the first one to start using the vault.',
                    ),
                  )
                : ListView.separated(
                    itemCount: credentials.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final CredentialItem credential = credentials[index];
                      return Card(
                        child: ListTile(
                          title: Text(credential.title),
                          subtitle: Text(
                            credential.username.isEmpty
                                ? (credential.url.isEmpty
                                      ? 'No username'
                                      : credential.url)
                                : credential.username,
                          ),
                          trailing: Wrap(
                            spacing: 8,
                            children: <Widget>[
                              IconButton(
                                tooltip: 'Copy username',
                                onPressed: () =>
                                    controller.copyUsername(credential),
                                icon: const Icon(Icons.person),
                              ),
                              IconButton(
                                tooltip: 'Copy password',
                                onPressed: () =>
                                    controller.copyPassword(credential),
                                icon: const Icon(Icons.key),
                              ),
                            ],
                          ),
                          onTap: () => showDialog<void>(
                            context: context,
                            builder: (context) => CredentialDetailDialog(
                              controller: controller,
                              credential: credential,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class CredentialDetailDialog extends StatelessWidget {
  const CredentialDetailDialog({
    super.key,
    required this.controller,
    required this.credential,
  });

  final AppController controller;
  final CredentialItem credential;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(credential.title),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _DetailRow(label: 'Username', value: credential.username),
            _DetailRow(label: 'Password', value: credential.password),
            _DetailRow(label: 'URL', value: credential.url),
            _DetailRow(label: 'Notes', value: credential.notes),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            await controller.copyUsername(credential);
            if (context.mounted) Navigator.of(context).pop();
          },
          child: const Text('Copy username'),
        ),
        TextButton(
          onPressed: () async {
            await controller.copyPassword(credential);
            if (context.mounted) Navigator.of(context).pop();
          },
          child: const Text('Copy password'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await showDialog<bool>(
              context: context,
              builder: (context) => CredentialEditorDialog(
                controller: controller,
                existingCredential: credential,
              ),
            );
          },
          child: const Text('Edit'),
        ),
        TextButton(
          onPressed: () async {
            await controller.deleteCredential(credential.id);
            if (context.mounted) Navigator.of(context).pop();
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

class CredentialEditorDialog extends StatefulWidget {
  const CredentialEditorDialog({
    super.key,
    required this.controller,
    this.existingCredential,
  });

  final AppController controller;
  final CredentialItem? existingCredential;

  @override
  State<CredentialEditorDialog> createState() => _CredentialEditorDialogState();
}

class _CredentialEditorDialogState extends State<CredentialEditorDialog> {
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
    return AlertDialog(
      title: Text(
        widget.existingCredential == null
            ? 'Add credential'
            : 'Edit credential',
      ),
      content: SizedBox(
        width: 640,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 16),
              Text(
                'Password generator',
                style: Theme.of(context).textTheme.titleMedium,
              ),
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
                  SizedBox(width: 48, child: Text('${_policy.length}')),
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
              const SizedBox(height: 16),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(labelText: 'URL'),
              ),
              TextField(
                controller: _notesController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            await widget.controller.saveCredential(
              credentialId: widget.existingCredential?.id,
              draft: CredentialDraft(
                title: _titleController.text,
                username: _usernameController.text,
                password: _passwordController.text,
                url: _urlController.text,
                notes: _notesController.text,
              ),
            );
            if (context.mounted) {
              Navigator.of(context).pop(true);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _CenteredPanel extends StatelessWidget {
  const _CenteredPanel({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(subtitle),
                const SizedBox(height: 24),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          SelectableText(value.isEmpty ? 'Not set' : value),
        ],
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final String? error = controller.errorMessage;
    final String? notice = controller.noticeMessage;
    final String? message = error ?? notice;
    if (message == null) {
      return const SizedBox.shrink();
    }
    final Color color = error == null
        ? Theme.of(context).colorScheme.primaryContainer
        : Theme.of(context).colorScheme.errorContainer;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(message),
      ),
    );
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
