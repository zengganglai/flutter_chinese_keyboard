abstract class PinYinIME {
  Future init(String path);
  Future<List<String>> search(String pinyin);
}
