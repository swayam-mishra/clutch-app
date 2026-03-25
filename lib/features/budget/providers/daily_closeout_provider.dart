import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';

part 'daily_closeout_provider.g.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

enum CloseoutType { surplus, deficit, none }

class CloseoutGoal {
  const CloseoutGoal({
    required this.id,
    required this.name,
    required this.icon,
    required this.targetAmount,
    required this.savedAmount,
    required this.remaining,
    required this.daysRemaining,
  });

  final String id;
  final String name;
  final String icon;
  final double targetAmount;
  final double savedAmount;
  final double remaining;
  final int daysRemaining;

  factory CloseoutGoal.fromJson(Map<String, dynamic> json) => CloseoutGoal(
        id: json['id'] as String,
        name: json['name'] as String,
        icon: json['icon'] as String? ?? 'other',
        targetAmount: (json['targetAmount'] as num).toDouble(),
        savedAmount: (json['savedAmount'] as num).toDouble(),
        remaining: (json['remaining'] as num).toDouble(),
        daysRemaining: (json['daysRemaining'] as num).toInt(),
      );
}

class DailySummary {
  const DailySummary({
    required this.needsCloseout,
    required this.type,
    required this.dailyBudget,
    required this.spent,
    required this.surplus,
    required this.deficit,
    required this.pendingSavings,
    required this.activeGoals,
  });

  final bool needsCloseout;
  final CloseoutType type;
  final double dailyBudget;
  final double spent;
  final double surplus;
  final double deficit;
  final double pendingSavings;
  final List<CloseoutGoal> activeGoals;

  factory DailySummary.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String? ?? 'none';
    final type = typeStr == 'surplus'
        ? CloseoutType.surplus
        : typeStr == 'deficit'
            ? CloseoutType.deficit
            : CloseoutType.none;

    final today = json['today'] as Map<String, dynamic>? ?? {};
    final goalsList = json['activeGoals'] as List<dynamic>? ?? [];

    return DailySummary(
      needsCloseout: json['needsCloseout'] as bool? ?? false,
      type: type,
      dailyBudget: (today['dailyBudget'] as num?)?.toDouble() ?? 0,
      spent: (today['spent'] as num?)?.toDouble() ?? 0,
      surplus: (today['surplus'] as num?)?.toDouble() ?? 0,
      deficit: (json['deficit'] as num?)?.toDouble() ?? 0,
      pendingSavings: (json['pendingSavings'] as num?)?.toDouble() ?? 0,
      activeGoals: goalsList
          .map((e) => CloseoutGoal.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AllocationResult {
  const AllocationResult({
    required this.allocated,
    required this.totalAllocated,
  });

  final List<AllocatedGoal> allocated;
  final double totalAllocated;

  factory AllocationResult.fromJson(Map<String, dynamic> json) {
    final list = json['allocated'] as List<dynamic>? ?? [];
    return AllocationResult(
      allocated: list
          .map((e) => AllocatedGoal.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalAllocated: (json['totalAllocated'] as num?)?.toDouble() ?? 0,
    );
  }
}

class AllocatedGoal {
  const AllocatedGoal({
    required this.goalId,
    required this.goalName,
    required this.amount,
  });

  final String goalId;
  final String goalName;
  final double amount;

  factory AllocatedGoal.fromJson(Map<String, dynamic> json) => AllocatedGoal(
        goalId: json['goalId'] as String,
        goalName: json['goalName'] as String,
        amount: (json['amount'] as num).toDouble(),
      );
}

// ---------------------------------------------------------------------------
// DailySummaryNotifier — fetched once per session on app open
// ---------------------------------------------------------------------------

@riverpod
class DailySummaryNotifier extends _$DailySummaryNotifier {
  @override
  Future<DailySummary> build() async {
    final res = await ref.read(dioClientProvider).get('/budget/daily-summary');
    return DailySummary.fromJson(res.data['data'] as Map<String, dynamic>);
  }
}

// ---------------------------------------------------------------------------
// CloseoutNotifier — manages per-goal allocation amounts during flow
// ---------------------------------------------------------------------------

@riverpod
class CloseoutNotifier extends _$CloseoutNotifier {
  @override
  Map<String, double> build() => {};

  void setAllocation(String goalId, double amount) {
    state = {...state, goalId: amount};
  }

  void clearAllocations() {
    state = {};
  }

  Future<AllocationResult> allocateManual() async {
    final allocations = state.entries
        .where((e) => e.value > 0)
        .map((e) => {'goalId': e.key, 'amount': e.value})
        .toList();

    final res = await ref.read(dioClientProvider).post(
      '/budget/allocate',
      data: {'mode': 'manual', 'allocations': allocations},
    );
    return AllocationResult.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<AllocationResult> allocateAuto() async {
    final res = await ref.read(dioClientProvider).post(
      '/budget/allocate',
      data: {'mode': 'auto'},
    );
    return AllocationResult.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<void> dismiss() async {
    await ref.read(dioClientProvider).post('/budget/dismiss-closeout');
  }
}
