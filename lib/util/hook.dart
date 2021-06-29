import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';

void useAsyncEffect(
  FutureOr<dynamic> Function() effect, {
  FutureOr<dynamic> Function()? cleanup,
  List<Object?>? keys,
}) {
  useEffect(() {
    effect();
    return () {
      if (cleanup == null) return;
      Future.microtask(cleanup);
    };
  }, keys);
}
