import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

// ── Category data ─────────────────────────────────────────────────────────────

typedef _Cat = ({String category, String short, IconData icon});

const List<_Cat> _kCategories = [
  (category: 'Food & Dining', short: 'food', icon: Icons.restaurant_rounded),
  (category: 'Transport', short: 'transport', icon: Icons.directions_car_rounded),
  (category: 'Shopping', short: 'shopping', icon: Icons.shopping_bag_rounded),
  (category: 'Entertainment', short: 'fun', icon: Icons.movie_rounded),
  (category: 'Health', short: 'health', icon: Icons.favorite_rounded),
  (category: 'Bills', short: 'bills', icon: Icons.receipt_rounded),
  (category: 'Education', short: 'edu', icon: Icons.school_rounded),
  (category: 'Other', short: 'other', icon: Icons.category_rounded),
];

({String category, IconData icon, int confidence}) _mockCategorize(String tag) {
  final t = tag.toLowerCase();
  if (RegExp(r'chaat|food|lunch|dinner|breakfast|coffee|chai|restaurant|swiggy|zomato|drink|snack|meal|biryani|pizza|burger|juice')
      .hasMatch(t)) {
    return (category: 'Food & Dining', icon: Icons.restaurant_rounded, confidence: 91);
  }
  if (RegExp(r'uber|ola|metro|bus|auto|cab|train|flight|petrol|fuel|rapido|bike|rickshaw')
      .hasMatch(t)) {
    return (category: 'Transport', icon: Icons.directions_car_rounded, confidence: 88);
  }
  if (RegExp(r'groceries|shopping|clothes|amazon|flipkart|mall|store|kirana|market|myntra')
      .hasMatch(t)) {
    return (category: 'Shopping', icon: Icons.shopping_bag_rounded, confidence: 85);
  }
  if (RegExp(r'movie|netflix|game|spotify|youtube|entertainment|party|concert|ticket|outing')
      .hasMatch(t)) {
    return (category: 'Entertainment', icon: Icons.movie_rounded, confidence: 83);
  }
  if (RegExp(r'doctor|medicine|pharmacy|hospital|gym|health|medical|chemist|tablet')
      .hasMatch(t)) {
    return (category: 'Health', icon: Icons.favorite_rounded, confidence: 87);
  }
  if (RegExp(r'rent|electricity|wifi|bill|recharge|subscription|mobile|internet|dth')
      .hasMatch(t)) {
    return (category: 'Bills', icon: Icons.receipt_rounded, confidence: 84);
  }
  if (RegExp(r'book|course|fees|tuition|school|college|class|study|stationery|notes')
      .hasMatch(t)) {
    return (category: 'Education', icon: Icons.school_rounded, confidence: 86);
  }
  return (category: 'Other', icon: Icons.category_rounded, confidence: 52);
}

// ── Sheet ─────────────────────────────────────────────────────────────────────

class AddExpenseSheet extends StatefulWidget {
  const AddExpenseSheet({super.key});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  String _amount = '';
  final TextEditingController _tagController = TextEditingController();
  String? _overrideCategory;
  bool _showPicker = false;

  @override
  void initState() {
    super.initState();
    _tagController.addListener(_onTagChanged);
  }

  void _onTagChanged() {
    setState(() => _overrideCategory = null);
  }

  @override
  void dispose() {
    _tagController.removeListener(_onTagChanged);
    _tagController.dispose();
    super.dispose();
  }

  void _appendDigit(String d) {
    if (_amount.length >= 6) return;
    if (d == '.' && _amount.contains('.')) return;
    if (d == '.' && _amount.isEmpty) return;
    setState(() => _amount += d);
  }

  void _backspace() {
    if (_amount.isEmpty) return;
    setState(() => _amount = _amount.substring(0, _amount.length - 1));
  }

