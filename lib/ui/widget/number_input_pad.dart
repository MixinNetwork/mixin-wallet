import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../generated/r.dart';
import 'brightness_observer.dart';

typedef InputCallback<T> = void Function(T value);

const _kMaxNumberLength = 8;

class NumberInputController extends ValueNotifier<String> {
  NumberInputController({
    String value = '0',
    this.numberMaxLength = _kMaxNumberLength,
  }) : super(value.isEmpty ? '0' : value);

  final int numberMaxLength;

  @override
  set value(String newValue) {
    if (newValue.length > numberMaxLength) {
      return;
    }
    super.value = newValue;
  }

  @override
  String get value {
    assert(double.tryParse(super.value) != null,
        '${super.value} is not a valid number.');
    return super.value;
  }

  @visibleForTesting
  void delete() {
    if (value.isEmpty) {
      return;
    }
    if (value.length == 1) {
      value = '0';
      return;
    }
    value = value.substring(0, value.length - 1);
  }

  @visibleForTesting
  void appendNumber(int number) {
    assert(number >= 0 && number <= 9);
    if (value == '0') {
      if (number != 0) {
        value = number.toString();
      }
      return;
    }
    value += number.toString();
  }

  @visibleForTesting
  void appendDot() {
    if (value.contains('.')) {
      return;
    }
    value += '.';
  }
}

class NumberInputWidget extends StatelessWidget {
  const NumberInputWidget({Key? key, required this.controller})
      : super(key: key);

  final NumberInputController controller;

  @override
  Widget build(BuildContext context) => _NumberInputPad(
        onNumberInput: controller.appendNumber,
        onDelete: controller.delete,
        onDotInput: controller.appendDot,
      );
}

class _NumberInputPad extends StatelessWidget {
  const _NumberInputPad({
    Key? key,
    required this.onNumberInput,
    required this.onDelete,
    required this.onDotInput,
  }) : super(key: key);

  final InputCallback<int> onNumberInput;
  final VoidCallback onDelete;
  final VoidCallback onDotInput;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 45,
        runSpacing: 12,
        children: [
          for (var i = 1; i <= 9; i++)
            _NumberKeyboardTile(num: i, onTap: onNumberInput),
          _KeyboardTile.char(char: '.', onTap: onDotInput),
          _NumberKeyboardTile(num: 0, onTap: onNumberInput),
          _KeyboardTile(
            content: SvgPicture.asset(R.resourcesDeleteArrowSvg),
            onTap: onDelete,
          ),
        ],
      );
}

class _NumberKeyboardTile extends StatelessWidget {
  const _NumberKeyboardTile({
    Key? key,
    required this.num,
    required this.onTap,
  }) : super(key: key);

  final int num;

  final InputCallback<int> onTap;

  @override
  Widget build(BuildContext context) =>
      _KeyboardTile.char(char: num.toString(), onTap: () => onTap(num));
}

class _KeyboardTile extends StatelessWidget {
  const _KeyboardTile({
    Key? key,
    required this.content,
    required this.onTap,
  }) : super(key: key);

  factory _KeyboardTile.char({
    required String char,
    required VoidCallback onTap,
  }) {
    assert(char.length == 1);
    return _KeyboardTile(
      content: Text(char),
      onTap: onTap,
    );
  }

  final Widget content;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: 64,
        child: InkResponse(
          onTap: onTap,
          radius: 32,
          child: Center(
            child: DefaultTextStyle(
              style: TextStyle(
                fontSize: 36,
                color: context.colorScheme.primaryText,
              ),
              child: content,
            ),
          ),
        ),
      );
}
