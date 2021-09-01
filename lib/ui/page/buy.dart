import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rxdart/rxdart.dart';

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
import '../../wyre/wyre_quote.dart';
import '../../wyre/wyre_vo.dart';
import '../router/mixin_routes.dart';
import '../widget/asset_selection_list_widget.dart';
import '../widget/brightness_observer.dart';
import '../widget/buttons.dart';
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

    final supportedAssets = useMemoizedFuture(
        () => context.appServices.findOrSyncAssets(supportedCryptosId)).data;
    final fiatList = useMemoized<List<WyreFiat>>(getWyreFiatList);

    if (supportedAssets == null || supportedAssets.isEmpty) {
      w('supportedAssets: $supportedAssets');
      return const SizedBox();
    }

    return Scaffold(
        backgroundColor: context.colorScheme.background,
        appBar: MixinAppBar(
          backgroundColor: context.colorScheme.background,
          title: Text(
            context.l10n.buy,
            style: TextStyle(
              color: context.colorScheme.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: const MixinBackButton2(),
        ),
        body: _BuyBody(supportedAssets: supportedAssets, fiatList: fiatList));
  }
}

class _BuyBody extends HookWidget {
  const _BuyBody({
    Key? key,
    required this.supportedAssets,
    required this.fiatList,
  }) : super(key: key);

  final List<AssetResult> supportedAssets;
  final List<WyreFiat> fiatList;

  @override
  Widget build(BuildContext context) {
    final asset = useState(supportedAssets[0]);
    final fiat = useState(fiatList[0]);
    final type = useState(WyrePayType.applePay);
    final wyreQuote = useState<WyreQuote?>(null);
    final lastQuoteByFiat = useState(true);

    final fiatController = useStreamController<String>();
    final cryptoController = useStreamController<String>();
    final fiatTextController = useTextEditingController();
    final cryptoTextController = useTextEditingController();
    final fiatStream = useMemoized(() => fiatController.stream.distinct());
    final cryptoStream = useMemoized(() => cryptoController.stream.distinct());
    final fiatFocusNode = useFocusNode(debugLabel: 'fiat input');
    final cryptoFocusNode = useFocusNode(debugLabel: 'crypto input');

    final country = useMemoized(getCountry);

    void showAssetListBottomSheet() {
      showMixinBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => AssetSelectionListWidget(
          onTap: (AssetResult assetResult) {
            context.replace(buyPath.toUri({'id': assetResult.assetId}));
            asset.value = assetResult;
          },
          selectedAssetId: asset.value.assetId,
          assetResultList: supportedAssets,
        ),
      );
    }

    void showFiatListBottomSheet() {
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
    }

    Future<WyreQuote> queryOrderQuote(bool byFiat, String amount) async {
      final data = {
        'sourceCurrency': fiat.value.name,
        'destCurrency': asset.value.symbol,
        'dest': 'ethereum:${asset.value.destination}',
        'country': country,
        'accountId': Env.wyreAccount,
        'walletType': type.value.forQuote(),
        'amountIncludeFees': 'true',
      };
      if (byFiat) {
        data['sourceAmount'] = amount;
      } else {
        data['destAmount'] = amount;
      }
      final quote =
          await WyreClient.instance.api.getOrderReservationQuote(data);
      return quote;
    }

    Future<void> updateAmount(
      String text,
      FocusNode inputFocusNode,
      TextEditingController effectedController,
    ) async {
      final amount = double.tryParse(text) ?? 0;
      if (amount == 0) {
        effectedController.text = '';
        wyreQuote.value = null;
        return;
      }

      if (inputFocusNode.hasFocus) {
        final byFiat = effectedController != fiatTextController;
        final quote = await queryOrderQuote(byFiat, text);
        effectedController.text = quote.destAmount.toString();
        wyreQuote.value = quote;
        lastQuoteByFiat.value = byFiat;
      }
    }

