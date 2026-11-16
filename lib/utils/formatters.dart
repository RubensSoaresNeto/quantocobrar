String formatCurrency(double value) {
  final parts = value.toStringAsFixed(2).split('.');
  final digits = parts.first;
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) buffer.write('.');
    buffer.write(digits[index]);
  }
  return 'R\$ ${buffer.toString()},${parts.last}';
}

double? parseDecimal(String text) {
  var value = text.trim().replaceAll(RegExp(r'[^0-9,.]'), '');
  if (value.isEmpty) return null;
  final comma = value.lastIndexOf(',');
  final dot = value.lastIndexOf('.');
  if (comma >= 0 && dot >= 0) {
    value = comma > dot
        ? value.replaceAll('.', '').replaceAll(',', '.')
        : value.replaceAll(',', '');
  } else if (comma >= 0) {
    value = value.replaceAll(',', '.');
  }
  return double.tryParse(value);
}
