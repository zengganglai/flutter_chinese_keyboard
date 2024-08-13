import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chinese_keyboard/helper/word_pinyin.dart';
import 'package:flutter_chinese_keyboard/pinyin_split/words_search.dart';
import 'package:flutter_chinese_keyboard/sogo/sougou_pinyin_txt.dart';
import 'package:flutter_chinese_keyboard/word_library/word_library.dart';
import 'package:flutter_chinese_keyboard/word_library/word_library_list.dart';

class ChineseKeyboardViewController {
  ValueNotifier<String> pinyinShow = ValueNotifier("");

  ValueNotifier<List<String>> candidateWords = ValueNotifier([]);

  static WordLibraryList? _wordLibraryList;

  static init() async {
    if (_wordLibraryList == null) {
      String wordsText = await rootBundle
          .loadString("packages/flutter_chinese_keyboard/lib/assets/words");
      _wordLibraryList =
          await SougouPinyinTxt().importLines(wordsText.split('\n'));
    }
  }

  static addWordLibrary(Iterable<WordLibrary> wb) {
    (_wordLibraryList ??= WordLibraryList()).addAll(wb);
  }

  Future input(String text) async {
    var allPinyin = WordsSearch.getPinYinSplit(text);
    pinyinShow.value = allPinyin.isEmpty ? "" : allPinyin.first.join("'");
    List<String> words = [];
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
    candidateWords.value = words;
  }
}
