import 'package:flutter_test/flutter_test.dart';
import 'package:mixin_wallet/util/extension/extension.dart';

void main() {
  test('test filter null elements', () {
    expect([1, 2, null].whereNotNull(), [1, 2]);
    expect([null, 1, 2, null].whereNotNull(), [1, 2]);
    expect([null, null].whereNotNull(), isEmpty);
  });

  test('test iterable separated', () {
    expect([1, 2, 3].separated(0), [1, 0, 2, 0, 3]);
    expect([1].separated(0), [1]);
    expect([1, 0, 0].separated(2), [1, 2, 0, 2, 0]);
  });
}
