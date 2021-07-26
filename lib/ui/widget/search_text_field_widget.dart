import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import '../../util/r.dart';

import 'brightness_observer.dart';

class SearchTextFieldWidget extends HookWidget {
  const SearchTextFieldWidget({
    Key? key,
    this.focusNode,
    required this.controller,
    this.onChanged,
    this.fontSize = 14,
    this.hintText,
    this.autofocus = false,
  }) : super(key: key);

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
        Radius.circular(12.0),
      ),
      gapPadding: 0,
    );
    final backgroundColor = BrightnessData.dynamicColor(
      context,
      const Color.fromRGBO(248, 248, 248, 1),
      darkColor: const Color.fromRGBO(255, 255, 255, 0.08),
    );
    final hintColor = BrightnessData.themeOf(context).secondaryText;

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
        color: BrightnessData.themeOf(context).text,
        fontSize: fontSize,
      ),
      scrollPadding: EdgeInsets.zero,
      decoration: InputDecoration(
        isDense: true,
        border: outlineInputBorder,
        focusedBorder: outlineInputBorder,
        enabledBorder: outlineInputBorder,
        filled: true,
        fillColor: backgroundColor,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        prefixIconConstraints:
            const BoxConstraints.expand(width: 40, height: 32),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: SvgPicture.asset(
            R.resourcesIcSearchSmallSvg,
            color: hintColor,
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
  const _SearchClearIcon(this.controller, {Key? key}) : super(key: key);

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final editingText = useValueListenable(controller);
    if (editingText.text.isEmpty) {
      return const SizedBox();
    } else {
      return MouseRegion(
        cursor: SystemMouseCursors.basic,
        child: InkWell(
          onTap: () {
            controller.text = '';
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Icon(
              Icons.close,
              color: BrightnessData.themeOf(context).secondaryText,
            ),
          ),
        ),
      );
    }
  }
}
