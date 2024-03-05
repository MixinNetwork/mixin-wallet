import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart';

import '../../db/mixin_database.dart';
import '../../service/account_provider.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/native_scroll.dart';
import '../widget/buttons.dart';
import '../widget/mixin_appbar.dart';
import '../widget/symbol.dart';
import '../widget/transaction_info_tile.dart';
import '../widget/transactions/transaction_item.dart';

class SnapshotDetail extends StatelessWidget {
  const SnapshotDetail({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: MixinAppBar(
          backgroundColor: context.colorScheme.background,
          leading: const MixinBackButton2(),
          title: SelectableText(
            context.l10n.transaction,
            style: TextStyle(
              color: context.colorScheme.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            enableInteractiveSelection: false,
          ),
        ),
        backgroundColor: context.colorScheme.background,
        body: _SnapshotDetailPageBody(context.pathParameters['id']!),
      );
}

class _SnapshotDetailPageBody extends HookWidget {
  const _SnapshotDetailPageBody(this.snapshotId);

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

    final faitCurrency = useAccountFaitCurrency();

    final asset = useMemoizedStream(
        () => snapshotItem == null
            ? const Stream<AssetResult>.empty()
            : context.appServices
                .assetResult(snapshotItem.assetId, faitCurrency)
                .watchSingleOrNull(),
        keys: [snapshotItem?.assetId, faitCurrency]).data;

    if (snapshotItem == null || asset == null) {
      return const SizedBox();
    }
    return NativeScrollBuilder(
      builder: (context, controller) => SingleChildScrollView(
        controller: controller,
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
      ),
    );
  }
}

class _SnapshotDetailHeader extends HookWidget {
  const _SnapshotDetailHeader({
    required this.snapshot,
    required this.asset,
  });

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
                      color: context.colorScheme.primaryText,
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
    required this.asset,
    required this.snapshot,
  });

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

    final faitCurrency = useAccountFaitCurrency();

    final currentValue = context.l10n.walletTransactionCurrentValue(
      snapshot
          .amountOfCurrentCurrency(asset)
          .abs()
          .currencyFormat(faitCurrency),
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
            .currencyFormat(faitCurrency),
      );
    }
    return DefaultTextStyle.merge(
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
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
              padding: const EdgeInsets.only(top: 2),
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
    required this.snapshot,
    required this.asset,
  });

  final SnapshotItem snapshot;

  final AssetResult asset;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TransactionInfoTile(
              title: Text(context.l10n.transactionsId),
              subtitle: SelectableText(snapshot.snapshotId),
            ),
            TransactionInfoTile(
              title: Text(context.l10n.transactionsType),
              subtitle: TransactionTypeWidget(
                item: snapshot,
                selectable: true,
              ),
            ),
            TransactionInfoTile(
              title: Text(context.l10n.assetType),
              subtitle: SelectableText(asset.name),
            ),
            _From(snapshot: snapshot),
            _To(snapshot: snapshot, asset: asset),
            TransactionInfoTile(
              title: Text(context.l10n.memo),
              subtitle: Builder(builder: (context) {
                final emptyMemo = snapshot.memo?.isEmpty ?? true;
                return SelectableText(
                  emptyMemo ? '-' : snapshot.memo ?? '-',
                  enableInteractiveSelection: !emptyMemo,
                  style: TextStyle(
                    color: emptyMemo ? context.colorScheme.thirdText : null,
                  ),
                );
              }),
            ),
            TransactionInfoTile(
              title: Text(context.l10n.date),
              subtitle: SelectableText(
                DateFormat.yMMMMd()
                    .add_Hms()
                    .format(snapshot.createdAt.toLocal()),
              ),
            ),
            if (snapshot.traceId != null && snapshot.traceId!.isNotEmpty)
              TransactionInfoTile(
                title: Text(context.l10n.trace),
                subtitle: SelectableText(snapshot.traceId ?? ''),
              ),
            if (snapshot.state != null)
              TransactionInfoTile(
                title: Text(context.l10n.state),
                subtitle: SelectableText(snapshot.state!),
              ),
            if (snapshot.snapshotHash != null)
              TransactionInfoTile(
                title: Text(context.l10n.snapshotHash),
                subtitle: SelectableText(snapshot.snapshotHash!),
              ),
          ],
        ),
      );
}

class _From extends StatelessWidget {
  const _From({
    required this.snapshot,
  });

  final SnapshotItem snapshot;

  @override
  Widget build(BuildContext context) {
    final String sender;
    String? title;

    switch (snapshot.type) {
      case SnapshotType.deposit:
      case SnapshotType.pending:
        sender = snapshot.sender ?? '';
      case SnapshotType.transfer:
        if (snapshot.isPositive) {
          sender = snapshot.opponentFulName ?? '';
        } else {
          final account = context.watch<AuthProvider>().value!.account;
          sender = account.fullName ?? '';
        }
      default:
        sender = snapshot.transactionHash ?? '';
        title = context.l10n.transactionHash;
        break;
    }
    return TransactionInfoTile(
      title: Text(title ?? context.l10n.from),
      subtitle: SelectableText(sender),
    );
  }
}

class _To extends StatelessWidget {
  const _To({
    required this.snapshot,
    required this.asset,
  });

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
        title = context.l10n.transactionHash;
      case SnapshotType.transfer:
        if (!snapshot.isPositive) {
          receiver = snapshot.opponentFulName ?? '';
        } else {
          final account = context.watch<AuthProvider>().value!.account;
          receiver = account.fullName ?? '';
        }
      default:
        receiver = snapshot.receiver ?? '';
        if (asset.tag != null && asset.tag!.isNotEmpty) {
          title = context.l10n.address;
        }
        break;
    }
    return TransactionInfoTile(
      title: Text(title ?? context.l10n.to),
      subtitle: SelectableText(receiver),
    );
  }
}
