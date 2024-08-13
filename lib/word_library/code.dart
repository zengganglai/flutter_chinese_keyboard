import 'dart:collection';

class Code extends ListBase<List<String>> {
  final List<List<String>> _innerList = [];

  Code([dynamic initValue, bool is1Char1Code = false]) {
    if (initValue is String) {
      _innerList.add([initValue]);
    } else if (initValue is List<String>) {
      if (is1Char1Code) {
        for (var py in initValue) {
          _innerList.add([py]);
        }
      } else {
        _innerList.add(initValue);
      }
    } else if (initValue is Iterable<List<String>>) {
      _innerList.addAll(initValue);
    }
  }

  @override
  List<String> operator [](int index) => _innerList[index];

  @override
  void operator []=(int index, List<String> value) {
    _innerList[index] = value;
  }

  @override
  int get length => _innerList.length;

  @override
  set length(int newLength) {
    _innerList.length = newLength;
  }

  @override
  void add(List<String> value) {
    _innerList.add(value);
  }

  List<String> getDefaultCode() {
    return _innerList.map((row) => row[0]).toList();
  }

  String getTop1Code() {
    return _innerList.isNotEmpty && _innerList[0].isNotEmpty
        ? _innerList[0][0]
        : "";
  }
}
