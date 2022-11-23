import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';

import '../../util/extension/extension.dart';
import '../../util/native_scroll.dart';
import '../../util/r.dart';
import '../widget/action_button.dart';
import '../widget/buttons.dart';
import '../widget/dialog/export_snapshots_csv_bottom_sheet.dart';
import '../widget/mixin_appbar.dart';
import '../widget/transactions/transaction_list.dart';
import '../widget/transactions/transactions_filter.dart';

class AllTransactions extends HookWidget {
  const AllTransactions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filter = useState(const SnapshotFilter(SortBy.time, FilterBy.all));
    return Scaffold(
      backgroundColor: context.colorScheme.background,
      appBar: MixinAppBar(
        leading: const MixinBackButton2(),
        title: SelectableText(
          context.l10n.allTransactions,
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
            name: R.resourcesDownloadSvg,
            size: 24,
            onTap: () async {
              await showExportSnapshotsCsvBottomSheet(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterDropdownMenus(filter: filter),
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
            return const EmptyTransaction();
          }
          return NativeScrollBuilder(
            builder: (context, controller) => ListView.builder(
              controller: controller,
              itemCount: snapshots.length,
              itemBuilder: (context, index) => TransactionItem(
                item: snapshots[index],
              ),
            ),
          );
        },
      );
}

class _FilterDropdownMenus extends StatelessWidget {
  const _FilterDropdownMenus({Key? key, required this.filter})
      : super(key: key);

  final ValueNotifier<SnapshotFilter> filter;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          const SizedBox(width: 20),
          Text(
            '${context.l10n.sortBy}:',
            style: TextStyle(
              color: context.colorScheme.secondaryText,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<SortBy>(
            value: filter.value.sortBy,
            icon: SvgPicture.asset(
              R.resourcesIcArrowDownSvg,
              width: 24,
              height: 24,
            ),
            style: TextStyle(
              color: context.colorScheme.primaryText,
              fontSize: 14,
            ),
            isDense: true,
            items: [
              DropdownMenuItem(
                value: SortBy.time,
                child: Text(context.l10n.time),
              ),
              DropdownMenuItem(
                value: SortBy.amount,
                child: Text(context.l10n.amount),
              ),
            ],
            onChanged: (value) =>
                filter.value = filter.value.copyWith(sortBy: value),
          ),
          const SizedBox(width: 20),
          Text(
            '${context.l10n.filterBy}:',
            style: TextStyle(
              color: context.colorScheme.secondaryText,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<FilterBy>(
            value: filter.value.filterBy,
            icon: SvgPicture.asset(
              R.resourcesIcArrowDownSvg,
              width: 24,
              height: 24,
            ),
            style: TextStyle(
              color: context.colorScheme.primaryText,
              fontSize: 14,
            ),
            isDense: true,
            items: [
              DropdownMenuItem(
                value: FilterBy.all,
                child: Text(context.l10n.filterAll),
              ),
              DropdownMenuItem(
                value: FilterBy.transfer,
                child: Text(context.l10n.transfer),
              ),
              DropdownMenuItem(
                value: FilterBy.deposit,
                child: Text(context.l10n.deposit),
              ),
              DropdownMenuItem(
                value: FilterBy.withdrawal,
                child: Text(context.l10n.withdrawal),
              ),
              DropdownMenuItem(
                value: FilterBy.fee,
                child: Text(context.l10n.fee),
              ),
              DropdownMenuItem(
                value: FilterBy.rebate,
                child: Text(context.l10n.rebate),
              ),
              DropdownMenuItem(
                value: FilterBy.raw,
                child: Text(context.l10n.raw),
              ),
            ],
            onChanged: (value) =>
                filter.value = filter.value.copyWith(filterBy: value),
          ),
        ],
      );
}
