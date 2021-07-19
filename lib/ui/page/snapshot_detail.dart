import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart';

import '../../db/mixin_database.dart';
import '../../service/auth/auth_manager.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../widget/mixin_appbar.dart';
import '../widget/symbol.dart';
import '../widget/transactions/transaction_item.dart';

class SnapshotDetail extends StatelessWidget {
  const SnapshotDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const MixinAppBar(
          backButtonColor: Colors.white,
        ),
        backgroundColor: context.theme.background,
        body: _SnapshotDetailPageBody(context.pathParameters['id']!),
      );
}

class _SnapshotDetailPageBody extends HookWidget {
  const _SnapshotDetailPageBody(this.snapshotId, {Key? key}) : super(key: key);

  final String snapshotId;

  @override
  Widget build(BuildContext context) {
    final snapshotItem = useMemoizedStream(() => context
        .mixinDatabase.snapshotDao
        .snapshotsById(snapshotId)
        .watchSingleOrNull()).data;

    useEffect(() {
      if (snapshotItem == null) {
        context.appServices.updateSnapshotById(snapshotId: snapshotId);
      }
    }, [snapshotId]);

    final asset = useMemoizedStream(
        () => snapshotItem == null
            ? const Stream<AssetResult>.empty()
            : context.appServices
                .assetResult(snapshotItem.assetId)
                .watchSingleOrNull(),
        keys: [snapshotItem?.assetId]).data;

    if (snapshotItem == null || asset == null) {
      return const SizedBox();
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SnapshotDetailHeader(
            snapshot: snapshotItem,
            asset: asset,
          ),
          _TransactionDetailInfo(
            snapshot: snapshotItem,
            asset: asset,
          ),
        ],
      ),
    );
  }
}

class _SnapshotDetailHeader extends HookWidget {
  const _SnapshotDetailHeader({
    Key? key,
    required this.snapshot,
    required this.asset,
  }) : super(key: key);

  final SnapshotItem snapshot;

  final AssetResult asset;

  @override
  Widget build(BuildContext context) => Container(
        color: context.theme.accent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 18),
            SymbolIcon(
              symbolUrl: asset.iconUrl,
              chainUrl: asset.chainIconUrl,
              size: 60,
              chinaSize: 18,
            ),
            const SizedBox(height: 18),
            Text.rich(TextSpan(children: [
              TextSpan(
                  text: snapshot.amount.numberFormat(),
                  style: TextStyle(
                    fontFamily: 'Mixin Condensed',
                    fontSize: 48,
                    color: snapshot.type == SnapshotType.pending
                        ? Colors.white
                        : snapshot.isPositive
                            ? context.theme.green
                            : context.theme.red,
                  )),
              const WidgetSpan(child: SizedBox(width: 2)),
              TextSpan(
                  text: asset.symbol,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.4),
                  )),
            ])),
            const SizedBox(height: 2),
            _ValuesDescription(snapshot: snapshot, asset: asset),
            const SizedBox(height: 38),
          ],
        ),
      );
}

class _ValuesDescription extends HookWidget {
  const _ValuesDescription({
    Key? key,
    required this.asset,
    required this.snapshot,
  }) : super(key: key);

  final AssetResult asset;
  final SnapshotItem snapshot;

  @override
  Widget build(BuildContext context) {
    final ticker = useMemoizedFuture(
      () => context.appServices.client.snapshotApi.getTicker(
        snapshot.assetId,
        offset: snapshot.createdAt.toIso8601String(),
      ),
      keys: [snapshot.snapshotId],
    ).data?.data;

    final String description;

    final currentValue = context.l10n.walletTransactionCurrentValue(
      snapshot.amountOfCurrentCurrency(asset),
    );
    if (ticker == null) {
      description = currentValue;
    } else if (ticker.priceUsd == '0') {
      description =
          '$currentValue${context.l10n.walletTransactionThatTimeNoValue}';
    } else {
      description = '$currentValue'
          '${context.l10n.walletTransactionThatTimeValue(snapshot.amount.asDecimal * ticker.priceUsd.asDecimal * asset.fiatRate.asDecimal)}';
    }
    return Text(
      description,
      style: TextStyle(
        fontSize: 14,
        color: Colors.white.withOpacity(0.5),
      ),
    );
  }
}

