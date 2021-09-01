import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart';

import '../../db/mixin_database.dart';
import '../../service/profile/profile_manager.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../widget/buttons.dart';
import '../widget/mixin_appbar.dart';
import '../widget/symbol.dart';
import '../widget/transactions/transaction_item.dart';

class SnapshotDetail extends StatelessWidget {
  const SnapshotDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: MixinAppBar(
          backgroundColor: context.colorScheme.background,
          leading: const MixinBackButton2(),
          title: Text(
            context.l10n.transactions,
            style: TextStyle(
              color: context.colorScheme.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        backgroundColor: context.colorScheme.background,
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
          Container(
            color: context.colorScheme.surface,
            height: 10,
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
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          SymbolIconWithBorder(
            symbolUrl: asset.iconUrl,
            chainUrl: asset.chainIconUrl,
            size: 58,
            chainSize: 14,
            chainBorder: const BorderSide(color: Colors.white, width: 2),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: SelectableText.rich(
              TextSpan(children: [
                TextSpan(
                    text: snapshot.amount.numberFormat().overflow,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: snapshot.type == SnapshotType.pending
                          ? context.colorScheme.primaryText
                          : snapshot.isPositive
                              ? context.colorScheme.green
                              : context.colorScheme.red,
                    )),
                const TextSpan(text: ' '),
                TextSpan(
                    text: asset.symbol.overflow,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.colorScheme.thirdText,
                    )),
              ]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),
          _ValuesDescription(snapshot: snapshot, asset: asset),
          const SizedBox(height: 24),
        ],
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

    final String? thatTimeValue;

    final currentValue = context.l10n.walletTransactionCurrentValue(
      snapshot.amountOfCurrentCurrency(asset).abs().currencyFormat,
    );

    if (ticker == null) {
      thatTimeValue = null;
    } else if (ticker.priceUsd == '0') {
      thatTimeValue = context.l10n.walletTransactionThatTimeNoValue;
    } else {
      thatTimeValue = context.l10n.walletTransactionThatTimeValue(
        (snapshot.amount.asDecimal *
                ticker.priceUsd.asDecimal *
                asset.fiatRate.asDecimal)
            .abs()
            .currencyFormat,
      );
    }
    return DefaultTextStyle(
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: context.colorScheme.thirdText,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SelectableText(
            currentValue,
            enableInteractiveSelection: false,
          ),
          if (thatTimeValue != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: SelectableText(
                thatTimeValue,
                enableInteractiveSelection: false,
              ),
            ),
        ],
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
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 20),
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
              subtitle: TransactionTypeWidget(
                item: snapshot,
                selectable: true,
              ),
            ),
            _TransactionInfoTile(
              title: Text(context.l10n.assetType.toUpperCase()),
              subtitle: SelectableText(asset.name),
            ),
            _From(snapshot: snapshot),
            _To(snapshot: snapshot, asset: asset),
            _TransactionInfoTile(
              title: Text(context.l10n.memo.toUpperCase()),
              subtitle: SelectableText(snapshot.memo ?? ''),
            ),
            _TransactionInfoTile(
              title: Text(context.l10n.time.toUpperCase()),
              subtitle: SelectableText(
                  '${DateFormat.yMMMMd().format(snapshot.createdAt)} '
                  '${DateFormat.Hms().format(snapshot.createdAt)}'),
            ),
            if (snapshot.traceId != null && snapshot.traceId!.isNotEmpty)
              _TransactionInfoTile(
                title: Text(context.l10n.trace.toUpperCase()),
                subtitle: SelectableText(snapshot.traceId ?? ''),
              ),
          ],
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
    String? title;

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
        title = context.l10n.transactionHash.toUpperCase();
        break;
    }
    return _TransactionInfoTile(
      title: Text(title ?? context.l10n.from.toUpperCase()),
      subtitle: SelectableText(sender),
    );
  }
}

class _To extends StatelessWidget {
  const _To({
    Key? key,
    required this.snapshot,
    required this.asset,
  }) : super(key: key);

  final SnapshotItem snapshot;

  final AssetResult asset;

  @override
  Widget build(BuildContext context) {
    final String receiver;
    String? title;

    switch (snapshot.type) {
      case SnapshotType.deposit:
      case SnapshotType.pending:
        receiver = snapshot.transactionHash ?? '';
        title = context.l10n.transactionHash.toUpperCase();
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
        if (asset.tag != null && asset.tag!.isNotEmpty) {
          title = context.l10n.address.toUpperCase();
        }
        break;
    }
    return _TransactionInfoTile(
      title: Text(title ?? context.l10n.to.toUpperCase()),
      subtitle: SelectableText(receiver),
    );
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
          const SizedBox(height: 12),
          DefaultTextStyle(
            style: TextStyle(
              fontSize: 16,
              color: context.colorScheme.thirdText,
            ),
            child: title,
          ),
          const SizedBox(height: 8),
          DefaultTextStyle(
            style: TextStyle(
              fontSize: 16,
              color: context.colorScheme.primaryText,
            ),
            child: subtitle,
          ),
          const SizedBox(height: 12),
        ],
      );
}
