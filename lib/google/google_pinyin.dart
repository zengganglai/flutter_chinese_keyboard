import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_chinese_keyboard/helper/pinyin_ime.dart';
import 'package:retrieval/trie.dart';

class GoogleWord {
  String? w;
  num f = 0;

  GoogleWord({this.w, this.f = 0});
  GoogleWord.fromJson(dynamic json) {
    if (json == null) return;
    w = json['w'];
    f = json['f'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['w'] = w;
    data['f'] = f;
    return data;
  }
}

class GooglePinyin extends PinYinIME {
  Map<String, dynamic>? _wordLibraryList;
  Trie? trie;
  int Max_Candidates = 100;
  @override
  init(String json) async {
    debugPrint("GooglePinyin init start: ${DateTime.now()}");
    _wordLibraryList = jsonDecode(json) as Map<String, dynamic>;
    if (_wordLibraryList != null) {
      trie = Trie();
      for (var key in _wordLibraryList!.keys) {
        trie!.insert(key);
      }
    }
    debugPrint("GooglePinyin init end: ${DateTime.now()}");
  }

  @override
  Future<List<String>> search(String pinyin) async {
    if (_wordLibraryList == null || trie == null) return [];
    debugPrint("GooglePinyin search: ${pinyin}");
    var allPinyin = trie!.find(pinyin);
    List<GoogleWord> wordLibrary = [];
    List<GoogleWord> singleWords = [];
    for (var py in allPinyin) {
      var list = (_wordLibraryList![py] as List<dynamic>?)
              ?.map((e) => GoogleWord.fromJson(e))
              .toList() ??
          [];
      singleWords.addAll(list.where((s) => (s.w?.length ?? 0) == 1));
      wordLibrary.addAll(list.where((s) => (s.w?.length ?? 0) > 1));
    }
    singleWords.sort(((a, b) => b.f.compareTo(a.f)));
    wordLibrary.sort(((a, b) => b.f.compareTo(a.f)));
    var res = [
      ...singleWords.map((e) => e.w!).toSet(),
      ...wordLibrary.take(Max_Candidates).map((e) => e.w!).toSet()
    ];
    return res;
  }
}
