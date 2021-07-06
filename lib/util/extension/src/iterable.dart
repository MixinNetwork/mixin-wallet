part of '../extension.dart';

extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T? element) test) =>
      cast<T?>().firstWhere(test, orElse: () => null);
}
