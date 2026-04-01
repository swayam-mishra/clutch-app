import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/extensions/currency_extension.dart';
import '../../../shared/utils/csv_export.dart';
import '../../expenses/providers/expense_provider.dart';
import '../providers/budget_provider.dart';

class BudgetMenuSheet extends ConsumerStatefulWidget {
  const BudgetMenuSheet({super.key});

  @override
  ConsumerState<BudgetMenuSheet> createState() => _BudgetMenuSheetState();
}

class _BudgetMenuSheetState extends ConsumerState<BudgetMenuSheet> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final budgetAsync = ref.watch(budgetNotifierProvider);
    final budget = budgetAsync.valueOrNull;

    return Container(
      padding: EdgeInsets.fromLTRB(
        24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 32,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            children: [
              Text(
                'budget',
                style: tt.titleMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.edit_rounded,
                    size: 18, color: cs.onSurfaceVariant),
                onPressed: () {
                  Navigator.pop(context);
                  context.push(AppConstants.routeBudgetSetup);
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (budget == null)
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: budgetAsync.isLoading
                    ? CircularProgressIndicator(color: cs.onPrimaryContainer)
                    : Text(
                        'no active budget',
                        style: tt.bodyMedium
                            ?.copyWith(color: cs.onPrimaryContainer),
                      ),
              ),
            )
          else ...[
            // Swipeable cards
            Stack(
              children: [
                SizedBox(
                  height: 130,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    children: [
                      _BudgetCard(
                        cs: cs,
                        tt: tt,
                        amount: budget.remainingBudget,
                        label: 'left',
                        percentText:
                            '${(budget.spentFraction * 100).toInt()}% of budget',
                      ),
                      _BudgetCard(
                        cs: cs,
                        tt: tt,
                        amount: budget.totalSpent,
                        label: 'spent',
                        percentText:
                            '${(budget.spentFraction * 100).toInt()}% of budget',
                      ),
                    ],
                  ),
                ),
                // Page dots
                Positioned(
                  top: 12,
                  right: 12,
                  child: Row(
                    children: List.generate(
                      2,
                      (i) => Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(left: 4),
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? cs.onPrimaryContainer
                              : cs.onPrimaryContainer.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Info row
            _BudgetInfoRow(cs: cs, tt: tt, budget: budget),
          ],

          const SizedBox(height: 8),
          Divider(color: cs.outlineVariant),

          // Tiles
          _SheetTile(
            icon: Icons.swap_horiz_rounded,
            title: 'rest',
            trailing: Text(
              budget?.distribution == 'distribute' ? 'distribute' : 'carry over',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            onTap: () {
              Navigator.pop(context);
              context.push(AppConstants.routeBudgetSetup);
            },
          ),
          _SheetTile(
            icon: Icons.monetization_on_outlined,
            title: 'currency',
            trailing: Text(
              budget?.currency == 'INR'
                  ? 'Indian Rupee (₹)'
                  : budget?.currency ?? 'INR',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            onTap: () {
              Navigator.pop(context);
              context.push(AppConstants.routeBudgetSetup);
            },
          ),
          _SheetTile(
            icon: Icons.download_rounded,
            title: 'export to csv',
            onTap: () {
              final expenses =
                  ref.read(expenseNotifierProvider).valueOrNull ?? [];
              exportExpensesCsv(expenses);
            },
          ),
          _SheetTile(
            icon: Icons.close_rounded,
            title: 'finish early',
            titleColor: cs.error,
            iconColor: cs.error,
            // TODO: implement /budget/finish-early endpoint on backend
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('coming soon')),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Private widgets ──────────────────────────────────────────────────────────

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.cs,
    required this.tt,
    required this.amount,
    required this.label,
    required this.percentText,
  });

  final ColorScheme cs;
  final TextTheme tt;
  final double amount;
  final String label;
  final String percentText;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            amount.toRupees(),
            style: tt.headlineMedium?.copyWith(
              color: cs.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: tt.bodySmall?.copyWith(
              color: cs.onPrimaryContainer.withValues(alpha: 0.8),
            ),
          ),
          const Spacer(),
          Text(
            percentText,
            style: tt.labelSmall?.copyWith(
              color: cs.onPrimaryContainer.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetInfoRow extends StatelessWidget {
  const _BudgetInfoRow({
    required this.cs,
    required this.tt,
    required this.budget,
  });

  final ColorScheme cs;
  final TextTheme tt;
  final BudgetState budget;

  @override
  Widget build(BuildContext context) {
    final startLabel =
        DateFormat('dd MMM').format(DateTime.parse(budget.startDate));
    final endLabel =
        DateFormat('dd MMM').format(DateTime.parse(budget.endDate));

    return Row(
      children: [
        // Starting budget
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                budget.amount.toRupees(),
                style: tt.titleMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'starting budget',
                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    startLabel,
                    style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Divider(
                          color: cs.outlineVariant, endIndent: 0, indent: 0),
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded,
                      size: 12, color: cs.onSurfaceVariant),
                  const SizedBox(width: 2),
                  Text(
                    endLabel,
                    style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // Days left circle
        SizedBox(
          width: 64,
          height: 64,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: budget.totalDays > 0
                    ? budget.daysRemaining / budget.totalDays
                    : 0,
                strokeWidth: 4,
                backgroundColor: cs.outlineVariant,
                valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                strokeCap: StrokeCap.round,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${budget.daysRemaining}',
                    style: tt.titleSmall?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'days left',
                    style:
                        tt.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontSize: 9),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SheetTile extends StatelessWidget {
  const _SheetTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.titleColor,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 20, color: iconColor ?? cs.onSurfaceVariant),
      title: Text(
        title,
        style: tt.bodyMedium?.copyWith(
          color: titleColor ?? cs.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
