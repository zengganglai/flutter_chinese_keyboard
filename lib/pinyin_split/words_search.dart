import 'package:flutter_chinese_keyboard/pinyin_split/trie_node.dart';
import 'package:flutter_chinese_keyboard/pinyin_split/words_search_result.dart';

class WordsSearch {
  TrieNode _root = TrieNode();
  List<TrieNode?> _first = List.filled(65536, null);

  void setKeywords(List<String> keywords) {
    final dict = <String, int>{};
    for (int i = 0; i < keywords.length; i++) {
      dict[keywords[i]] = i;
    }
    _setKeywords(dict);
  }

  void setKeywordsWithIndices(List<String> keywords, List<int> indices) {
    if (keywords.length != indices.length) {
      throw Exception('数量不一样');
    }
    final dict = <String, int>{};
    for (int i = 0; i < keywords.length; i++) {
      dict[keywords[i]] = indices[i];
    }
    _setKeywords(dict);
  }

  void _setKeywords(Map<String, int> keywords) {
    final first = List<TrieNode?>.filled(65536, null);
    final root = TrieNode();

    keywords.forEach((key, value) {
      if (key.isEmpty) return;

      var nd = first[key.codeUnitAt(0)];
      if (nd == null) {
        nd = root.add(key[0]);
        first[key.codeUnitAt(0)] = nd;
      }
      for (int i = 1; i < key.length; i++) {
        nd = nd!.add(key[i]);
      }
      nd?.setResults(key, value);
    });

    _first = first;

    final links = <TrieNode, TrieNode>{};
    root.values.forEach((item, value) {
      _tryLinks(value, null, links);
    });

    links.forEach((key, value) {
      key.merge(value);
    });

    _root = root;
  }

  void _tryLinks(
      TrieNode node, TrieNode? node2, Map<TrieNode, TrieNode> links) {
    node.values.forEach((key, value) {
      TrieNode? tn;
      if (node2 == null) {
        tn = _first[key.codeUnitAt(0)];
        if (tn != null) {
          links[value] = tn;
        }
      } else {
        tn = node2.tryGetValue(key);
        if (tn != null) {
          links[value] = tn;
        }
      }
      _tryLinks(value, tn, links);
    });
  }

  bool containsAny(String text) {
    TrieNode? ptr;
    for (int i = 0; i < text.length; i++) {
      TrieNode? tn;
      if (ptr == null) {
        tn = _first[text.codeUnitAt(i)];
      } else {
        tn = ptr.tryGetValue(text[i]);
        tn ??= _first[text.codeUnitAt(i)];
      }
      if (tn != null && tn.end) {
        return true;
      }
      ptr = tn;
    }
    return false;
  }

  WordsSearchResult? findFirst(String text) {
    TrieNode? ptr;
    for (int i = 0; i < text.length; i++) {
      TrieNode? tn;
      if (ptr == null) {
        tn = _first[text.codeUnitAt(i)];
      } else {
        tn = ptr.tryGetValue(text[i]);
        tn ??= _first[text.codeUnitAt(i)];
      }
      if (tn != null && tn.end) {
        final item = tn.results[0];
        return WordsSearchResult(
            item.item1, i + 1 - item.item1.length, i, item.item2);
      }
      ptr = tn;
    }
    return null;
  }

  List<WordsSearchResult> findAll(String text) {
    TrieNode? ptr;
    final list = <WordsSearchResult>[];

    for (int i = 0; i < text.length; i++) {
      TrieNode? tn;
      if (ptr == null) {
        tn = _first[text.codeUnitAt(i)];
      } else {
        tn = ptr.tryGetValue(text[i]);
        tn ??= _first[text.codeUnitAt(i)];
      }
      if (tn != null && tn.end) {
        for (var item in tn.results) {
          final searchResult = WordsSearchResult(item.item1.toLowerCase(),
              i + 1 - item.item1.length, i, item.item2);
          list.add(searchResult);
        }
      }
      ptr = tn;
    }

    for (var s in list) {
      final childs = list.where((c) => c.start > s.end).toList()
        ..sort((a, b) => a.start.compareTo(b.start));
      if (childs.isNotEmpty) {
        final firstStart = childs[0].start;
        s.childs = childs.where((c) => c.start == firstStart).toList();
      }
      for (var c in s.childs) {
        c.parents.add(s);
      }
    }

    list.removeWhere((s) => s.parents.isNotEmpty);
    return list;
  }

