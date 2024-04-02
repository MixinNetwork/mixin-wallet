import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

AsyncSnapshot<T> useMemoizedFuture<T>(
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

AsyncSnapshot<T> useMemoizedStream<T>(
  Stream<T> Function() valueBuilder, {
  T? initialData,
  List<Object?> keys = const <Object>[],
}) =>
    useStream<T>(
      useMemoized<Stream<T>>(valueBuilder, keys),
      initialData: initialData,
    );

Stream<T> useValueNotifierConvertSteam<T>(ValueNotifier<T> valueNotifier) {
  final streamController = useStreamController<T>(keys: [valueNotifier]);
  useEffect(() {
    void onListen() => streamController.add(valueNotifier.value);

    valueNotifier.addListener(onListen);
    return () {
      valueNotifier.removeListener(onListen);
    };
  }, [valueNotifier]);

  final stream = useMemoized(() => streamController.stream, [valueNotifier]);
  return stream;
}