  void _confirm() {
    final tag = _tagController.text.trim();
    final predicted = tag.isNotEmpty ? _mockCategorize(tag) : null;
    final finalCategory = _overrideCategory ?? predicted?.category ?? 'Other';
    debugPrint('log: ₹$_amount · $tag · $finalCategory');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final hasTag = _tagController.text.isNotEmpty;

    // Resolve what to display in the category chip
    final predicted = hasTag ? _mockCategorize(_tagController.text) : null;
    final isOverridden = _overrideCategory != null;
    final displayCategory = _overrideCategory ?? predicted?.category;
    final displayIcon = isOverridden
        ? _kCategories
            .firstWhere((c) => c.category == _overrideCategory,
                orElse: () => _kCategories.last)
            .icon
        : predicted?.icon;
    final confidence = isOverridden ? null : predicted?.confidence;
    final isHighConfidence = confidence != null && confidence >= 80;

    // Chip colors
    final chipBg = isOverridden
        ? cs.secondaryContainer
        : isHighConfidence
            ? cs.primaryContainer
            : cs.tertiaryContainer;
    final chipOn = isOverridden
        ? cs.onSecondaryContainer
        : isHighConfidence
            ? cs.onPrimaryContainer
            : cs.onTertiaryContainer;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      height: _showPicker ? screenHeight * 0.92 : screenHeight * 0.85,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
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

          // Amount display
          Column(
            children: [
              Text(
                _amount.isEmpty ? '₹0' : '₹$_amount',
                style: tt.displayMedium?.copyWith(
                  color: _amount.isEmpty ? cs.onSurfaceVariant : cs.onSurface,
                  fontWeight: _amount.isEmpty ? null : FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'enter amount',
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tag input
          TextField(
            controller: _tagController,
            textCapitalization: TextCapitalization.sentences,
            cursorColor: AppTheme.textSecondary,
            style: tt.bodyMedium?.copyWith(color: cs.onSurface),
            decoration: InputDecoration(
              hintText: 'what was this for? (chaat, uber...)',
              filled: true,
              fillColor: cs.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          // Category preview + picker — animated in/out
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: hasTag
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),

                      // Category chip row
                      GestureDetector(
                        onTap: () =>
                            setState(() => _showPicker = !_showPicker),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: chipBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(displayIcon, size: 16, color: chipOn),
                              const SizedBox(width: 8),
                              Text(
                                displayCategory ?? '',
                                style: tt.labelMedium?.copyWith(
                                  color: chipOn,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Confidence badge OR "edited" badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isOverridden
                                      ? 'edited'
                                      : '$confidence%',
                                  style: tt.labelSmall?.copyWith(
                                    color: chipOn,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _showPicker ? 'close' : 'change',
                                style: tt.labelSmall?.copyWith(
                                  color: chipOn.withValues(alpha: 0.7),
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                _showPicker
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                size: 16,
                                color: chipOn.withValues(alpha: 0.7),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Category picker grid
                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        child: _showPicker
                            ? Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _kCategories.map((cat) {
                                    final isSelected =
                                        (_overrideCategory ??
                                                predicted?.category) ==
                                            cat.category;
                                    return GestureDetector(
                                      onTap: () => setState(() {
                                        _overrideCategory = cat.category;
                                        _showPicker = false;
                                      }),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? cs.secondaryContainer
                                              : cs.surfaceContainerHigh,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: isSelected
                                              ? Border.all(
                                                  color: cs.primary,
                                                  width: 1,
                                                )
                                              : null,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              cat.icon,
                                              size: 14,
                                              color: isSelected
                                                  ? cs.onSecondaryContainer
                                                  : cs.onSurfaceVariant,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              cat.short,
                                              style: tt.labelMedium
                                                  ?.copyWith(
                                                color: isSelected
                                                    ? cs.onSecondaryContainer
                                                    : cs.onSurfaceVariant,
                                                fontWeight: isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 16),

          // Numpad
          _NumRow(children: [
            _NumButton(label: '7', onTap: () => _appendDigit('7'), cs: cs, tt: tt),
            _NumButton(label: '8', onTap: () => _appendDigit('8'), cs: cs, tt: tt),
            _NumButton(label: '9', onTap: () => _appendDigit('9'), cs: cs, tt: tt),
            _BackspaceButton(onTap: _backspace, cs: cs),
          ]),
          const SizedBox(height: 8),
          _NumRow(children: [
            _NumButton(label: '4', onTap: () => _appendDigit('4'), cs: cs, tt: tt),
            _NumButton(label: '5', onTap: () => _appendDigit('5'), cs: cs, tt: tt),
            _NumButton(label: '6', onTap: () => _appendDigit('6'), cs: cs, tt: tt),
            const SizedBox(height: 56),
          ]),
          const SizedBox(height: 8),
          _NumRow(children: [
            _NumButton(label: '1', onTap: () => _appendDigit('1'), cs: cs, tt: tt),
            _NumButton(label: '2', onTap: () => _appendDigit('2'), cs: cs, tt: tt),
            _NumButton(label: '3', onTap: () => _appendDigit('3'), cs: cs, tt: tt),
            _ConfirmButton(onTap: _confirm, cs: cs),
          ]),
          const SizedBox(height: 8),
          _NumRow(children: [
            const SizedBox(height: 56),
            _NumButton(label: '0', onTap: () => _appendDigit('0'), cs: cs, tt: tt),
            _NumButton(label: '.', onTap: () => _appendDigit('.'), cs: cs, tt: tt),
            const SizedBox(height: 56),
          ]),
        ],
      ),
    );
  }
}

// ── Layout helpers ────────────────────────────────────────────────────────────

class _NumRow extends StatelessWidget {
  const _NumRow({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: children
          .expand((w) => [Expanded(child: w), const SizedBox(width: 8)])
          .toList()
        ..removeLast(),
    );
  }
}

class _NumButton extends StatelessWidget {
  const _NumButton({
    required this.label,
    required this.onTap,
    required this.cs,
    required this.tt,
  });

  final String label;
  final VoidCallback onTap;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: tt.headlineSmall?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _BackspaceButton extends StatelessWidget {
  const _BackspaceButton({required this.onTap, required this.cs});
  final VoidCallback onTap;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.backspace_outlined,
          size: 20,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({required this.onTap, required this.cs});
  final VoidCallback onTap;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.check_rounded,
          size: 24,
          color: cs.onPrimary,
        ),
      ),
    );
  }
}
