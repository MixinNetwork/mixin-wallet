import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mixswap_sdk_dart/mixswap_sdk_dart.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../db/mixin_database.dart';
import '../../service/mix_swap.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/l10n.dart';
import '../../util/logger.dart';
import '../../util/r.dart';
import '../widget/brightness_observer.dart';
import '../widget/buttons.dart';
import '../widget/mixin_appbar.dart';
import '../widget/paid_in_mixin_dialog.dart';
import '../widget/symbol.dart';
import '../widget/transaction_info_tile.dart';

class SwapDetail extends HookWidget {
  const SwapDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pathParameters = context.pathParameters;
    final traceId = pathParameters['id'];
    final queryParams = context.queryParameters;
    final sourceId = useState(queryParams['source']);
    final destId = useState(queryParams['dest']);

    if (traceId == null) {
      return const SizedBox();
    }

    final order = useState<Order?>(null);
    final swapPhase = useState<SwapPhase>(SwapPhase.checking);
    useEffect(() {
      var canceled = false;
      scheduleMicrotask(() async {
        while (!canceled) {
          try {
            final traceOrder = (await MixSwap.client.getOrder(traceId)).data;
            sourceId.value = traceOrder.payAssetUuid;
            destId.value = traceOrder.receiveAssetUuid;
            order.value = traceOrder;
            final done = _isOrderDone(traceOrder);
            if (done) {
              swapPhase.value = SwapPhase.done;
              canceled = true;
              break;
            } else {
              swapPhase.value = SwapPhase.trading;
            }
          } catch (error, stack) {
            if (error is DioError &&
                error.response?.statusCode == mixSwapRetryErrorCode) {
              swapPhase.value = SwapPhase.checking;
            } else {
              i('error: $error $stack');
              break;
            }
          }
          await Future.delayed(const Duration(milliseconds: 2000));
        }
      });
      return () => canceled = true;
    }, [traceId]);
    final assets = useMemoizedFuture(() {
      if (sourceId.value == null || destId.value == null) {
        return Future.value(null);
      }
      return context.appServices
          .findOrSyncAssets(<String>[sourceId.value!, destId.value!]);
    }, keys: [sourceId.value, destId.value]).data;

    if (assets == null || assets.isEmpty) {
      return const SizedBox();
    }
    final source =
        assets.firstWhere((e) => e.assetId.equalsIgnoreCase(sourceId.value));
    final dest =
        assets.firstWhere((e) => e.assetId.equalsIgnoreCase(destId.value));

    return Scaffold(
        backgroundColor: context.colorScheme.background,
        appBar: MixinAppBar(
          backgroundColor: context.colorScheme.background,
          title: Text(
            context.l10n.transferDetail,
            style: TextStyle(
              color: context.colorScheme.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: const MixinBackButton2(),
        ),
        body: _Body(
          swapPhase: swapPhase.value,
          order: order.value,
          source: source,
          dest: dest,
          traceId: traceId,
        ));
  }

  bool _isOrderDone(Order order) => order.orderStatus.toLowerCase() == 'done';
}

class _Body extends StatelessWidget {
  const _Body({
    Key? key,
    required this.swapPhase,
    required this.order,
    required this.source,
    required this.dest,
    required this.traceId,
  }) : super(key: key);

  final SwapPhase swapPhase;
  final Order? order;
  final AssetResult source;
  final AssetResult dest;
  final String traceId;

