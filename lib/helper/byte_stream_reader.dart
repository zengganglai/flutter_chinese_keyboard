import 'dart:io';
import 'dart:typed_data';

class ByteStreamReader {
  final RandomAccessFile _stream;
  int get position => _stream.positionSync();
  set position(int position) {
    _stream.setPositionSync(position);
  }

  int get length => _stream.lengthSync();

  ByteStreamReader(this._stream);

  Future<int> readInt32() async {
    final bytes = await readBytes(4);
    var byteData = Uint8List.fromList(bytes).buffer.asByteData();
    int s = byteData.getInt32(0, Endian.little);
    return s;
  }

  Future<List<int>> readBytes(int count) async {
    return _stream.read(count);
  }
}
