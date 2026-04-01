import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';

/// Animated numpad keyboard — Buckwheat-inspired.
///
/// Buttons animate their border-radius from pill (28px) → rounded-rect (14px)
/// on press, giving tactile feedback without any external packages.
class ClutchKeyboard extends StatelessWidget {
  const ClutchKeyboard({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    required this.onConfirm,
    required this.onAskClutch,
    this.isConfirmLoading = false,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onConfirm;
  final VoidCallback onAskClutch;
  final bool isConfirmLoading;

  @override
  Widget build(BuildContext context) {
    const hGap = SizedBox(width: 8);
    return Column(
      children: [
        // Row 1: 7  8  9  ⌫
        _KeyRow(children: [
          _ClutchKey.digit('7', onTap: () => onDigit('7')),
          _ClutchKey.digit('8', onTap: () => onDigit('8')),
          _ClutchKey.digit('9', onTap: () => onDigit('9')),
          _ClutchKey.delete(onTap: onBackspace),
        ]),
        const SizedBox(height: 8),

        // Row 2: 4  5  6  ✨ask
        _KeyRow(children: [
          _ClutchKey.digit('4', onTap: () => onDigit('4')),
          _ClutchKey.digit('5', onTap: () => onDigit('5')),
          _ClutchKey.digit('6', onTap: () => onDigit('6')),
          _ClutchKey.ai(onTap: onAskClutch),
        ]),
        const SizedBox(height: 8),

        // Rows 3+4: digits on left (3 cols), tall confirm on right (1 col)
        Expanded(
          flex: 2,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    // Row 3: 1  2  3
                    Expanded(
                      child: Row(children: [
                        Expanded(child: _ClutchKey.digit('1', onTap: () => onDigit('1'))),
                        hGap,
                        Expanded(child: _ClutchKey.digit('2', onTap: () => onDigit('2'))),
                        hGap,
                        Expanded(child: _ClutchKey.digit('3', onTap: () => onDigit('3'))),
                      ]),
                    ),
                    const SizedBox(height: 8),
                    // Row 4: 0 (wide)  .
                    Expanded(
                      child: Row(children: [
                        Expanded(flex: 2, child: _ClutchKey.digit('0', onTap: () => onDigit('0'))),
                        hGap,
                        Expanded(child: _ClutchKey.digit('.', onTap: () => onDigit('.'))),
                      ]),
                    ),
                  ],
                ),
              ),
              hGap,
              // Tall confirm — spans rows 3+4
              Expanded(child: _ClutchKey.confirm(onTap: onConfirm, isLoading: isConfirmLoading)),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Row layout ────────────────────────────────────────────────────────────────

class _KeyRow extends StatelessWidget {
  const _KeyRow({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: children
            .expand((w) => [Expanded(child: w), const SizedBox(width: 8)])
            .toList()
          ..removeLast(),
      ),
    );
  }
}

// ── Key types ─────────────────────────────────────────────────────────────────

enum _KeyType { digit, confirm, delete, ai }

class _ClutchKey extends StatefulWidget {
  const _ClutchKey({
    required this.type,
    this.label,
    this.icon,
    required this.onTap,
    this.isLoading = false,
  });

  factory _ClutchKey.digit(String label, {required VoidCallback onTap}) =>
      _ClutchKey(type: _KeyType.digit, label: label, onTap: onTap);

  factory _ClutchKey.confirm({
    required VoidCallback onTap,
    bool isLoading = false,
  }) =>
      _ClutchKey(
        type: _KeyType.confirm,
        icon: Icons.check_rounded,
        onTap: onTap,
        isLoading: isLoading,
      );

  factory _ClutchKey.delete({required VoidCallback onTap}) => _ClutchKey(
        type: _KeyType.delete,
        icon: Icons.backspace_outlined,
        onTap: onTap,
      );

  factory _ClutchKey.ai({required VoidCallback onTap}) => _ClutchKey(
        type: _KeyType.ai,
        icon: Icons.auto_awesome_rounded,
        onTap: onTap,
      );

  final _KeyType type;
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  State<_ClutchKey> createState() => _ClutchKeyState();
}

class _ClutchKeyState extends State<_ClutchKey> {
  bool _pressed = false;

  void _handleTapDown(TapDownDetails _) => setState(() => _pressed = true);
  void _handleTapUp(TapUpDetails _) => setState(() => _pressed = false);
  void _handleTapCancel() => setState(() => _pressed = false);

  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final (bg, fg) = switch (widget.type) {
      _KeyType.digit   => (AppTheme.card, cs.onSurface),
      _KeyType.confirm => (cs.primary, cs.onPrimary),
      _KeyType.delete  => (cs.errorContainer, cs.onErrorContainer),
      _KeyType.ai      => (cs.primaryContainer, cs.onPrimaryContainer),
    };

    final radius = _pressed ? 14.0 : 28.0;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.isLoading ? null : _handleTap,
      child: AnimatedContainer(
        duration: _pressed
            ? const Duration(milliseconds: 80)
            : const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(radius),
        ),
        alignment: Alignment.center,
        child: widget.isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: fg,
                ),
              )
            : widget.label != null
                ? Text(
                    widget.label!,
                    style: tt.headlineSmall?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : Icon(widget.icon, size: 22, color: fg),
      ),
    );
  }
}
