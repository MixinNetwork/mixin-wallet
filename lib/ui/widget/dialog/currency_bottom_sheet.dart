import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../generated/r.dart';
import '../../../util/extension/extension.dart';
import '../mixin_bottom_sheet.dart';
import '../text.dart';

Future<CurrencyItem?> showCurrencyBottomSheet(
  BuildContext context, {
  String? selectedCurrency,
}) =>
    showMixinBottomSheet<CurrencyItem>(
      context: context,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height - 70,
        child: CurrencyBottomSheetDialog(
          selectedCurrency: selectedCurrency,
        ),
      ),
      isScrollControlled: true,
    );

class CurrencyItem {
  const CurrencyItem(this.name, this.symbol, this.flag);

  final String name;
  final String symbol;
  final String flag;
}

const currencyItems = [
  CurrencyItem('AED', 'AED\u00a0', R.resourcesIcFlagAedPng),
  CurrencyItem('AUD', r'A$', R.resourcesIcFlagAudPng),
  CurrencyItem('CNY', '¥', R.resourcesIcFlagCnyPng),
  CurrencyItem('EUR', '€', R.resourcesIcFlagEurPng),
  CurrencyItem('GBP', '£', R.resourcesIcFlagGbpPng),
  CurrencyItem('HKD', r'HK$', R.resourcesIcFlagHkdPng),
  CurrencyItem('JPY', '¥', R.resourcesIcFlagJpyPng),
  CurrencyItem('KRW', '₩', R.resourcesIcFlagKrwPng),
  CurrencyItem('MYR', 'RM', R.resourcesIcFlagMyrPng),
  CurrencyItem('PHP', '₱', R.resourcesIcFlagPhpPng),
  CurrencyItem('SGD', r'S$', R.resourcesIcFlagSgdPng),
  CurrencyItem('TWD', r'NT$', R.resourcesIcFlagTwdPng),
  CurrencyItem('USD', r'$', R.resourcesIcFlagUsdPng),
];

class CurrencyBottomSheetDialog extends StatelessWidget {
  const CurrencyBottomSheetDialog({
    Key? key,
    this.selectedCurrency,
  }) : super(key: key);

  final String? selectedCurrency;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          MixinBottomSheetTitle(title: Text(context.l10n.currency)),
          Expanded(
            child: ListView.builder(
              itemCount: currencyItems.length,
              itemBuilder: (context, index) {
                final item = currencyItems[index];
                return InkWell(
                  onTap: () {
                    Navigator.of(context).pop(item);
                  },
                  child: SizedBox(
                    height: 72,
                    child: Row(
                      children: [
                        const SizedBox(width: 20),
                        Image.asset(
                          item.flag,
                          width: 42,
                          height: 42,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MixinText(
                            '${item.name} (${item.symbol})',
                            style: TextStyle(
                              color: context.colorScheme.primaryText,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (selectedCurrency == item.name)
                          SvgPicture.asset(R.resourcesIcCheckSvg),
                        const SizedBox(width: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
}
