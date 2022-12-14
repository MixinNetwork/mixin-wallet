import 'package:flutter_test/flutter_test.dart';
import 'package:mixin_wallet/ui/widget/chain_network_label.dart';

void main() {
  test('isDigitsOnly', () {
    expect(isDigitsOnly('12345678901'), isTrue);
    expect(isDigitsOnly('1'), isTrue);
    expect(isDigitsOnly('0'), isTrue);
    expect(isDigitsOnly('ABCD'), isFalse);
    expect(isDigitsOnly('X'), isFalse);
  });
}
