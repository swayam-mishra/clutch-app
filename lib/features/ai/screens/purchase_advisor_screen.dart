import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';

class PurchaseAdvisorScreen extends ConsumerWidget {
  const PurchaseAdvisorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: const Center(child: Text('Purchase Advisor')),
    );
  }
}
