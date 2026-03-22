import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class ClutchButton extends StatelessWidget {
  const ClutchButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.background,
              ),
            )
          : Text(label),
    );
  }
}
