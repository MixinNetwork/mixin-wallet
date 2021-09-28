import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../db/mixin_database.dart';
import '../../service/env.dart';
import '../../util/constants.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/r.dart';
import '../../wyre/wyre_client.dart';
import '../../wyre/wyre_constants.dart';
import '../../wyre/wyre_quote.dart';
import '../../wyre/wyre_vo.dart';
import '../router/mixin_routes.dart';
import '../widget/buttons.dart';
import '../widget/fiat_selection_list_widget.dart';
import '../widget/mixin_appbar.dart';
import '../widget/mixin_bottom_sheet.dart';
import '../widget/number_input_pad.dart';

class Buy extends HookWidget {
  const Buy({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var assetId = usePathParameter('id', path: buyPath);

    assert(supportedCryptosId.contains(assetId));

    if (!supportedCryptosId.contains(assetId)) {
      assetId = erc20USDT;
    }

    final asset = useMemoizedFuture(
      () => context.appServices.findOrSyncAsset(assetId),
      keys: [assetId],
    );

    if (!asset.hasData) {
      return _BuyScaffold(
        child: Center(
          child: SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(
              color: context.colorScheme.captionIcon,
            ),
          ),
        ),
      );
    }

    return _BuyScaffold(
      asset: asset.data,
      child: _Body(asset: asset.data!),
    );
  }
}

class _BuyScaffold extends StatelessWidget {
  const _BuyScaffold({Key? key, this.asset, required this.child})
      : super(key: key);

  final AssetResult? asset;

  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.colorScheme.background,
        appBar: MixinAppBar(
          backgroundColor: context.colorScheme.background,
          title: Text(
            asset == null
                ? context.l10n.buy
                : '${context.l10n.buy} ${asset!.name}',
            style: TextStyle(
              color: context.colorScheme.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: const MixinBackButton2(),
        ),
        body: child,
      );
}

class _Body extends HookWidget {
  const _Body({
    Key? key,
    required this.asset,
  }) : super(key: key);

  final AssetResult asset;

  @override
  Widget build(BuildContext context) {
    final fiat = useState(getWyreFiatList().first);

    final inputController = useMemoized(() => NumberInputController());
    useValueListenable(inputController);

    final quote = useState(const AsyncSnapshot<WyreQuote>.nothing());

    final showLoading = useState(false);

    useEffect(() {
      var canceled = false;
      scheduleMicrotask(() async {
        final data = {
          'sourceCurrency': fiat.value.name,
          'destCurrency': asset.symbol,
          'dest': 'ethereum:${asset.destination}',
          'country': getCountry(),
          'accountId': Env.wyreAccount,
          'walletType': WyrePayType.applePay.forQuote(),
          'amountIncludeFees': 'true',
          'sourceAmount': inputController.value,
        };
        quote.value = const AsyncSnapshot.waiting();
        try {
          final result =
              await WyreClient.instance.api.getOrderReservationQuote(data);
          if (canceled) {
            return;
          }
          quote.value = AsyncSnapshot.withData(ConnectionState.done, result);
        } catch (e) {
          // ignore: invariant_booleans
          if (canceled) {
            return;
          }
          quote.value = AsyncSnapshot.withError(ConnectionState.done, e);
        }
      });
      return () => canceled = true;
    }, [fiat.value, inputController.value]);

    return Stack(
      children: [
        Column(children: [
          SizedBox(
            height: 80,
            child: Row(
              children: [
                const Spacer(),
                _FiatIcon(
                    fiat: fiat.value,
                    onTap: () async {
                      final selected = await showFiatListBottomSheet(
                          context: context, selectedFiat: fiat.value);
                      if (selected == null) {
                        return;
                      }
                      fiat.value = selected;
                    }),
                const SizedBox(width: 17),
              ],
            ),
          ),
          _InputPreview(
            text: inputController.value,
            fiat: fiat.value,
            asset: asset,
            quote: quote.value,
          ),
          const SizedBox(height: 35),
          NumberInputWidget(controller: inputController),
          const Spacer(),
          _PayButton(
            enable: quote.value.hasData,
            onTap: () async {
              showLoading.value = true;
              final redirectUrl =
                  'http://localhost:8001/#/buySuccess?asset=${asset.assetId}&fiat=${fiat.value.name}&sourceAmount=${inputController.value}';
              final failureRedirectUrl =
                  'http://localhost:8001/#/buy/${asset.assetId}';
              final data = {
                'sourceCurrency': fiat.value.name,
                'destCurrency': asset.symbol,
                'dest': 'ethereum:${asset.destination}',
                'country': getCountry(),
                'redirectUrl': redirectUrl,
                'failureRedirectUrl': failureRedirectUrl,
                'paymentMethod': WyrePayType.applePay.forReservation(),
                'referrerAccountId': Env.wyreAccount,
                'amountIncludeFees': 'true',
                'sourceAmount': inputController.value,
              };
              try {
                final url =
                    await WyreClient.instance.api.createOrderReservation(data);
                if (url == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text('Wyre serve empty url')));
                  return;
                }
                context.toExternal(url);
              } finally {
                showLoading.value = false;
              }
            },
          ),
          const SizedBox(height: 10),
          _BuyDescription(
              quote: quote.value.data, asset: asset, fiat: fiat.value),
          const SizedBox(height: 16),
        ]),
        if (showLoading.value) const _LoadingLayout(),
      ],
    );
  }
}

