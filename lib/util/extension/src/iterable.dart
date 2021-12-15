part of '../extension.dart';

extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T? element) test) =>
      cast<T?>().firstWhere(test, orElse: () => null);

  T? get firstOrNull => isEmpty ? null : first;

  T? get lastOrNull => isEmpty ? null : last;

  Iterable<T> separated(T toInsert) sync* {
    var i = 0;
    for (final item in this) {
      if (i != 0) {
        yield toInsert;
      }
      yield item;
      i++;
    }
  }
}

extension EnumByNameNull<T extends Enum> on Iterable<T> {
  T? byNameOrNull(String name) {
    for (final value in this) {
      if (value.name == name) return value;
    }
    return null;
  }
}
