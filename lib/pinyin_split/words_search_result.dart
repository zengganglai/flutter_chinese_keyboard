class WordsSearchResult {
  bool success;
  int start;
  int end;
  String? keyword;
  int index;
  List<WordsSearchResult> childs;
  List<WordsSearchResult> parents;
  int _hash = -1;

  WordsSearchResult(this.keyword, this.start, this.end, this.index)
      : success = true,
        childs = [],
        parents = [];

  WordsSearchResult.emptyData()
      : success = false,
        start = 0,
        end = 0,
        index = -1,
        keyword = null,
        childs = [],
        parents = [];

  // Factory constructor for creating an empty instance
  static WordsSearchResult get empty => WordsSearchResult.emptyData();

  int getHashCode() {
    if (_hash == -1) {
      var i = start << 5;
      i += end - start;
      _hash = i << 1 + (success ? 1 : 0);
    }
    return _hash;
  }

  @override
  String toString() {
    return '$start|$keyword';
  }
}