    useEffect(() {
      final listen = fiatStream
          .debounceTime(const Duration(milliseconds: 500))
          .map((String text) =>
              updateAmount(text, fiatFocusNode, cryptoTextController))
          .listen((_) {});
      return listen.cancel;
    });
    useEffect(() {
      final listen = cryptoStream
          .debounceTime(const Duration(milliseconds: 500))
          .map((String text) =>
              updateAmount(text, cryptoFocusNode, fiatTextController))
          .listen((_) {});
      return listen.cancel;
    });

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(topRadius)),
        color: context.colorScheme.background,
      ),
      child: Column(children: [
        const SizedBox(height: 20),
        RoundContainer(
          height: 64,
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          child: Row(children: [
            InkWell(
              onTap: showFiatListBottomSheet,
              child: ClipOval(
                  child: Image.asset(
                fiat.value.flag,
                width: 40,
                height: 40,
              )),
            ),
            const SizedBox(width: 12),
            InkWell(
                onTap: showFiatListBottomSheet,
                child: Text(
                  fiat.value.name,
                  style: TextStyle(
                    color: context.colorScheme.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                )),
            const SizedBox(width: 10),
            SvgPicture.asset(R.resourcesIcArrowDownSvg),
            const SizedBox(width: 10),
            Expanded(
                child: _AmountTextField(
                    focusNode: fiatFocusNode,
                    controller: fiatTextController,
                    onChanged: fiatController.add)),
            const SizedBox(width: 20),
          ]),
        ),
        const SizedBox(height: 20),
        RoundContainer(
          height: 64,
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          child: Row(children: [
            InkWell(
                onTap: showAssetListBottomSheet,
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
            InkWell(
                onTap: showAssetListBottomSheet,
                child: Text(
                  asset.value.symbol,
                  style: TextStyle(
                    color: context.colorScheme.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                )),
            const SizedBox(width: 10),
            SvgPicture.asset(R.resourcesIcArrowDownSvg),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                    height: 38,
                    child: _AmountTextField(
                        focusNode: cryptoFocusNode,
                        controller: cryptoTextController,
                        onChanged: cryptoController.add)),
                const SizedBox(height: 7),
                Text(
                  '${asset.value.balance} ${context.l10n.balance}',
                  style: TextStyle(
                    color: context.colorScheme.secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.end,
                ),
              ],
            )),
            const SizedBox(width: 20),
          ]),
        ),
        const SizedBox(height: 20),
        if (wyreQuote.value != null)
          Align(
              alignment: Alignment.centerLeft,
              child: Text.rich(TextSpan(
                  style: TextStyle(
                    color: context.colorScheme.secondaryText,
                    fontSize: 13,
                    height: 2,
                  ),
                  children: [
                    TextSpan(text: '${context.l10n.transactionFee} '),
                    TextSpan(
                        text:
                            '${(wyreQuote.value?.fees[fiat.value.name] ?? 0).toString()} ${fiat.value.name}',
                        style: TextStyle(
                          color: context.colorScheme.primaryText,
                          fontWeight: FontWeight.bold,
                        )),
                    TextSpan(text: '\n${context.l10n.networkFee} '),
                    TextSpan(
                        text:
                            '${(wyreQuote.value?.fees[asset.value.symbol] ?? 0).toString()} ${fiat.value.name}',
                        style: TextStyle(
                          color: context.colorScheme.primaryText,
                          fontWeight: FontWeight.bold,
                        )),
                  ]))),
        const Spacer(),
        HookBuilder(
            builder: (context) => _PayButton(
                  enable: wyreQuote.value != null,
                  onTap: () async {
                    final fiatAmount = await fiatStream.last;
                    final cryptoAmount = await cryptoStream.last;
                    final redirectUrl =
                        'http://localhost:8001/#/buySuccess?asset=${asset.value.assetId}&fiat=${fiat.value.name}&sourceAmount=$fiatAmount&destAmount=$cryptoAmount';
                    final failureRedirectUrl =
                        'http://localhost:8001/#/buy/${asset.value.assetId}';
                    final data = {
                      'sourceCurrency': fiat.value.name,
                      'destCurrency': asset.value.symbol,
                      'dest': 'ethereum:${asset.value.destination}',
                      'country': country,
                      'redirectUrl': redirectUrl,
                      'failureRedirectUrl': failureRedirectUrl,
                      'paymentMethod': type.value.forReservation(),
                      'referrerAccountId': Env.wyreAccount,
                      'amountIncludeFees': 'true',
                    };
                    if (lastQuoteByFiat.value) {
                      data['sourceAmount'] = fiatAmount;
                    } else {
                      data['destAmount'] = cryptoAmount;
                    }
                    final url = await WyreClient.instance.api
                        .createOrderReservation(data);
                    if (url == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text('Wyre serve empty url')));
                      return;
                    }
                    context.toExternal(url);
                  },
                )),
        const SizedBox(height: 30),
      ]),
    );
  }
}

class _AmountTextField extends HookWidget {
  const _AmountTextField({
    Key? key,
    required this.focusNode,
    required this.controller,
    required this.onChanged,
  }) : super(key: key);

  final FocusNode focusNode;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      void notifyChanged() {
        onChanged.call(controller.text);
      }

      controller.addListener(notifyChanged);
      return () {
        controller.removeListener(notifyChanged);
      };
    }, [controller, onChanged]);
    return TextField(
      focusNode: focusNode,
      style: TextStyle(
        color: context.colorScheme.primaryText,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      maxLines: 1,
      decoration: const InputDecoration(
        hintText: '0.000',
        border: InputBorder.none,
      ),
      controller: controller,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}'))
      ],
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.end,
    );
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
        borderRadius: BorderRadius.circular(72),
        color: enable ? const Color(0xFF333333) : const Color(0x33333333),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(72),
          child: SizedBox(
            width: 110,
            height: 48,
            child: Center(
                child: Row(mainAxisSize: MainAxisSize.min, children: [
              SvgPicture.asset(
                R.resourcesIcApplePay,
                width: 12,
                height: 15,
              ),
              const SizedBox(width: 4),
              Text(
                context.l10n.pay,
                style: TextStyle(
                  fontSize: 16,
                  color: context.colorScheme.background,
                ),
              ),
            ])),
          ),
        ),
      );
}