  static List<List<String>> getAllNext(WordsSearchResult words) {
    final results = <List<String>>[];
    if (words.childs.isNotEmpty) {
      for (var c in words.childs) {
        results.addAll(getAllNext(c));
      }
      if (words.keyword != null) {
        for (var s in results) {
          s.add(words.keyword!);
        }
      }
    } else {
      if (words.keyword != null) {
        results.add([words.keyword!]);
      }
    }
    return results;
  }

  static WordsSearch? _pinyinSplit;
  static List<List<String>> getPinYinSplit(String pinyin) {
    pinyin = pinyin.toUpperCase();
    _pinyinSplit ??= WordsSearch._initPinyinSplit();

    final list = _pinyinSplit!.findAll(pinyin);
    final ss = <List<String>>[];
    for (var p in list) {
      ss.addAll(getAllNext(p));
    }
    for (var i = 0; i < ss.length; i++) {
      ss[i] = ss[i].reversed.toList();
    }
    ss.sort((a, b) {
      var lengthCompare = a.length.compareTo(b.length);
      if (lengthCompare != 0) {
        return lengthCompare;
      }
      return b
          .reduce((sum, item) => sum + item)
          .compareTo(a.reduce((sum, item) => sum + item));
    });
    return ss;
  }

  static WordsSearch _initPinyinSplit() {
    final ws = WordsSearch();
    final pys = <String>[];
    for (var item in pyName) {
      final t = item.toUpperCase();
      if (t.isNotEmpty) {
        pys.add(t);
      }
    }
    ws.setKeywords(pys);
    return ws;
  }

