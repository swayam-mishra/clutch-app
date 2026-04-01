import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Character-level animated number widget.
///
/// Each digit slides up when the value increases and slides down when it
/// decreases — identical to Buckwheat's AnimatedNumber behavior.
class AnimatedNumber extends StatefulWidget {
  const AnimatedNumber({
    super.key,
    required this.value,
    required this.style,
    this.duration = const Duration(milliseconds: 200),
    this.emptyText = '₹0',
  });

  final double value;
  final TextStyle style;
  final Duration duration;
  /// Text shown when value is 0 (placeholder state).
  final String emptyText;

  @override
  State<AnimatedNumber> createState() => _AnimatedNumberState();
}

class _AnimatedNumberState extends State<AnimatedNumber> {
  double _previousValue = 0;

  static final _fmt = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  String _format(double v) => v <= 0 ? '' : _fmt.format(v);

  @override
  void didUpdateWidget(AnimatedNumber old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _previousValue = old.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isZero = widget.value <= 0;

    if (isZero) {
      return Text(
        widget.emptyText,
        style: widget.style.copyWith(
          color: cs.onSurfaceVariant.withValues(alpha: 0.4),
        ),
      );
    }

    final current = _format(widget.value);
    final previous = _format(_previousValue);

    // Direction: 1 = value went up → chars slide up (enter from below)
    //           -1 = value went down → chars slide down (enter from above)
    final direction = widget.value >= _previousValue ? 1 : -1;

    // Pad shorter string with leading spaces so indices align from the right
    final maxLen = current.length > previous.length ? current.length : previous.length;
    final curPadded = current.padLeft(maxLen);
    final prevPadded = previous.padLeft(maxLen);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: List.generate(maxLen, (i) {
        final curChar = curPadded[i];
        final prevChar = prevPadded[i];
        final changed = curChar != prevChar;

        if (curChar == ' ') return const SizedBox.shrink();

        if (!changed) {
          return Text(curChar, style: widget.style);
        }

        return ClipRect(
          child: AnimatedSwitcher(
            duration: widget.duration,
            transitionBuilder: (child, animation) {
              final isIncoming =
                  child.key == ValueKey('${curChar}_${widget.value}');
              final offsetBegin = isIncoming
                  ? Offset(0, direction * 1.0)
                  : Offset(0, -direction * 1.0);
              final slide = Tween<Offset>(
                begin: offsetBegin,
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ));
              return SlideTransition(
                position: slide,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: Text(
              curChar,
              key: ValueKey('${curChar}_${widget.value}'),
              style: widget.style,
            ),
          ),
        );
      }),
    );
  }
}
