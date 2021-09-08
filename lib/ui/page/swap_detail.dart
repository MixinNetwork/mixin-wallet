import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mixswap_sdk_dart/mixswap_sdk_dart.dart';

import '../../db/mixin_database.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/l10n.dart';
import '../../util/logger.dart';
import '../../util/r.dart';
import '../widget/brightness_observer.dart';
import '../widget/buttons.dart';
import '../widget/mixin_appbar.dart';
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

    final client = Client(null);
    final order = useState<Order?>(null);
    useEffect(() {
      var canceled = false;
      scheduleMicrotask(() async {
        while (!canceled) {
          try {
            final traceOrder = (await client.getOrder(traceId)).data;
            sourceId.value = traceOrder.payAssetUuid;
            destId.value = traceOrder.receiveAssetUuid;
            order.value = traceOrder;
            final done = _isOrderDone(traceOrder);
            if (done) {
              canceled = true;
              break;
            }
          } catch (error, stack) {
            // TODO should only continue with error code 403?
            i('error: $error $stack');
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
          order: order.value,
          source: source,
          dest: dest,
        ));
  }
}

class _Body extends StatelessWidget {
  const _Body({
    Key? key,
    required this.order,
    required this.source,
    required this.dest,
  }) : super(key: key);

  final Order? order;
  final AssetResult source;
  final AssetResult dest;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
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
                const SizedBox(height: 24),
                Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TransactionInfoTile(
                          title: Text(context.l10n.transactionPhase),
                          subtitle:
                              SelectableText(getOrderStatus(order, context))),
                      TransactionInfoTile(
                          title: Text(context.l10n.paid),
                          subtitle: SelectableText(
                              '${filterNull(order?.payAmount)} ${source.symbol}')),
                      TransactionInfoTile(
                          title: Text(context.l10n.received),
                          subtitle: SelectableText(
                              '${filterNull(order?.receiveAmount)} ${dest.symbol}')),
                      TransactionInfoTile(
                          title: Text(context.l10n.refund),
                          subtitle: SelectableText(
                              '${filterNull(order?.refundAmount)} ${source.symbol}')),
                    ]),
                const Spacer(),
                if (order == null || !_isOrderDone(order!)) const _Bottom(),
              ],
            ),
          )));

  String getOrderStatus(Order? order, BuildContext context) {
    if (order != null && _isOrderDone(order)) {
      return context.l10n.transactionDone;
    } else {
      return context.l10n.transactionOngoing;
    }
  }

  String filterNull(String? origin) =>
      (origin == null || origin == 'null') ? '-' : origin;
}

class _Bottom extends HookWidget {
  const _Bottom({Key? key}) : super(key: key);

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
          child: Text(context.l10n.transactionOngoing),
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

bool _isOrderDone(Order order) => order.orderStatus.toLowerCase() == 'done';
