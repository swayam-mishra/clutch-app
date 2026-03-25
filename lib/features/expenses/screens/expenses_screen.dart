import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/expense_provider.dart';

const List<String> _categories = [
  'All', 'Food & Dining', 'Transport',
  'Shopping', 'Entertainment', 'Education',
];

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  String _searchQuery = '';
  String? _selectedCategory;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static IconData _categoryIcon(String category) {
    switch (category) {
      case 'Food & Dining': return Icons.restaurant_rounded;
      case 'Transport':     return Icons.directions_car_rounded;
      case 'Shopping':      return Icons.shopping_bag_rounded;
      case 'Entertainment': return Icons.movie_rounded;
      case 'Health':        return Icons.favorite_rounded;
      case 'Bills':         return Icons.receipt_rounded;
      case 'Education':     return Icons.school_rounded;
      default:              return Icons.category_rounded;
    }
  }

  static String _displayDate(Expense e) {
    final local = DateTime.parse('${e.date}T${e.time}:00Z').toLocal();
    return DateFormat('d MMM yyyy').format(local);
  }

  List<Expense> _filter(List<Expense> expenses) {
    return expenses.where((e) {
      final matchSearch = _searchQuery.isEmpty ||
          e.tag.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchCat =
          _selectedCategory == null || e.category == _selectedCategory;
      return matchSearch && matchCat;
    }).toList();
  }

  Map<String, List<Expense>> _group(List<Expense> filtered) {
    final result = <String, List<Expense>>{};
    for (final e in filtered) {
      result.putIfAbsent(_displayDate(e), () => []).add(e);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final expenses = ref.watch(expenseNotifierProvider).valueOrNull ?? [];
    final filtered = _filter(expenses);
    final grouped = _group(filtered);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // Pinned header
          SliverAppBar(
            backgroundColor: AppTheme.background,
            floating: false,
            pinned: true,
            snap: false,
            expandedHeight: 0,
            centerTitle: false,
            title: Text(
              'expenses',
              style: tt.titleLarge?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              Text(
                '${expenses.length} transactions',
                style: tt.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),

          // Search + filter section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'search expenses...',
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: cs.onSurfaceVariant,
                          size: 20,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                ),
                                onPressed: () => setState(() {
                                  _searchQuery = '';
                                  _searchController.clear();
                                }),
                              )
                            : null,
                        border: InputBorder.none,
                        filled: false,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Category chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((cat) {
                        final isSelected = cat == 'All'
                            ? _selectedCategory == null
                            : _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _selectedCategory =
                                  cat == 'All' ? null : cat;
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? cs.secondaryContainer
                                    : cs.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                cat,
                                style: tt.labelMedium?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? cs.onSecondaryContainer
                                      : cs.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // Expense groups or empty state
          if (filtered.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'no expenses found',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final entries = grouped.entries.toList();
                  // Build a flat list of: [header, item, item, ..., header, ...]
                  final widgets = <Widget>[];
                  for (final entry in entries) {
                    final date = entry.key;
                    final items = entry.value;
                    final dayTotal = items.fold<double>(
                      0, (sum, e) => sum + e.amount,
                    );
                    // Date header
                    widgets.add(
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Row(
                          children: [
                            Text(
                              date,
                              style: tt.titleSmall?.copyWith(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'day total: ₹${dayTotal.toInt()}',
                              style: tt.labelMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                    // Expense items
                    for (final expense in items) {
                      widgets.add(
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4,
                            ),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: cs.secondaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                _categoryIcon(expense.category),
                                color: cs.onSecondaryContainer,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              expense.tag,
                              style: tt.bodyMedium?.copyWith(
                                color: cs.onSurface,
                              ),
                            ),
                            subtitle: Text(
                              expense.category,
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${expense.amount.toInt()}',
                                  style: tt.titleSmall?.copyWith(
                                    color: cs.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  expense.time,
                                  style: tt.labelSmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            onTap: null,
                          ),
                        ),
                      );
                    }
                  }
                  return widgets[index];
                },
                childCount: grouped.entries.fold<int>(
                  0, (sum, e) => sum + 1 + e.value.length,
                ),
              ),
            ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
