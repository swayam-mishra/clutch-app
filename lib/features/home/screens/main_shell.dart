import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../budget/providers/budget_provider.dart';
import '../../budget/providers/daily_closeout_provider.dart';
import '../../budget/widgets/budget_menu_sheet.dart';
import '../../budget/widgets/daily_closeout_sheet.dart';
import '../../expenses/widgets/add_expense_sheet.dart';
import '../../analytics/screens/analytics_screen.dart';
import '../../expenses/screens/expenses_screen.dart';
import '../../expenses/screens/home_screen.dart';
import '../../goals/screens/goals_screen.dart';

part 'main_shell.g.dart';

@Riverpod(keepAlive: true)
class ShellTabIndex extends _$ShellTabIndex {
  @override
  int build() => 0;

  void set(int index) => state = index;
}

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  static const List<Widget> _screens = [
    HomeScreen(),
    AnalyticsScreen(),
    ExpensesScreen(),
    GoalsScreen(),
  ];

  // Tracks whether the budget sheet is currently on screen.
  // Reset to false when the sheet closes so it re-appears if the user
  // returns to the shell without completing setup.
  bool _budgetSheetShowing = false;

  void _showBudgetSheet() {
    if (_budgetSheetShowing || !mounted) return;
    _budgetSheetShowing = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.32),
      builder: (_) => const BudgetMenuSheet(),
    ).whenComplete(() => _budgetSheetShowing = false);
  }

  @override
  void initState() {
    super.initState();
    // Trigger daily close-out check after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listen<AsyncValue<DailySummary>>(
        dailySummaryNotifierProvider,
        (_, next) {
          next.whenData((summary) {
            if (summary.needsCloseout && mounted) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                barrierColor:
                    Theme.of(context).colorScheme.scrim.withValues(alpha: 0.32),
                builder: (_) => DailyCloseoutSheet(summary: summary),
              );
            }
          });
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedIndex = ref.watch(shellTabIndexProvider);

    // Show budget sheet if no active budget — check both current state (already
    // resolved) and transitions (loading → data) via watch + listen.
    final budgetAsync = ref.watch(budgetNotifierProvider);
    if (!_budgetSheetShowing) {
      budgetAsync.whenData((budget) {
        if (budget == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _showBudgetSheet());
        }
      });
    }

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: _screens,
      ),
      floatingActionButton: selectedIndex == 0
          // Home tab: ask clutch is in the keyboard — no FAB needed
          ? null
          // Other tabs: AI FAB + Add Expense FAB stacked
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'fab_ai',
                  onPressed: () =>
                      context.push(AppConstants.routePurchaseAdvisor),
                  backgroundColor: colorScheme.surfaceContainerHigh,
                  foregroundColor: colorScheme.primary,
                  elevation: 4,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, size: 18),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'fab_add',
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    barrierColor:
                        colorScheme.scrim.withValues(alpha: 0.32),
                    builder: (_) => const AddExpenseSheet(),
                  ),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  elevation: 6,
                  focusElevation: 8,
                  hoverElevation: 8,
                  highlightElevation: 12,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  child: const Icon(Icons.add_rounded),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: colorScheme.outlineVariant,
              width: 0.5,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) =>
              ref.read(shellTabIndexProvider.notifier).set(index),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'home',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart_rounded),
              label: 'analytics',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded),
              label: 'expenses',
            ),
            NavigationDestination(
              icon: Icon(Icons.flag_outlined),
              selectedIcon: Icon(Icons.flag_rounded),
              label: 'goals',
            ),
          ],
        ),
      ),
    );
  }
}
