import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';

import '../../db/mixin_database.dart';
import '../../service/auth/auth_manager.dart';
import '../../util/constants.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/r.dart';
import '../router/mixin_routes.dart';
import '../widget/action_button.dart';
import '../widget/address_selection_widget.dart';
import '../widget/asset_selection_list_widget.dart';
import '../widget/interactable_box.dart';
import '../widget/mixin_appbar.dart';
import '../widget/mixin_bottom_sheet.dart';
import '../widget/round_container.dart';
import '../widget/symbol.dart';

class Withdrawal extends HookWidget {
  const Withdrawal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var assetId = context.pathParameters['id'];
    assetId ??= bitcoin;
    final data = useMemoizedFuture(
      () => context.appServices.assetResult(assetId!).getSingleOrNull(),
      keys: [assetId],
    ).data;
    if (data == null) {
      return const SizedBox();
    }
    return _WithdrawalPage(asset: data);
  }
}

class _WithdrawalPage extends HookWidget {
  const _WithdrawalPage({
    Key? key,
    required this.asset,
  }) : super(key: key);

  final AssetResult asset;

  @override
  Widget build(BuildContext context) {
    final assetState = useState(this.asset);
    final asset = assetState.value;

    final selectedAddress = useState<Addresse?>(null);
    final valueFirst = useState<double>(0);
    final valueSecond = useState<String>('0.00'.currencyFormatWithoutSymbol);
    final symbolFirst = useState<bool>(false);
    final switched = useState<bool>(false);

    final currency = auth!.account.fiatCurrency;

    final assetPriceUsd = double.tryParse(asset.priceUsd) ?? 1;
    final controller = useTextEditingController();
    useEffect(() {
      void notifyChanged() {
        refreshValues(controller, symbolFirst, switched, valueFirst,
            valueSecond, assetPriceUsd);
      }

      controller.addListener(notifyChanged);
      return () {
        controller.removeListener(notifyChanged);
      };
    }, [controller]);

    return Scaffold(
      backgroundColor: context.theme.background,
      appBar: MixinAppBar(
        title: Text(
          context.l10n.sendToAddress,
          style: TextStyle(color: context.theme.text),
        ),
        backgroundColor: context.theme.background,
        actions: <Widget>[
          ActionButton(
              name: R.resourcesIcFileSvg,
              color: BrightnessData.themeOf(context).icon,
              onTap: () {}),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        child: Column(children: [
          const SizedBox(height: 20),
          InteractableBox(
            onTap: () {
              showMixinBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => AssetSelectionListWidget(
                  onTap: (AssetResult assetResult) {
                    assetState.value = assetResult;
                    context.replace(
                        withdrawalPath.toUri({'id': assetResult.assetId}));
                  },
                  selectedAssetId: asset.assetId,
                ),
              );
            },
            child: RoundContainer(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                children: [
                  SymbolIcon(
                      symbolUrl: asset.iconUrl,
                      chainUrl: asset.chainIconUrl,
                      size: 32),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          asset.symbol.overflow,
                          style: TextStyle(
                            color: context.theme.text,
                            fontSize: 16,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${asset.balance}${asset.symbol}',
                          style: TextStyle(
                            color: context.theme.secondaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SvgPicture.asset(R.resourcesIcArrowDownSvg),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          InteractableBox(
            onTap: () {
              showMixinBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => AddressSelectionWidget(
                        assetId: asset.assetId,
                        selectedAddress: selectedAddress.value,
                        onTap: (address) => selectedAddress.value = address,
                      ));
            },
            child: RoundContainer(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: selectedAddress.value == null
                        ? Text(
                            context.l10n.selectFromAddressBook,
                            style: TextStyle(
                              color: context.theme.secondaryText,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                selectedAddress.value!.label.overflow,
                                style: TextStyle(
                                  color: context.theme.text,
                                  fontSize: 16,
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                selectedAddress.value!
                                    .displayAddress()
                                    .formatAddress(),
                                style: TextStyle(
                                  color: context.theme.secondaryText,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SvgPicture.asset(R.resourcesIcArrowDownSvg),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          RoundContainer(
            height: null,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(children: [
                        IntrinsicWidth(
                            child: TextField(
                          style: TextStyle(
                            color: context.theme.text,
                            fontSize: 16,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          decoration: InputDecoration(
                            hintText: symbolFirst.value
                                ? ''
                                : '0.00 ${switched.value ? currency : asset.symbol}',
                            border: InputBorder.none,
                          ),
                          controller: controller,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(
                                switched.value
                                    ? r'^\d*\.?\d{0,2}'
                                    : r'^\d*\.?\d{0,8}')),
                          ],
                        )),
                        Text(
                          symbolFirst.value
                              ? (switched.value ? currency : asset.symbol)
                              : '',
                          style: TextStyle(
                            color: context.theme.text,
                            fontSize: 16,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ]),
                      Text(
                        '${valueSecond.value} ${switched.value ? asset.symbol : currency}',
                        style: TextStyle(
                          color: context.theme.secondaryText,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                    alignment: Alignment.centerRight,
                    child: InteractableBox(
                        onTap: () {
                          switched.value = !switched.value;
                          refreshValues(controller, symbolFirst, switched,
                              valueFirst, valueSecond, assetPriceUsd);
                        },
                        child: SvgPicture.asset(R.resourcesIcSwitchSvg))),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _FeeText(asset: asset, address: selectedAddress.value),
          const Spacer(),
          Align(
            alignment: Alignment.bottomCenter,
            child: InteractableBox(
                onTap: () {},
                child: Container(
                    width: 160,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xffB2B3C7),
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      vertical: 11,
                      horizontal: 22,
                    ),
                    child: Text(context.l10n.send,
                        style: TextStyle(
                          fontSize: 16,
                          color: context.theme.background,
                        )))),
          ),
          const SizedBox(height: 70),
        ]),
      ),
    );
  }

  void refreshValues(
      TextEditingController controller,
      ValueNotifier<bool> symbolFirst,
      ValueNotifier<bool> switched,
      ValueNotifier<double> valueFirst,
      ValueNotifier<String> valueSecond,
      double assetPriceUsd) {
    final s = controller.text;
    symbolFirst.value = s.isNotEmpty;
    if (switched.value) {
      valueFirst.value = double.tryParse(controller.text) ?? 0;
      valueSecond.value = (valueFirst.value / assetPriceUsd).currencyFormatCoin;
    } else {
      valueFirst.value = double.tryParse(controller.text) ?? 0;
      valueSecond.value =
          (valueFirst.value * assetPriceUsd).currencyFormatWithoutSymbol;
    }
  }
}

class _FeeText extends StatelessWidget {
  const _FeeText({Key? key, this.address, required this.asset})
      : super(key: key);

  final Addresse? address;
  final AssetResult asset;

  @override
  Widget build(BuildContext context) {
    if (address == null) {
      return const SizedBox();
    }
    final reserveVal = double.tryParse(address!.reserve);
    final bold = '${address!.fee} ${asset.chainSymbol}';
    final String text;
    if (reserveVal == null || reserveVal <= 0) {
      text = context.l10n.withdrawalFee(bold, asset.name);
    } else {
      text = context.l10n.withdrawalFeeReserve(
          bold, asset.symbol, asset.name, address!.reserve, asset.symbol);
    }
    return Text(text,
        style: TextStyle(
          color: context.theme.secondaryText,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ));
  }
}
