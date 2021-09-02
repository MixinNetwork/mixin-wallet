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

extension IterableExtenstionNull<T> on Iterable<T?> {
  Iterable<T> whereNotNull() => where((e) => e != null).cast();
}
