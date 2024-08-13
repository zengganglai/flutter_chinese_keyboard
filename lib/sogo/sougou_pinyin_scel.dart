import 'dart:io';
import 'package:async/async.dart';
import 'package:charset/charset.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chinese_keyboard/helper/byte_stream_reader.dart';
import 'package:flutter_chinese_keyboard/word_library/word_library.dart';
import 'package:flutter_chinese_keyboard/word_library/word_library_list.dart';
import 'dart:convert';
import 'dart:typed_data';

class SougouPinyinScel {
  Map<int, String> pyDic = {};
  int countWord = 0;
  int currentStatus = 0;

  Future<WordLibraryList> import(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      throw Exception('File not found: $path');
    }
    return _readScel(file.openSync());
  }

  Future<WordLibraryList> _readScel(RandomAccessFile stream) async {
    pyDic = {};
    final pyAndWord = WordLibraryList();
    final reader = ByteStreamReader(stream);

    // Check file header
    reader.position = 0;
    final str = await reader.readBytes(128);
    int hzPosition = 0;
    if (str[4] == 0x44) {
      hzPosition = 0x2628;
    } else if (str[4] == 0x45) {
      hzPosition = 0x26C4;
    } else {
      throw Exception('Unsupported scel file format');
    }

    reader.position = 0x124;
    countWord = await reader.readInt32();
    currentStatus = 0;

    // Read pinyin dictionary
    reader.position = 0x1540;
    await reader.readBytes(4);
    while (true) {
      final num = await reader.readBytes(4);
      final mark = num[0] + num[1] * 256;
      final pinyinLength = num[2];
      final str = await reader.readBytes(pinyinLength);
      var ss =
          String.fromCharCodes(Uint8List.fromList(str).buffer.asUint16List());
      final py = ss.split(String.fromCharCodes([0]))[0];
      pyDic[mark] = py;
      if (py == 'zuo') {
        break;
      }
    }

    // Read words
    reader.position = hzPosition;
    while (true) {
      try {
        final words = await _readAPinyinWord(reader);
        pyAndWord.addAll(words);
      } catch (e) {
        print(e);
      }
      if (reader.position == reader.length) {
        stream.closeSync();
        break;
      }
    }
    return pyAndWord;
  }

  Future<List<WordLibrary>> _readAPinyinWord(ByteStreamReader reader) async {
    final num = await reader.readBytes(4);
    final samePYcount = num[0] + num[1] * 256;
    final count = num[2] + num[3] * 256;

    // Read pinyin
    final str = await reader.readBytes(count);
    final wordPY = <String>[];
    for (var i = 0; i < count / 2; i++) {
      final key = str[i * 2] + str[i * 2 + 1] * 256;
      wordPY.add(pyDic[key] ?? '');
    }

    // Read words
    final pyAndWord = <WordLibrary>[];
    for (var s = 0; s < samePYcount; s++) {
      final hzNum = await reader.readBytes(2);
      final hzBytecount = hzNum[0] + hzNum[1] * 256;
      final wordBytes = await reader.readBytes(hzBytecount);
      var unknown1 = await reader.readBytes(2);
      var unknown2 = await reader.readBytes(4);
      var word = String.fromCharCodes(
          Uint8List.fromList(wordBytes).buffer.asUint16List());
      await reader.readBytes(6); // skip unknown bytes
      pyAndWord.add(WordLibrary(word: word, pinYin: wordPY));
      currentStatus++;
    }
    return pyAndWord;
  }
}
