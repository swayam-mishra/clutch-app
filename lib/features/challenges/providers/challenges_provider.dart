import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';

part 'challenges_provider.g.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

class ActiveChallenge {
  const ActiveChallenge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconKey,
    required this.difficulty,
    required this.duration,
    required this.daysLeft,
    required this.totalDays,
    required this.progress,
    this.reward,
    required this.rewardIconKey,
    required this.color,
  });

  final String id;
  final String name;
  final String description;
  final String iconKey;
  final String difficulty; // "easy"|"medium"|"hard"
  final String duration;
  final int daysLeft;
  final int totalDays;
  final double progress; // 0.0–1.0
  final String? reward;
  final String rewardIconKey;
  final String color; // "primary"|"tertiary"

  factory ActiveChallenge.fromJson(Map<String, dynamic> json) =>
      ActiveChallenge(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        iconKey: json['iconKey'] as String? ?? 'star',
        difficulty: json['difficulty'] as String,
        duration: json['duration'] as String,
        daysLeft: (json['daysLeft'] as num).toInt(),
        totalDays: (json['totalDays'] as num).toInt(),
        progress: (json['progress'] as num).toDouble(),
        reward: json['reward'] as String?,
        rewardIconKey: json['rewardIconKey'] as String? ?? 'star',
        color: json['color'] as String? ?? 'primary',
      );
}

class AvailableChallenge {
  const AvailableChallenge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconKey,
    required this.difficulty,
    required this.duration,
    this.reward,
    required this.rewardIconKey,
  });

  final String id;
  final String name;
  final String description;
  final String iconKey;
  final String difficulty;
  final String duration;
  final String? reward;
  final String rewardIconKey;

  factory AvailableChallenge.fromJson(Map<String, dynamic> json) =>
      AvailableChallenge(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        iconKey: json['iconKey'] as String? ?? 'star',
        difficulty: json['difficulty'] as String,
        duration: json['duration'] as String,
        reward: json['reward'] as String?,
        rewardIconKey: json['rewardIconKey'] as String? ?? 'star',
      );
}

class ChallengesState {
  const ChallengesState({
    required this.active,
    required this.available,
  });

  final List<ActiveChallenge> active;
  final List<AvailableChallenge> available;
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
class ChallengesNotifier extends _$ChallengesNotifier {
  @override
  Future<ChallengesState> build() async {
    final dio = ref.read(dioClientProvider);
    final results = await Future.wait([
      dio.get('/challenges/active'),
      dio.get('/challenges/available'),
    ]);

    final active = (results[0].data['data']['challenges'] as List<dynamic>)
        .map((e) => ActiveChallenge.fromJson(e as Map<String, dynamic>))
        .toList();

    final available =
        (results[1].data['data']['challenges'] as List<dynamic>)
            .map((e) =>
                AvailableChallenge.fromJson(e as Map<String, dynamic>))
            .toList();

    return ChallengesState(active: active, available: available);
  }

  Future<void> joinChallenge(String id) async {
    final res = await ref
        .read(dioClientProvider)
        .post('/challenges/$id/join');
    final joined = ActiveChallenge.fromJson(
        res.data['data'] as Map<String, dynamic>);

    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncValue.data(ChallengesState(
      active: [...current.active, joined],
      available: current.available.where((c) => c.id != id).toList(),
    ));
  }
}
