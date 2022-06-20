import 'package:flutter/widgets.dart';

extension AsyncSnapshotExt on AsyncSnapshot<void> {
  bool get isNoneOrWaiting =>
      connectionState == ConnectionState.none ||
      connectionState == ConnectionState.waiting;

  bool get isActiveOrDone =>
      connectionState == ConnectionState.active ||
      connectionState == ConnectionState.done;
}
