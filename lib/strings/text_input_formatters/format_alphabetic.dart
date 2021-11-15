import 'package:flutter/services.dart';

class FormatCurrencyAlphabetic extends TextInputFormatter {
  FormatCurrencyAlphabetic({this.leadingDigits = 16, this.decimalPlaces = 8});
  int leadingDigits;
  int decimalPlaces;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    TextEditingValue result = newValue;
    // var regExPattern = RegExp(r"\d*[.]?\d{0,4}");
    if (newValue.text.length < oldValue.text.length) return result;

    var regExAlpha = RegExp(r"[^a-z,A-Z,_]");
    if (regExAlpha.hasMatch(newValue.text)) return oldValue;

    return result;
  }
}