  static final List<String> pyName = [
    // Add actual pinyin entries here
    "",
    "A",
    "Ai",
    "An",
    "Ang",
    "Ao",
    "B",
    "Ba",
    "Bai",
    "Ban",
    "Bang",
    "Bao",
    "Bei",
    "Ben",
    "Beng",
    "Bi",
    "Bian",
    "Biao",
    "Bie",
    "Bin",
    "Bing",
    "Bo",
    "Bu",
    "Bun",
    "C",
    "Ca",
    "Cai",
    "Cal",
    "Can",
    "Cang",
    "Cao",
    "Ce",
    "Cen",
    "Ceng",
    "Ceon",
    "Cha",
    "Chai",
    "Chan",
    "Chang",
    "Chao",
    "Che",
    "Chen",
    "Cheng",
    "Chi",
    "Chong",
    "Chou",
    "Chu",
    "Chua",
    "Chuai",
    "Chuan",
    "Chuang",
    "Chui",
    "Chun",
    "Chuo",
    "Ci",
    "Cong",
    "Cou",
    "Cu",
    "Cuan",
    "Cui",
    "Cun",
    "Cuo",
    "D",
    "Da",
    "Dai",
    "Dan",
    "Dang",
    "Dao",
    "De",
    "Dei",
    "Den",
    "Deng",
    "Di",
    "Dia",
    "Dian",
    "Diao",
    "Die",
    "Ding",
    "Diu",
    "Dong",
    "Dou",
    "Du",
    "Duan",
    "Dug",
    "Dui",
    "Dun",
    "Duo",
    "E",
    "Ei",
    "En",
    "Eng",
    "Eos",
    "Er",
    "F",
    "Fa",
    "Fan",
    "Fang",
    "Fei",
    "Fen",
    "Feng",
    "Fenwa",
    "Fo",
    "Fou",
    "Fu",
    "G",
    "Ga",
    "Gai",
    "Gan",
    "Gang",
    "Gao",
    "Ge",
    "Gei",
    "Gen",
    "Geng",
    "Gi",
    "Gong",
    "Gou",
    "Gu",
    "Gua",
    "Guai",
    "Guan",
    "Guang",
    "Gui",
    "Gun",
    "Guo",
    "H",
    "Ha",
    "Hai",
    "Han",
    "Hang",
    "Hao",
    "He",
    "Hei",
    "Hen",
    "Heng",
    "Hol",
    "Hong",
    "Hou",
    "Hu",
    "Hua",
    "Huai",
    "Huan",
    "Huang",
    "Hui",
    "Hun",
    "Huo",
    "J",
    "Ji",
    "Jia",
    "Jian",
    "Jiang",
    "Jiao",
    "Jie",
    "Jin",
    "Jing",
    "Jiong",
    "Jiu",
    "Ju",
    "Juan",
    "Jue",
    "Jun",
    "K",
    "Ka",
    "Kai",
    "Kan",
    "Kang",
    "Kao",
    "Ke",
    "Kei",
    "Ken",
    "Keng",
    "Kong",
    "Kou",
    "Ku",
    "Kua",
    "Kuai",
    "Kuan",
    "Kuang",
    "Kui",
    "Kun",
    "Kuo",
    "L",
    "La",
    "Lai",
    "Lan",
    "Lang",
    "Lao",
    "Le",
    "Lei",
    "Leng",
    "Li",
    "Lia",
    "Lian",
    "Liang",
    "Liao",
    "Lie",
    "Lin",
    "Ling",
    "Liu",
    "Long",
    "Lou",
    "Lu",
    "Luan",
    "Lue",
    "Lun",
    "Luo",
    "Lv",
    "Lve",
    "M",
    "Ma",
    "Mai",
    "Man",
    "Mang",
    "Mao",
    "Me",
    "Mei",
    "Men",
    "Meng",
    "Mi",
    "Mian",
    "Miao",
    "Mie",
    "Min",
    "Ming",
    "Miu",
    "Mo",
    "Mou",
    "Mu",
    "N",
    "Na",
    "Nai",
    "Nan",
    "Nang",
    "Nao",
    "Ne",
    "Nei",
    "Nen",
    "Neng",
    "Ni",
    "Nian",
    "Niang",
    "Niao",
    "Nie",
    "Nin",
    "Ning",
    "Niu",
    "Nong",
    "Nou",
    "Nu",
    "Nuan",
    "Nue",
    "Nun",
    "Nuo",
    "Nv",
    "Nve",
    "O",
    "Ou",
    "P",
    "Pa",
    "Pai",
    "Pan",
    "Pang",
    "Pao",
    "Pei",
    "Pen",
    "Peng",
    "Pi",
    "Pian",
    "Piao",
    "Pie",
    "Pin",
    "Ping",
    "Po",
    "Pou",
    "Pu",
    "Q",
    "Qi",
    "Qia",
    "Qian",
    "Qiang",
    "Qiao",
    "Qie",
    "Qin",
    "Qing",
    "Qiong",
    "Qiu",
    "Qu",
    "Quan",
    "Que",
    "Qun",
    "R",
    "Ran",
    "Rang",
    "Rao",
    "Re",
    "Ren",
    "Reng",
    "Ri",
    "Rong",
    "Rou",
    "Ru",
    "Ruan",
    "Rui",
    "Run",
    "Ruo",
    "S",
    "Sa",
    "Sai",
    "San",
    "Sang",
    "Sao",
    "Se",
    "Sen",
    "Seng",
    "Sh",
    "Sha",
    "Shai",
    "Shan",
    "Shang",
    "Shao",
    "She",
    "Shei",
    "Shen",
    "Sheng",
    "Shi",
    "Shou",
    "Shu",
    "Shua",
    "Shuai",
    "Shuan",
    "Shuang",
    "Shui",
    "Shun",
    "Shuo",
    "Si",
    "Song",
    "Sou",
    "Su",
    "Suan",
    "Sui",
    "Sun",
    "Suo",
    "T",
    "Ta",
    "Tai",
    "Tan",
    "Tang",
    "Tao",
    "Te",
    "Tei",
    "Teng",
    "Ti",
    "Tian",
    "Tiao",
    "Tie",
    "Ting",
    "Tong",
    "Tou",
    "Tu",
    "Tuan",
    "Tui",
    "Tun",
    "Tuo",
    "W",
    "Wa",
    "Wai",
    "Wan",
    "Wang",
    "Wei",
    "Wen",
    "Weng",
    "Wo",
    "Wu",
    "X",
    "Xi",
    "Xia",
    "Xian",
    "Xiang",
    "Xiao",
    "Xie",
    "Xin",
    "Xing",
    "Xiong",
    "Xiu",
    "Xu",
    "Xuan",
    "Xue",
    "Xun",
    "Y",
    "Ya",
    "Yai",
    "Yan",
    "Yang",
    "Yao",
    "Ye",
    "Yi",
    "Yin",
    "Ying",
    "Yo",
    "Yong",
    "You",
    "Yu",
    "Yuan",
    "Yue",
    "Yun",
    "Z",
    "Za",
    "Zai",
    "Zan",
    "Zang",
    "Zao",
    "Ze",
    "Zei",
    "Zen",
    "Zeng",
    "Zh",
    "Zha",
    "Zhai",
    "Zhan",
    "Zhang",
    "Zhao",
    "Zhe",
    "Zhei",
    "Zhen",
    "Zheng",
    "Zhi",
    "Zhong",
    "Zhou",
    "Zhu",
    "Zhua",
    "Zhuai",
    "Zhuan",
    "Zhuang",
    "Zhui",
    "Zhun",
    "Zhuo",
    "Zi",
    "Zong",
    "Zou",
    "Zu",
    "Zuan",
    "Zui",
    "Zun",
    "Zuo"
  ];
}
