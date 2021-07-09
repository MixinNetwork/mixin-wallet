import 'package:flutter_test/flutter_test.dart';
import 'package:mixin_wallet/util/extension/extension.dart';

void main() {
  test('get pattern', () {
    const s1 = '12345678901';
    const s2 = '123456789.1234567';
    const s3 = '12345.0600';
    const s4 = '0.00011231';
    const s5 = '1234567.00101';
    const s6 = '123.0001014324';
    const s7 = '-0.0001123';

    expect(s1.getPattern(), ',###');
    expect(s2.getPattern(), ',###');
    expect(s3.getPattern(), ',###.###');
    expect(s4.getPattern(), ',###.########');
    expect(s5.getPattern(), ',###.#');
    expect(s6.getPattern(), ',###.#####');
    expect(s7.getPattern(), ',###.########');
  });

  test('number format', () {
    const s1 = '12345678901';
    const s2 = '123456789.1234567';
    const s3 = '12345.0600';
    const s4 = '0.0001123120008234';
    const s5 = '1234567.000112312900823470';
    const s6 = '1234567.000112312900823478945';
    const s7 = '1e-7';
    const s8 = '1e+8';
    expect(s1.numberFormat(), '12,345,678,901');
    expect(s2.numberFormat(), '123,456,789.1234567');
    expect(s3.numberFormat(), '12,345.06');
    expect(s4.numberFormat(), '0.0001123120008234');
    expect(s5.numberFormat(), '1,234,567.00011231290082347');
    expect(s6.numberFormat(), '1,234,567.000112312900823479');
    expect(s7.numberFormat(), '0.0000001');
    expect(s8.numberFormat(), '100,000,000');
  });
}
