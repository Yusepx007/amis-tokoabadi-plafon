import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _rupiahFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final NumberFormat _compactFormatter = NumberFormat.compactCurrency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 1,
  );

  /// Format angka ke Rupiah: Rp 1.500.000
  static String format(num amount) {
    return _rupiahFormatter.format(amount);
  }

  /// Format compact: Rp 1,5 Jt
  static String formatCompact(num amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)} Jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)} Rb';
    }
    return format(amount);
  }

  /// Format per satuan: Rp 85.000/lbr
  static String formatPerUnit(num amount, String unit) {
    return '${format(amount)}/$unit';
  }
}
