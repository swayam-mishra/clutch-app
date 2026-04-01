import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../features/budget/providers/budget_provider.dart';
import '../../features/budget/widgets/budget_menu_sheet.dart';
import '../extensions/currency_extension.dart';

/// Buckwheat-style budget pill.
///
/// Two-section design: "for today" label on the left, large status-colored
/// amount on the right. Tapping opens the budget management sheet.
class BudgetPill extends ConsumerWidget {
  const BudgetPill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final budgetAsync = ref.watch(budgetNotifierProvider);

    return budgetAsync.when(
      loading: () => _PillSkeleton(cs: cs),
      error: (_, _) => _PillSkeleton(cs: cs),
      data: (budget) {
        if (budget == null) return _PillSkeleton(cs: cs);

        final dailyRemaining = budget.dailyRemaining;
        final isOver = dailyRemaining <= 0;
        final amountText = isOver
            ? '-${(-dailyRemaining).toRupees()}'
            : dailyRemaining.toRupees();
        final amountColor = isOver
            ? AppTheme.budgetBad
            : AppTheme.budgetStateColor(budget.spentFraction);

        return GestureDetector(
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            barrierColor: cs.scrim.withValues(alpha: 0.32),
            builder: (_) => const BudgetMenuSheet(),
          ),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: amountColor.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              children: [
                Text(
                  'for today',
                  style: tt.labelMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const Spacer(),
                Text(
                  amountText,
                  style: tt.titleLarge?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PillSkeleton extends StatelessWidget {
  const _PillSkeleton({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}
