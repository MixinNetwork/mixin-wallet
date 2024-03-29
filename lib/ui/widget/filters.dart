import 'package:flutter/material.dart';

import '../../util/extension/extension.dart';

class FilterWidget<T> extends StatelessWidget {
  const FilterWidget({
    required this.groupValue,
    required this.value,
    required this.child,
    super.key,
    this.onChanged,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T>? onChanged;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return Container(
      decoration: BoxDecoration(
        color: selected
            ? context.colorScheme.surface
            : context.colorScheme.background,
        borderRadius: BorderRadius.circular(8),
        border: selected
            ? Border.all(color: context.colorScheme.background)
            : Border.all(color: context.colorScheme.captionIcon),
      ),
      constraints: const BoxConstraints(minWidth: 70),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => onChanged?.call(value),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                fontSize: 16,
                color: context.colorScheme.primaryText,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
