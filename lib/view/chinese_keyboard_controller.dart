import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chinese_keyboard/google/google_pinyin.dart';
import 'package:flutter_chinese_keyboard/helper/pinyin_ime.dart';
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

  static PinYinIME pinyinIME = GooglePinyin();

  ChineseKeyboardController() {
    ChineseKeyboardController.init();
  }

  static Function(String, List<String>)? _onResultCallback;
  static SendPort? _searchSendPort;

  static bool isinit = false;
  static init() async {
    if (isinit) {
      return;
    }
    debugPrint("ChineseKeyboard init: ${DateTime.now()}");
    isinit = true;
    final receivePort = ReceivePort();
    final sendPort = receivePort.sendPort;
    String googleJson = await rootBundle.loadString(
        "packages/flutter_chinese_keyboard/lib/assets/google_pinyin_dict_utf8_55320.json");
    Isolate.spawn(_init, [sendPort, googleJson]);
    receivePort.listen((message) {
      if (message is List) {
        _onResultCallback?.call(message[0], message[1]);
      } else if (message is SendPort) {
        _searchSendPort = message;
      }
    });
  }

  static void _init(List data) async {
    debugPrint("ChineseKeyboard init call");
    SendPort sendPort = data[0];
    String googleJson = data[1];
    pinyinIME.init(googleJson);
    var port = ReceivePort();
    sendPort.send(port.sendPort);
    await for (var sendData in port) {
      sendPort.send([sendData[0], await _search(sendData[0])]);
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
      debugPrint("ChineseKeyboard input start: ${text}--${DateTime.now()}");
      pinyinShow.value = text;
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
          _searchSendPort?.send([text]);
        } else {
          candidateWords.value = [];
        }
      }
    } else {
      pinyinShow.value = "";
      candidateWords.value = [];
    }
    showCandidateWords.value = text.isNotEmpty;
    debugPrint("ChineseKeyboard input end: ${text}--${DateTime.now()}");
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

  static Future<List<String>> _search(String pinyin) async {
    debugPrint("ChineseKeyboard _search call: ${pinyin}");
    return await pinyinIME.search(pinyin);
  }
}
