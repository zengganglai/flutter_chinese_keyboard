import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:charset/charset.dart';
import 'package:flutter_chinese_keyboard/pinyin_split/words_search.dart';
import 'package:flutter_chinese_keyboard/helper/word_pinyin.dart';
import 'package:flutter_chinese_keyboard/sogo/sougou_pinyin_scel.dart';
import 'package:flutter_chinese_keyboard/sogo/sougou_pinyin_txt.dart';
import 'package:retrieval/trie.dart';

void main() async {
  // final file = File("D:\\Code\\Vrzwk\\flutter_chinese_keyboard\\test\\GBK.txt");
  // var lines = await file.readAsLines();
  // String code = "[";
  // for (var line in lines) {
  //   final parts = line.split('=');
  //   if (parts.length >= 2) {
  //     final py = parts[0];
  //     final word = parts[1];
  //     code = "$code\r\nWordLibrary(word: '$word',pinYin: ['$py']),";
  //   }
  // }
  // code = "$code\r\n]";
  // final nfile =
  //     File("D:\\Code\\Vrzwk\\flutter_chinese_keyboard\\test\\code.txt");
  // await nfile.create();
  // await nfile.writeAsString(code);
  final file = File(
      "D:\\Code\\Vrzwk\\FlutterQuestTool\\flutter_chinese_keyboard\\lib\\assets\\google_pinyin_dict_utf8_55320.json");
  if (!file.existsSync()) {
    throw Exception('File not found:');
  }
  var json = await file.readAsString();
  var map = jsonDecode(json) as Map<String, dynamic>;

  final trie = Trie();
  for (var key in map.keys) {
    trie.insert(key);
  }
  var pinyins = trie.find("zhangh");
  Map<String, dynamic> ress = {};
  for (var py in pinyins) {
    ress[py] = map[py];
  }
  var ss = WordsSearch.getPinYinSplit('nshis');
  // SougouPinyinScel sogo = SougouPinyinScel();
  // var res = await sogo
  //     .import("D:\\Code\\Vrzwk\\flutter_chinese_keyboard\\test\\最新常用聊天短语.scel");
  SougouPinyinTxt sogo = SougouPinyinTxt();
  var res = await sogo.init(
      "D:\\Code\\Vrzwk\\FlutterQuestTool\\flutter_chinese_keyboard\\lib\\assets\\words");
  List<String> words = [];
  for (var pinYin in ss) {
    if (pinYin.length == 1) {
      for (var word in wordPinYinList.search(pinYin).words) {
        if (!words.contains(word)) {
          words.add(word);
        }
      }
    }
    for (var word in res.search(pinYin).words) {
      if (!words.contains(word)) {
        words.add(word);
      }
    }
  }
  print(words);
}
