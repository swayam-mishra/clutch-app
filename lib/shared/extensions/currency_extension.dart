import 'package:intl/intl.dart';

extension CurrencyExtension on num {
  /// Formats as ₹1,234 or ₹1,234.56
  String toRupees({bool showPaise = false}) {
    final format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: showPaise ? 2 : 0,
    );
    return format.format(this);
  }
}
