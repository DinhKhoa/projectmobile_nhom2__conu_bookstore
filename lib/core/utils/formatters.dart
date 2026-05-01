import 'package:intl/intl.dart';

class AppFormatters {
  static final _currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
  static final _currencyNoSymbol = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '',
  );
  static final _date = DateFormat('dd/MM/yyyy');
  static final _dateTime = DateFormat('dd/MM/yyyy HH:mm');

  static String formatCurrency(num amount) => _currency.format(amount);

  static String formatCurrencyNoSymbol(num amount) =>
      _currencyNoSymbol.format(amount).trim();

  static String formatDate(DateTime date) => _date.format(date);

  static String formatDateTime(DateTime date) => _dateTime.format(date);
}
