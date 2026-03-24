import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';

part 'goals_provider.g.dart';

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

class Goal {
  const Goal({
    required this.id,
    required this.name,
    required this.icon,
    required this.targetAmount,
    required this.savedAmount,
    required this.targetDate,
    required this.daysRemaining,
    required this.estimatedCompletion,
  });

  final String id;
  final String name;
  final String icon; // "laptop"|"travel"|"shield"|"phone"|"home"|"other"
  final double targetAmount;
  final double savedAmount;
  final String targetDate;          // "31 Dec 2026" — display string
  final int daysRemaining;
  final String estimatedCompletion; // "Oct 2026"

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'] as String,
        name: json['name'] as String,
        icon: json['icon'] as String? ?? 'other',
        targetAmount: (json['targetAmount'] as num).toDouble(),
        savedAmount: (json['savedAmount'] as num).toDouble(),
        targetDate: json['targetDate'] as String,
        daysRemaining: (json['daysRemaining'] as num).toInt(),
        estimatedCompletion: json['estimatedCompletion'] as String,
      );
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
class GoalsNotifier extends _$GoalsNotifier {
  @override
  Future<List<Goal>> build() async {
    final res = await ref.read(dioClientProvider).get('/goals');
    final list = res.data['data']['goals'] as List<dynamic>;
    return list
        .map((e) => Goal.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addGoal({
    required String name,
    required double targetAmount,
    required DateTime targetDate,
    required String icon,
  }) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(targetDate);
    final res = await ref.read(dioClientProvider).post('/goals', data: {
      'name': name,
      'targetAmount': targetAmount,
      'targetDate': dateStr,
      'icon': icon,
    });
    final newGoal =
        Goal.fromJson(res.data['data'] as Map<String, dynamic>);
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data([...current, newGoal]);
  }
}
