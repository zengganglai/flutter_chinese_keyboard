import 'package:flutter_chinese_keyboard/word_library/word_library.dart';

class WordLibraryList {
  final List<WordLibrary> _libraries = [];

  /// 将词库中重复出现的单词合并成一个词，多词库合并时使用(词重复就算)
  void mergeSameWord() {
    final dic = <String, WordLibrary>{};
    for (var wl in _libraries) {
      if (!dic.containsKey(wl.word)) {
        dic[wl.word] = wl;
      }
    }
    _libraries
      ..clear()
      ..addAll(dic.values);
  }

  void addWordLibraryList(WordLibraryList wll) {
    _libraries.addAll(wll._libraries);
  }

  WordLibraryList();

  WordLibraryList.fromIterable(Iterable<WordLibrary> wll) {
    _libraries.addAll(wll);
  }

  void add(WordLibrary wordLibrary) => _libraries.add(wordLibrary);

  void addAll(Iterable<WordLibrary> wordLibraries) =>
      _libraries.addAll(wordLibraries);

  void clear() => _libraries.clear();

  int get length => _libraries.length;

  List<WordLibrary> get wordLibraries => _libraries;

  WordLibrary operator [](int index) => _libraries[index];

  void operator []=(int index, WordLibrary value) => _libraries[index] = value;

  WordLibraryList search(List<String> pinYin) {
    var res = _libraries.where((s) => pinyinCompare(s.pinYin, pinYin)).toList();
    return WordLibraryList.fromIterable(res);
  }

  List<String> get words => _libraries.map((e) => e.word).toList();

  bool pinyinCompare(List<String> candidate, List<String> pinyin) {
    if (candidate.length < pinyin.length) {
      return false;
    } else if (candidate.length == 1 && pinyin.length == 1) {
      return candidate[0] == pinyin[0];
    } else {
      for (int i = 0; i < pinyin.length; i++) {
        if (!candidate[i].startsWith(pinyin[i])) return false;
      }
    }
    return true;
  }

  // Additional methods or properties can be added as needed
}
