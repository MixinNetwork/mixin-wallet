import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../util/extension/extension.dart';
import '../widget/buttons.dart';
import '../widget/mixin_appbar.dart';
import '../widget/transactions/transaction_list.dart';

class TransferTransactions extends StatelessWidget {
  const TransferTransactions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.colorScheme.background,
        appBar: MixinAppBar(
          leading: const MixinBackButton2(),
          title: Text(
            context.l10n.transactions,
            style: TextStyle(
              color: context.colorScheme.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: context.colorScheme.background,
        ),
        body: _Body(
          assetId: context.pathParameters['id']!,
          opponent: context.queryParameters['opponent'],
        ),
      );
}

class _Body extends StatelessWidget {
  const _Body({Key? key, required this.assetId, required this.opponent})
      : super(key: key);

  final String assetId;

  final String? opponent;

  @override
  Widget build(BuildContext context) {
    if (opponent == null) {
      return const EmptyTransaction();
    }
    return TransactionListBuilder(
      loadMoreItemDb: (offset, limit) => context.mixinDatabase.snapshotDao
          .snapshots(assetId, offset: offset, limit: limit, opponent: opponent)
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
