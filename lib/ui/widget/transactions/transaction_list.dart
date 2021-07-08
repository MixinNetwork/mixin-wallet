import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';

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
    importExtension();
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
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // TODO transaction type
                    Text(
                      item.type,
                      style: TextStyle(
                        fontSize: 16,
                        color: BrightnessData.themeOf(context).text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${isPositive ? '+' : ''}${item.amount.currencyFormat}',
                      style: TextStyle(
                        fontSize: 16,
                        color: BrightnessData.themeOf(context).secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      item.createdAt.toIso8601String(),
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
                )
              ],
            )),
            const SizedBox(width: 20),
          ],
        ));
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
