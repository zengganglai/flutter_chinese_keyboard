import 'dart:collection';

class TrieNode {
  bool end = false;
  List<Tuple<String, int>> results = [];
  final Map<String, TrieNode> values = {};
  int minFlag = 0xFFFFFFFF;
  int maxFlag = 0x00000000;

  TrieNode();

  TrieNode? tryGetValue(
    String character,
  ) {
    if (_inRange(character)) {
      return values[character];
    }
    return null;
  }

  TrieNode add(String character) {
    if (character.length != 1) {
      throw ArgumentError('Character must be a single character string.');
    }
    if (minFlag > character.codeUnitAt(0)) {
      minFlag = character.codeUnitAt(0);
    }
    if (maxFlag < character.codeUnitAt(0)) {
      maxFlag = character.codeUnitAt(0);
    }
    return values.putIfAbsent(character, () => TrieNode());
  }

  void setResults(String text, int index) {
    if (!end) {
      end = true;
    }
    results.add(Tuple(text, index));
  }

  void merge(TrieNode node) {
    if (node.end) {
      if (!end) {
        end = true;
      }
      results.addAll(node.results);
    }

    node.values.forEach((key, value) {
      if (!values.containsKey(key)) {
        if (minFlag > key.codeUnitAt(0)) {
          minFlag = key.codeUnitAt(0);
        }
        if (maxFlag < key.codeUnitAt(0)) {
          maxFlag = key.codeUnitAt(0);
        }
        values[key] = value;
      }
    });
  }

  bool _inRange(String character) {
    int charCode = character.codeUnitAt(0);
    return minFlag <= charCode && maxFlag >= charCode;
  }
}

class Tuple<T1, T2> {
  final T1 item1;
  final T2 item2;

  Tuple(this.item1, this.item2);

  @override
  String toString() => '($item1, $item2)';
}
