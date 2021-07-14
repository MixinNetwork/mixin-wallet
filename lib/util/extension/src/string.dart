part of '../extension.dart';

extension StringExtension on String {
  String get overflow => Characters(this)
      .replaceAll(Characters(''), Characters('\u{200B}'))
      .toString();

  bool containsIgnoreCase(String secondString) =>
      toLowerCase().contains(secondString.toLowerCase());

  String formatAddress() {
    if (length <= 10) {
      return this;
    }
    return '${substring(0, 6)}...${substring(length - 4, length)}';
  }
}
