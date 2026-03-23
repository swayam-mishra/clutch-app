import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';

part 'settings_provider.g.dart';

// ---------------------------------------------------------------------------
// SettingsState
// ---------------------------------------------------------------------------

class SettingsState {
  const SettingsState({
    required this.name,
    required this.email,
    required this.spendingAlerts,
    required this.goalReminders,
    required this.challengeNudges,
    required this.appLock,
  });

  final String name;
  final String email;
  final bool spendingAlerts;
  final bool goalReminders;
  final bool challengeNudges;
  final bool appLock;

  SettingsState copyWith({
    String? name,
    String? email,
    bool? spendingAlerts,
    bool? goalReminders,
    bool? challengeNudges,
    bool? appLock,
  }) {
    return SettingsState(
      name: name ?? this.name,
      email: email ?? this.email,
      spendingAlerts: spendingAlerts ?? this.spendingAlerts,
      goalReminders: goalReminders ?? this.goalReminders,
      challengeNudges: challengeNudges ?? this.challengeNudges,
      appLock: appLock ?? this.appLock,
    );
  }
}

// ---------------------------------------------------------------------------
// SettingsNotifier
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
class SettingsNotifier extends _$SettingsNotifier {
  @override
  Future<SettingsState> build() async {
    final res = await ref.read(dioClientProvider).get('/user/profile');
    final data = res.data['data'] as Map<String, dynamic>;
    final prefs = (data['preferences'] as Map<String, dynamic>?) ?? {};
    return SettingsState(
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      spendingAlerts: prefs['spendingAlerts'] as bool? ?? true,
      goalReminders: prefs['goalReminders'] as bool? ?? true,
      challengeNudges: prefs['challengeNudges'] as bool? ?? false,
      appLock: prefs['appLock'] as bool? ?? false,
    );
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  Future<void> saveProfile(String name, String email) async {
    await ref.read(dioClientProvider).put('/user/profile', data: {
      'name': name.trim(),
      'email': email.trim(),
    });
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncValue.data(
        current.copyWith(name: name.trim(), email: email.trim()),
      );
    }
  }

  // ── Preferences — optimistic update ──────────────────────────────────────

  Future<void> updatePreference({
    bool? spendingAlerts,
    bool? goalReminders,
    bool? challengeNudges,
    bool? appLock,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final updated = current.copyWith(
      spendingAlerts: spendingAlerts,
      goalReminders: goalReminders,
      challengeNudges: challengeNudges,
      appLock: appLock,
    );
    state = AsyncValue.data(updated);
    try {
      await ref.read(dioClientProvider).put('/user/preferences', data: {
        'spendingAlerts': updated.spendingAlerts,
        'goalReminders': updated.goalReminders,
        'challengeNudges': updated.challengeNudges,
        'appLock': updated.appLock,
      });
    } catch (_) {
      state = AsyncValue.data(current); // revert on failure
    }
  }

  // ── Password ──────────────────────────────────────────────────────────────

  Future<void> changePassword(String currentPw, String newPw) async {
    await ref.read(dioClientProvider).put('/user/password', data: {
      'currentPassword': currentPw,
      'newPassword': newPw,
    });
  }
}
