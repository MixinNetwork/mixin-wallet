part of '../extension.dart';

extension StringExtension on String {
  String get overflow => Characters(this)
      .replaceAll(Characters(''), Characters('\u{200B}'))
      .toString();

  bool containsIgnoreCase(String secondString) =>
      toLowerCase().contains(secondString.toLowerCase());

  bool equalsIgnoreCase(String? secondString) =>
      secondString != null && toLowerCase() == secondString.toLowerCase();

  String formatAddress() {
    if (length <= 10) {
      return this;
    }
    return '${substring(0, 6)}...${substring(length - 4, length)}';
  }

  TextSpan highlight(
      TextStyle style, String? highlight, TextStyle? highlightStyle) {
    if (highlight == null || highlight.isEmpty) {
      return TextSpan(text: this, style: style);
    }
    final spans = <TextSpan>[];
    var start = 0;
    var indexOfHighlight = 0;
    while (indexOfHighlight >= 0) {
      indexOfHighlight = indexOf(highlight, start);
      if (indexOfHighlight < 0) {
        spans.add(TextSpan(text: substring(start), style: style));
        break;
      }
      if (indexOfHighlight > start) {
        spans.add(
            TextSpan(text: substring(start, indexOfHighlight), style: style));
      }
      start = indexOfHighlight + highlight.length;
      spans.add(TextSpan(
          text: substring(indexOfHighlight, start), style: highlightStyle));
    }

    return TextSpan(children: spans);
  }
}
