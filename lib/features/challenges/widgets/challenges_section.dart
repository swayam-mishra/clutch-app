import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/challenges_provider.dart';

// ---------------------------------------------------------------------------
// Icon mapping
// ---------------------------------------------------------------------------

IconData _challengeIcon(String key) {
  const map = {
    'no_meals': Icons.no_meals_rounded,
    'price_check': Icons.price_check_rounded,
    'local_fire_department': Icons.local_fire_department_rounded,
    'block': Icons.block_rounded,
    'directions_walk': Icons.directions_walk_rounded,
    'emoji_events': Icons.emoji_events_rounded,
    'military_tech': Icons.military_tech_rounded,
    'workspace_premium': Icons.workspace_premium_rounded,
    'shield': Icons.shield_rounded,
    'eco': Icons.eco_rounded,
    'savings': Icons.savings_rounded,
    'trending_down': Icons.trending_down_rounded,
    'restaurant': Icons.restaurant_rounded,
    'coffee': Icons.coffee_rounded,
    'shopping_bag': Icons.shopping_bag_rounded,
    'directions_bus': Icons.directions_bus_rounded,
  };
  return map[key] ?? Icons.star_rounded;
}

// ---------------------------------------------------------------------------
// Difficulty color helper
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// ChallengesSection
// ---------------------------------------------------------------------------

class ChallengesSection extends ConsumerWidget {
  const ChallengesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final challengesAsync = ref.watch(challengesNotifierProvider);

    return challengesAsync.when(
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(color: cs.primary)),
      ),
      error: (_, err) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text('failed to load challenges',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
      ),
      data: (data) => Column(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${data.active.length}',
                  style: tt.labelSmall?.copyWith(
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (data.active.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'no active challenges — join one below',
                style:
                    tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            )
          else
            ...data.active.map((c) => _ActiveChallengeCard(
                  challenge: c,
                  cs: cs,
                  tt: tt,
                )),

          const SizedBox(height: 24),

          // Available challenges header
          Text(
            'available challenges',
            style: tt.titleMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          if (data.available.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'you\'ve joined all available challenges!',
                style:
                    tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            )
          else
            ...data.available.map((c) => _AvailableChallengeCard(
                  challenge: c,
                  cs: cs,
                  tt: tt,
                )),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Active challenge card
// ---------------------------------------------------------------------------

class _ActiveChallengeCard extends StatelessWidget {
  const _ActiveChallengeCard({
    required this.challenge,
    required this.cs,
    required this.tt,
  });

  final ActiveChallenge challenge;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    final isPrimary = challenge.color == 'primary';
    final bgColor =
        isPrimary ? cs.primaryContainer : cs.tertiaryContainer;
    final onColor =
        isPrimary ? cs.onPrimaryContainer : cs.onTertiaryContainer;

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
                child: Icon(_challengeIcon(challenge.iconKey),
                    color: onColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(challenge.name,
                        style: tt.titleSmall?.copyWith(
                            color: onColor,
                            fontWeight: FontWeight.w600)),
                    Text(challenge.description,
                        style: tt.labelSmall?.copyWith(
                            color: onColor.withValues(alpha: 0.7))),
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
                    child: Text(challenge.difficulty,
                        style: tt.labelSmall?.copyWith(
                            color: onColor,
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 4),
                  Text('${challenge.daysLeft}d left',
                      style: tt.labelSmall?.copyWith(
                          color: onColor.withValues(alpha: 0.7))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: challenge.progress.clamp(0.0, 1.0),
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(onColor),
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(_challengeIcon(challenge.rewardIconKey),
                  size: 14, color: onColor.withValues(alpha: 0.7)),
              const SizedBox(width: 6),
              Text(challenge.reward ?? '',
                  style: tt.labelSmall
                      ?.copyWith(color: onColor.withValues(alpha: 0.7))),
              const Spacer(),
              Text('${(challenge.progress * 100).toInt()}%',
                  style: tt.labelSmall?.copyWith(
                      color: onColor, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Available challenge card
// ---------------------------------------------------------------------------

class _AvailableChallengeCard extends ConsumerWidget {
  const _AvailableChallengeCard({
    required this.challenge,
    required this.cs,
    required this.tt,
  });

  final AvailableChallenge challenge;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final difficulty = challenge.difficulty;
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
                child: Icon(_challengeIcon(challenge.iconKey),
                    color: cs.onSecondaryContainer, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(challenge.name,
                        style: tt.titleSmall?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: diffColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(difficulty,
                          style: tt.labelSmall?.copyWith(
                              color: diffColor,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 2),
                    Text(challenge.description,
                        style: tt.labelSmall
                            ?.copyWith(color: cs.onSurfaceVariant),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(challenge.duration,
                      style: tt.labelSmall
                          ?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => ref
                        .read(challengesNotifierProvider.notifier)
                        .joinChallenge(challenge.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: cs.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('join',
                          style: tt.labelMedium?.copyWith(
                              color: cs.onSecondaryContainer,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(_challengeIcon(challenge.rewardIconKey),
                  size: 12, color: cs.primary),
              const SizedBox(width: 4),
              Text(challenge.reward ?? '',
                  style: tt.labelSmall
                      ?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}
