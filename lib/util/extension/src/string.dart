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
    return (hilo >> 32) ^ hilo.toSigned(32);
  }
}
