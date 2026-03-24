import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';

part 'analytics_provider.g.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

class SpendRecord {
  const SpendRecord({
    required this.amount,
    required this.tag,
    required this.datetime,
  });

  final double amount;
  final String tag;
  final String datetime; // "DD Mon HH:mm" — already formatted by backend

  factory SpendRecord.fromJson(Map<String, dynamic> json) => SpendRecord(
        amount: (json['amount'] as num).toDouble(),
        tag: json['tag'] as String,
        datetime: json['datetime'] as String,
      );
}

class AnalyticsState {
  const AnalyticsState({
    required this.budget,
    required this.totalSpent,
    required this.daysLeft,
    required this.totalDays,
    required this.startDate,
    required this.endDate,
    required this.percentUsed,
    this.minSpend,
    this.maxSpend,
    required this.totalCount,
    required this.categories,
    required this.weeklySpend,
    required this.calendarData,
  });

  final double budget;
  final double totalSpent;
  final int daysLeft;
  final int totalDays;
  final String startDate; // "YYYY-MM-DD"
  final String endDate; // "YYYY-MM-DD"
  final double percentUsed;
  final SpendRecord? minSpend;
  final SpendRecord? maxSpend;
  final int totalCount;
  final Map<String, double> categories; // category → amount
  final List<double> weeklySpend; // 7 values Mon–Sun
  final Map<String, double> calendarData; // day-of-month string → amount

  factory AnalyticsState.fromJson(Map<String, dynamic> json) {
    final cats = (json['categories'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, (v as num).toDouble()),
    );
    final weekly = (json['weeklySpend'] as List<dynamic>)
        .map((e) => (e as num).toDouble())
        .toList();
    // calendarData keys are strings ("1", "3", "11") — not integers
    final cal = (json['calendarData'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, (v as num).toDouble()),
    );

    return AnalyticsState(
      budget: (json['budget'] as num).toDouble(),
      totalSpent: (json['totalSpent'] as num).toDouble(),
      daysLeft: (json['daysLeft'] as num).toInt(),
      totalDays: (json['totalDays'] as num).toInt(),
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      percentUsed: (json['percentUsed'] as num).toDouble(),
      minSpend: json['minSpend'] != null
          ? SpendRecord.fromJson(json['minSpend'] as Map<String, dynamic>)
          : null,
      maxSpend: json['maxSpend'] != null
          ? SpendRecord.fromJson(json['maxSpend'] as Map<String, dynamic>)
          : null,
      totalCount: (json['totalCount'] as num).toInt(),
      categories: cats,
      weeklySpend: weekly,
      calendarData: cal,
    );
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
class AnalyticsNotifier extends _$AnalyticsNotifier {
  @override
  Future<AnalyticsState> build() async {
    final res = await ref.read(dioClientProvider).get('/analytics/summary');
    return AnalyticsState.fromJson(
        res.data['data'] as Map<String, dynamic>);
  }
}
