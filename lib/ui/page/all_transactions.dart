import 'package:flutter/material.dart';

import '../../util/extension/extension.dart';
import '../../util/r.dart';
import '../widget/action_button.dart';
import '../widget/mixin_appbar.dart';
import '../widget/transactions/transaction_list.dart';

class AllTransactions extends StatelessWidget {
  const AllTransactions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: MixinAppBar(
          title: Text(
            context.l10n.allTransactions,
            style: TextStyle(
              color: context.theme.text,
            ),
          ),
          backgroundColor: context.theme.background,
          actions: [
            ActionButton(
              name: R.resourcesFilterSvg,
              size: 24,
              onTap: () {},
            )
          ],
        ),
        backgroundColor: context.theme.background,
        body: const Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: _AllTransactionsBody(),
        ),
      );
}

class _AllTransactionsBody extends StatelessWidget {
  const _AllTransactionsBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => TransactionListBuilder(
        loadMoreItemDb: (offset, limit) =>
            context.mixinDatabase.snapshotDao.allSnapshots(
          offset: offset,
          limit: limit,
          orderByAmount: false,
          types: const [],
        ).get(),
        refreshSnapshots: (offset, limit) => context.appServices
            .updateAllSnapshots(offset: offset, limit: limit),
        builder: (context, snapshots) => ListView.builder(
          itemCount: snapshots.length,
          itemBuilder: (context, index) => TransactionItem(
            item: snapshots[index],
          ),
        ),
      );
}
