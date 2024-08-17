import 'dart:io';
import 'dart:typed_data';

import 'package:charset/charset.dart';
import 'package:flutter_chinese_keyboard/pinyin_split/words_search.dart';
import 'package:flutter_chinese_keyboard/helper/word_pinyin.dart';
import 'package:flutter_chinese_keyboard/sogo/sougou_pinyin_scel.dart';
import 'package:flutter_chinese_keyboard/sogo/sougou_pinyin_txt.dart';

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
  var ss = WordsSearch.getPinYinSplit('zhangh');
  // SougouPinyinScel sogo = SougouPinyinScel();
  // var res = await sogo
  //     .import("D:\\Code\\Vrzwk\\flutter_chinese_keyboard\\test\\最新常用聊天短语.scel");
  SougouPinyinTxt sogo = SougouPinyinTxt();
  var res = await sogo
      .import("D:\\Code\\Vrzwk\\flutter_chinese_keyboard\\lib\\assets\\words");
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
