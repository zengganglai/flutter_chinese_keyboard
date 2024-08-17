import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chinese_keyboard/helper/word_pinyin.dart';
import 'package:flutter_chinese_keyboard/pinyin_split/words_search.dart';
import 'package:flutter_chinese_keyboard/sogo/sougou_pinyin_txt.dart';
import 'package:flutter_chinese_keyboard/word_library/word_library.dart';
import 'package:flutter_chinese_keyboard/word_library/word_library_list.dart';

enum InputLanguage { en, zh }

class ChineseKeyboardController {
  ValueNotifier<String> pinyinShow = ValueNotifier("");
  ValueNotifier<String> pinyin = ValueNotifier("");

  ValueNotifier<bool> showCandidateWords = ValueNotifier(false);
  ValueNotifier<List<String>> candidateWords = ValueNotifier([]);
  ValueNotifier<InputLanguage> selectedInputLanguage =
      ValueNotifier(InputLanguage.zh);
  ValueNotifier<bool> showSymbol = ValueNotifier(false);
  ValueNotifier<bool> capitalize = ValueNotifier(false);

  static final Map<String, List<String>> _cache = {};

  static final Map<String, List<String>> _selectedCache = {};

  ChineseKeyboardController() {
    ChineseKeyboardController.init();
  }

  static WordLibraryList? _wordLibraryList;

  static Function(String, List<String>)? _onResultCallback;
  static SendPort? _searchSendPort;

  static bool isinit = false;
  static init() async {
    if (isinit) {
      return;
    }
    isinit = true;
    final receivePort = ReceivePort();
    final sendPort = receivePort.sendPort;
    String wordsText = await rootBundle
        .loadString("packages/flutter_chinese_keyboard/lib/assets/words");
    Isolate.spawn(_init, [sendPort, wordsText]);
    receivePort.listen((message) {
      if (message is List) {
        _onResultCallback?.call(message[0], message[1]);
      } else if (message is SendPort) {
        _searchSendPort = message;
      }
    });
  }

  static void _init(List data) async {
    SendPort sendPort = data[0];
    String wordsText = data[1];
    _wordLibraryList ??=
        await SougouPinyinTxt().importLines(wordsText.split('\n'));
    var port = ReceivePort();
    sendPort.send(port.sendPort);
    await for (var sendData in port) {
      sendPort.send([
        sendData[0],
        _search(sendData[1], wordPinYinList, _wordLibraryList)
      ]);
    }
  }

  clear() {
    pinyin.value = "";
    input(pinyin.value);
  }

  addKey(String key) {
    pinyin.value = pinyin.value + key;
    input(pinyin.value);
  }

  removeKey() {
    if (pinyin.value.isNotEmpty) {
      pinyin.value = pinyin.value.substring(0, pinyin.value.length - 1);
      input(pinyin.value);
    }
  }

  selected(String value) {
    if (_selectedCache.containsKey(pinyin.value)) {
      if (!_selectedCache[pinyin.value]!.contains(value)) {
        _selectedCache[pinyin.value]!.add(value);
      }
    } else {
      _selectedCache[pinyin.value] = [value];
    }
  }

  Future input(String text) async {
    if (text.isNotEmpty) {
      var allPinyin = WordsSearch.getPinYinSplit(text);
      allPinyin.sort((a, b) {
        var lengthCompare = b.join().length.compareTo(a.join().length);
        if (lengthCompare != 0) {
          return lengthCompare;
        }
        return a.length.compareTo(b.length);
      });
      pinyinShow.value = allPinyin.isEmpty ? "" : allPinyin.first.join("'");
      List<String> result;
      if (_cache.containsKey(text)) {
        result = _cache[text] ?? [];
        if (_selectedCache.containsKey(text)) {
          for (var word in _selectedCache[text]!) {
            result.remove(word);
            result.insert(0, word);
          }
        }
        candidateWords.value = result;
      } else {
        if (_searchSendPort != null) {
          _onResultCallback = _onResult;
          _searchSendPort?.send([text, allPinyin]);
        } else {
          candidateWords.value = [];
        }
      }
    } else {
      pinyinShow.value = "";
      candidateWords.value = [];
    }
    showCandidateWords.value = text.isNotEmpty;
  }

  _onResult(String py, List<String> result) {
    _cache[py] = result;
    if (_selectedCache.containsKey(py)) {
      for (var word in _selectedCache[py]!) {
        result.remove(word);
        result.insert(0, word);
      }
    }
    candidateWords.value = result;
  }

  static List<String> _search(List<List<String>> allPinyin,
      WordLibraryList wordPinYinList, WordLibraryList? wordLibraryList) {
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
        for (var word in wordLibraryList!.search(pinYin).words) {
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
