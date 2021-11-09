import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../db/mixin_database.dart';
import '../../service/profile/profile_manager.dart';
import '../../util/extension/extension.dart';
import '../../util/mixin_context.dart';
import '../../util/r.dart';
import 'symbol.dart';

class TransferAssetHeader extends StatelessWidget {
  const TransferAssetHeader({
    Key? key,
    required this.asset,
  }) : super(key: key);

  final AssetResult asset;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          SymbolIconWithBorder(
            symbolUrl: asset.iconUrl,
            chainUrl: asset.chainIconUrl,
            size: 58,
            chainSize: 14,
            chainBorder:
                BorderSide(color: context.colorScheme.background, width: 1.5),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: SelectableText.rich(
              TextSpan(children: [
                TextSpan(
                  text:
                      '${context.l10n.balance}: ${asset.balance.numberFormat()}'
                          .overflow,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.colorScheme.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: ' '),
                TextSpan(
                  text: asset.symbol.overflow,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colorScheme.primaryText,
                  ),
                ),
              ]),
              textAlign: TextAlign.center,
              enableInteractiveSelection: false,
            ),
          ),
        ],
      );
}

class TransferAmountWidget extends HookWidget {
  const TransferAmountWidget({
    Key? key,
    required this.asset,
    required this.amount,
  }) : super(key: key);

  final AssetResult asset;
  final ValueNotifier<String> amount;

  @override
  Widget build(BuildContext context) {
    final fiatInputMode = useState(false);

    useEffect(() {
      if (asset.priceUsd.isZero) {
        fiatInputMode.value = false;
      }
    }, [asset.priceUsd.isZero]);

    final controller = useTextEditingController.fromValue(
      TextEditingValue(text: amount.value),
    );
    final input = useValueListenable(controller).text;

    final currency = auth!.account.fiatCurrency;

    final inputFocusNode = useFocusNode(debugLabel: 'amount input');

    final String equivalent;
    if (fiatInputMode.value) {
      assert(!asset.priceUsd.isZero);
      equivalent =
          '${(input.toDecimalWithLocale() / asset.usdUnitPrice).currencyFormatCoin}'
          ' ${asset.symbol}';
    } else {
      equivalent =
          '${(input.toDecimalWithLocale() * asset.usdUnitPrice).currencyFormatWithoutSymbol}'
          ' $currency';
    }

    useEffect(() {
      void updateAmount() {
        if (fiatInputMode.value) {
          if (controller.text.isEmpty) {
            amount.value = '';
          } else {
            assert(!asset.priceUsd.isZero);
            amount.value = (input.toDecimalWithLocale() / asset.usdUnitPrice)
                .currencyFormatCoin;
          }
        } else {
          amount.value = controller.text;
        }
      }

      controller.addListener(updateAmount);
      fiatInputMode.addListener(updateAmount);
      return () {
        controller.removeListener(updateAmount);
        fiatInputMode.removeListener(updateAmount);
      };
    }, [controller, fiatInputMode]);

    return Material(
      borderRadius: BorderRadius.circular(13),
      color: context.colorScheme.surface,
      child: SizedBox(
        height: 64,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: inputFocusNode.requestFocus,
                  behavior: HitTestBehavior.translucent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(flex: 3),
                      IntrinsicWidth(
                          child: TextField(
                        focusNode: inputFocusNode,
                        style: TextStyle(
                          color: context.colorScheme.primaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        decoration: InputDecoration(
                          isDense: true,
                          isCollapsed: true,
                          hintText: input.isNotEmpty
                              ? ''
                              : '0.00 ${fiatInputMode.value ? currency : asset.symbol}',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: context.colorScheme.thirdText,
                            fontWeight: FontWeight.w400,
                          ),
                          suffixText: input.isNotEmpty
                              ? (fiatInputMode.value ? currency : asset.symbol)
                              : '',
                          suffixStyle: TextStyle(
                            color: context.colorScheme.primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        controller: controller,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(
                              fiatInputMode.value
                                  ? r'^\d*[,.]?\d{0,2}'
                                  : r'^\d*[,.]?\d{0,8}')),
                        ],
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                      )),
                      const Spacer(flex: 1),
                      Text(
                        equivalent,
                        style: TextStyle(
                          color: context.colorScheme.thirdText,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Spacer(flex: 3),
                    ],
                  ),
                ),
              ),
              if (!asset.priceUsd.isZero)
                Align(
                  alignment: Alignment.centerRight,
                  child: InkResponse(
                    radius: 24,
                    onTap: () {
                      fiatInputMode.value = !fiatInputMode.value;
                    },
                    child: SvgPicture.asset(R.resourcesIcSwitchSmallSvg),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

extension _NumberFormat on String {
  Decimal toDecimalWithLocale() {
    try {
      return asDecimal;
    } catch (e) {
      // ignore.
    }
    // if we can not parse the string, retry parse with locale.
    // for example: 1,23 in fr meanings 1.23 in en.
    final locale = getMixinLocaleOrPlatformLocale();
    final numberFormat = NumberFormat.decimalPattern(locale.toString());
    try {
      return Decimal.parse(numberFormat.parse(this).toString());
    } catch (e) {
      return Decimal.zero;
    }
  }
}

class TransferMemoWidget extends HookWidget {
  const TransferMemoWidget({
    Key? key,
    required this.onMemoInput,
    this.initialValue = '',
  }) : super(key: key);

  final void Function(String) onMemoInput;

  final String initialValue;

  @override
  Widget build(BuildContext context) {
    final inputController = useTextEditingController.fromValue(TextEditingValue(
      text: initialValue,
    ));
    useEffect(() {
      void onTextChanged() {
        onMemoInput(inputController.text.trim());
      }

      inputController.addListener(onTextChanged);
      return () {
        inputController.removeListener(onTextChanged);
      };
    }, [inputController]);
    return Material(
      color: context.colorScheme.surface,
      borderRadius: BorderRadius.circular(13),
      child: SizedBox(
        height: 64,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: TextField(
              controller: inputController,
              style: TextStyle(
                color: context.colorScheme.primaryText,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                  hintText: context.l10n.withdrawalMemoHint,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintStyle: TextStyle(
                    color: context.colorScheme.thirdText,
                  )),
            ),
          ),
        ),
      ),
    );
  }
}
