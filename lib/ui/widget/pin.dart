import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../util/extension/extension.dart';

const _kPinCodeLength = 6;

class PinInputController extends ValueNotifier<String> {
  PinInputController() : super('');

  void clear() {
    value = '';
  }

  void append(int value) {
    if (isFull) {
      return;
    }
    assert(value >= 0 && value <= 9);
    this.value += value.toString();
  }

  void delete() {
    if (isEmpty) {
      return;
    }
    value = value.substring(0, value.length - 1);
  }

  bool get isFull => value.length == _kPinCodeLength;

  bool get isEmpty => value.isEmpty;
}

class PinField extends HookWidget {
  const PinField({Key? key, required this.controller}) : super(key: key);

  final PinInputController controller;

  @override
  Widget build(BuildContext context) {
    final pinText = useValueListenable(controller);
    final inputPinLength = pinText.length;
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          for (var i = 0; i < inputPinLength; i++)
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: context.theme.text,
                shape: BoxShape.circle,
              ),
            ),
          for (var i = inputPinLength; i < _kPinCodeLength; i++)
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.theme.secondaryText,
                ),
              ),
            ),
        ].separated(const SizedBox(width: 20)).toList(),
      ),
    );
  }
}

class PinInputNumPad extends HookWidget {
  const PinInputNumPad({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final PinInputController controller;

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          for (var i = 0; i < 3; i++)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                for (var j = 0; j < 3; j++)
                  Expanded(
                    child: _NumPadButton(
                      value: i * 3 + j + 1,
                      controller: controller,
                    ),
                  ),
              ],
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Spacer(),
              Expanded(
                child: _NumPadButton(
                  value: 0,
                  controller: controller,
                ),
              ),
              Expanded(
                child: _NumPadButton(
                  value: -1,
                  controller: controller,
                ),
              ),
            ],
          ),
        ],
      );
}

class _NumPadButton extends HookWidget {
  const _NumPadButton({
    Key? key,
    required this.value,
    required this.controller,
  }) : super(key: key);

  final int value;
  final PinInputController controller;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 60,
        child: TextButton(
          onPressed: () {
            if (value == -1) {
              controller.delete();
            } else {
              controller.append(value);
            }
          },
          child: value == -1
              ? const Icon(Icons.backspace)
              : Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 24,
                    color: context.theme.text,
                  ),
                ),
        ),
      );
}
