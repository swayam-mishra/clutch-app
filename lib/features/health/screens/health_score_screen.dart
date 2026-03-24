import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/health_provider.dart';

const List<String> _kDayLabels = [
  'mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'
];

IconData _factorIcon(String title) {
  switch (title) {
    case 'adherence':
      return Icons.check_circle_outline_rounded;
    case 'velocity':
      return Icons.speed_rounded;
    case 'streak':
      return Icons.local_fire_department_rounded;
    default:
      return Icons.analytics_rounded;
  }
}

class HealthScoreScreen extends ConsumerWidget {
  const HealthScoreScreen({super.key});

  Color _progressColor(int score, ColorScheme cs) {
    if (score >= 80) return cs.primary;
    if (score >= 60) return cs.tertiary;
    return cs.error;
  }

  ({Color bg, Color on, String subtitle}) _statusStyle(
      String status, ColorScheme cs) {
    switch (status) {
      case 'doing well':
        return (
          bg: cs.primaryContainer,
          on: cs.onPrimaryContainer,
          subtitle: 'based on your last 30 days',
        );
      case 'watch out':
        return (
          bg: cs.tertiaryContainer,
          on: cs.onTertiaryContainer,
          subtitle: 'a few areas need attention',
        );
      default:
        return (
          bg: cs.errorContainer,
          on: cs.onErrorContainer,
          subtitle: 'let\'s get back on budget',
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final healthAsync = ref.watch(healthNotifierProvider);

    return healthAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppTheme.background,
        appBar: _appBar(cs, tt),
        body: Center(child: CircularProgressIndicator(color: cs.primary)),
      ),
      error: (_, err) => Scaffold(
        backgroundColor: AppTheme.background,
        appBar: _appBar(cs, tt),
        body: Center(
          child: Text('failed to load health score',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
        ),
      ),
      data: (h) {
        final progressColor = _progressColor(h.score, cs);
        final style = _statusStyle(h.status, cs);

        // Convert trendScores to FlSpots
        final trendSpots = h.trendScores
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), e.value))
            .toList();
        final minTrend = h.trendScores.fold<double>(
            100, (m, v) => v < m ? v : m);
        final chartMinY = (minTrend - 10).clamp(0.0, 90.0);

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: _appBar(cs, tt),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),

                // Score ring
                Center(
                  child: SizedBox(
                    width: 180,
                    height: 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 0,
                            centerSpaceRadius: 68,
                            startDegreeOffset: -90,
                            sections: [
                              PieChartSectionData(
                                value: h.score.toDouble(),
                                color: progressColor,
                                radius: 22,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                value: (100 - h.score).toDouble(),
                                color: cs.surfaceContainerHighest,
                                radius: 22,
                                showTitle: false,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${h.score}',
                                style: tt.displaySmall?.copyWith(
                                    color: cs.onSurface,
                                    fontWeight: FontWeight.w700)),
                            Text('/ 100',
                                style: tt.labelSmall?.copyWith(
                                    color: cs.onSurfaceVariant)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Status chip
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: style.bg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(h.status,
                            style: tt.labelLarge?.copyWith(
                                color: style.on,
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 6),
                      Text(style.subtitle,
                          style: tt.labelSmall
                              ?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                Divider(color: cs.outlineVariant),
                const SizedBox(height: 24),

                // Breakdown
                Text('breakdown',
                    style: tt.titleMedium?.copyWith(
                        color: cs.onSurface, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),

                ...h.factors.map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _FactorCard(factor: f),
                  ),
                ),

                const SizedBox(height: 24),
                Divider(color: cs.outlineVariant),
                const SizedBox(height: 24),

                // 7-day trend
                Text('7-day trend',
                    style: tt.titleMedium?.copyWith(
                        color: cs.onSurface, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 96,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      minY: chartMinY,
                      maxY: 100,
                      lineTouchData:
                          const LineTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 ||
                                  idx >= _kDayLabels.length) {
                                return const SizedBox.shrink();
                              }
                              return Text(_kDayLabels[idx],
                                  style: tt.labelSmall?.copyWith(
                                      color: cs.onSurfaceVariant));
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: trendSpots,
                          isCurved: true,
                          curveSmoothness: 0.35,
                          color: progressColor,
                          barWidth: 2.5,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                progressColor.withValues(alpha: 0.2),
                                progressColor.withValues(alpha: 0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                Divider(color: cs.outlineVariant),
                const SizedBox(height: 24),

                // Suggestions
                Row(
                  children: [
                    Text('suggestions',
                        style: tt.titleMedium?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: cs.tertiaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('ai',
                          style: tt.labelSmall?.copyWith(
                              color: cs.onTertiaryContainer,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                ...h.tips.map((t) => _TipCard(tip: t)),

                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  AppBar _appBar(ColorScheme cs, TextTheme tt) => AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: true,
        title: Text('health score',
            style: tt.titleMedium?.copyWith(
                color: cs.onSurface, fontWeight: FontWeight.w600)),
      );
}

// ---------------------------------------------------------------------------
// Factor card
// ---------------------------------------------------------------------------

class _FactorCard extends StatelessWidget {
  const _FactorCard({required this.factor});

  final HealthFactor factor;

  Color _scoreColor(ColorScheme cs) {
    if (factor.score >= 80) return cs.primary;
    if (factor.score >= 60) return cs.tertiary;
    return cs.error;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final scoreColor = _scoreColor(cs);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cs.secondaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_factorIcon(factor.title),
                    size: 20, color: cs.onSecondaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(factor.title,
                        style: tt.titleSmall?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w600)),
                    Text(factor.subtitle,
                        style: tt.labelSmall
                            ?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${factor.score}',
                      style: tt.titleMedium?.copyWith(
                          color: scoreColor,
                          fontWeight: FontWeight.w700)),
                  Text('/ 100',
                      style: tt.labelSmall
                          ?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: factor.score / 100,
            backgroundColor: cs.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
            minHeight: 5,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(factor.description,
              style:
                  tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tip card
// ---------------------------------------------------------------------------

class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip});

  final HealthTip tip;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb_outline_rounded,
                  size: 16, color: cs.tertiary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(tip.tip,
                    style: tt.bodySmall?.copyWith(color: cs.onSurface)),
              ),
            ],
          ),
          if (tip.challengeName != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Spacer(),
                GestureDetector(
                  onTap: () =>
                      debugPrint('start challenge: ${tip.challengeName}'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: cs.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('start challenge',
                        style: tt.labelMedium?.copyWith(
                            color: cs.onSecondaryContainer,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
