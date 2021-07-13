part of '../extension.dart';

extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T? element) test) =>
      cast<T?>().firstWhere(test, orElse: () => null);
}

extension IterableExtenstionNull<T> on Iterable<T?> {
  Iterable<T> whereNotNull() => where((e) => e != null).cast();
}
