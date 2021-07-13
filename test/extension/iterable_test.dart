import 'package:flutter_test/flutter_test.dart';
import 'package:mixin_wallet/util/extension/extension.dart';

void main() {
  test('test filter null elements', () {
    expect([1, 2, null].whereNotNull(), [1, 2]);
    expect([null, 1, 2, null].whereNotNull(), [1, 2]);
    expect([null, null].whereNotNull(), isEmpty);
  });
}
