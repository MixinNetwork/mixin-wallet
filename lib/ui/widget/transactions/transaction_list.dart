import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';

import '../../../db/mixin_database.dart';
import '../../../util/extension/extension.dart';
import '../../../util/r.dart';
import 'transaction_item.dart';
import 'transaction_list_controller.dart';

export 'transaction_item.dart';

typedef LoadMoreTransactionCallback = Future<List<SnapshotItem>> Function(
  int? offset,
  int limit,
);

typedef RefreshTransactionCallback = Future<void> Function(
  String? offset,
  int limit,
);

typedef TransactionLayoutBuilder = Widget Function(
  BuildContext context,
  List<SnapshotItem> items,
);

class TransactionListBuilder extends StatelessWidget {
  const TransactionListBuilder({
    Key? key,
    required this.loadMoreItemDb,
    required this.refreshSnapshots,
    required this.builder,
  }) : super(key: key);

  final LoadMoreTransactionCallback loadMoreItemDb;
  final RefreshTransactionCallback refreshSnapshots;

  final TransactionLayoutBuilder builder;

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final pageSize =
            (constraints.maxHeight * 1.4) ~/ kTransactionItemHeight;
        return _TransactionList(
          loadMoreItemDb: loadMoreItemDb,
          refreshSnapshots: refreshSnapshots,
          pageSize: pageSize,
          builder: builder,
        );
      });
}

class _TransactionList extends HookWidget {
  const _TransactionList({
    Key? key,
    required this.loadMoreItemDb,
    required this.refreshSnapshots,
    required this.pageSize,
    required this.builder,
  }) : super(key: key);

  final LoadMoreTransactionCallback loadMoreItemDb;
  final RefreshTransactionCallback refreshSnapshots;
  final int pageSize;

  final TransactionLayoutBuilder builder;

  @override
  Widget build(BuildContext context) {
    final controller = useTransactionListController(
      loadMoreItemDb: loadMoreItemDb,
      refreshSnapshots: refreshSnapshots,
      pageSize: pageSize,
    );

    useEffect(() {
      unawaited(controller.loadMoreItem());
    }, [controller]);

    final snapshots = useValueListenable(controller.snapshots);

    assert(() {
      final distinctItems = snapshots.map((e) => e.snapshotId).toSet();
      for (final item in snapshots) {
        if (!distinctItems.remove(item.snapshotId)) {
          throw FlutterError('got duplicated snapshot item: $item');
        }
      }
      return true;
    }());

    return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is! ScrollUpdateNotification) return false;
          if (notification.scrollDelta == null) return false;
          if (notification.scrollDelta! < 0) return false;

          final dimension = notification.metrics.viewportDimension / 2;
          if (notification.metrics.maxScrollExtent -
                  notification.metrics.pixels <
              dimension) {
            controller.loadMoreItem();
          }
          return false;
        },
        child: builder(context, snapshots));
  }
}

class EmptyTransaction extends StatelessWidget {
  const EmptyTransaction({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(flex: 100),
          Center(
            child: SvgPicture.asset(
              R.resourcesEmptyTransactionGreySvg,
              width: 52,
              height: 68,
            ),
          ),
          const SizedBox(height: 26),
          Center(
            child: Text(
              context.l10n.noTransaction,
              style: TextStyle(
                color: context.theme.secondaryText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(flex: 164),
        ],
      );
}
