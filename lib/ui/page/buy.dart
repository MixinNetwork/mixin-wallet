import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../db/mixin_database.dart';
import '../../service/env.dart';
import '../../service/profile/profile_manager.dart';
import '../../third_party/buy_coin_api.dart';
import '../../util/constants.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/logger.dart';
import '../../util/r.dart';
import '../../wyre/wyre_client.dart';
import '../../wyre/wyre_constants.dart';
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

    final inputController = useMemoized(NumberInputController.new);
    useValueListenable(inputController);

    final quote = useState(const AsyncSnapshot<Quote>.nothing());

    final showLoading = useState(false);

    useEffect(() {
      var canceled = false;
      scheduleMicrotask(() async {
        if (inputController.value == '0') {
          quote.value = const AsyncSnapshot<Quote>.nothing();
          return;
        }
        quote.value = const AsyncSnapshot.waiting();
        try {
          final results = await Future.wait([
            for (final service in BuyService.values)
              service.api.getCurrencyPrice(
                asset,
                inputController.value,
                fiat.value.name,
              ),
          ]);

          assert(() {
            for (final result in results) {
              d('api ${result.service} : ${result.fee} ${result.sourceAmount} ${result.destAmount}');
            }
            return true;
          }());

          final minFee = results.reduce(
            (value, element) => value.fee < element.fee ? value : element,
          );

          if (canceled) {
            return;
          }
          quote.value = AsyncSnapshot.withData(ConnectionState.done, minFee);
        } catch (error, stacktrace) {
          // ignore: invariant_booleans
          if (canceled) {
            return;
          }
          e('get currency price failed: $error $stacktrace');
          quote.value = AsyncSnapshot.withError(ConnectionState.done, error);
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
                  'https://mixinwallet.com/#/buySuccess?asset=${asset.assetId}&fiat=${fiat.value.name}&sourceAmount=${inputController.value}';
              final failureRedirectUrl =
                  'https://mixinwallet.com/#/buy/${asset.assetId}';
              try {
                final quoteData = quote.value.data!;
                final url = await quoteData.service.api.generatePayUrl(
                  asset,
                  auth!.account.userId,
                  fiat.value.name,
                  inputController.value,
                );
                context.toExternal(url);
              } catch (error, stacktrace) {
                e('generate pay url failed: $error $stacktrace');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text('Generate pay url failed: $error'),
                  ),
                );
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
  final AsyncSnapshot<Quote> quote;

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

  final Quote? quote;
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
    return DefaultTextStyle.merge(
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
              // TextSpan(
              //     text:
              //         '${(quote?.fees[fiat.name] ?? 0).toString()} ${fiat.name}',
              //     style: TextStyle(color: context.colorScheme.primaryText)),
            ]),
            enableInteractiveSelection: false,
          ),
          const SizedBox(height: 4),
          SelectableText.rich(
            TextSpan(children: [
              TextSpan(text: context.l10n.networkFee),
              // TextSpan(
              //     text:
              //         '${(quote?.fees[asset.symbol] ?? 0).toString()} ${fiat.name}',
              //     style: TextStyle(color: context.colorScheme.primaryText)),
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
