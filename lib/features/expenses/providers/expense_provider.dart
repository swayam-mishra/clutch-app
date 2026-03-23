import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';
import '../../budget/providers/budget_provider.dart';

part 'expense_provider.g.dart';

// ---------------------------------------------------------------------------
// Expense model
// ---------------------------------------------------------------------------

class Expense {
  const Expense({
    required this.id,
    required this.date,
    required this.time,
    required this.tag,
    required this.category,
    required this.amount,
    required this.confidence,
  });

  final String id;
  final String date;      // "YYYY-MM-DD"
  final String time;      // "HH:mm"
  final String tag;
  final String category;
  final double amount;
  final int confidence;

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      tag: json['tag'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      confidence: (json['confidence'] as num?)?.toInt() ?? 100,
    );
  }
}

// ---------------------------------------------------------------------------
// ExpenseNotifier
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
class ExpenseNotifier extends _$ExpenseNotifier {
  @override
  Future<List<Expense>> build() async {
    final res = await ref.read(dioClientProvider).get('/expenses');
    final list = res.data['data']['expenses'] as List<dynamic>;
    return list
        .map((e) => Expense.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> logExpense({
    required double amount,
    required String tag,
    required String category,
    required int confidence,
  }) async {
    final res = await ref.read(dioClientProvider).post('/expenses', data: {
      'amount': amount,
      'tag': tag,
      'category': category,
      'confidence': confidence,
    });

    // Prepend the new expense directly from the POST response — no refetch needed
    final newExpense =
        Expense.fromJson(res.data['data'] as Map<String, dynamic>);
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data([newExpense, ...current]);

    // Budget numbers change — refetch
    ref.invalidate(budgetNotifierProvider);
  }

  Future<({String category, int confidence})> categorize(String tag) async {
    final res = await ref.read(dioClientProvider).post(
      '/expenses/categorize',
      data: {'tag': tag},
    );
    final data = res.data['data'] as Map<String, dynamic>;
    return (
      category: data['category'] as String,
      confidence: (data['confidence'] as num).toInt(),
    );
  }

  Future<void> deleteExpense(String id) async {
    await ref.read(dioClientProvider).delete('/expenses/$id');
    ref.invalidateSelf();
    ref.invalidate(budgetNotifierProvider);
  }
}
