import 'dart:io';

import 'package:flutter_chinese_keyboard/word_library/word_library.dart';
import 'package:flutter_chinese_keyboard/word_library/word_library_list.dart';

class SougouPinyinTxt {
  Future<WordLibraryList> import(String path) async {
    final file = File(path);
    if (!file.existsSync()) {
      throw Exception('File not found: $path');
    }
    List<String> lines = await file.readAsLines();
    return importLines(lines);
  }

  Future<WordLibraryList> importLines(List<String> lines) async {
    final wll = WordLibraryList();
    for (var line in lines) {
      line = line.trim();
      if (line.startsWith("'")) {
        final parts = line.split(' ');
        if (parts.length >= 2) {
          final py = parts[0];
          final word = parts[1];
          final wl = WordLibrary(
              word: word,
              pinYin: py
                  .split("'")
                  .where((element) => element.isNotEmpty)
                  .toList());
          wll.add(wl);
        }
      }
    }
    return wll;
  }
}
