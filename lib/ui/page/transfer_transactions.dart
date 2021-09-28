import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../util/extension/extension.dart';
import '../../util/r.dart';
import '../widget/action_button.dart';
import '../widget/buttons.dart';
import '../widget/mixin_appbar.dart';
import '../widget/transactions/transaction_list.dart';
import '../widget/transactions/transactions_filter.dart';

class TransferTransactions extends HookWidget {
  const TransferTransactions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sort = useState(SortBy.time);
    return Scaffold(
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
        actions: [
          ActionButton(
            name: R.resourcesFilterSvg,
            size: 24,
            onTap: () async {
              final selection = await showFilterSortBottomSheetDialog(
                context,
                initial: sort.value,
              );
              if (selection == null) {
                return;
              }
              sort.value = selection;
            },
          )
        ],
      ),
      body: _Body(
        assetId: context.pathParameters['id']!,
        opponent: context.queryParameters['opponent'],
        sort: sort.value,
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    Key? key,
    required this.assetId,
    required this.opponent,
    required this.sort,
  }) : super(key: key);

  final String assetId;

  final String? opponent;

  final SortBy sort;

  @override
  Widget build(BuildContext context) {
    if (opponent == null) {
      return const EmptyTransaction();
    }
    return TransactionListBuilder(
      key: ValueKey(sort),
      loadMoreItemDb: (offset, limit) => context.mixinDatabase.snapshotDao
          .snapshots(
            assetId,
            offset: offset,
            limit: limit,
            opponent: opponent,
            orderByAmount: sort == SortBy.amount,
          )
          .get(),
      refreshSnapshots: (offset, limit) => context.appServices.getSnapshots(
        assetId: assetId,
        opponent: opponent,
        offset: offset,
        limit: limit,
      ),
      builder: (context, snapshots) {
        if (snapshots.isEmpty) {
          return const EmptyTransaction();
        }
        return ListView.builder(
          itemCount: snapshots.length,
          itemBuilder: (context, index) {
            final widget = TransactionItem(
              item: snapshots[index],
            );
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: widget,
              );
            }
            return widget;
          },
        );
      },
    );
  }
}
