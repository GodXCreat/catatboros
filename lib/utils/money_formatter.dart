class MoneyFormatter {
  static String format(int value, {String symbol = 'Rp', String separator = '.'}) {
    final negative = value < 0;
    final digits = value.abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final reverseIndex = digits.length - i;
      buffer.write(digits[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) buffer.write(separator);
    }
    return '${negative ? '-' : ''}$symbol${buffer.toString()}';
  }

  static int parse(String input) {
    final clean = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) return 0;
    return int.tryParse(clean) ?? 0;
  }
}
