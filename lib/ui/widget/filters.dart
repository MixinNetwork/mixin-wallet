import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FilterWidget<T> extends StatelessWidget {
  const FilterWidget({
    Key? key,
    required this.value,
    required this.groupValue,
    this.onChanged,
    required this.child,
  }) : super(key: key);

  final T value;
  final T? groupValue;
  final ValueChanged<T>? onChanged;

  final Widget child;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => onChanged?.call(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
          decoration: BoxDecoration(
            color: value == groupValue ? const Color(0xFFF5F7FA) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: value == groupValue
                ? Border.all(color: const Color(0xFFF5F7FA))
                : Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: child,
        ),
      );
}