class _TransactionDetailInfo extends StatelessWidget {
  const _TransactionDetailInfo({
    Key? key,
    required this.snapshot,
    required this.asset,
  }) : super(key: key);

  final SnapshotItem snapshot;

  final AssetResult asset;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: context.theme.accent,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            color: context.theme.background,
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TransactionInfoTile(
                  title: Text(context.l10n.transactionsId.toUpperCase()),
                  subtitle: SelectableText(snapshot.snapshotId),
                ),
                _TransactionInfoTile(
                  title: Text(context.l10n.transactionsType.toUpperCase()),
                  subtitle: TransactionTypeWidget(item: snapshot),
                ),
                _TransactionInfoTile(
                  title: Text(context.l10n.assetType.toUpperCase()),
                  subtitle: Text(asset.name),
                ),
                _TransactionInfoTile(
                  title: Text(context.l10n.from.toUpperCase()),
                  subtitle: _From(snapshot: snapshot),
                ),
                _TransactionInfoTile(
                  title: Text(context.l10n.to.toUpperCase()),
                  subtitle: _To(snapshot: snapshot),
                ),
                _TransactionInfoTile(
                  title: Text(context.l10n.memo.toUpperCase()),
                  subtitle: Text(snapshot.memo ?? ''),
                ),
                _TransactionInfoTile(
                  title: Text(context.l10n.time.toUpperCase()),
                  subtitle:
                      Text('${DateFormat.yMMMMd().format(snapshot.createdAt)} '
                          '${DateFormat.Hms().format(snapshot.createdAt)}'),
                ),
              ],
            ),
          ),
        ),
      );
}

class _From extends StatelessWidget {
  const _From({
    Key? key,
    required this.snapshot,
  }) : super(key: key);

  final SnapshotItem snapshot;

  @override
  Widget build(BuildContext context) {
    final String sender;

    switch (snapshot.type) {
      case SnapshotType.deposit:
      case SnapshotType.pending:
        sender = snapshot.sender ?? '';
        break;
      case SnapshotType.transfer:
        if (snapshot.isPositive) {
          sender = snapshot.opponentFulName ?? '';
        } else {
          sender = auth?.account.fullName ?? '';
        }
        break;
      default:
        sender = snapshot.transactionHash ?? '';
        break;
    }

    return Text(sender);
  }
}

class _To extends StatelessWidget {
  const _To({Key? key, required this.snapshot}) : super(key: key);

  final SnapshotItem snapshot;

  @override
  Widget build(BuildContext context) {
    final String receiver;

    switch (snapshot.type) {
      case SnapshotType.deposit:
      case SnapshotType.pending:
        receiver = snapshot.transactionHash ?? '';
        break;
      case SnapshotType.transfer:
        if (!snapshot.isPositive) {
          receiver = snapshot.opponentFulName ?? '';
        } else {
          receiver = auth?.account.fullName ?? '';
        }
        break;
      default:
        receiver = snapshot.receiver ?? '';
        break;
    }
    return Text(receiver);
  }
}

class _TransactionInfoTile extends StatelessWidget {
  const _TransactionInfoTile({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  final Widget title;
  final Widget subtitle;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DefaultTextStyle(
            style: const TextStyle(
              fontSize: 12,
              color: Color(0x4D222222),
            ),
            child: title,
          ),
          const SizedBox(height: 6),
          DefaultTextStyle(
            style: TextStyle(fontSize: 16, color: context.theme.text),
            child: subtitle,
          ),
          const SizedBox(height: 20),
        ],
      );
}
