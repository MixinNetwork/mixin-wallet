// ignore_for_file: avoid_web_libraries_in_flutter

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class NativeScrollBuilder extends HookWidget {
  const NativeScrollBuilder({
    required this.builder,
    super.key,
  });

  final Widget Function(BuildContext context, ScrollController controller)
      builder;

  @override
  Widget build(BuildContext context) {
    final controller = useScrollController();
    return builder(context, controller);
  }
}
