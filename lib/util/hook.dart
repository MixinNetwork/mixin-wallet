import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

AsyncSnapshot<T?> useMemoizedFuture<T>(
  Future<T> Function() futureBuilder, {
  T? initialData,
  List<Object?> keys = const <Object>[],
}) =>
    useFuture(
      useMemoized(
        futureBuilder,
        keys,
      ),
      initialData: initialData,
    );
