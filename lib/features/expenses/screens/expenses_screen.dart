import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';

final List<Map<String, dynamic>> mockExpenses = [
  {
    'id': 1, 'date': '23 Mar 2026', 'tag': 'chaat',
    'category': 'Food & Dining', 'amount': 60.0,
    'time': '09:12', 'icon': Icons.restaurant_rounded,
  },
  {
    'id': 2, 'date': '23 Mar 2026', 'tag': 'uber',
    'category': 'Transport', 'amount': 120.0,
    'time': '10:45', 'icon': Icons.directions_car_rounded,
  },
  {
    'id': 3, 'date': '23 Mar 2026', 'tag': 'cold drink',
    'category': 'Food & Dining', 'amount': 20.0,
    'time': '14:30', 'icon': Icons.local_cafe_rounded,
  },
  {
    'id': 4, 'date': '22 Mar 2026', 'tag': 'groceries',
    'category': 'Shopping', 'amount': 340.0,
    'time': '11:20', 'icon': Icons.shopping_bag_rounded,
  },
  {
    'id': 5, 'date': '22 Mar 2026', 'tag': 'metro',
    'category': 'Transport', 'amount': 30.0,
    'time': '09:05', 'icon': Icons.directions_subway_rounded,
  },
  {
    'id': 6, 'date': '21 Mar 2026', 'tag': 'netflix',
    'category': 'Entertainment', 'amount': 199.0,
    'time': '20:00', 'icon': Icons.play_circle_outline_rounded,
  },
  {
    'id': 7, 'date': '21 Mar 2026', 'tag': 'dinner',
    'category': 'Food & Dining', 'amount': 450.0,
    'time': '21:30', 'icon': Icons.restaurant_rounded,
  },
  {
    'id': 8, 'date': '20 Mar 2026', 'tag': 'rapido',
    'category': 'Transport', 'amount': 45.0,
    'time': '08:15', 'icon': Icons.two_wheeler_rounded,
  },
  {
    'id': 9, 'date': '20 Mar 2026', 'tag': 'books',
    'category': 'Education', 'amount': 280.0,
    'time': '15:00', 'icon': Icons.menu_book_rounded,
  },
  {
    'id': 10, 'date': '19 Mar 2026', 'tag': 'maggi',
    'category': 'Food & Dining', 'amount': 30.0,
    'time': '23:45', 'icon': Icons.ramen_dining_rounded,
  },
];

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

  List<Map<String, dynamic>> get _filtered {
    return mockExpenses.where((e) {
      final matchSearch = _searchQuery.isEmpty ||
          (e['tag'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      final matchCat = _selectedCategory == null ||
          e['category'] == _selectedCategory;
      return matchSearch && matchCat;
    }).toList();
  }

  Map<String, List<Map<String, dynamic>>> get _grouped {
    final result = <String, List<Map<String, dynamic>>>{};
    for (final e in _filtered) {
      result.putIfAbsent(e['date'] as String, () => []).add(e);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final grouped = _grouped;

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
                '${mockExpenses.length} transactions',
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
                                style: TextStyle(
                                  fontSize: 13,
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
          if (_filtered.isEmpty)
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
                      0, (sum, e) => sum + (e['amount'] as double),
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
                                expense['icon'] as IconData,
                                color: cs.onSecondaryContainer,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              expense['tag'] as String,
                              style: tt.bodyMedium?.copyWith(
                                color: cs.onSurface,
                              ),
                            ),
                            subtitle: Text(
                              expense['category'] as String,
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${(expense['amount'] as double).toInt()}',
                                  style: tt.titleSmall?.copyWith(
                                    color: cs.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  expense['time'] as String,
                                  style: tt.labelSmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () =>
                                print('tapped ${expense['tag']}'),
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
