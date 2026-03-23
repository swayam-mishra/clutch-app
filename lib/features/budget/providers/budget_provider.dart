import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';

part 'budget_provider.g.dart';

// ---------------------------------------------------------------------------
// BudgetState
// ---------------------------------------------------------------------------

class BudgetState {
  const BudgetState({
    required this.amount,
    required this.currency,
    required this.startDate,
    required this.endDate,
    required this.distribution,
    required this.dailyLimit,
    required this.totalDays,
    required this.daysRemaining,
    required this.totalSpent,
    required this.remainingBudget,
    required this.dailyRemaining,
  });

  final double amount;
  final String currency;
  final String startDate;    // ISO: "2026-03-01"
  final String endDate;
  final String distribution;
  final double dailyLimit;
  final int totalDays;
  final int daysRemaining;
  final double totalSpent;
  final double remainingBudget;
  final double dailyRemaining;

  bool get isOnTrack => remainingBudget >= (daysRemaining * dailyLimit);
  double get spentFraction => (totalSpent / amount).clamp(0.0, 1.0);

  factory BudgetState.fromJson(Map<String, dynamic> json) {
    return BudgetState(
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'INR',
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      distribution: json['distribution'] as String? ?? 'distribute',
      dailyLimit: (json['dailyLimit'] as num).toDouble(),
      totalDays: json['totalDays'] as int,
      daysRemaining: json['daysLeft'] as int,
      totalSpent: (json['spent'] as num).toDouble(),
      remainingBudget: (json['remaining'] as num).toDouble(),
      dailyRemaining: (json['todayRemaining'] as num).toDouble(),
    );
  }
}

// ---------------------------------------------------------------------------
// BudgetNotifier
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
class BudgetNotifier extends _$BudgetNotifier {
  @override
  Future<BudgetState?> build() => _fetch();

  Future<BudgetState?> _fetch() async {
    try {
      final res = await ref.read(dioClientProvider).get('/budget/current');
      return BudgetState.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<void> saveBudget({
    required double amount,
    required String currency,
    required DateTime startDate,
    required DateTime endDate,
    required String distribution,
  }) async {
    String toIso(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    await ref.read(dioClientProvider).post('/budget', data: {
      'amount': amount,
      'currency': currency,
      'startDate': toIso(startDate),
      'endDate': toIso(endDate),
      'distribution': distribution,
    });

    ref.invalidateSelf();
    await future;
  }
}
