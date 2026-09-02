import 'package:afine/core/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Formatters.formatNumber', () {
    test('adds separators to positive and negative values', () {
      expect(Formatters.formatNumber(0), '0');
      expect(Formatters.formatNumber(1234567), '1,234,567');
      expect(Formatters.formatNumber(-1234567), '-1,234,567');
    });
  });

  group('Formatters.formatDate', () {
    test('formats the month abbreviation and day', () {
      expect(Formatters.formatDate(DateTime(2026, 9, 2)), 'Sep 2');
    });
  });

  group('Formatters.formatCurrency', () {
    test('uses a sign, symbol, and grouped amount', () {
      expect(Formatters.formatCurrency(125000, '₸'), '-₸125,000');
      expect(
        Formatters.formatCurrency(125000, '₸', isIncome: true),
        '+₸125,000',
      );
    });
  });
}
