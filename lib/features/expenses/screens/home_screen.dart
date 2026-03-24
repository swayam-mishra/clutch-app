import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../budget/providers/budget_provider.dart';
import '../../expenses/providers/expense_provider.dart';
import '../../health/providers/health_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static IconData _categoryIcon(String category) {
    switch (category) {
      case 'Food & Dining':
        return Icons.restaurant_rounded;
      case 'Transport':
        return Icons.directions_car_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Entertainment':
        return Icons.movie_rounded;
      case 'Health':
        return Icons.favorite_rounded;
      case 'Bills':
        return Icons.receipt_rounded;
      case 'Education':
        return Icons.school_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  static String _periodLabel(String isoDate) {
    final parts = isoDate.split('-');
    if (parts.length < 2) return '';
    final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    return DateFormat('MMMM yyyy').format(dt).toLowerCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final auth = ref.watch(authNotifierProvider);
    final firstName =
        (auth.userName ?? 'there').split(' ').first.toLowerCase();
    final budget = ref.watch(budgetNotifierProvider).valueOrNull;
    final allExpenses = ref.watch(expenseNotifierProvider).valueOrNull ?? [];
    final now = DateTime.now();
    final todayExpenses = allExpenses.where((e) {
      final local = DateTime.parse('${e.date}T${e.time}:00Z').toLocal();
      return local.year == now.year &&
          local.month == now.month &&
          local.day == now.day;
    }).toList();
    final dayTotal =
        todayExpenses.fold<double>(0, (sum, e) => sum + e.amount);
    final dateLabel =
        DateFormat('EEEE, d MMMM').format(DateTime.now()).toLowerCase();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar — greeting + settings
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
                child: Row(
                  children: [
                    Text(
                      'hi, $firstName',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () =>
                          context.push(AppConstants.routeSettings),
                      icon: const Icon(Icons.settings_rounded, size: 22),
                      visualDensity: VisualDensity.compact,
                      style: IconButton.styleFrom(
                        foregroundColor: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // 1. "For today" header
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'for today',
                          style: textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          dateLabel,
                          style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          budget != null
                              ? '₹${budget.dailyRemaining.toInt()}'
                              : '—',
                          style: textTheme.headlineLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'left today',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 2. Spacing
              const SizedBox(height: 8),

              // 3. Monthly budget card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'monthly budget',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 2),
                            GestureDetector(
                              onTap: () => context.push(AppConstants.routeBudgetSetup),
                              child: Icon(
                                Icons.edit_outlined,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          budget != null
                              ? _periodLabel(budget.startDate)
                              : '—',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      budget != null
                          ? '₹${budget.amount.toInt()}'
                          : '—',
                      style: textTheme.displaySmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      budget != null
                          ? '₹${budget.totalSpent.toInt()} spent · ${(budget.spentFraction * 100).toInt()}% used'
                          : '—',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: budget?.spentFraction ?? 0,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 4,
                    ),
                  ],
                ),
              ),

              // 4. Spacing
              const SizedBox(height: 8),

              // 5. Stats row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Card 1 — Remaining
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              budget != null
                                  ? '₹${budget.remainingBudget.toInt()}'
                                  : '—',
                              style: textTheme.titleLarge?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'remaining',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: (budget?.isOnTrack ?? true)
                                    ? colorScheme.primaryContainer
                                    : colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                (budget?.isOnTrack ?? true)
                                    ? 'on track'
                                    : 'over budget',
                                style: textTheme.labelSmall?.copyWith(
                                  color: (budget?.isOnTrack ?? true)
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Card 2 — Days left
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              budget != null
                                  ? '${budget.daysRemaining}'
                                  : '—',
                              style: textTheme.titleLarge?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'days left',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              budget != null
                                  ? '₹${budget.dailyLimit.toInt()}/day'
                                  : '—',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 6. Health score card
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const _HealthScoreCard(),
              ),
              const SizedBox(height: 16),

              // 7. "today's expenses" section header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'today',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => debugPrint('see all'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'see all',
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 8. Today's expense list
              if (todayExpenses.isEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    'no expenses logged today',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                ...todayExpenses.take(3).map((e) => _ExpenseItem(
                      icon: _categoryIcon(e.category),
                      title: e.tag,
                      subtitle: e.category.toLowerCase(),
                      amount: '₹${e.amount.toInt()}',
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    )),

              // Day total row
              if (todayExpenses.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Spacer(),
                      Text(
                        'day total: ₹${dayTotal.toInt()}',
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

              // 9. Bottom spacing for FAB
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}

class _HealthScoreCard extends ConsumerWidget {
  const _HealthScoreCard();

  Color _scoreColor(int score, ColorScheme cs) {
    if (score >= 80) return cs.primary;
    if (score >= 60) return cs.tertiary;
    return cs.error;
  }

  Color _statusBg(String status, ColorScheme cs) {
    switch (status) {
      case 'doing well': return cs.primaryContainer;
      case 'watch out': return cs.tertiaryContainer;
      default: return cs.errorContainer;
    }
  }

  Color _statusOn(String status, ColorScheme cs) {
    switch (status) {
      case 'doing well': return cs.onPrimaryContainer;
      case 'watch out': return cs.onTertiaryContainer;
      default: return cs.onErrorContainer;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final healthAsync = ref.watch(healthNotifierProvider);
    healthAsync.whenOrNull(error: (e, _) => debugPrint('[health] error: $e'));
    final health = healthAsync.valueOrNull;

    final score = health?.score ?? 0;
    final status = health?.status ?? '';
    final progressColor = _scoreColor(score, cs);

    return GestureDetector(
      onTap: () => context.push(AppConstants.routeHealthScore),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: health == null
            ? SizedBox(
                height: 72,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2, color: cs.primary),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('health score',
                          style: tt.labelMedium
                              ?.copyWith(color: cs.onSurfaceVariant)),
                      const Spacer(),
                      Text('$score',
                          style: tt.titleLarge?.copyWith(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w700)),
                      Text(' / 100',
                          style: tt.labelSmall
                              ?.copyWith(color: cs.onSurfaceVariant)),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded,
                          size: 18, color: cs.onSurfaceVariant),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: score / 100,
                    backgroundColor: cs.surfaceContainerHighest,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(progressColor),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _statusBg(status, cs),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(status,
                            style: tt.labelSmall?.copyWith(
                                color: _statusOn(status, cs),
                                fontWeight: FontWeight.w600)),
                      ),
                      const Spacer(),
                      ...health.factors.map((f) => Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: _FactorDot(
                              label: f.title,
                              color: _scoreColor(f.score, cs),
                            ),
                          )),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class _FactorDot extends StatelessWidget {
  const _FactorDot({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _ExpenseItem extends StatelessWidget {
  const _ExpenseItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.colorScheme,
    required this.textTheme,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String amount;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: colorScheme.onSecondaryContainer,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        ),
        subtitle: Text(
          subtitle,
          style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        trailing: Text(
          amount,
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
