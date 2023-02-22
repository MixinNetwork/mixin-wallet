import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import '../../util/r.dart';

import 'brightness_observer.dart';

class SearchTextFieldWidget extends HookWidget {
  const SearchTextFieldWidget({
    required this.controller,
    super.key,
    this.focusNode,
    this.onChanged,
    this.fontSize = 14,
    this.hintText,
    this.autofocus = false,
  });

  final FocusNode? focusNode;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final double fontSize;

  final String? hintText;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    const outlineInputBorder = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.transparent,
      ),
      borderRadius: BorderRadius.all(
        Radius.circular(100),
      ),
      gapPadding: 0,
    );
    final backgroundColor = context.colorScheme.surface;
    final hintColor = context.colorScheme.thirdText;

    useEffect(() {
      void notifyChanged() {
        onChanged?.call(controller.text);
      }

      // listen controller state to update onChanged, in case value updated by
      // controller by onChanged is not called.
      controller.addListener(notifyChanged);
      return () {
        controller.removeListener(notifyChanged);
      };
    }, [controller, onChanged]);

    return TextField(
      focusNode: focusNode,
      autofocus: autofocus,
      controller: controller,
      style: TextStyle(
        color: context.colorScheme.primaryText,
        fontSize: fontSize,
      ),
      cursorHeight: 20,
      scrollPadding: EdgeInsets.zero,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        isDense: false,
        border: outlineInputBorder,
        focusedBorder: outlineInputBorder,
        enabledBorder: outlineInputBorder,
        filled: true,
        fillColor: backgroundColor,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        prefixIconConstraints:
            const BoxConstraints.expand(width: 44, height: 44),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 12),
          child: SvgPicture.asset(
            R.resourcesIcSearchSmallSvg,
            colorFilter: ColorFilter.mode(hintColor, BlendMode.srcIn),
            width: 16,
            height: 16,
          ),
        ),
        suffixIcon: _SearchClearIcon(controller),
        contentPadding: const EdgeInsets.only(right: 4),
        hintText: hintText,
        hintStyle: TextStyle(
          color: hintColor,
          fontSize: fontSize,
        ),
      ),
    );
  }
}

class _SearchClearIcon extends HookWidget {
  const _SearchClearIcon(this.controller);

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final editingText = useValueListenable(controller);
    if (editingText.text.isEmpty) {
      return const SizedBox();
    } else {
      return Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            children: [
              Center(
                child: MouseRegion(
                  cursor: SystemMouseCursors.basic,
                  child: Opacity(
                    opacity: 0.4,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: InkResponse(
                        onTap: () {
                          controller.text = '';
                        },
                        radius: 20,
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: SvgPicture.asset(
                            R.resourcesIcCircleCloseSvg,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
