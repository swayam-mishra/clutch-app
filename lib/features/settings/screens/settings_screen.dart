import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsNotifierProvider);
    _nameController = TextEditingController(text: s.name);
    _emailController = TextEditingController(text: s.email);
  }

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

  void _saveProfile() {
    ref.read(settingsNotifierProvider.notifier).updateProfile(
          _nameController.text,
          _emailController.text,
        );
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final settings = ref.watch(settingsNotifierProvider);

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

            // ── Profile ──────────────────────────────────────────────────
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _initials(settings.name),
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
                onPressed: _saveProfile,
                child: const Text('save changes'),
              ),
            ),

            const SizedBox(height: 28),
            Divider(color: cs.outlineVariant),
            const SizedBox(height: 20),

            // ── Budget ───────────────────────────────────────────────────
            _SectionHeader('budget'),
            _SettingsTile(
              icon: Icons.account_balance_wallet_rounded,
              title: 'monthly limit',
              subtitle: '₹3,000 · resets 1st of month',
              trailing: Icon(Icons.chevron_right_rounded,
                  color: cs.onSurfaceVariant, size: 20),
              onTap: () => context.push(AppConstants.routeBudgetSetup),
            ),

            const SizedBox(height: 24),
            Divider(color: cs.outlineVariant),
            const SizedBox(height: 20),

            // ── Notifications ────────────────────────────────────────────
            _SectionHeader('notifications'),
            _ToggleTile(
              icon: Icons.notifications_rounded,
              title: 'spending alerts',
              subtitle: 'when you\'re close to your daily limit',
              value: settings.spendingAlerts,
              onChanged: (v) => ref
                  .read(settingsNotifierProvider.notifier)
                  .toggleSpendingAlerts(v),
            ),
            _ToggleTile(
              icon: Icons.flag_rounded,
              title: 'goal reminders',
              subtitle: 'milestones and deadlines',
              value: settings.goalReminders,
              onChanged: (v) => ref
                  .read(settingsNotifierProvider.notifier)
                  .toggleGoalReminders(v),
            ),
            _ToggleTile(
              icon: Icons.emoji_events_rounded,
              title: 'challenge nudges',
              subtitle: 'progress updates and completions',
              value: settings.challengeNudges,
              onChanged: (v) => ref
                  .read(settingsNotifierProvider.notifier)
                  .toggleChallengeNudges(v),
            ),

            const SizedBox(height: 24),
            Divider(color: cs.outlineVariant),
            const SizedBox(height: 20),

            // ── Security ─────────────────────────────────────────────────
            _SectionHeader('security'),
            _ToggleTile(
              icon: Icons.fingerprint_rounded,
              title: 'app lock',
              subtitle: 'biometrics or PIN',
              value: settings.appLock,
              onChanged: (v) => ref
                  .read(settingsNotifierProvider.notifier)
                  .toggleAppLock(v),
            ),
            _SettingsTile(
              icon: Icons.lock_rounded,
              title: 'change password',
              trailing: Icon(Icons.chevron_right_rounded,
                  color: cs.onSurfaceVariant, size: 20),
              onTap: () => debugPrint('change password'),
            ),

            const SizedBox(height: 24),
            Divider(color: cs.outlineVariant),
            const SizedBox(height: 20),

            // ── About ────────────────────────────────────────────────────
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

            // ── Account ──────────────────────────────────────────────────
            _SectionHeader('account'),
            _SettingsTile(
              icon: Icons.logout_rounded,
              title: 'log out',
              iconColor: cs.error,
              onTap: () => debugPrint('log out'),
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
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.titleColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
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
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              )
            : null,
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
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
