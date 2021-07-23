import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../util/l10n.dart';
import 'brightness_observer.dart';
import 'interactable_box.dart';
import 'search_text_field_widget.dart';

class SearchHeaderWidget extends HookWidget {
  const SearchHeaderWidget({Key? key, this.hintText, this.onChanged})
      : super(key: key);

  final String? hintText;

  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => SizedBox(
      height: 48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Material(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: SearchTextFieldWidget(
                onChanged: (k) => onChanged?.call(k),
                fontSize: 14,
                controller: useTextEditingController(),
                hintText: hintText,
              ),
            ),
          ),
          const SizedBox(width: 20),
          InteractableBox(
            onTap: () {
              Navigator.pop(context);
            },
            child: Text(context.l10n.cancel,
                style: TextStyle(
                  color: context.theme.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                )),
          ),
        ],
      ));
}