  @override
  Widget build(BuildContext context) {
    final amount = context.queryParameters['amount'];
    return SingleChildScrollView(
        child: SizedBox(
            height: MediaQuery.of(context).size.height - 48,
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 20),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 16,
                      color: context.colorScheme.thirdText,
                    ),
                    child: Text(context.l10n.swapType),
                  ),
                  const SizedBox(height: 12),
                  _AssetLayout(
                    source: source,
                    dest: dest,
                  ),
                  const SizedBox(height: 14),
                  Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TransactionInfoTile(
                            title: Text(context.l10n.transactionPhase),
                            subtitle: SelectableText(
                                getOrderStatus(swapPhase, context))),
                        TransactionInfoTile(
                            title: Text(context.l10n.paid),
                            subtitle: SelectableText(
                                subtitle(order?.payAmount, source.symbol)),
                            subtitleColor:
                                subtitleColor(order?.payAmount, context)),
                        TransactionInfoTile(
                            title: Text(context.l10n.received),
                            subtitle: SelectableText(
                                subtitle(order?.receiveAmount, dest.symbol)),
                            subtitleColor:
                                subtitleColor(order?.receiveAmount, context)),
                        TransactionInfoTile(
                            title: Text(context.l10n.refund),
                            subtitle: SelectableText(
                                subtitle(order?.refundAmount, source.symbol)),
                            subtitleColor:
                                subtitleColor(order?.refundAmount, context)),
                      ]),
                  const Spacer(),
                  if (swapPhase == SwapPhase.checking && amount != null)
                    _BottomPayButton(onTap: () async {
                      await showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) =>
                              buildPaidInMixinDialog(context, amount));
                    })
                  else if (swapPhase == SwapPhase.trading)
                    const _BottomLoading(),
                ],
              ),
            )));
  }

  PaidInMixinDialog buildPaidInMixinDialog(
          BuildContext context, String amount) =>
      PaidInMixinDialog(
          title: context.l10n.paidInMixinWarning,
          positiveText: context.l10n.goPay,
          negativeText: context.l10n.paid,
          onPaid: () async {
            Navigator.of(context).pop();

            final memo = buildMixSwapMemo(dest.assetId);
            final uri = Uri.https('mixin.one', 'pay', {
              'amount': amount,
              'trace': traceId,
              'asset': source.assetId,
              'recipient': mixSwapUserId,
              'memo': memo,
            });
            final uriString = uri.toString();
            if (!await canLaunch(uriString)) {
              w('can not launch url: $uriString');
              return;
            }
            await launch(uri.toString());

            await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => PaidInMixinDialog(
                    onPaid: () => Navigator.of(context).pop()));
          });

  String getOrderStatus(SwapPhase swapPhase, BuildContext context) {
    if (swapPhase == SwapPhase.checking) {
      return context.l10n.transactionChecking;
    } else if (swapPhase == SwapPhase.trading) {
      return context.l10n.transactionTrading;
    } else {
      return context.l10n.transactionDone;
    }
  }

  bool isNull(String? origin) => origin == null || origin == 'null';

  String subtitle(String? origin, String symbol) =>
      isNull(origin) ? '-' : '${origin!} $symbol';

  Color? subtitleColor(String? origin, BuildContext context) =>
      isNull(origin) ? context.colorScheme.thirdText : null;
}

class _BottomPayButton extends HookWidget {
  const _BottomPayButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Center(
          child: Column(children: [
        Material(
            borderRadius: BorderRadius.circular(72),
            color: const Color(0xFF333333),
            child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(72),
                child: SizedBox(
                    width: 110,
                    height: 48,
                    child: Center(
                      child: Text(
                        context.l10n.goPay,
                        style: TextStyle(
                          fontSize: 16,
                          color: context.colorScheme.background,
                        ),
                      ),
                    )))),
        const SizedBox(height: 32),
      ]));
}

class _BottomLoading extends HookWidget {
  const _BottomLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(children: [
        SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(
              color: context.colorScheme.primaryText,
              strokeWidth: 2,
            )),
        const SizedBox(height: 22),
        DefaultTextStyle(
          style: TextStyle(
            fontSize: 16,
            height: 1,
            color: context.colorScheme.thirdText,
          ),
          child: Text(context.l10n.transactionTrading),
        ),
        const SizedBox(height: 32),
      ]);
}

class _AssetLayout extends StatelessWidget {
  const _AssetLayout({
    Key? key,
    required this.source,
    required this.dest,
  }) : super(key: key);

  final AssetResult source;
  final AssetResult dest;

  @override
  Widget build(BuildContext context) => Row(children: [
        SymbolIconWithBorder(
          symbolUrl: source.iconUrl,
          chainUrl: source.chainIconUrl,
          size: 32,
          chainBorder: const BorderSide(color: Color(0xfff8f8f8), width: 1),
          symbolBorder: const BorderSide(color: Color(0xfff8f8f8), width: 2),
          chainSize: 8,
        ),
        const SizedBox(width: 10),
        DefaultTextStyle(
          style: TextStyle(
            fontSize: 16,
            color: context.colorScheme.primaryText,
          ),
          child: Text(source.symbol),
        ),
        const SizedBox(width: 16),
        SvgPicture.asset(
          R.resourcesIcDoubleArrowSvg,
          width: 12,
          height: 12,
        ),
        const SizedBox(width: 16),
        SymbolIconWithBorder(
          symbolUrl: dest.iconUrl,
          chainUrl: dest.chainIconUrl,
          size: 32,
          chainBorder: const BorderSide(color: Color(0xfff8f8f8), width: 1),
          symbolBorder: const BorderSide(color: Color(0xfff8f8f8), width: 2),
          chainSize: 8,
        ),
        const SizedBox(width: 10),
        DefaultTextStyle(
          style: TextStyle(
            fontSize: 16,
            color: context.colorScheme.primaryText,
          ),
          child: Text(dest.symbol),
        ),
      ]);
}
