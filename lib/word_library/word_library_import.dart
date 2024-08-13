import 'package:flutter_chinese_keyboard/word_library/word_library_list.dart';

abstract class WordLibraryImport {
  int countWord = 0;
  int currentStatus = 0;
  bool get isText;

  WordLibraryImport({
    required this.countWord,
    required this.currentStatus,
  });

  WordLibraryList importFromPath(String path);
  WordLibraryList importFromStream(Stream<List<int>> stream);
}
