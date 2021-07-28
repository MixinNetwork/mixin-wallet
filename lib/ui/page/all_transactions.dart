import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../util/extension/extension.dart';
import '../../util/r.dart';
import '../widget/action_button.dart';
import '../widget/mixin_appbar.dart';
import '../widget/transactions/transaction_list.dart';
import '../widget/transactions/transactions_filter.dart';

class AllTransactions extends HookWidget {
  const AllTransactions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filter = useState(const SnapshotFilter(SortBy.time, FilterBy.all));
    return Scaffold(
      appBar: MixinAppBar(
        title: Text(
          context.l10n.allTransactions,
        ),
        backButtonColor: Colors.white,
        actions: [
          ActionButton(
            name: R.resourcesFilterWhiteSvg,
            size: 24,
            onTap: () async {
              final selection = await showFilterBottomSheetDialog(
                context,
                initial: filter.value,
              );
              if (selection == null) {
                return;
              }
              filter.value = selection;
            },
          )
        ],
      ),
      backgroundColor: context.theme.background,
      body: Column(
        children: [
          const ListRoundedHeaderContainer(height: 18),
          Expanded(child: _AllTransactionsBody(filter: filter.value)),
        ],
      ),
    );
  }
}

class _AllTransactionsBody extends StatelessWidget {
  const _AllTransactionsBody({
    Key? key,
    required this.filter,
  }) : super(key: key);

  final SnapshotFilter filter;

  @override
  Widget build(BuildContext context) => TransactionListBuilder(
        key: ValueKey(filter),
        loadMoreItemDb: (offset, limit) => context.mixinDatabase.snapshotDao
            .allSnapshots(
                offset: offset,
                limit: limit,
                orderByAmount: filter.sortBy == SortBy.amount,
                types: filter.filterBy.snapshotTypes)
            .get(),
        refreshSnapshots: (offset, limit) => context.appServices
            .updateAllSnapshots(offset: offset, limit: limit),
        builder: (context, snapshots) {
          if (snapshots.isEmpty) {
            return const Center(
              child: EmptyTransaction(),
            );
          }
          return ListView.builder(
            itemCount: snapshots.length,
            itemBuilder: (context, index) => TransactionItem(
              item: snapshots[index],
            ),
          );
        },
      );
}
