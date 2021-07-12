part of '../extension.dart';

extension StringExtension on String {
  String get overflow => Characters(this)
      .replaceAll(Characters(''), Characters('\u{200B}'))
      .toString();
}
