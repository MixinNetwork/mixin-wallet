import 'package:flutter_test/flutter_test.dart';
import 'package:mixin_wallet/ui/widget/number_input_pad.dart';

void main() {
  test('input number controller', () {
    final controller = NumberInputController()
      ..appendDot()
      ..appendNumber(1)
      ..appendNumber(1)
      ..appendNumber(1)
      ..appendNumber(1);
    expect(controller.value, '0.1111');

    controller
      ..appendDot()
      ..appendDot()
      ..appendNumber(0);

    expect(controller.value, '0.11110');

    controller
      ..delete()
      ..delete()
      ..delete();

    expect(controller.value, '0.11');

    controller
      ..delete()
      ..delete()
      ..delete();
    expect(controller.value, '0');

    controller.delete();
    expect(controller.value, '0');

    controller.appendNumber(1);
    expect(controller.value, '1');

    controller.appendNumber(2);
    expect(controller.value, '12');

    controller.appendDot();
    expect(controller.value, '12.');

    controller.appendNumber(2);
    expect(controller.value, '12.2');

    controller.delete();
    expect(controller.value, '12.');

    controller.appendNumber(0);
    expect(controller.value, '12.0');
  });
}
