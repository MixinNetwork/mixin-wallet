import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../db/mixin_database.dart';
import '../../service/env.dart';
import '../../util/constants.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/l10n.dart';
import '../../util/logger.dart';
import '../../util/r.dart';
import '../../wyre/wyre_client.dart';
import '../../wyre/wyre_constants.dart';
import '../../wyre/wyre_vo.dart';
import '../router/mixin_routes.dart';
import '../widget/asset_selection_list_widget.dart';
import '../widget/brightness_observer.dart';
import '../widget/fiat_selection_list_widget.dart';
import '../widget/mixin_appbar.dart';
import '../widget/mixin_bottom_sheet.dart';
import '../widget/round_container.dart';
import '../widget/symbol.dart';

class Buy extends HookWidget {
  const Buy({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var assetId = context.pathParameters['id'];
    assetId ??= erc20USDT;

    final wyreClient = WyreClient.instance;
    final wyreRateMap =
        useMemoizedFuture(() => wyreClient.api.getRate().then(filterWyreRates))
            .data;
    if (wyreRateMap == null || wyreRateMap.isEmpty) {
      w('wyreRates: $wyreRateMap');
      return const SizedBox();
    }

    final supportedAssets = useMemoizedFuture(
        () => context.appServices.findOrSyncAssets(supportedCryptosId)).data;
    if (supportedAssets == null || supportedAssets.isEmpty) {
      w('supportedAssets: $supportedAssets');
      return const SizedBox();
    }

    final fiatList = getWyreFiatList();
    return _Buy(
        wyreRateMap: wyreRateMap,
        supportedAssets: supportedAssets,
        fiatList: fiatList);
  }

  Future<Map<String, double>> filterWyreRates(Map<String, double> data) async {
    final wyreRateMap = <String, double>{};
    supportedFiats.forEach((fiat) {
      supportedCryptos.forEach((crypto) {
        final key = '$fiat$crypto';
        final target = data[key];
        if (target != null) {
          wyreRateMap[key] = target;
        }
      });
    });
    return wyreRateMap;
  }
}

class _Buy extends HookWidget {
  const _Buy({
    Key? key,
    required this.wyreRateMap,
    required this.supportedAssets,
    required this.fiatList,
  }) : super(key: key);

  final Map<String, double> wyreRateMap;
  final List<AssetResult> supportedAssets;
  final List<WyreFiat> fiatList;

