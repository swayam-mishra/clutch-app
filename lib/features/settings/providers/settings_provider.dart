import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_provider.g.dart';

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

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  SettingsState build() => const SettingsState(
        name: 'Rahul Sharma',
        email: 'rahul@example.com',
        spendingAlerts: true,
        goalReminders: true,
        challengeNudges: false,
        appLock: false,
      );

  void updateProfile(String name, String email) {
    state = state.copyWith(name: name.trim(), email: email.trim());
  }

  void toggleSpendingAlerts(bool value) {
    state = state.copyWith(spendingAlerts: value);
  }

  void toggleGoalReminders(bool value) {
    state = state.copyWith(goalReminders: value);
  }

  void toggleChallengeNudges(bool value) {
    state = state.copyWith(challengeNudges: value);
  }

  void toggleAppLock(bool value) {
    state = state.copyWith(appLock: value);
  }
}
