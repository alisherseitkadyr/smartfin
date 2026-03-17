// Number and date formatting utilities (without intl package)

class Formatters {
  Formatters._();

  /// Format a number with thousand separators (e.g., 1000 -> "1,000")
  static String formatNumber(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    int count = 0;

    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
      count++;
    }

    return buffer.toString().split('').reversed.join('');
  }

  /// Format a date as "MMM d" (e.g., "Feb 15")
  static String formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  /// Format amount with currency symbol
  static String formatCurrency(int tiyn, String currency, {bool isIncome = false}) {
    final formatted = formatNumber(tiyn);
    final prefix = isIncome ? '+' : '-';
    return '$prefix$currency$formatted';
  }
}
