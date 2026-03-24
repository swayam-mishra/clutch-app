import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';

part 'health_provider.g.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

class HealthFactor {
  const HealthFactor({
    required this.title,
    required this.subtitle,
    required this.score,
    required this.description,
  });

  final String title; // "adherence"|"velocity"|"streak"
  final String subtitle;
  final int score; // 0–100
  final String description;

  factory HealthFactor.fromJson(Map<String, dynamic> json) => HealthFactor(
        title: json['title'] as String,
        subtitle: json['subtitle'] as String,
        score: (json['score'] as num).toInt(),
        description: json['description'] as String,
      );
}

class HealthTip {
  const HealthTip({required this.tip, this.challengeName});

  final String tip;
  final String? challengeName;

  factory HealthTip.fromJson(Map<String, dynamic> json) => HealthTip(
        tip: json['tip'] as String,
        challengeName: json['challengeName'] as String?,
      );
}

class HealthState {
  const HealthState({
    required this.score,
    required this.status,
    required this.factors,
    required this.trendScores,
    required this.tips,
  });

  final int score; // 0–100
  final String status; // "doing well"|"watch out"|"off track"
  final List<HealthFactor> factors;
  final List<double> trendScores; // 7 values
  final List<HealthTip> tips;

  factory HealthState.fromJson(Map<String, dynamic> json) => HealthState(
        score: (json['score'] as num).toInt(),
        status: json['status'] as String,
        factors: (json['factors'] as List<dynamic>)
            .map((e) => HealthFactor.fromJson(e as Map<String, dynamic>))
            .toList(),
        trendScores: (json['trendScores'] as List<dynamic>)
            .map((e) => (e as num).toDouble())
            .toList(),
        tips: (json['tips'] as List<dynamic>)
            .map((e) => HealthTip.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
class HealthNotifier extends _$HealthNotifier {
  @override
  Future<HealthState> build() async {
    final res = await ref.read(dioClientProvider).get('/health/score');
    return HealthState.fromJson(res.data['data'] as Map<String, dynamic>);
  }
}
