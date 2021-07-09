import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart';

import '../../../db/mixin_database.dart';
import '../../../util/extension/extension.dart';
import '../../../util/r.dart';
import 'transaction_list_controller.dart';

typedef LoadMoreTransactionCallback = Future<List<SnapshotItem>> Function(
    String? offset);

typedef RefreshTransactionCallback = Future<List<SnapshotItem>> Function(
    String? offset);

class TransactionList extends HookWidget {
  const TransactionList({
    Key? key,
    required this.loadMoreItemDb,
    required this.refreshSnapshots,
  }) : super(key: key);

  final LoadMoreTransactionCallback loadMoreItemDb;
  final RefreshTransactionCallback refreshSnapshots;

  Widget _buildItem(SnapshotItem item) => _TransactionItem(item: item);

  @override
  Widget build(BuildContext context) {
    final controller = useTransactionListController(
      loadMoreItemDb: loadMoreItemDb,
      refreshSnapshots: refreshSnapshots,
    );

    useEffect(() {
      unawaited(controller.loadMoreItem());
    }, [controller]);

    final snapshots = useValueListenable(controller.snapshots);
    if (snapshots.isEmpty) {
      return const SliverToBoxAdapter(child: _EmptyTransaction());
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildItem(snapshots[index]),
        childCount: snapshots.length,
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  const _TransactionItem({Key? key, required this.item}) : super(key: key);

  final SnapshotItem item;

  @override
  Widget build(BuildContext context) {
    final isPositive = double.parse(item.amount) > 0;
    return Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: 50,
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            const SizedBox(width: 20),
            _TransactionIcon(item: item),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    _TransactionItemTitle(item: item),
                    const Spacer(),
                    Text(
                      '${isPositive ? '+' : ''}${item.amount.numberFormat()}',
                      style: TextStyle(
                        fontSize: 16,
                        color: BrightnessData.themeOf(context).secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      DateFormat.yMMMMd().format(item.createdAt),
                      style: TextStyle(
                        fontSize: 14,
                        color: BrightnessData.themeOf(context).secondaryText,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      item.assetSymbol,
                      style: TextStyle(
                        fontSize: 12,
                        color: BrightnessData.themeOf(context).text,
                        fontFamily: 'SF Pro Text',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
              ],
            )),
            const SizedBox(width: 20),
          ],
        ));
  }
}

class _TransactionItemTitle extends StatelessWidget {
  const _TransactionItemTitle({Key? key, required this.item}) : super(key: key);

  final SnapshotItem item;

  @override
  Widget build(BuildContext context) {
    String title;
    switch (item.type) {
      case SnapshotType.pending:
        title = context.l10n.depositing;
        break;
      case SnapshotType.deposit:
        title = context.l10n.deposit;
        break;
      case SnapshotType.transfer:
        title = context.l10n.transfer;
        break;
      case SnapshotType.withdrawal:
        title = context.l10n.withdrawal;
        break;
      case SnapshotType.fee:
        title = context.l10n.fee;
        break;
      case SnapshotType.rebate:
        title = context.l10n.rebate;
        break;
      case SnapshotType.raw:
        title = context.l10n.raw;
        break;
      default:
        title = item.type;
        break;
    }

    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        color: BrightnessData.themeOf(context).text,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _TransactionIcon extends StatelessWidget {
  const _TransactionIcon({Key? key, required this.item}) : super(key: key);

  final SnapshotItem item;

  // TODO icon with type
  @override
  Widget build(BuildContext context) => Container(
        height: 44,
        width: 44,
        decoration: const BoxDecoration(
          color: Colors.amber,
          shape: BoxShape.circle,
        ),
      );
}

class _EmptyTransaction extends StatelessWidget {
  const _EmptyTransaction({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 130),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              R.resourcesEmptyTransactionSvg,
              width: 52,
              height: 68,
            ),
            const SizedBox(height: 26),
            Text(
              context.l10n.noTransaction,
              style: TextStyle(
                color: context.theme.secondaryText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
}
