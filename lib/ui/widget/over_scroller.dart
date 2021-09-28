import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ColoredOverScrollTopWidget extends StatelessWidget {
  const ColoredOverScrollTopWidget({
    Key? key,
    required this.child,
    required this.background,
  }) : super(key: key);

  final Widget child;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    if (platform != TargetPlatform.iOS && platform != TargetPlatform.macOS) {
      return child;
    }
    return _ColoredBackground(
      background: background,
      child: child,
    );
  }
}

class _ColoredBackground extends HookWidget {
  const _ColoredBackground({
    Key? key,
    required this.child,
    required this.background,
  }) : super(key: key);

  final Widget child;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final offset = useState(0.0);
    return NotificationListener<ScrollUpdateNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels >= 0) {
            offset.value = 0;
            return false;
          }
          offset.value = notification.metrics.pixels;
          return false;
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: offset.value.abs() + 1,
                color: background,
              ),
            ),
            child,
          ],
        ));
  }
}
