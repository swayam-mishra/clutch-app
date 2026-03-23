import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../challenges/widgets/challenges_section.dart';

final List<Map<String, dynamic>> mockGoals = [
  {
    'id': 1,
    'name': 'New MacBook',
    'icon': Icons.laptop_mac_rounded,
    'targetAmount': 120000.0,
    'savedAmount': 45000.0,
    'targetDate': '31 Dec 2026',
    'daysRemaining': 283,
    'estimatedCompletion': 'Oct 2026',
  },
  {
    'id': 2,
    'name': 'Goa Trip',
    'icon': Icons.beach_access_rounded,
    'targetAmount': 15000.0,
    'savedAmount': 8500.0,
    'targetDate': '01 Jun 2026',
    'daysRemaining': 70,
    'estimatedCompletion': 'May 2026',
  },
  {
    'id': 3,
    'name': 'Emergency Fund',
    'icon': Icons.shield_rounded,
    'targetAmount': 50000.0,
    'savedAmount': 12000.0,
    'targetDate': '31 Mar 2027',
    'daysRemaining': 373,
    'estimatedCompletion': 'Feb 2027',
  },
  {
    'id': 4,
    'name': 'New Phone',
    'icon': Icons.smartphone_rounded,
    'targetAmount': 25000.0,
    'savedAmount': 24000.0,
    'targetDate': '30 Apr 2026',
    'daysRemaining': 38,
    'estimatedCompletion': 'Apr 2026',
  },
];

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  double _progress(Map<String, dynamic> g) =>
      (g['savedAmount'] as double) / (g['targetAmount'] as double);

  String _percentage(Map<String, dynamic> g) =>
      '${(_progress(g) * 100).toStringAsFixed(0)}%';

  String _remaining(Map<String, dynamic> g) =>
      '₹${((g['targetAmount'] as double) - (g['savedAmount'] as double)).toInt()}';

  bool _nearDeadline(Map<String, dynamic> g) =>
      (g['daysRemaining'] as int) < 90;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Sort by daysRemaining ASC — closest deadline first
    final goals = List<Map<String, dynamic>>.from(mockGoals)
      ..sort((a, b) =>
          (a['daysRemaining'] as int).compareTo(b['daysRemaining'] as int));

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'goals',
                    style: tt.headlineSmall?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  FilledButton.tonal(
                    onPressed: () => print('add goal'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.add_rounded, size: 16),
                        const SizedBox(width: 4),
                        Text('new goal', style: tt.labelLarge),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Summary strip
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '4',
                          style: tt.titleLarge?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'active',
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1, height: 32,
                      color: cs.outlineVariant,
                    ),
                    Column(
                      children: [
                        Text(
                          '₹89,500',
                          style: tt.titleLarge?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'saved',
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1, height: 32,
                      color: cs.outlineVariant,
                    ),
                    Column(
                      children: [
                        Text(
                          '₹1,21,500',
                          style: tt.titleLarge?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'target',
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Row 1 — Large featured card (goals[0], closest deadline)
              _LargeGoalCard(
                goal: goals[0],
                cs: cs,
                tt: tt,
                progress: _progress(goals[0]),
                percentage: _percentage(goals[0]),
                remaining: _remaining(goals[0]),
                featured: true,
              ),
              const SizedBox(height: 8),

              // Row 2 — Two small cards side by side
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _SmallGoalCard(
                      goal: goals[1],
                      cs: cs,
                      tt: tt,
                      progress: _progress(goals[1]),
                      percentage: _percentage(goals[1]),
                      nearDeadline: _nearDeadline(goals[1]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SmallGoalCard(
                      goal: goals[2],
                      cs: cs,
                      tt: tt,
                      progress: _progress(goals[2]),
                      percentage: _percentage(goals[2]),
                      nearDeadline: _nearDeadline(goals[2]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Row 3 — Second large card (goals[3])
              _LargeGoalCard(
                goal: goals[3],
                cs: cs,
                tt: tt,
                progress: _progress(goals[3]),
                percentage: _percentage(goals[3]),
                remaining: _remaining(goals[3]),
                featured: false,
              ),

              const SizedBox(height: 24),
              Divider(color: cs.outlineVariant),
              const SizedBox(height: 8),

              const ChallengesSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _LargeGoalCard extends StatelessWidget {
  const _LargeGoalCard({
    required this.goal,
    required this.cs,
    required this.tt,
    required this.progress,
    required this.percentage,
    required this.remaining,
    required this.featured,
  });

  final Map<String, dynamic> goal;
  final ColorScheme cs;
  final TextTheme tt;
  final double progress;
  final String percentage;
  final String remaining;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final bgColor =
        featured ? cs.primaryContainer : cs.surfaceContainerHigh;
    final textColor =
        featured ? cs.onPrimaryContainer : cs.onSurface;
    final iconBgColor = featured
        ? cs.primary.withValues(alpha: 0.2)
        : cs.secondaryContainer;
    final iconColor =
        featured ? cs.onPrimaryContainer : cs.onSecondaryContainer;
    final progressBg = featured
        ? cs.primary.withValues(alpha: 0.2)
        : cs.surfaceContainerHighest;
    final progressColor =
        featured ? cs.onPrimaryContainer : cs.primary;
    final subtleColor = textColor.withValues(alpha: 0.7);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  goal['icon'] as IconData,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal['name'] as String,
                      style: tt.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${goal['daysRemaining']} days left',
                      style: tt.labelSmall?.copyWith(color: subtleColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    percentage,
                    style: tt.displaySmall?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'of ₹${(goal['targetAmount'] as double).toInt()}',
                    style: tt.labelSmall?.copyWith(color: subtleColor),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    remaining,
                    style: tt.titleMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'remaining',
                    style: tt.labelSmall?.copyWith(color: subtleColor),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: progressBg,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 12,
                color: subtleColor,
              ),
              const SizedBox(width: 4),
              Text(
                'on track for ${goal['estimatedCompletion']}',
                style: tt.labelSmall?.copyWith(color: subtleColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallGoalCard extends StatelessWidget {
  const _SmallGoalCard({
    required this.goal,
    required this.cs,
    required this.tt,
    required this.progress,
    required this.percentage,
    required this.nearDeadline,
  });

  final Map<String, dynamic> goal;
  final ColorScheme cs;
  final TextTheme tt;
  final double progress;
  final String percentage;
  final bool nearDeadline;

  @override
  Widget build(BuildContext context) {
    final days = goal['daysRemaining'] as int;
    final timeLabel = nearDeadline
        ? '${days}d'
        : '${(days / 30).floor()}mo';

    return Container(
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
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: cs.secondaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  goal['icon'] as IconData,
                  color: cs.onSecondaryContainer,
                  size: 18,
                ),
              ),
              const Spacer(),
              Text(
                timeLabel,
                style: tt.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            goal['name'] as String,
            style: tt.titleSmall?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            percentage,
            style: tt.headlineSmall?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: cs.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
            minHeight: 4,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '₹${(goal['savedAmount'] as double).toInt()}',
                style: tt.labelSmall?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                ' / ₹${(goal['targetAmount'] as double).toInt()}',
                style: tt.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
