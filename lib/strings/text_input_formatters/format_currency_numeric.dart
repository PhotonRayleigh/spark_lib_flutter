import 'package:flutter/services.dart';
import 'package:characters/characters.dart';
// import 'package:get/get.dart';
import 'package:vy_string_utils/vy_string_utils.dart';

class FormatCurrencyNumeric extends TextInputFormatter {
  FormatCurrencyNumeric({this.leadingDigits = 16, this.decimalPlaces = 8});
  int leadingDigits;
  int decimalPlaces;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    TextEditingValue result = newValue;
    // var regExPattern = RegExp(r"\d*[.]?\d{0,4}");
    // 16 digits before decimal, 8 after
    int position = 0;
    int period = -1;
    int postPeriod = 0;
    for (var char in newValue.text.characters) {
      if (!char.onlyContainsDigits() && char != '.') {
        result = oldValue;
        break;
      }
      if (char == '.') {
        if (period == -1) {
          period = position;
        } else {
          result = oldValue;
          break;
        }
      }
      if (period == -1 && position >= 16) {
        result = oldValue;
        break;
      }
      if (postPeriod > 8) {
        result = oldValue;
        break;
      }

      position++;
      if (period >= 0) postPeriod++;
    }

    return result;
  }
}
