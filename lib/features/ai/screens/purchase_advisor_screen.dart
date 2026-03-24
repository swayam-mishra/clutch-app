import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

class _BudgetImpact {
  const _BudgetImpact({
    required this.dailyBudget,
    required this.remaining,
    required this.afterPurchase,
    required this.percentOfBudget,
  });
  final double dailyBudget;
  final double remaining;
  final double afterPurchase;
  final double percentOfBudget;

  factory _BudgetImpact.fromJson(Map<String, dynamic> j) => _BudgetImpact(
        dailyBudget: (j['dailyBudget'] as num).toDouble(),
        remaining: (j['remaining'] as num).toDouble(),
        afterPurchase: (j['afterPurchase'] as num).toDouble(),
        percentOfBudget: (j['percentOfBudget'] as num).toDouble(),
      );
}

class _GoalImpact {
  const _GoalImpact({required this.goalName, required this.delayDays});
  final String goalName;
  final int delayDays;

  factory _GoalImpact.fromJson(Map<String, dynamic> j) => _GoalImpact(
        goalName: j['goalName'] as String,
        delayDays: (j['delayDays'] as num).toInt(),
      );
}

class _AdvisorResult {
  const _AdvisorResult({
    required this.verdict,
    required this.reason,
    required this.budgetImpact,
    required this.velocityNote,
    required this.goalImpacts,
  });
  final String verdict; // "go for it"|"think twice"|"skip it"
  final String reason;
  final _BudgetImpact budgetImpact;
  final String velocityNote;
  final List<_GoalImpact> goalImpacts;

