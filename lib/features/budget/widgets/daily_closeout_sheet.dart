import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/extensions/currency_extension.dart';
import '../../goals/providers/goals_provider.dart';
import '../../budget/providers/budget_provider.dart';
import '../providers/daily_closeout_provider.dart';

// ---------------------------------------------------------------------------
// Icon mapping (mirrors goals_screen.dart)
// ---------------------------------------------------------------------------

IconData _goalIcon(String icon) {
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
// DailyCloseoutSheet
// ---------------------------------------------------------------------------

class DailyCloseoutSheet extends ConsumerStatefulWidget {
  const DailyCloseoutSheet({super.key, required this.summary});

  final DailySummary summary;

  @override
  ConsumerState<DailyCloseoutSheet> createState() => _DailyCloseoutSheetState();
}

class _DailyCloseoutSheetState extends ConsumerState<DailyCloseoutSheet> {
  bool _autoRoute = true;
  late Map<String, double> _sliderValues;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _sliderValues = {
      for (final g in widget.summary.activeGoals) g.id: 0.0,
    };
  }

  double get _totalAllocated =>
      _sliderValues.values.fold(0.0, (a, b) => a + b);
  double get _remaining => widget.summary.pendingSavings - _totalAllocated;

  double _maxForGoal(String goalId) {
    final othersSum = _sliderValues.entries
        .where((e) => e.key != goalId)
        .fold(0.0, (a, e) => a + e.value);
    return (widget.summary.pendingSavings - othersSum).clamp(0.0, widget.summary.pendingSavings);
  }

  Future<void> _confirm() async {
    setState(() => _loading = true);
    try {
      final notifier = ref.read(closeoutNotifierProvider.notifier);
      if (_autoRoute) {
        await notifier.allocateAuto();
      } else {
        for (final e in _sliderValues.entries) {
          notifier.setAllocation(e.key, e.value);
        }
        await notifier.allocateManual();
      }
      ref.invalidate(goalsNotifierProvider);
      ref.invalidate(budgetNotifierProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _skip() async {
    setState(() => _loading = true);
    try {
      await ref.read(closeoutNotifierProvider.notifier).dismiss();
    } finally {
      if (mounted) Navigator.of(context).pop();
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
      padding: EdgeInsets.fromLTRB(
        24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: widget.summary.type == CloseoutType.deficit
          ? _buildDeficit(cs, tt)
          : _buildSurplus(cs, tt),
    );
  }

  // ─── Deficit variant ────────────────────────────────────────────────────

  Widget _buildDeficit(ColorScheme cs, TextTheme tt) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DragHandle(),
        const SizedBox(height: 24),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: cs.errorContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.trending_up_rounded, color: cs.onErrorContainer, size: 28),
        ),
        const SizedBox(height: 16),
        Text(
          'you went over today',
          style: tt.titleLarge?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          widget.summary.deficit.toRupees(),
          style: tt.displaySmall?.copyWith(color: AppTheme.error, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'daily limit was ${widget.summary.dailyBudget.toRupees()}',
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _loading ? null : _skip,
            child: _loading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: cs.onPrimary),
                  )
                : const Text('got it'),
          ),
        ),
      ],
    );
  }

  // ─── Surplus variant ────────────────────────────────────────────────────

  Widget _buildSurplus(ColorScheme cs, TextTheme tt) {
    final hasPending = widget.summary.pendingSavings > widget.summary.surplus;
    final rolledOver = widget.summary.pendingSavings - widget.summary.surplus;

    // Auto-route: nearest deadline goal
    final autoGoal = widget.summary.activeGoals.isNotEmpty
        ? widget.summary.activeGoals.first
        : null;

    final fullyAllocated = _remaining <= 0;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: _DragHandle()),
          const SizedBox(height: 20),

          // ── Header ──────────────────────────────────────────────────────
          Text(
            'you saved ${widget.summary.surplus.toRupees()} today 🎯',
            style: tt.titleLarge?.copyWith(
              color: AppTheme.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (hasPending && rolledOver > 0) ...[
            const SizedBox(height: 4),
            Text(
              '+ ${rolledOver.toRupees()} rolled over',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Text('total to allocate  ', style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant)),
              Text(
                widget.summary.pendingSavings.toRupees(),
                style: tt.labelLarge?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Divider(color: AppTheme.divider, height: 1),
          const SizedBox(height: 20),

          // ── Auto-route toggle ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.bolt_rounded, color: AppTheme.accent, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'auto-route',
                        style: tt.labelLarge?.copyWith(color: cs.onSurface),
                      ),
                      Text(
                        'send it all to nearest deadline goal',
                        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _autoRoute,
                  onChanged: (v) => setState(() {
                    _autoRoute = v;
                    if (v) {
                      for (final k in _sliderValues.keys) {
                        _sliderValues[k] = 0.0;
                      }
                    }
                  }),
                  activeThumbColor: AppTheme.accent,
                  activeTrackColor: AppTheme.accent.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Auto-route: show target goal ─────────────────────────────────
          if (_autoRoute && autoGoal != null)
            _GoalChip(goal: autoGoal, amount: widget.summary.pendingSavings, cs: cs, tt: tt)
          // ── Manual: sliders ──────────────────────────────────────────────
          else if (!_autoRoute && widget.summary.activeGoals.isNotEmpty) ...[
            ...widget.summary.activeGoals.map((g) => _GoalSlider(
                  goal: g,
                  value: _sliderValues[g.id] ?? 0.0,
                  max: _maxForGoal(g.id),
                  onChanged: (v) => setState(() => _sliderValues[g.id] = v),
                  cs: cs,
                  tt: tt,
                )),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('remaining  ', style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
                Text(
                  _remaining.toRupees(),
                  style: tt.labelMedium?.copyWith(
                    color: fullyAllocated ? AppTheme.accent : cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (fullyAllocated) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.check_circle_rounded, size: 14, color: AppTheme.accent),
                ],
              ],
            ),
          ] else
            Text(
              'no active goals — create one first',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),

          const SizedBox(height: 24),

          // ── Confirm button ───────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _loading || widget.summary.activeGoals.isEmpty
                  ? null
                  : _confirm,
              child: _loading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: cs.onPrimary),
                    )
                  : Text(
                      _autoRoute
                          ? 'allocate ${widget.summary.pendingSavings.toRupees()}'
                          : 'allocate',
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: _loading ? null : _skip,
              child: Text(
                'skip for now',
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _DragHandle
// ---------------------------------------------------------------------------

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 4,
      decoration: BoxDecoration(
        color: AppTheme.divider,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _GoalChip — auto-route selected goal display
// ---------------------------------------------------------------------------

class _GoalChip extends StatelessWidget {
  const _GoalChip({
    required this.goal,
    required this.amount,
    required this.cs,
    required this.tt,
  });

  final CloseoutGoal goal;
  final double amount;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_goalIcon(goal.icon), color: cs.onPrimaryContainer, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(goal.name, style: tt.labelLarge?.copyWith(color: cs.onSurface)),
                Text(
                  '${goal.daysRemaining} days left',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Text(
            amount.toRupees(),
            style: tt.titleMedium?.copyWith(color: AppTheme.accent, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _GoalSlider — manual split slider for one goal
// ---------------------------------------------------------------------------

class _GoalSlider extends StatelessWidget {
  const _GoalSlider({
    required this.goal,
    required this.value,
    required this.max,
    required this.onChanged,
    required this.cs,
    required this.tt,
  });

  final CloseoutGoal goal;
  final double value;
  final double max;
  final ValueChanged<double> onChanged;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_goalIcon(goal.icon), color: cs.onPrimaryContainer, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(goal.name, style: tt.labelLarge?.copyWith(color: cs.onSurface)),
              ),
              Text(
                '${goal.daysRemaining}d left',
                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.accent,
              inactiveTrackColor: AppTheme.divider,
              thumbColor: AppTheme.accent,
              overlayColor: AppTheme.accent.withValues(alpha: 0.12),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: value.clamp(0.0, max),
              min: 0,
              max: max <= 0 ? 1 : max,
              onChanged: max <= 0 ? null : onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('₹0', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
              Text(
                'allocating: ${value.toRupees()}',
                style: tt.labelSmall?.copyWith(
                  color: value > 0 ? AppTheme.accent : cs.onSurfaceVariant,
                  fontWeight: value > 0 ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              Text(
                max.toRupees(),
                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
