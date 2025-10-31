import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String formatCurrency({
    required double amount,
     String locale="ar_IQ",
    required String symbol,
    int decimalDigits = 0,
  }) {
    return NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: decimalDigits,
    ).format(amount);
  }
}
