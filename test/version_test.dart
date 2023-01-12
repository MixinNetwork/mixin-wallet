import 'package:flutter_test/flutter_test.dart';
import 'package:mixin_wallet/util/version.dart';

void main() {
  test('version', () {
    expect(isCurrentVersionGreaterOrEqualThan('6.4', '6.4'), isTrue);
    expect(isCurrentVersionGreaterOrEqualThan('6.4', '6.0'), isTrue);
    expect(isCurrentVersionGreaterOrEqualThan('6.10', '6.0'), isTrue);
    expect(isCurrentVersionGreaterOrEqualThan('6.0', '6.4'), isFalse);
  });
}
