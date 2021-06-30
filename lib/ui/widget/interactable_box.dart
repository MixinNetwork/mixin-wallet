import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class InteractableBox extends HookWidget {
  const InteractableBox({
    Key? key,
    this.enabled = true,
    this.pressedOpacity = 0.4,
    required this.child,
    required this.onTap,
  }) : super(key: key);

  final bool enabled;
  final double pressedOpacity;
  final Widget child;
  final VoidCallback onTap;

  static const Duration kFadeOutDuration = Duration(milliseconds: 10);
  static const Duration kFadeInDuration = Duration(milliseconds: 100);

  @override
  Widget build(BuildContext context) {
    final heldDown = useState(false);
    return GestureDetector(
      onTapDown: (_) => heldDown.value = true,
      onTapUp: (_) => heldDown.value = false,
      onTapCancel: () => heldDown.value = true,
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: heldDown.value ? pressedOpacity : 1,
        duration: heldDown.value ? kFadeOutDuration : kFadeInDuration,
        child: child,
      ),
    );
  }
}
