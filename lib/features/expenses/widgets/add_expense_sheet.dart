import 'package:flutter/material.dart';

class AddExpenseSheet extends StatefulWidget {
  const AddExpenseSheet({super.key});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  String _amount = '';
  final TextEditingController _tagController = TextEditingController();

  @override
  void dispose() {
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
    debugPrint('₹$_amount — ${_tagController.text}');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Drag handle
          Center(
            child: Container(
              width: 32,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // 2. Amount display
          Column(
            children: [
              Text(
                _amount.isEmpty ? '₹0' : '₹$_amount',
                style: textTheme.displayMedium?.copyWith(
                  color: _amount.isEmpty
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onSurface,
                  fontWeight:
                      _amount.isEmpty ? null : FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'enter amount',
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          // 3. Spacing
          const SizedBox(height: 24),

          // 4. Tag input
          TextField(
            controller: _tagController,
            textCapitalization: TextCapitalization.words,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'what was this for? (chaat, uber...)',
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
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

          // 5. Spacing
          const SizedBox(height: 24),

          // 6. Numpad
          _NumRow(children: [
            _NumButton(label: '7', onTap: () => _appendDigit('7'), colorScheme: colorScheme, textTheme: textTheme),
            _NumButton(label: '8', onTap: () => _appendDigit('8'), colorScheme: colorScheme, textTheme: textTheme),
            _NumButton(label: '9', onTap: () => _appendDigit('9'), colorScheme: colorScheme, textTheme: textTheme),
            _BackspaceButton(onTap: _backspace, colorScheme: colorScheme),
          ]),
          const SizedBox(height: 8),
          _NumRow(children: [
            _NumButton(label: '4', onTap: () => _appendDigit('4'), colorScheme: colorScheme, textTheme: textTheme),
            _NumButton(label: '5', onTap: () => _appendDigit('5'), colorScheme: colorScheme, textTheme: textTheme),
            _NumButton(label: '6', onTap: () => _appendDigit('6'), colorScheme: colorScheme, textTheme: textTheme),
            const SizedBox(height: 56),
          ]),
          const SizedBox(height: 8),
          _NumRow(children: [
            _NumButton(label: '1', onTap: () => _appendDigit('1'), colorScheme: colorScheme, textTheme: textTheme),
            _NumButton(label: '2', onTap: () => _appendDigit('2'), colorScheme: colorScheme, textTheme: textTheme),
            _NumButton(label: '3', onTap: () => _appendDigit('3'), colorScheme: colorScheme, textTheme: textTheme),
            _ConfirmButton(onTap: _confirm, colorScheme: colorScheme),
          ]),
          const SizedBox(height: 8),
          _NumRow(children: [
            const SizedBox(height: 56),
            _NumButton(label: '0', onTap: () => _appendDigit('0'), colorScheme: colorScheme, textTheme: textTheme),
            _NumButton(label: '.', onTap: () => _appendDigit('.'), colorScheme: colorScheme, textTheme: textTheme),
            const SizedBox(height: 56),
          ]),
        ],
      ),
    );
  }
}

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
    required this.colorScheme,
    required this.textTheme,
  });

  final String label;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _BackspaceButton extends StatelessWidget {
  const _BackspaceButton({required this.onTap, required this.colorScheme});
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.backspace_outlined,
          size: 20,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({required this.onTap, required this.colorScheme});
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.check_rounded,
          size: 24,
          color: colorScheme.onPrimary,
        ),
      ),
    );
  }
}
