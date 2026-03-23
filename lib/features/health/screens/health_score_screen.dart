import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';

// ── Mock data ─────────────────────────────────────────────────────────────────

const int _kScore = 82;

typedef _Factor = ({
  IconData icon,
  String title,
  String subtitle,
  int score,
  String description,
});

const List<_Factor> _kFactors = [
  (
    icon: Icons.check_circle_outline_rounded,
    title: 'adherence',
    subtitle: 'sticking to your daily budget',
    score: 85,
    description: 'You stayed within budget on 24 of 31 days this month.',
  ),
  (
    icon: Icons.speed_rounded,
    title: 'velocity',
    subtitle: 'how fast you\'re spending',
    score: 72,
    description: 'Your spending pace is slightly above target for the month.',
  ),
  (
    icon: Icons.local_fire_department_rounded,
    title: 'streak',
    subtitle: 'consistent daily logging',
    score: 90,
    description: '9-day logging streak — you\'re building a great habit.',
  ),
];

typedef _Tip = ({String tip, String? challengeName, IconData? challengeIcon});

const List<_Tip> _kTips = [
  (
    tip:
        'You overspent 3 days this week. Try the ₹200/day Cap challenge to build discipline.',
    challengeName: '₹200/day Cap',
    challengeIcon: Icons.price_check_rounded,
  ),
  (
    tip:
        'Your spending velocity is high mid-week. Plan your Tuesday purchases in advance.',
    challengeName: null,
    challengeIcon: null,
  ),
  (
    tip:
        'You\'re on a 9-day streak — join the 30-Day Savings Streak to make it official.',
    challengeName: '30-Day Savings Streak',
    challengeIcon: Icons.local_fire_department_rounded,
  ),
];

const List<FlSpot> _kTrendSpots = [
  FlSpot(0, 74),
  FlSpot(1, 78),
  FlSpot(2, 80),
  FlSpot(3, 76),
  FlSpot(4, 82),
  FlSpot(5, 84),
  FlSpot(6, 82),
];

const List<String> _kDayLabels = [
  'mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'
];

// ── Screen ────────────────────────────────────────────────────────────────────

class HealthScoreScreen extends ConsumerWidget {
  const HealthScoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final Color progressColor;
    final Color statusBg;
    final Color statusOn;
    final String statusLabel;
    final String statusSubtitle;

    if (_kScore >= 80) {
      progressColor = cs.primary;
      statusBg = cs.primaryContainer;
      statusOn = cs.onPrimaryContainer;
      statusLabel = 'doing well';
      statusSubtitle = 'based on your last 30 days';
    } else if (_kScore >= 60) {
      progressColor = cs.tertiary;
      statusBg = cs.tertiaryContainer;
      statusOn = cs.onTertiaryContainer;
      statusLabel = 'watch out';
      statusSubtitle = 'a few areas need attention';
    } else {
      progressColor = cs.error;
      statusBg = cs.errorContainer;
      statusOn = cs.onErrorContainer;
      statusLabel = 'off track';
      statusSubtitle = 'let\'s get back on budget';
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: true,
        title: Text(
          'health score',
          style: tt.titleMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),

            // ── Score ring ────────────────────────────────────────────────
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
                            value: _kScore.toDouble(),
                            color: progressColor,
                            radius: 22,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: (100 - _kScore).toDouble(),
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
                        Text(
                          '$_kScore',
                          style: tt.displaySmall?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '/ 100',
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
            const SizedBox(height: 16),

            // Status chip + subtitle
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusLabel,
                      style: tt.labelLarge?.copyWith(
                        color: statusOn,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    statusSubtitle,
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            Divider(color: cs.outlineVariant),
            const SizedBox(height: 24),

            // ── Breakdown ─────────────────────────────────────────────────
            Text(
              'breakdown',
              style: tt.titleMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            ..._kFactors.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _FactorCard(factor: f),
              ),
            ),

            const SizedBox(height: 24),
            Divider(color: cs.outlineVariant),
            const SizedBox(height: 24),

            // ── 7-day trend ───────────────────────────────────────────────
            Text(
              '7-day trend',
              style: tt.titleMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 96,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  minY: 55,
                  maxY: 100,
                  lineTouchData: const LineTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= _kDayLabels.length) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            _kDayLabels[idx],
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _kTrendSpots,
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

            // ── Suggestions ───────────────────────────────────────────────
            Row(
              children: [
                Text(
                  'suggestions',
                  style: tt.titleMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: cs.tertiaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'ai',
                    style: tt.labelSmall?.copyWith(
                      color: cs.onTertiaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ..._kTips.map((t) => _TipCard(tip: t)),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// ── Factor card ───────────────────────────────────────────────────────────────

class _FactorCard extends StatelessWidget {
  const _FactorCard({required this.factor});

  final _Factor factor;

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
                child: Icon(
                  factor.icon,
                  size: 20,
                  color: cs.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      factor.title,
                      style: tt.titleSmall?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      factor.subtitle,
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${factor.score}',
                    style: tt.titleMedium?.copyWith(
                      color: scoreColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '/ 100',
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
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
          Text(
            factor.description,
            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ── Tip card ──────────────────────────────────────────────────────────────────

class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip});

  final _Tip tip;

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
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 16,
                color: cs.tertiary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  tip.tip,
                  style: tt.bodySmall?.copyWith(color: cs.onSurface),
                ),
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tip.challengeIcon,
                          size: 12,
                          color: cs.onSecondaryContainer,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'start challenge',
                          style: tt.labelMedium?.copyWith(
                            color: cs.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
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
