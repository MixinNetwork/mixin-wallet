part of '../extension.dart';

extension StringExtension on String {
  String get overflow => Characters(this)
      .replaceAll(Characters(''), Characters('\u{200B}'))
      .toString();

  int uuidHashcode() {
    final components = split('-');
    assert(components.length == 5);
    final mostSigBits = (int.parse(components[0], radix: 16) << 32) |
        (int.parse(components[1], radix: 16) << 16) |
        (int.parse(components[2], radix: 16));
    final leastSigBits = (int.parse(components[3], radix: 16) << 48) |
        (int.parse(components[4], radix: 16));
    final hilo = mostSigBits ^ leastSigBits;
    final i = Uint8List(8)..buffer.asByteData().setInt64(0, hilo, Endian.big);
    final a = _toInt32(i.sublist(0, 4));
    final b = _toInt32(i.sublist(4, 8));
    return a ^ b;
  }
}

int _toInt32(Uint8List list) {
  final buffer = list.buffer;
  final data = ByteData.view(buffer);
  final short = data.getInt32(0, Endian.big);
  return short;
}
