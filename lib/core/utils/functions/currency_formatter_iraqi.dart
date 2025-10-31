import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat('#,###', 'en_US');

  static String formatIraqiDinar(double amount) {
    return '${_formatter.format(amount.toInt())} دينار';
  }

  static String formatAmount(double amount) {
    return _formatter.format(amount.toInt());
  }
}
