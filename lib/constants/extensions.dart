extension NumberFormatter on double {
  String formatWithCommas() {
    final isNegative = this < 0;
    final absoluteValue = abs();

    final parts = absoluteValue.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decimalPart = parts[1] == '00' ? '' : '.${parts[1]}';

    if (intPart.length <= 3) {
      return (isNegative ? '-' : '') + intPart + decimalPart;
    }

    final lastThree = intPart.substring(intPart.length - 3);
    final rest = intPart.substring(0, intPart.length - 3);

    final buffer = StringBuffer();
    int count = 0;

    for (int i = rest.length - 1; i >= 0; i--) {
      buffer.write(rest[i]);
      count++;
      if (count % 2 == 0 && i != 0) {
        buffer.write(',');
      }
    }

    final formattedRest = buffer.toString().split('').reversed.join('');
    return (isNegative ? '-' : '') + '$formattedRest,$lastThree$decimalPart';
  }
}
