import 'dart:io';

import 'package:flutter_chinese_keyboard/helper/pinyin_ime.dart';
import 'package:flutter_chinese_keyboard/helper/word_pinyin.dart';
import 'package:flutter_chinese_keyboard/pinyin_split/words_search.dart';
import 'package:flutter_chinese_keyboard/word_library/word_library.dart';
import 'package:flutter_chinese_keyboard/word_library/word_library_list.dart';

class SougouPinyinTxt extends PinYinIME {
  WordLibraryList? _wordLibraryList;

  @override
  Future init(String text) async {
    List<String> lines = text.split('\n');
    await importLines(lines);
  }

  Future importLines(List<String> lines) async {
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
    _wordLibraryList = wll;
  }

  @override
  Future<List<String>> search(String pinyin) async {
    List<String> words = [];
    var allPinyin = WordsSearch.getPinYinSplit(pinyin);
    allPinyin.sort((a, b) {
      var lengthCompare = b.join().length.compareTo(a.join().length);
      if (lengthCompare != 0) {
        return lengthCompare;
      }
      return a.length.compareTo(b.length);
    });
    for (var pinYin in allPinyin) {
      if (pinYin.length == 1) {
        for (var word in wordPinYinList.search(pinYin).words) {
          if (!words.contains(word)) {
            words.add(word);
          }
        }
      }
      if (_wordLibraryList != null) {
        for (var word in _wordLibraryList!.search(pinYin).words) {
          if (!words.contains(word)) {
            words.add(word);
          }
        }
      }
    }
    words.sort((a, b) => a.length.compareTo(b.length));
    return words;
  }
}
