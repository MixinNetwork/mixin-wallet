import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../db/mixin_database.dart';
import '../../util/extension/extension.dart';
import '../widget/buttons.dart';
import '../widget/mixin_appbar.dart';
import '../widget/transactions/transaction_list.dart';

class WithdrawalTransactions extends StatelessWidget {
  const WithdrawalTransactions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.colorScheme.background,
        appBar: MixinAppBar(
          leading: const MixinBackButton2(),
          title: SelectableText(
            context.l10n.transactions,
            style: TextStyle(
              color: context.colorScheme.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            enableInteractiveSelection: false,
          ),
          backgroundColor: context.colorScheme.background,
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          final pageSize =
              (constraints.maxHeight * 1.4) ~/ kTransactionItemHeight;
          return _Body(
            assetId: context.pathParameters['id']!,
            destination: context.queryParameters['destination'],
            tag: context.queryParameters['tag'],
            pageSize: pageSize,
          );
        }),
      );
}

class _Body extends HookWidget {
  const _Body({
    Key? key,
    required this.assetId,
    required this.destination,
    required this.tag,
    required this.pageSize,
  }) : super(key: key);

  final String assetId;
  final String? destination;
  final String? tag;
  final int pageSize;

  @override
  Widget build(BuildContext context) {
    final snapshots = useState(const <SnapshotItem>[]);

    final hasMore = useRef(true);
    final isLoading = useState(false);

    Future<void> loadMore() async {
      if (!hasMore.value || isLoading.value) {
        return;
      }
      isLoading.value = true;
      final result = await context.appServices.getSnapshots(
        assetId: assetId,
        destination: destination,
        tag: tag,
        offset: snapshots.value.lastOrNull?.createdAt.toIso8601String(),
        limit: pageSize,
      );
      if (result.length < pageSize) {
        hasMore.value = false;
      }
      isLoading.value = false;
      // 2021-09-02T08%3A36%3A06.347Z
      snapshots.value = [
        ...snapshots.value,
        ...result,
      ];
    }

    useMemoized(() {
      snapshots.value = const [];
      isLoading.value = false;
      hasMore.value = true;
      loadMore();
    }, [assetId, destination, tag]);

    if (snapshots.value.isEmpty) {
      if (isLoading.value) {
        return Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              color: context.colorScheme.captionIcon,
            ),
          ),
        );
      }
      return const EmptyTransaction();
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is! ScrollUpdateNotification) return false;
        if (notification.scrollDelta == null) return false;
        if (notification.scrollDelta! < 0) return false;

        final dimension = notification.metrics.viewportDimension / 2;
        if (notification.metrics.maxScrollExtent - notification.metrics.pixels <
            dimension) {
          loadMore();
        }
        return false;
      },
      child: ListView.builder(
        itemCount: snapshots.value.length,
        itemBuilder: (context, index) {
          final widget = TransactionItem(
            item: snapshots.value[index],
          );
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: widget,
            );
          }
          return widget;
        },
      ),
    );
  }
}
