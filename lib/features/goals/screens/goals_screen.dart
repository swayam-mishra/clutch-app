import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../challenges/widgets/challenges_section.dart';
import '../providers/goals_provider.dart';

// ---------------------------------------------------------------------------
// Icon mapping
// ---------------------------------------------------------------------------

IconData _iconData(String icon) {
  switch (icon) {
    case 'laptop':
      return Icons.laptop_mac_rounded;
    case 'travel':
      return Icons.beach_access_rounded;
    case 'shield':
      return Icons.shield_rounded;
    case 'phone':
      return Icons.smartphone_rounded;
    case 'home':
      return Icons.home_rounded;
    default:
      return Icons.savings_rounded;
  }
}

// ---------------------------------------------------------------------------
// GoalsScreen
// ---------------------------------------------------------------------------

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  double _progress(Goal g) => g.savedAmount / g.targetAmount;
  String _percentage(Goal g) =>
      '${(_progress(g) * 100).toStringAsFixed(0)}%';
  String _remaining(Goal g) =>
      '₹${(g.targetAmount - g.savedAmount).toInt()}';
  bool _nearDeadline(Goal g) => g.daysRemaining < 90;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final goalsAsync = ref.watch(goalsNotifierProvider);

    return goalsAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(child: CircularProgressIndicator(color: cs.primary)),
      ),
      error: (_, err) => Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: Text('failed to load goals',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
        ),
      ),
      data: (rawGoals) {
        final goals = List<Goal>.from(rawGoals)
          ..sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));

        final totalSaved =
            goals.fold<double>(0, (s, g) => s + g.savedAmount);
        final totalTarget =
            goals.fold<double>(0, (s, g) => s + g.targetAmount);

        return Scaffold(
          backgroundColor: AppTheme.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Header
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
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const _AddGoalSheet(),
                        ),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 36),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12)),
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
                              '${goals.length}',
                              style: tt.titleLarge?.copyWith(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text('active',
                                style: tt.labelSmall?.copyWith(
                                    color: cs.onSurfaceVariant)),
                          ],
                        ),
                        Container(
                            width: 1,
                            height: 32,
                            color: cs.outlineVariant),
                        Column(
                          children: [
                            Text(
                              '₹${totalSaved.toInt()}',
                              style: tt.titleLarge?.copyWith(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text('saved',
                                style: tt.labelSmall?.copyWith(
                                    color: cs.onSurfaceVariant)),
                          ],
                        ),
                        Container(
                            width: 1,
                            height: 32,
                            color: cs.outlineVariant),
                        Column(
                          children: [
                            Text(
                              '₹${totalTarget.toInt()}',
                              style: tt.titleLarge?.copyWith(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text('target',
                                style: tt.labelSmall?.copyWith(
                                    color: cs.onSurfaceVariant)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Goals list — adaptive layout
                  if (goals.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          'no goals yet — add your first one',
                          style: tt.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant),
                        ),
                      ),
                    )
                  else ...[
                    // First goal — large featured
                    _LargeGoalCard(
                      goal: goals[0],
                      cs: cs,
                      tt: tt,
                      progress: _progress(goals[0]),
                      percentage: _percentage(goals[0]),
                      remaining: _remaining(goals[0]),
                      featured: true,
                    ),

                    if (goals.length >= 3) ...[
                      const SizedBox(height: 8),
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
                    ] else if (goals.length == 2) ...[
                      const SizedBox(height: 8),
                      _LargeGoalCard(
                        goal: goals[1],
                        cs: cs,
                        tt: tt,
                        progress: _progress(goals[1]),
                        percentage: _percentage(goals[1]),
                        remaining: _remaining(goals[1]),
                        featured: false,
                      ),
                    ],

                    // goals[3] and beyond — large cards
                    ...goals.sublist(goals.length > 3 ? 3 : goals.length).map(
                          (g) => Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: _LargeGoalCard(
                              goal: g,
                              cs: cs,
                              tt: tt,
                              progress: _progress(g),
                              percentage: _percentage(g),
                              remaining: _remaining(g),
                              featured: false,
                            ),
                          ),
                        ),
                  ],

                  const SizedBox(height: 24),
                  Divider(color: cs.outlineVariant),
                  const SizedBox(height: 8),

                  const ChallengesSection(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Large goal card
// ---------------------------------------------------------------------------

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

  final Goal goal;
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
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(_iconData(goal.icon),
                    color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.name,
                        style: tt.titleMedium?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600)),
                    Text('${goal.daysRemaining} days left',
                        style: tt.labelSmall
                            ?.copyWith(color: subtleColor)),
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
                  Text(percentage,
                      style: tt.displaySmall?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w700)),
                  Text('of ₹${goal.targetAmount.toInt()}',
                      style:
                          tt.labelSmall?.copyWith(color: subtleColor)),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(remaining,
                      style: tt.titleMedium?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w600)),
                  Text('remaining',
                      style:
                          tt.labelSmall?.copyWith(color: subtleColor)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: progressBg,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 6,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded,
                  size: 12, color: subtleColor),
              const SizedBox(width: 4),
              Text('on track for ${goal.estimatedCompletion}',
                  style: tt.labelSmall?.copyWith(color: subtleColor)),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small goal card
// ---------------------------------------------------------------------------

class _SmallGoalCard extends StatelessWidget {
  const _SmallGoalCard({
    required this.goal,
    required this.cs,
    required this.tt,
    required this.progress,
    required this.percentage,
    required this.nearDeadline,
  });

  final Goal goal;
  final ColorScheme cs;
  final TextTheme tt;
  final double progress;
  final String percentage;
  final bool nearDeadline;

  @override
  Widget build(BuildContext context) {
    final timeLabel = nearDeadline
        ? '${goal.daysRemaining}d'
        : '${(goal.daysRemaining / 30).floor()}mo';

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
                child: Icon(_iconData(goal.icon),
                    color: cs.onSecondaryContainer, size: 18),
              ),
              const Spacer(),
              Text(timeLabel,
                  style: tt.labelSmall
                      ?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 12),
          Text(goal.name,
              style: tt.titleSmall?.copyWith(
                  color: cs.onSurface, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(percentage,
              style: tt.headlineSmall?.copyWith(
                  color: cs.onSurface, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: cs.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
            minHeight: 4,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('₹${goal.savedAmount.toInt()}',
                  style: tt.labelSmall?.copyWith(
                      color: cs.primary, fontWeight: FontWeight.w600)),
              Text(' / ₹${goal.targetAmount.toInt()}',
                  style: tt.labelSmall
                      ?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add goal bottom sheet
// ---------------------------------------------------------------------------

const _kIcons = [
  ('laptop', Icons.laptop_mac_rounded, 'laptop'),
  ('travel', Icons.beach_access_rounded, 'travel'),
  ('shield', Icons.shield_rounded, 'emergency'),
  ('phone', Icons.smartphone_rounded, 'phone'),
  ('home', Icons.home_rounded, 'home'),
  ('other', Icons.savings_rounded, 'other'),
];

class _AddGoalSheet extends ConsumerStatefulWidget {
  const _AddGoalSheet();

  @override
  ConsumerState<_AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends ConsumerState<_AddGoalSheet> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _targetDate;
  String _selectedIcon = 'other';
  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _targetDate = picked);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());

    if (name.isEmpty || amount == null || amount <= 0 || _targetDate == null) {
      setState(() => _error = 'fill in all fields');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await ref.read(goalsNotifierProvider.notifier).addGoal(
            name: name,
            targetAmount: amount,
            targetDate: _targetDate!,
            icon: _selectedIcon,
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _error = 'failed to save goal';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text('new goal',
              style: tt.titleLarge?.copyWith(
                  color: cs.onSurface, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),

          // Name
          TextField(
            controller: _nameController,
            cursorColor: AppTheme.textSecondary,
            style: tt.bodyLarge?.copyWith(color: AppTheme.textPrimary),
            decoration: const InputDecoration(hintText: 'goal name'),
          ),
          const SizedBox(height: 12),

          // Amount
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            cursorColor: AppTheme.textSecondary,
            style: tt.bodyLarge?.copyWith(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
                hintText: 'target amount (₹)', prefixText: '₹ '),
          ),
          const SizedBox(height: 12),

          // Target date
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _targetDate == null
                    ? 'target date'
                    : DateFormat('dd MMM yyyy').format(_targetDate!),
                style: tt.bodyLarge?.copyWith(
                  color: _targetDate == null
                      ? cs.onSurfaceVariant
                      : AppTheme.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Icon picker
          Text('icon',
              style: tt.labelMedium
                  ?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _kIcons.map((item) {
              final key = item.$1;
              final iconData = item.$2;
              final selected = _selectedIcon == key;
              return GestureDetector(
                onTap: () => setState(() => _selectedIcon = key),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: selected
                        ? cs.primaryContainer
                        : cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    iconData,
                    size: 22,
                    color: selected
                        ? cs.onPrimaryContainer
                        : cs.onSurfaceVariant,
                  ),
                ),
              );
            }).toList(),
          ),

          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!,
                style: tt.labelSmall?.copyWith(color: cs.error)),
          ],

          const SizedBox(height: 20),

          FilledButton(
            onPressed: _isSaving ? null : _save,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            child: _isSaving
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: cs.onPrimary))
                : const Text('save goal'),
          ),
        ],
      ),
    );
  }
}
