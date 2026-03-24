import 'dart:io';
import 'dart:math' show max;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/extensions/currency_extension.dart';
import '../../expenses/providers/expense_provider.dart';
import '../providers/analytics_provider.dart';

Future<void> _exportCsv(List<Expense> expenses) async {
  final buffer = StringBuffer();
  buffer.writeln('date,time,tag,category,amount');
  for (final e in expenses) {
    buffer.writeln(
        '${e.date},${e.time},${e.tag},${e.category},${e.amount.toStringAsFixed(2)}');
  }

  final dir = await getTemporaryDirectory();
  final shareDir = Directory('${dir.path}/share_plus');
  if (!await shareDir.exists()) await shareDir.create();
  final file = File('${shareDir.path}/clutch_expenses.csv');
  await file.writeAsString(buffer.toString());

  await Share.shareXFiles(
    [XFile(file.path, mimeType: 'text/csv')],
    subject: 'Clutch Expenses',
  );
}

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  Color _heatColor(double spend, ColorScheme cs) {
    if (spend == 0) return cs.surfaceContainer;
    if (spend < 100) return cs.primaryContainer;
    if (spend < 200) return cs.primary.withValues(alpha: 0.6);
    return cs.primary;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final expenses = ref.watch(expenseNotifierProvider).valueOrNull ?? [];
    final analyticsAsync = ref.watch(analyticsNotifierProvider);

    return analyticsAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: CircularProgressIndicator(color: cs.primary),
        ),
      ),
      error: (_, err) => Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: Text(
            'failed to load analytics',
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
      ),
      data: (a) {
        // Derived display values
        final startDt = DateTime.parse(a.startDate);
        final endDt = DateTime.parse(a.endDate);
        final startLabel = DateFormat('dd MMM').format(startDt);
        final endLabel = DateFormat('dd MMM').format(endDt);
        // Calendar always shows current month
        final now = DateTime.now();
        final calMonthDt = DateTime(now.year, now.month, 1);
        final monthLabel =
            DateFormat('MMMM yyyy').format(calMonthDt).toLowerCase();
        final daysInMonth =
            DateTime(calMonthDt.year, calMonthDt.month + 1, 0).day;
        // Mon-first grid: Mon=0 ... Sun=6
        final gridOffset = calMonthDt.weekday - 1;

        final categoryEntries = a.categories.entries.toList();
        final categoryColors = [
          cs.primary,
          cs.secondary,
          cs.tertiary,
          cs.outline,
          cs.error,
          cs.primaryContainer,
        ];

        final maxWeekly = a.weeklySpend.fold<double>(0, max);
        final barMaxY = maxWeekly > 0 ? maxWeekly * 1.3 : 100.0;
        final dailyLimit =
            a.totalDays > 0 ? a.budget / a.totalDays : 0.0;

        return Scaffold(
          backgroundColor: AppTheme.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Text(
                        'analytics',
                        style: tt.headlineSmall?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.ios_share_rounded),
                        color: cs.onSurfaceVariant,
                        onPressed: () => _exportCsv(expenses),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // CARD 1 — Hero budget card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.budget.toRupees(),
                                  style: tt.displaySmall?.copyWith(
                                    color: cs.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'starting budget',
                                  style: tt.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${a.totalDays} days',
                                style: tt.labelMedium?.copyWith(
                                  color: cs.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              startLabel,
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            Expanded(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Divider(color: cs.outlineVariant),
                                  Container(
                                    color: cs.surfaceContainerHigh,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4,
                                    ),
                                    child: Text(
                                      monthLabel,
                                      style: tt.labelSmall?.copyWith(
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              endLabel,
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // CARD 2 — Spent + Days left
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cs.primaryContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.totalSpent.toRupees(),
                                  style: tt.headlineMedium?.copyWith(
                                    color: cs.onPrimaryContainer,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'spent',
                                  style: tt.bodySmall?.copyWith(
                                    color: cs.onPrimaryContainer
                                        .withValues(alpha: 0.8),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${a.percentUsed.toStringAsFixed(1)}% of budget',
                                  style: tt.labelSmall?.copyWith(
                                    color: cs.onPrimaryContainer
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: CircularProgressIndicator(
                                      value: a.totalDays > 0
                                          ? a.daysLeft / a.totalDays
                                          : 0,
                                      strokeWidth: 6,
                                      backgroundColor:
                                          cs.surfaceContainerHighest,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                        cs.primary,
                                      ),
                                      strokeCap: StrokeCap.round,
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${a.daysLeft}',
                                        style: tt.titleLarge?.copyWith(
                                          color: cs.onSurface,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        'days left',
                                        style: tt.labelSmall?.copyWith(
                                          color: cs.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // CARD 3 — Min + Max spend
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Min
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cs.secondaryContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: a.minSpend == null
                                ? Text(
                                    'no data yet',
                                    style: tt.labelSmall?.copyWith(
                                      color: cs.onSecondaryContainer
                                          .withValues(alpha: 0.7),
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        a.minSpend!.amount.toRupees(),
                                        style: tt.headlineSmall?.copyWith(
                                          color: cs.onSecondaryContainer,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        'minimum spend',
                                        style: tt.labelSmall?.copyWith(
                                          color: cs.onSecondaryContainer
                                              .withValues(alpha: 0.8),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        a.minSpend!.datetime,
                                        style: tt.labelSmall?.copyWith(
                                          color: cs.onSecondaryContainer,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.label_outline_rounded,
                                            size: 12,
                                            color: cs.onSecondaryContainer,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            a.minSpend!.tag,
                                            style: tt.labelSmall?.copyWith(
                                              color:
                                                  cs.onSecondaryContainer,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Max
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cs.tertiaryContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: a.maxSpend == null
                                ? Text(
                                    'no data yet',
                                    style: tt.labelSmall?.copyWith(
                                      color: cs.onTertiaryContainer
                                          .withValues(alpha: 0.7),
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        a.maxSpend!.amount.toRupees(),
                                        style: tt.headlineSmall?.copyWith(
                                          color: cs.onTertiaryContainer,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        'maximum spend',
                                        style: tt.labelSmall?.copyWith(
                                          color: cs.onTertiaryContainer
                                              .withValues(alpha: 0.8),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        a.maxSpend!.datetime,
                                        style: tt.labelSmall?.copyWith(
                                          color: cs.onTertiaryContainer,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.label_outline_rounded,
                                            size: 12,
                                            color: cs.onTertiaryContainer,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            a.maxSpend!.tag,
                                            style: tt.labelSmall?.copyWith(
                                              color:
                                                  cs.onTertiaryContainer,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // CARD 4 — Total spending count
                  GestureDetector(
                    onTap: () => debugPrint('go to expenses'),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${a.totalCount}',
                                style: tt.headlineMedium?.copyWith(
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'total spending',
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: cs.onSurfaceVariant,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // CARD 5 — Weekly bar chart
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'this week',
                              style: tt.titleSmall?.copyWith(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'mon – sun',
                              style: tt.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 140,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: barMaxY,
                              barTouchData:
                                  BarTouchData(enabled: false),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      const days = [
                                        'M', 'T', 'W', 'T', 'F', 'S', 'S'
                                      ];
                                      return Text(
                                        days[value.toInt()],
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: cs.onSurfaceVariant,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: const AxisTitles(
                                  sideTitles:
                                      SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles:
                                      SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles:
                                      SideTitles(showTitles: false),
                                ),
                              ),
                              gridData:
                                  const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              barGroups:
                                  List.generate(7, (i) {
                                final spend = a.weeklySpend[i];
                                return BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    BarChartRodData(
                                      toY: spend,
                                      color: spend > dailyLimit
                                          ? cs.error
                                          : cs.primary,
                                      width: 20,
                                      borderRadius:
                                          BorderRadius.circular(6),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // CARD 6 — Pie chart by category
                  if (categoryEntries.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'by category',
                            style: tt.titleSmall?.copyWith(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              SizedBox(
                                width: 160,
                                height: 160,
                                child: PieChart(
                                  PieChartData(
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 40,
                                    centerSpaceColor:
                                        cs.surfaceContainerHigh,
                                    sections: categoryEntries
                                        .asMap()
                                        .entries
                                        .map((e) => PieChartSectionData(
                                              value: e.value.value,
                                              color: categoryColors[e.key %
                                                  categoryColors.length],
                                              radius: 40,
                                              showTitle: false,
                                            ))
                                        .toList(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: categoryEntries
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    final i = entry.key;
                                    final name = entry.value.key;
                                    final amount = entry.value.value;
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: i <
                                                categoryEntries.length - 1
                                            ? 8
                                            : 0,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: categoryColors[i %
                                                  categoryColors.length],
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      3),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              name,
                                              style: tt.labelMedium
                                                  ?.copyWith(
                                                color: cs.onSurface,
                                              ),
                                              overflow:
                                                  TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '₹${amount.toInt()}',
                                            style: tt.labelMedium
                                                ?.copyWith(
                                              color: cs.onSurface,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  if (categoryEntries.isNotEmpty) const SizedBox(height: 8),

                  // CARD 7 — Calendar heatmap
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          monthLabel,
                          style: tt.titleSmall?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                              .map(
                                (d) => Expanded(
                                  child: Text(
                                    d,
                                    textAlign: TextAlign.center,
                                    style: tt.labelSmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 8),
                        GridView.count(
                          crossAxisCount: 7,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                          children: [
                            // Empty cells for offset (Mon-first grid)
                            ...List.generate(
                                gridOffset, (_) => const SizedBox()),
                            // Day cells
                            ...List.generate(daysInMonth, (i) {
                              final day = i + 1;
                              final spend =
                                  a.calendarData['$day'] ?? 0.0;
                              final bgColor = _heatColor(spend, cs);
                              return Container(
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '$day',
                                    style: tt.labelSmall?.copyWith(
                                      color: spend > 0
                                          ? cs.onPrimary
                                          : cs.onSurfaceVariant,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