  factory _AdvisorResult.fromJson(Map<String, dynamic> j) => _AdvisorResult(
        verdict: j['verdict'] as String,
        reason: j['reason'] as String,
        budgetImpact: _BudgetImpact.fromJson(
            j['budgetImpact'] as Map<String, dynamic>),
        velocityNote: j['velocityNote'] as String,
        goalImpacts: (j['goalImpacts'] as List<dynamic>)
            .map((e) => _GoalImpact.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class PurchaseAdvisorScreen extends ConsumerStatefulWidget {
  const PurchaseAdvisorScreen({super.key});

  @override
  ConsumerState<PurchaseAdvisorScreen> createState() =>
      _PurchaseAdvisorScreenState();
}

class _PurchaseAdvisorScreenState
    extends ConsumerState<PurchaseAdvisorScreen> {
  final _itemController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isLoading = false;
  _AdvisorResult? _result;

  @override
  void dispose() {
    _itemController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final item = _itemController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    if (item.isEmpty || price == null || price <= 0) return;

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final res = await ref.read(dioClientProvider).post(
        '/advisor/analyze',
        data: {'item': item, 'price': price},
      );
      final data = res.data['data'] as Map<String, dynamic>;
      setState(() {
        _isLoading = false;
        _result = _AdvisorResult.fromJson(data);
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('failed to analyze — try again')),
        );
      }
    }
  }

  // Verdict styling
  Color _verdictBg(ColorScheme cs) {
    switch (_result?.verdict) {
      case 'go for it': return cs.primaryContainer;
      case 'skip it':   return cs.errorContainer;
      default:          return cs.tertiaryContainer;
    }
  }

  Color _verdictOn(ColorScheme cs) {
    switch (_result?.verdict) {
      case 'go for it': return cs.onPrimaryContainer;
      case 'skip it':   return cs.onErrorContainer;
      default:          return cs.onTertiaryContainer;
    }
  }

  IconData _verdictIcon() {
    switch (_result?.verdict) {
      case 'go for it': return Icons.check_circle_rounded;
      case 'skip it':   return Icons.cancel_rounded;
      default:          return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final canSubmit = _itemController.text.isNotEmpty &&
        _priceController.text.isNotEmpty &&
        !_isLoading;

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ask clutch',
                          style: tt.headlineSmall?.copyWith(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w600)),
                      Text('should you buy it?',
                          style: tt.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.push('/chat'),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: cs.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.chat_bubble_outline_rounded,
                          size: 20, color: cs.onSecondaryContainer),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Input card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('what do you want to buy?',
                        style: tt.titleSmall?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),

                    // Item
                    Text('item',
                        style: tt.labelMedium
                            ?.copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _itemController,
                        onChanged: (_) => setState(() {}),
                        cursorColor: AppTheme.textSecondary,
                        style: tt.bodyMedium
                            ?.copyWith(color: cs.onSurface),
                        decoration: const InputDecoration.collapsed(
                          hintText:
                              'e.g. new earphones, dinner, shoes...',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Price
                    Text('price',
                        style: tt.labelMedium
                            ?.copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text('₹',
                              style: tt.titleMedium?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: TextField(
                              controller: _priceController,
                              onChanged: (_) => setState(() {}),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              cursorColor: AppTheme.textSecondary,
                              style: tt.titleMedium?.copyWith(
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.w600),
                              decoration:
                                  const InputDecoration.collapsed(
                                      hintText: '0'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Submit
                    Opacity(
                      opacity: canSubmit ? 1.0 : 0.5,
                      child: FilledButton(
                        onPressed: canSubmit ? _submit : null,
                        style: FilledButton.styleFrom(
                          minimumSize:
                              const Size(double.infinity, 52),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(16)),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: cs.onPrimary),
                              )
                            : const Text('ask clutch →'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Result
              if (_result != null) ...[
                // Verdict card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _verdictBg(cs),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _verdictOn(cs)
                                        .withValues(alpha: 0.15),
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _result!.verdict.toUpperCase(),
                                    style: tt.labelLarge?.copyWith(
                                        color: _verdictOn(cs),
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(_itemController.text,
                                    style: tt.titleLarge?.copyWith(
                                        color: _verdictOn(cs),
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text('₹${_priceController.text}',
                                    style: tt.bodySmall?.copyWith(
                                        color: _verdictOn(cs)
                                            .withValues(alpha: 0.7))),
                              ],
                            ),
                          ),
                          Icon(_verdictIcon(),
                              size: 48,
                              color: _verdictOn(cs)
                                  .withValues(alpha: 0.4)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(
                          color:
                              _verdictOn(cs).withValues(alpha: 0.2)),
                      const SizedBox(height: 16),
                      Text(_result!.reason,
                          style: tt.bodyMedium
                              ?.copyWith(color: _verdictOn(cs))),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Context cards
                Row(
                  children: [
                    // Budget impact
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 20,
                                color: cs.primary),
                            const SizedBox(height: 8),
                            Text(
                              '${_result!.budgetImpact.percentOfBudget.toStringAsFixed(1)}%',
                              style: tt.titleLarge?.copyWith(
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.w700),
                            ),
                            Text('of remaining\nbudget',
                                style: tt.labelSmall?.copyWith(
                                    color: cs.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Velocity
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.speed_rounded,
                                size: 20, color: cs.tertiary),
                            const SizedBox(height: 8),
                            Text('velocity',
                                style: tt.titleLarge?.copyWith(
                                    color: cs.onSurface,
                                    fontWeight: FontWeight.w700)),
                            Text(_result!.velocityNote,
                                style: tt.labelSmall?.copyWith(
                                    color: cs.onSurfaceVariant),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                if (_result!.goalImpacts.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  // Goal impact card
                  Container(
                    width: double.infinity,
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
                            Icon(Icons.flag_rounded,
                                size: 20, color: cs.primary),
                            const SizedBox(width: 8),
                            Text('goal impact',
                                style: tt.titleSmall?.copyWith(
                                    color: cs.onSurface,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ..._result!.goalImpacts
                            .asMap()
                            .entries
                            .map((entry) {
                          final i = entry.key;
                          final g = entry.value;
                          final delayed = g.delayDays > 0;
                          return Padding(
                            padding: EdgeInsets.only(
                                top: i > 0 ? 8 : 0),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: delayed
                                        ? cs.error
                                        : cs.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(g.goalName,
                                      style: tt.bodyMedium?.copyWith(
                                          color: cs.onSurface,
                                          fontWeight:
                                              FontWeight.w500)),
                                ),
                                Text(
                                  delayed
                                      ? 'delayed ~${g.delayDays}d'
                                      : 'no impact',
                                  style: tt.labelSmall?.copyWith(
                                    color: delayed
                                        ? cs.error
                                        : cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ],

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
