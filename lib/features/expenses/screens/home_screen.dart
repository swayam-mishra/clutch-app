import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/extensions/currency_extension.dart';
import '../../../shared/widgets/animated_number.dart';
import '../../../shared/widgets/budget_pill.dart';
import '../../../shared/widgets/clutch_keyboard.dart';
import '../../expenses/providers/expense_provider.dart';

// ── Category data (shared with add_expense_sheet.dart) ───────────────────────

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

// ── HomeScreen ────────────────────────────────────────────────────────────────

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // ── Keyboard / entry state ──────────────────────────────────────────────────
  String _amount = '';
  final TextEditingController _tagController = TextEditingController();
  String? _overrideCategory;
  bool _showPicker = false;
  bool _isLogging = false;

  // AI categorization
  String? _predictedCategory;
  IconData? _predictedIcon;
  int? _predictedConfidence;
  bool _isCategorizing = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _tagController.addListener(_onTagChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _tagController.removeListener(_onTagChanged);
    _tagController.dispose();
    super.dispose();
  }

  // ── Keyboard handlers ───────────────────────────────────────────────────────

  void _appendDigit(String d) {
    if (_amount.length >= 8) return;
    if (d == '.' && _amount.contains('.')) return;
    if (d == '.' && _amount.isEmpty) return;
    setState(() => _amount += d);
  }

  void _backspace() {
    if (_amount.isEmpty) return;
    setState(() => _amount = _amount.substring(0, _amount.length - 1));
  }

  Future<void> _confirm() async {
    final amount = double.tryParse(_amount) ?? 0;
    if (amount <= 0) return;

    final tag = _tagController.text.trim();
    final finalCategory = _overrideCategory ?? _predictedCategory ?? 'Other';
    final confidence =
        _overrideCategory != null ? 100 : (_predictedConfidence ?? 100);

    setState(() => _isLogging = true);
    try {
      await ref.read(expenseNotifierProvider.notifier).logExpense(
            amount: amount,
            tag: tag.isNotEmpty ? tag : 'expense',
            category: finalCategory,
            confidence: confidence,
          );
      if (mounted) {
        setState(() {
          _amount = '';
          _overrideCategory = null;
          _predictedCategory = null;
          _predictedIcon = null;
          _predictedConfidence = null;
          _isLogging = false;
          _showPicker = false;
        });
        _tagController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${amount.toRupees()} logged'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLogging = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('failed to log expense')),
        );
      }
    }
  }

  // ── Ask Clutch ──────────────────────────────────────────────────────────────

  void _askClutch() {
    final amount = double.tryParse(_amount) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('enter an amount first')),
      );
      return;
    }
    final item = _tagController.text.trim();
    final uri = Uri(
      path: AppConstants.routePurchaseAdvisor,
      queryParameters: {
        'amount': _amount,
        if (item.isNotEmpty) 'item': item,
      },
    ).toString();
    context.push(uri);
  }

  // ── AI categorization ───────────────────────────────────────────────────────

  void _onTagChanged() {
    setState(() => _overrideCategory = null);
    _debounceTimer?.cancel();
    final tag = _tagController.text.trim();
    if (tag.isEmpty) {
      setState(() {
        _predictedCategory = null;
        _predictedIcon = null;
        _predictedConfidence = null;
        _isCategorizing = false;
      });
      return;
    }
    setState(() => _isCategorizing = true);
    _debounceTimer = Timer(
      const Duration(milliseconds: 600),
      () => _categorize(tag),
    );
  }

  Future<void> _categorize(String tag) async {
    try {
      final result =
          await ref.read(expenseNotifierProvider.notifier).categorize(tag);
      final match = _kCategories.firstWhere(
        (c) => c.category == result.category,
        orElse: () => _kCategories.last,
      );
      if (mounted) {
        setState(() {
          _predictedCategory = result.category;
          _predictedIcon = match.icon;
          _predictedConfidence = result.confidence;
          _isCategorizing = false;
          if (result.confidence < 70) _showPicker = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isCategorizing = false);
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final enteredAmount = double.tryParse(_amount) ?? 0.0;
    final hasTag = _tagController.text.isNotEmpty;

    // Category chip state
    final isOverridden = _overrideCategory != null;
    final displayCategory = _overrideCategory ?? _predictedCategory;
    final displayIcon = isOverridden
        ? _kCategories
            .firstWhere((c) => c.category == _overrideCategory,
                orElse: () => _kCategories.last)
            .icon
        : _predictedIcon;
    final confidence = isOverridden ? null : _predictedConfidence;
    final isHighConfidence = confidence != null && confidence >= 80;

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

    final isSystemKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── ZONE A: Editor (~45% of screen height) ──────────────────────
            Expanded(
              flex: 4,
              child: ClipRect(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Pill + gear header (pinned to top)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
                      child: Row(
                        children: [
                          const Expanded(child: BudgetPill()),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => context.push(AppConstants.routeSettings),
                            icon: const Icon(Icons.settings_rounded, size: 22),
                            visualDensity: VisualDensity.compact,
                            style: IconButton.styleFrom(
                              foregroundColor: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Amount display + blinking cursor — right-aligned
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 32),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: _amount.isEmpty && !isSystemKeyboardVisible
                              ? _BlinkingCursor(color: cs.primary)
                              : AnimatedNumber(
                                  value: enteredAmount,
                                  style: tt.displayLarge!.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurface,
                                  ),
                                  emptyText: '',
                                ),
                        ),
                      ),
                    ),

                  // Tag field — slides in after first digit typed
                  AnimatedSize(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    child: _amount.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                            child: TextField(
                              controller: _tagController,
                              textCapitalization: TextCapitalization.sentences,
                              cursorColor: AppTheme.textSecondary,
                              style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                              decoration: InputDecoration(
                                hintText: 'what\'s this for? (chaat, uber…)',
                                filled: true,
                                fillColor: cs.surfaceContainerHighest,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  // Category chip — animated in/out when tag typed
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: hasTag
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                GestureDetector(
                                  onTap: () => setState(
                                      () => _showPicker = !_showPicker),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: chipBg,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        if (_isCategorizing)
                                          SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: cs.onSurfaceVariant,
                                            ),
                                          )
                                        else
                                          Icon(
                                              displayIcon ??
                                                  Icons.category_rounded,
                                              size: 16,
                                              color: chipOn),
                                        const SizedBox(width: 8),
                                        Text(
                                          _isCategorizing
                                              ? 'categorizing...'
                                              : displayCategory ?? '',
                                          style: tt.labelMedium?.copyWith(
                                            color: _isCategorizing
                                                ? cs.onSurfaceVariant
                                                : chipOn,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (!_isCategorizing &&
                                            (isOverridden ||
                                                confidence != null)) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withValues(alpha: 0.18),
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                                        ],
                                        const Spacer(),
                                        Text(
                                          _showPicker ? 'close' : 'change',
                                          style: tt.labelSmall?.copyWith(
                                            color:
                                                chipOn.withValues(alpha: 0.7),
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Icon(
                                          _showPicker
                                              ? Icons.keyboard_arrow_up_rounded
                                              : Icons
                                                  .keyboard_arrow_down_rounded,
                                          size: 16,
                                          color: chipOn.withValues(alpha: 0.7),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  child: _showPicker
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children:
                                                _kCategories.map((cat) {
                                              final isSelected =
                                                  (_overrideCategory ??
                                                          _predictedCategory) ==
                                                      cat.category;
                                              return GestureDetector(
                                                onTap: () => setState(() {
                                                  _overrideCategory =
                                                      cat.category;
                                                  _showPicker = false;
                                                }),
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 8),
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? cs.secondaryContainer
                                                        : cs
                                                            .surfaceContainerHigh,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: isSelected
                                                        ? Border.all(
                                                            color: cs.primary,
                                                            width: 1)
                                                        : null,
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(cat.icon,
                                                          size: 14,
                                                          color: isSelected
                                                              ? cs
                                                                  .onSecondaryContainer
                                                              : cs
                                                                  .onSurfaceVariant),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        cat.short,
                                                        style: tt.labelMedium
                                                            ?.copyWith(
                                                          color: isSelected
                                                              ? cs
                                                                  .onSecondaryContainer
                                                              : cs
                                                                  .onSurfaceVariant,
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
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  // Drag handle
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: cs.onSurface.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ], // end inner Column children
              ), // end inner Column
            ), // end DecoratedBox
            ), // end ClipRect
          ), // end Expanded(flex:4) editor zone

            // ── ZONE B: Keyboard (dark background) ─────────────────────────
            if (!isSystemKeyboardVisible) ...[
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: ClutchKeyboard(
                    onDigit: _appendDigit,
                    onBackspace: _backspace,
                    onConfirm: _confirm,
                    onAskClutch: _askClutch,
                    isConfirmLoading: _isLogging,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ], // end outer Column children
        ), // end outer Column
      ), // end SafeArea
    ); // end Scaffold
  }
}

// ── Blinking cursor ───────────────────────────────────────────────────────────

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor({required this.color});
  final Color color;

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Container(
        width: 3,
        height: 52,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
