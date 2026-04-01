import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _initialized = false;
  bool _isSavingProfile = false;
  bool _isLoggingOut = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }

  Future<void> _saveProfile() async {
    setState(() => _isSavingProfile = true);
    try {
      await ref.read(settingsNotifierProvider.notifier).saveProfile(
            _nameController.text,
            _emailController.text,
          );
      if (mounted) FocusScope.of(context).unfocus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_extractError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingProfile = false);
    }
  }

  Future<void> _logout() async {
    setState(() => _isLoggingOut = true);
    await ref.read(authNotifierProvider.notifier).logout();
    if (mounted) context.go(AppConstants.routeLogin);
  }

  void _showChangePasswordSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ChangePasswordSheet(),
    );
  }

  String _extractError(Object e) {
    try {
      // DioException shape
      final dynamic ex = e;
      final msg = ex.response?.data['error'] as String?;
      if (msg != null) return msg;
    } catch (_) {}
    return 'Something went wrong';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final settingsAsync = ref.watch(settingsNotifierProvider);

    // Populate controllers once when data first loads
    if (!_initialized) {
      settingsAsync.whenData((s) {
        _nameController.text = s.name;
        _emailController.text = s.email;
        _initialized = true;
      });
    }

    final settings = settingsAsync.valueOrNull;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: true,
        title: Text(
          'settings',
          style: tt.titleMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // ── Profile ────────────────────────────────────────────────────
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: settingsAsync.isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cs.onPrimaryContainer,
                          ),
                        )
                      : Text(
                          _initials(_nameController.text.isNotEmpty
                              ? _nameController.text
                              : '?'),
                          style: tt.headlineSmall?.copyWith(
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              cursorColor: AppTheme.textSecondary,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              cursorColor: AppTheme.textSecondary,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'email'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSavingProfile ? null : _saveProfile,
                child: _isSavingProfile
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: cs.onPrimary,
                        ),
                      )
                    : const Text('save changes'),
              ),
            ),

            const SizedBox(height: 28),
            Divider(color: cs.outlineVariant),
            const SizedBox(height: 20),

            // ── Notifications ───────────────────────────────────────────────
            _SectionHeader('notifications'),
            _ToggleTile(
              icon: Icons.notifications_rounded,
              title: 'spending alerts',
              subtitle: 'when you\'re close to your daily limit',
              value: settings?.spendingAlerts ?? true,
              onChanged: (v) => ref
                  .read(settingsNotifierProvider.notifier)
                  .updatePreference(spendingAlerts: v),
            ),
            _ToggleTile(
              icon: Icons.flag_rounded,
              title: 'goal reminders',
              subtitle: 'milestones and deadlines',
              value: settings?.goalReminders ?? true,
              onChanged: (v) => ref
                  .read(settingsNotifierProvider.notifier)
                  .updatePreference(goalReminders: v),
            ),
            _ToggleTile(
              icon: Icons.emoji_events_rounded,
              title: 'challenge nudges',
              subtitle: 'progress updates and completions',
              value: settings?.challengeNudges ?? false,
              onChanged: (v) => ref
                  .read(settingsNotifierProvider.notifier)
                  .updatePreference(challengeNudges: v),
            ),

            const SizedBox(height: 24),
            Divider(color: cs.outlineVariant),
            const SizedBox(height: 20),

            // ── Security ────────────────────────────────────────────────────
            _SectionHeader('security'),
            _ToggleTile(
              icon: Icons.fingerprint_rounded,
              title: 'app lock',
              subtitle: 'biometrics or PIN',
              value: settings?.appLock ?? false,
              onChanged: (v) => ref
                  .read(settingsNotifierProvider.notifier)
                  .updatePreference(appLock: v),
            ),
            _SettingsTile(
              icon: Icons.lock_rounded,
              title: 'change password',
              trailing: Icon(Icons.chevron_right_rounded,
                  color: cs.onSurfaceVariant, size: 20),
              onTap: _showChangePasswordSheet,
            ),

            const SizedBox(height: 24),
            Divider(color: cs.outlineVariant),
            const SizedBox(height: 20),

            // ── About ───────────────────────────────────────────────────────
            _SectionHeader('about'),
            _SettingsTile(
              icon: Icons.info_outline_rounded,
              title: 'version',
              trailing: Text(
                'v0.1.0',
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
            _SettingsTile(
              icon: Icons.feedback_outlined,
              title: 'send feedback',
              trailing: Icon(Icons.chevron_right_rounded,
                  color: cs.onSurfaceVariant, size: 20),
              onTap: () => debugPrint('send feedback'),
            ),
            _SettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'privacy policy',
              trailing: Icon(Icons.chevron_right_rounded,
                  color: cs.onSurfaceVariant, size: 20),
              onTap: () => debugPrint('privacy policy'),
            ),

            const SizedBox(height: 24),
            Divider(color: cs.outlineVariant),
            const SizedBox(height: 20),

            // ── Account ─────────────────────────────────────────────────────
            _SectionHeader('account'),
            _SettingsTile(
              icon: Icons.logout_rounded,
              title: _isLoggingOut ? 'logging out...' : 'log out',
              iconColor: cs.error,
              onTap: _isLoggingOut ? null : _logout,
            ),
            _SettingsTile(
              icon: Icons.delete_forever_rounded,
              title: 'delete account',
              iconColor: cs.error,
              titleColor: cs.error,
              onTap: () => debugPrint('delete account'),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// ── Change password bottom sheet ─────────────────────────────────────────────

class _ChangePasswordSheet extends ConsumerStatefulWidget {
  const _ChangePasswordSheet();

  @override
  ConsumerState<_ChangePasswordSheet> createState() =>
      _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends ConsumerState<_ChangePasswordSheet> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_newController.text != _confirmController.text) {
      setState(() => _error = 'new passwords don\'t match');
      return;
    }
    if (_newController.text.length < 6) {
      setState(() => _error = 'password must be at least 6 characters');
      return;
    }
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      await ref.read(settingsNotifierProvider.notifier).changePassword(
            _currentController.text,
            _newController.text,
          );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        String msg = 'Failed to update password';
        try {
          final dynamic ex = e;
          msg = ex.response?.data['error'] as String? ?? msg;
        } catch (_) {}
        setState(() {
          _isSaving = false;
          _error = msg;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 32,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'change password',
              style: tt.titleMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _currentController,
              obscureText: true,
              cursorColor: AppTheme.textSecondary,
              decoration: const InputDecoration(labelText: 'current password'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newController,
              obscureText: true,
              cursorColor: AppTheme.textSecondary,
              decoration: const InputDecoration(labelText: 'new password'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmController,
              obscureText: true,
              cursorColor: AppTheme.textSecondary,
              decoration: const InputDecoration(labelText: 'confirm new password'),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style: tt.labelSmall?.copyWith(color: cs.error),
                ),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSaving ? null : _submit,
              child: _isSaving
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.onPrimary,
                      ),
                    )
                  : const Text('update password'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Private widgets ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        label,
        style: tt.labelMedium?.copyWith(
          color: cs.primary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.titleColor,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: cs.secondaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon,
              size: 18, color: iconColor ?? cs.onSecondaryContainer),
        ),
        title: Text(
          title,
          style: tt.bodyMedium?.copyWith(
            color: titleColor ?? cs.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: cs.secondaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: cs.onSecondaryContainer),
        ),
        title: Text(
          title,
          style: tt.bodyMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              )
            : null,
        trailing: Switch(value: value, onChanged: onChanged),
      ),
    );
  }
}
