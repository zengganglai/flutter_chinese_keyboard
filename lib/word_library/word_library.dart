import 'dart:collection';

import 'package:flutter_chinese_keyboard/word_library/code.dart';

class WordLibrary {
  bool isEnglish = false;
  String _pinYinString = "";
  int rank = 0;
  String word = "";
  Code codes = Code();

  String get singleCode {
    if (codes.isNotEmpty && codes[0].isNotEmpty) {
      return codes[0][0];
    }
    return "";
  }

  WordLibrary(
      {required this.word, required List<String> pinYin, this.rank = 0}) {
    this.pinYin = pinYin;
  }

  List<String> get pinYin {
    if (codes.isNotEmpty) {
      return codes.map((list) => list[0]).toList();
    }
    return codes.isNotEmpty ? codes[0] : [];
  }

  set pinYin(List<String> value) {
    codes = Code(value, true);
    for (int i = 0; i < value.length; i++) {
      codes[i] = [value[i]];
    }
  }

  int getPinYinLength() {
    int len = 0;
    if (codes.length > 1 || codes[0].length > 1) {
      for (var s in pinYin) {
        len += s.length;
      }
    } else {
      len = codes[0][0].length;
    }
    return len;
  }

  String get pinYinString {
    if (_pinYinString.isEmpty && !isEnglish) {
      _pinYinString = pinYin.join("'");
    }
    return _pinYinString;
  }
}

// CollectionHelper and BuildType classes need to be implemented based on your specific requirements.