  @override
  Widget build(BuildContext context) {
    final asset = useState(supportedAssets[0]);
    final fiat = useState(fiatList[0]);
    final type = useState(WyrePayType.debitCard);
    final fiatAmount = useValueNotifier('');

    final fiatController = useTextEditingController();
    final cryptoController = useTextEditingController();
    final fiatFocusNode = useFocusNode(debugLabel: 'fiat input');
    final cryptoFocusNode = useFocusNode(debugLabel: 'crypto input');

    useEffect(() {
      void updateAmount() {
        final rate = getRate(fiat, asset);
        if (fiatFocusNode.hasFocus) {
          cryptoController.text = (fiatController.text.asDecimalOrZero /
                  Decimal.parse(rate.toString()))
              .toString();
          fiatAmount.value = fiatController.text;
        }
      }

      fiatController.addListener(updateAmount);
      return () {
        fiatController.removeListener(updateAmount);
      };
    }, [fiatController]);

    useEffect(() {
      void updateAmount() {
        final rate = getRate(fiat, asset);
        if (cryptoFocusNode.hasFocus) {
          assert(rate != 0);
          fiatController.text = (cryptoController.text.asDecimalOrZero *
                  Decimal.parse(rate.toString()))
              .toString();
          fiatAmount.value = fiatController.text;
        }
      }

      cryptoController.addListener(updateAmount);
      return () {
        cryptoController.removeListener(updateAmount);
      };
    }, [cryptoController]);

    return Scaffold(
        backgroundColor: context.theme.accent,
        appBar: MixinAppBar(
          title: Text(context.l10n.buy),
          backButtonColor: Colors.white,
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(topRadius)),
            color: context.theme.background,
          ),
          child: Column(children: [
            const SizedBox(height: 20),
            RoundContainer(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Row(children: [
                InkWell(
                  onTap: () {
                    showMixinBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => FiatSelectionListWidget(
                        fiatList: fiatList,
                        selectedFiat: fiat.value,
                        onTap: (WyreFiat wyreFiat) {
                          fiat.value = wyreFiat;
                        },
                      ),
                    );
                  },
                  child: ClipOval(
                      child: Image.asset(
                    fiat.value.flag,
                    width: 40,
                    height: 40,
                  )),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    focusNode: fiatFocusNode,
                    style: TextStyle(
                      color: context.theme.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    decoration: const InputDecoration(
                      hintText: '0.000',
                      border: InputBorder.none,
                    ),
                    controller: fiatController,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,3}'))
                    ],
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  fiat.value.name,
                  style: TextStyle(
                    color: context.theme.secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 10),
                SvgPicture.asset(R.resourcesIcArrowDownSvg),
                const SizedBox(width: 20),
              ]),
            ),
            const SizedBox(height: 20),
            RoundContainer(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Row(children: [
                InkWell(
                    onTap: () {
                      showMixinBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => AssetSelectionListWidget(
                          onTap: (AssetResult assetResult) {
                            context.replace(
                                buyPath.toUri({'id': assetResult.assetId}));
                            asset.value = assetResult;
                          },
                          selectedAssetId: asset.value.assetId,
                          assetResultList: supportedAssets,
                        ),
                      );
                    },
                    child: SymbolIconWithBorder(
                      symbolUrl: asset.value.iconUrl,
                      chainUrl: asset.value.chainIconUrl,
                      size: 40,
                      chainBorder:
                          const BorderSide(color: Color(0xfff8f8f8), width: 1),
                      symbolBorder:
                          const BorderSide(color: Color(0xfff8f8f8), width: 2),
                      chainSize: 8,
                    )),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    focusNode: cryptoFocusNode,
                    style: TextStyle(
                      color: context.theme.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    decoration: const InputDecoration(
                      hintText: '0.000',
                      border: InputBorder.none,
                    ),
                    controller: cryptoController,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,3}'))
                    ],
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  asset.value.symbol,
                  style: TextStyle(
                    color: context.theme.secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 10),
                SvgPicture.asset(R.resourcesIcArrowDownSvg),
                const SizedBox(width: 20),
              ]),
            ),
            const SizedBox(height: 20),
            Align(
                alignment: Alignment.centerLeft,
                child: Text.rich(TextSpan(
                    style: TextStyle(
                      color: context.theme.secondaryText,
                      fontSize: 13,
                      height: 2,
                    ),
                    children: [
                      TextSpan(text: '${context.l10n.transactionFee} '),
                      TextSpan(
                          text:
                              '${calcTransactionFee(double.tryParse(fiatAmount.value) ?? 0, fiat.value.area)} ${fiat.value.name}',
                          style: TextStyle(
                            color: context.theme.text,
                            fontWeight: FontWeight.bold,
                          )),
                      TextSpan(text: '\n${context.l10n.networkFee} '),
                      TextSpan(
                          text: 'TODO',
                          style: TextStyle(
                            color: context.theme.text,
                            fontWeight: FontWeight.bold,
                          )),
                    ]))),
            const Spacer(),
            HookBuilder(
                builder: (context) => _PayButton(
                      enable: fiatAmount.value.isNotEmpty,
                      onTap: () async {
                        final redirectUrl =
                            'http://localhost:8001/#/tokens/${asset.value.assetId}';
                        final data = {
                          'sourceCurrency': fiat.value.name,
                          'destCurrency': asset.value.symbol,
                          'dest': 'ethereum:${asset.value.destination}',
                          'country': 'US', // TODO Country code (Alpha-2)
                          'redirectUrl': redirectUrl,
                          'failureRedirectUrl': redirectUrl,
                          'paymentMethod': type.value.inString(),
                          'referrerAccountId': Env.wyreAccount,
                          'amountIncludeFees': 'false',
                          'sourceAmount': fiatController.text,
                        };
                        final url = await WyreClient.instance.api
                            .createOrderReservation(data);
                        if (url == null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              behavior: SnackBarBehavior.floating,
                              content: Text('empty $url')));
                          return;
                        }
                        context.toExternal(url);
                      },
                    )),
            const SizedBox(height: 30),
          ]),
        ));
  }

  double getRate(
      ValueNotifier<WyreFiat> fiat, ValueNotifier<AssetResult> asset) {
    final key = '${fiat.value.name}${asset.value.symbol}';
    final rate = wyreRateMap[key];
    assert(rate != null);
    return rate!;
  }
}

class _PayButton extends StatelessWidget {
  const _PayButton({
    Key? key,
    required this.onTap,
    required this.enable,
  }) : super(key: key);

  final VoidCallback onTap;
  final bool enable;

  @override
  Widget build(BuildContext context) => Material(
        borderRadius: BorderRadius.circular(12),
        color: enable ? context.theme.accent : const Color(0xffB2B3C7),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 160,
            height: 44,
            child: Center(
              child: Text(
                context.l10n.buy,
                style: TextStyle(
                  fontSize: 16,
                  color: context.theme.background,
                ),
              ),
            ),
          ),
        ),
      );
}
