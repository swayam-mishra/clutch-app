import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_theme.dart';
import '../../expenses/providers/expense_provider.dart';

// Mock data
const double mockBudget = 3000;
const double mockSpent = 670;
const int mockDaysLeft = 12;
const int mockTotalDays = 31;
const double mockMinSpend = 20;
const double mockMaxSpend = 168;
const String mockMinTag = 'cold drink';
const String mockMinDate = '03 Mar 05:41';
const String mockMaxTag = 'food';
const String mockMaxDate = '05 Mar 06:09';
const int mockTotalCount = 10;

const Map<String, double> mockCategories = {
  'Food & Dining': 380,
  'Transport': 180,
  'Shopping': 60,
  'Entertainment': 50,
};

const List<double> mockWeeklySpend = [120, 0, 168, 200, 92, 60, 30];

const Map<int, double> mockCalendarData = {
  1: 0, 2: 0, 3: 20, 4: 60, 5: 168,
  6: 92, 7: 0, 8: 0, 9: 0, 10: 0,
  11: 330, 12: 0, 13: 0, 14: 0,
  15: 0, 16: 0, 17: 0, 18: 0,
  19: 0, 20: 0, 21: 0, 22: 0,
  23: 0, 24: 0, 25: 0, 26: 0,
  27: 0, 28: 0, 29: 0, 30: 0, 31: 0,
};

Future<void> _exportCsv(List<Expense> expenses) async {
  final buffer = StringBuffer();
  buffer.writeln('date,time,tag,category,amount');
  for (final e in expenses) {
    buffer.writeln('${e.date},${e.time},${e.tag},${e.category},${e.amount.toStringAsFixed(2)}');
  }

  final dir = await getTemporaryDirectory();
  final shareDir = Directory('${dir.path}/share_plus');
  if (!await shareDir.exists()) await shareDir.create();
  final file = File('${shareDir.path}/clutch_expenses.csv');
  await file.writeAsString(buffer.toString());

  await Share.shareXFiles(
    [XFile(file.path, mimeType: 'text/csv')],
    subject: 'Clutch Expenses — March 2026',
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
    final categoryColors = [cs.primary, cs.secondary, cs.tertiary, cs.outline];
    final expenses = ref.watch(expenseNotifierProvider).valueOrNull ?? [];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
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
                              '₹3,000',
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
                            '31 days',
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
                          '01 Mar',
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
                                  'march 2026',
                                  style: tt.labelSmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '31 Mar',
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

              // CARD 2 — Spent (left 60%) + Days left (right 40%)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left — Spent
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
                              '₹670',
                              style: tt.headlineMedium?.copyWith(
                                color: cs.onPrimaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'spent',
                              style: tt.bodySmall?.copyWith(
                                color: cs.onPrimaryContainer.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '22.33% of budget',
                              style: tt.labelSmall?.copyWith(
                                color: cs.onPrimaryContainer.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Right — Days left circular progress
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
                                  value: mockDaysLeft / mockTotalDays,
                                  strokeWidth: 6,
                                  backgroundColor: cs.surfaceContainerHighest,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    cs.primary,
                                  ),
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '12',
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

              // CARD 3 — Min spend + Max spend
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹20',
                              style: tt.headlineSmall?.copyWith(
                                color: cs.onSecondaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'minimum spend',
                              style: tt.labelSmall?.copyWith(
                                color: cs.onSecondaryContainer.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              mockMinDate,
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
                                  mockMinTag,
                                  style: tt.labelSmall?.copyWith(
                                    color: cs.onSecondaryContainer,
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹168',
                              style: tt.headlineSmall?.copyWith(
                                color: cs.onTertiaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'maximum spend',
                              style: tt.labelSmall?.copyWith(
                                color: cs.onTertiaryContainer.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              mockMaxDate,
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
                                  mockMaxTag,
                                  style: tt.labelSmall?.copyWith(
                                    color: cs.onTertiaryContainer,
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

              // CARD 4 — Total spending (tappable)
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
                            '10',
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
                          maxY: 250,
                          barTouchData: BarTouchData(enabled: false),
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
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(7, (i) {
                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: mockWeeklySpend[i],
                                  color: mockWeeklySpend[i] > 150
                                      ? cs.error
                                      : cs.primary,
                                  width: 20,
                                  borderRadius: BorderRadius.circular(6),
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
                              centerSpaceColor: cs.surfaceContainerHigh,
                              sections: [
                                PieChartSectionData(
                                  value: 380,
                                  color: cs.primary,
                                  radius: 40,
                                  showTitle: false,
                                ),
                                PieChartSectionData(
                                  value: 180,
                                  color: cs.secondary,
                                  radius: 40,
                                  showTitle: false,
                                ),
                                PieChartSectionData(
                                  value: 60,
                                  color: cs.tertiary,
                                  radius: 40,
                                  showTitle: false,
                                ),
                                PieChartSectionData(
                                  value: 50,
                                  color: cs.outline,
                                  radius: 40,
                                  showTitle: false,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...mockCategories.entries
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final i = entry.key;
                                final name = entry.value.key;
                                final amount = entry.value.value;
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom:
                                        i < mockCategories.length - 1 ? 8 : 0,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: categoryColors[i],
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          name,
                                          style: tt.labelMedium?.copyWith(
                                            color: cs.onSurface,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '₹${amount.toInt()}',
                                        style: tt.labelMedium?.copyWith(
                                          color: cs.onSurface,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

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
                      'march 2026',
                      style: tt.titleSmall?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Day labels
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
                    // Calendar grid — March 2026 starts on Sunday (index 6 in Mon-first)
                    GridView.count(
                      crossAxisCount: 7,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      children: [
                        // 6 empty cells for Mon–Sat before Sunday Mar 1
                        ...List.generate(6, (_) => const SizedBox()),
                        // Day cells
                        ...List.generate(31, (i) {
                          final day = i + 1;
                          final spend = mockCalendarData[day] ?? 0;
                          final bgColor = _heatColor(spend, cs);
                          return Container(
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(8),
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
  }
}
