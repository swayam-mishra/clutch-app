import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class PurchaseAdvisorScreen extends ConsumerStatefulWidget {
  const PurchaseAdvisorScreen({super.key});

  @override
  ConsumerState<PurchaseAdvisorScreen> createState() =>
      _PurchaseAdvisorScreenState();
}

class _PurchaseAdvisorScreenState
    extends ConsumerState<PurchaseAdvisorScreen> {
  String _itemName = '';
  String _price = '';
  bool _hasResult = false;
  final _itemController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void dispose() {
    _itemController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final canSubmit = _itemName.isNotEmpty && _price.isNotEmpty;

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
                      Text(
                        'ask clutch',
                        style: tt.headlineSmall?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'should you buy it?',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Chat FAB
                  GestureDetector(
                    onTap: () => context.push('/chat'),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: cs.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 20,
                        color: cs.onSecondaryContainer,
                      ),
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
                    Text(
                      'what do you want to buy?',
                      style: tt.titleSmall?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Item field
                    Text(
                      'item',
                      style: tt.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _itemController,
                        onChanged: (v) => setState(() => _itemName = v),
                        cursorColor: AppTheme.textSecondary,
                        style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                        decoration: const InputDecoration.collapsed(
                          hintText: 'e.g. new earphones, dinner, shoes...',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Price field
                    Text(
                      'price',
                      style: tt.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '₹',
                            style: tt.titleMedium?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: TextField(
                              controller: _priceController,
                              onChanged: (v) => setState(() => _price = v),
                              keyboardType: TextInputType.number,
                              cursorColor: AppTheme.textSecondary,
                              style: tt.titleMedium?.copyWith(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: const InputDecoration.collapsed(
                                hintText: '0',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Submit button
                    Opacity(
                      opacity: canSubmit ? 1.0 : 0.5,
                      child: FilledButton(
                        onPressed: canSubmit
                            ? () => setState(() => _hasResult = true)
                            : null,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(16)),
                          ),
                        ),
                        child: const Text('ask clutch →'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Result section
              AnimatedOpacity(
                opacity: _hasResult ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: _hasResult
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Verdict card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: cs.tertiaryContainer,
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
                                              horizontal: 12, vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: cs.tertiary.withValues(
                                                  alpha: 0.2),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'MAYBE',
                                              style: tt.labelLarge?.copyWith(
                                                color: cs.onTertiaryContainer,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _itemController.text,
                                            style: tt.titleLarge?.copyWith(
                                              color: cs.onTertiaryContainer,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '₹${_priceController.text}',
                                            style: tt.bodySmall?.copyWith(
                                              color: cs.onTertiaryContainer
                                                  .withValues(alpha: 0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.help_outline_rounded,
                                      size: 48,
                                      color: cs.onTertiaryContainer
                                          .withValues(alpha: 0.4),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Divider(
                                  color: cs.onTertiaryContainer
                                      .withValues(alpha: 0.2),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'not the best time, but not terrible either.',
                                  style: tt.bodyMedium?.copyWith(
                                    color: cs.onTertiaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Context cards row
                          Row(
                            children: [
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
                                        Icons
                                            .account_balance_wallet_outlined,
                                        size: 20,
                                        color: cs.primary,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '12.9%',
                                        style: tt.titleLarge?.copyWith(
                                          color: cs.onSurface,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        'of remaining\nbudget',
                                        style: tt.labelSmall?.copyWith(
                                          color: cs.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
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
                                        Icons.speed_rounded,
                                        size: 20,
                                        color: cs.error,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'high',
                                        style: tt.titleLarge?.copyWith(
                                          color: cs.onSurface,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        'spending\nvelocity',
                                        style: tt.labelSmall?.copyWith(
                                          color: cs.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                                    Icon(
                                      Icons.flag_rounded,
                                      size: 20,
                                      color: cs.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'goal impact',
                                      style: tt.titleSmall?.copyWith(
                                        color: cs.onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Goa Trip
                                Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: cs.secondaryContainer,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.beach_access_rounded,
                                        size: 18,
                                        color: cs.onSecondaryContainer,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Goa Trip',
                                            style: tt.bodyMedium?.copyWith(
                                              color: cs.onSurface,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            'delayed by ~3 days',
                                            style: tt.labelSmall?.copyWith(
                                              color: cs.error,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // MacBook
                                Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: cs.secondaryContainer,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.laptop_mac_rounded,
                                        size: 18,
                                        color: cs.onSecondaryContainer,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'New MacBook',
                                            style: tt.bodyMedium?.copyWith(
                                              color: cs.onSurface,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            'no impact',
                                            style: tt.labelSmall?.copyWith(
                                              color: cs.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
