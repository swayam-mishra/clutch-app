import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final List<Map<String, dynamic>> activeChallenges = [
  {
    'id': 1,
    'name': 'No Eating Out Week',
    'description': 'Cook at home for 7 days straight',
    'icon': Icons.no_meals_rounded,
    'difficulty': 'medium',
    'duration': '7 days',
    'daysLeft': 4,
    'totalDays': 7,
    'progress': 0.43,
    'reward': '₹500 saved badge',
    'rewardIcon': Icons.emoji_events_rounded,
    'color': 'primary',
  },
  {
    'id': 2,
    'name': '₹200/day Cap',
    'description': 'Stay under ₹200 every day this week',
    'icon': Icons.price_check_rounded,
    'difficulty': 'hard',
    'duration': '7 days',
    'daysLeft': 2,
    'totalDays': 7,
    'progress': 0.71,
    'reward': 'Budget Master badge',
    'rewardIcon': Icons.military_tech_rounded,
    'color': 'tertiary',
  },
];

final List<Map<String, dynamic>> availableChallenges = [
  {
    'id': 3,
    'name': '30-Day Savings Streak',
    'description': 'Save something every day for 30 days',
    'icon': Icons.local_fire_department_rounded,
    'difficulty': 'hard',
    'duration': '30 days',
    'reward': 'Savings Streak badge',
    'rewardIcon': Icons.workspace_premium_rounded,
  },
  {
    'id': 4,
    'name': 'Zero Impulse Week',
    'description': 'No unplanned purchases for 7 days',
    'icon': Icons.block_rounded,
    'difficulty': 'medium',
    'duration': '7 days',
    'reward': 'Impulse Crusher badge',
    'rewardIcon': Icons.shield_rounded,
  },
  {
    'id': 5,
    'name': 'Transport Saver',
    'description': 'Cut transport spend by 50% this week',
    'icon': Icons.directions_walk_rounded,
    'difficulty': 'easy',
    'duration': '7 days',
    'reward': 'Green Commuter badge',
    'rewardIcon': Icons.eco_rounded,
  },
];

Color _difficultyColor(String d, ColorScheme cs) {
  switch (d) {
    case 'easy':
      return cs.primary;
    case 'medium':
      return cs.tertiary;
    case 'hard':
      return cs.error;
    default:
      return cs.outline;
  }
}

class ChallengesSection extends ConsumerWidget {
  const ChallengesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Active challenges header
        Row(
          children: [
            Text(
              'active challenges',
              style: tt.titleMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${activeChallenges.length}',
                style: tt.labelSmall?.copyWith(
                  color: cs.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Active challenge cards
        ...activeChallenges.map((c) => _ActiveChallengeCard(
              challenge: c,
              cs: cs,
              tt: tt,
            )),

        const SizedBox(height: 24),

        // Available challenges header
        Row(
          children: [
            Text(
              'available challenges',
              style: tt.titleMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Available challenge cards
        ...availableChallenges.map((c) => _AvailableChallengeCard(
              challenge: c,
              cs: cs,
              tt: tt,
            )),

        const SizedBox(height: 80),
      ],
    );
  }
}

class _ActiveChallengeCard extends StatelessWidget {
  const _ActiveChallengeCard({
    required this.challenge,
    required this.cs,
    required this.tt,
  });

  final Map<String, dynamic> challenge;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    final isPrimary = challenge['color'] == 'primary';
    final bgColor = isPrimary ? cs.primaryContainer : cs.tertiaryContainer;
    final onColor =
        isPrimary ? cs.onPrimaryContainer : cs.onTertiaryContainer;
    final progress = challenge['progress'] as double;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  challenge['icon'] as IconData,
                  color: onColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge['name'] as String,
                      style: tt.titleSmall?.copyWith(
                        color: onColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      challenge['description'] as String,
                      style: tt.labelSmall?.copyWith(
                        color: onColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      challenge['difficulty'] as String,
                      style: tt.labelSmall?.copyWith(
                        color: onColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${challenge['daysLeft']}d left',
                    style: tt.labelSmall?.copyWith(
                      color: onColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(onColor),
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                challenge['rewardIcon'] as IconData,
                size: 14,
                color: onColor.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
              Text(
                challenge['reward'] as String,
                style: tt.labelSmall?.copyWith(
                  color: onColor.withValues(alpha: 0.7),
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toInt()}%',
                style: tt.labelSmall?.copyWith(
                  color: onColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AvailableChallengeCard extends StatelessWidget {
  const _AvailableChallengeCard({
    required this.challenge,
    required this.cs,
    required this.tt,
  });

  final Map<String, dynamic> challenge;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    final difficulty = challenge['difficulty'] as String;
    final diffColor = _difficultyColor(difficulty, cs);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cs.secondaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  challenge['icon'] as IconData,
                  color: cs.onSecondaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge['name'] as String,
                      style: tt.titleSmall?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: diffColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        difficulty,
                        style: tt.labelSmall?.copyWith(
                          color: diffColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      challenge['description'] as String,
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    challenge['duration'] as String,
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => print('join challenge ${challenge['id']}'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: cs.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'join',
                        style: tt.labelMedium?.copyWith(
                          color: cs.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                challenge['rewardIcon'] as IconData,
                size: 12,
                color: cs.primary,
              ),
              const SizedBox(width: 4),
              Text(
                challenge['reward'] as String,
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