Future<WyreFiat?> showFiatListBottomSheet({
  required BuildContext context,
  WyreFiat? selectedFiat,
}) =>
    showMixinBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FiatSelectionListWidget(selectedFiat: selectedFiat),
    );

class _FiatIcon extends StatelessWidget {
  const _FiatIcon({
    Key? key,
    required this.fiat,
    required this.onTap,
  }) : super(key: key);

  final WyreFiat fiat;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(64),
        child: SizedBox(
          height: 32,
          child: InkWell(
            borderRadius: BorderRadius.circular(64),
            onTap: onTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 16),
                ClipOval(
                    child: Image.asset(
                  fiat.flag,
                  width: 16,
                  height: 16,
                )),
                const SizedBox(width: 4),
                SelectableText(
                  fiat.name,
                  enableInteractiveSelection: false,
                  onTap: onTap,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.colorScheme.primaryText,
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox.square(
                  dimension: 24,
                  child: SvgPicture.asset(
                    R.resourcesIcArrowDownSvg,
                    width: 24,
                    height: 24,
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      );
}

class _InputPreview extends HookWidget {
  const _InputPreview({
    Key? key,
    required this.text,
    required this.fiat,
    required this.asset,
    required this.quote,
  }) : super(key: key);

  final String text;

  final WyreFiat fiat;

  final AssetResult asset;
  final AsyncSnapshot<WyreQuote> quote;

  @override
  Widget build(BuildContext context) {
    final Widget quoteWidget;

    if (quote.hasData || quote.hasError) {
      String? desc;
      if (quote.hasData) {
        desc = '≈ ${quote.data!.destAmount} ${asset.symbol}';
      } else {
        if (quote.error is DioError) {
          final response = (quote.error! as DioError).response;
          if (response != null) {
            // ignore: avoid_dynamic_calls
            final errorCode = response.data['errorCode'];
            if (errorCode == 'validation.snapx.min' ||
                errorCode == 'exchange.sourceAmountTooSmall') {
              desc = context.l10n.notMeetMinimumAmount;
            } else {
              // ignore: avoid_dynamic_calls
              desc = response.data['message']?.toString();
            }
          }
        }
      }

      quoteWidget = SelectableText(
        desc ?? '',
        enableInteractiveSelection: false,
        style: TextStyle(
          fontSize: 14,
          color: quote.hasError
              ? context.colorScheme.red
              : context.colorScheme.thirdText,
        ),
        maxLines: 1,
      );
    } else {
      quoteWidget = Center(
        child: SizedBox.square(
          dimension: 16,
          child: CircularProgressIndicator(
            color: context.colorScheme.captionIcon,
            strokeWidth: 2,
          ),
        ),
      );
    }

    final faitSymbol = useMemoized(
        () => NumberFormat.simpleCurrency(name: fiat.name).currencySymbol,
        [fiat.name]);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SelectableText(
          '$faitSymbol$text',
          enableInteractiveSelection: false,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w500,
            color: context.colorScheme.primaryText,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(height: 22, child: quoteWidget),
      ],
    );
  }
}

class _BuyDescription extends HookWidget {
  const _BuyDescription({
    Key? key,
    required this.quote,
    required this.fiat,
    required this.asset,
  }) : super(key: key);

  final WyreQuote? quote;
  final WyreFiat fiat;
  final AssetResult asset;

  @override
  Widget build(BuildContext context) {
    final previous = useRef(this.quote);

    useEffect(() {
      if (this.quote != null) {
        previous.value = this.quote;
      }
    }, [this.quote]);

    final quote = this.quote ?? previous.value;
    return DefaultTextStyle(
      style: TextStyle(
        color: context.colorScheme.thirdText,
        fontWeight: FontWeight.w600,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SelectableText.rich(
            TextSpan(children: [
              TextSpan(text: context.l10n.transactionFee),
              TextSpan(
                  text:
                      '${(quote?.fees[fiat.name] ?? 0).toString()} ${fiat.name}',
                  style: TextStyle(color: context.colorScheme.primaryText)),
            ]),
            enableInteractiveSelection: false,
          ),
          const SizedBox(height: 4),
          SelectableText.rich(
            TextSpan(children: [
              TextSpan(text: context.l10n.networkFee),
              TextSpan(
                  text:
                      '${(quote?.fees[asset.symbol] ?? 0).toString()} ${fiat.name}',
                  style: TextStyle(color: context.colorScheme.primaryText)),
            ]),
            enableInteractiveSelection: false,
          ),
          const SizedBox(height: 4),
          SelectableText(
            context.l10n.buyDisclaimer,
            enableInteractiveSelection: false,
          ),
        ],
      ),
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
                R.resourcesIcApplePaySvg,
                width: 12,
                height: 15,
              ),
              const SizedBox(width: 4),
              SelectableText(
                context.l10n.pay,
                style: TextStyle(
                  fontSize: 16,
                  color: context.colorScheme.background,
                ),
                enableInteractiveSelection: false,
                onTap: onTap,
              ),
            ])),
          ),
        ),
      );
}

class _LoadingLayout extends StatelessWidget {
  const _LoadingLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: 110,
          height: 90,
          decoration: BoxDecoration(
            color: const Color(0xFF3B3C3E),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: SizedBox.square(
              dimension: 30,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          ),
        ),
      );
}
