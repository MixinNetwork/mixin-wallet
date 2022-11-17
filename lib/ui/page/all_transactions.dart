import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart';

import '../../util/extension/extension.dart';
import '../../util/logger.dart';
import '../../util/native_scroll.dart';
import '../../util/r.dart';
import '../widget/action_button.dart';
import '../widget/buttons.dart';
import '../widget/mixin_appbar.dart';
import '../widget/toast.dart';
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
            name: R.resourcesFilterSvg,
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
  Widget build(BuildContext context) => Wrap(
        alignment: WrapAlignment.start,
        children: [
          DropdownButton<SortBy>(
            value: filter.value.sortBy,
            iconSize: 30,
            icon: SvgPicture.asset(
              R.resourcesIcArrowDownSvg,
              color: context.colorScheme.primaryText,
            ),
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
          DropdownButton<FilterBy>(
            value: filter.value.filterBy,
            icon: SvgPicture.asset(
              R.resourcesIcArrowDownSvg,
              color: context.colorScheme.primaryText,
            ),
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
          ActionButton(
            name: R.resourcesDownloadSvg,
            size: 24,
            onTap: () async {
              d('export filter to svg');
              await computeWithLoading(() async {
                final snapshots = await context.mixinDatabase.snapshotDao
                    .allSnapshots(
                      orderByAmount: filter.value.sortBy == SortBy.amount,
                      types: filter.value.filterBy.snapshotTypes,
                      limit: null,
                    )
                    .get();

                if (snapshots.isEmpty) {
                  showErrorToast(context.l10n.noTransaction);
                  return;
                }

                final header = [
                  'asset',
                  'snapshotId',
                  'type',
                  'amount',
                  'confirmation',
                  'date',
                  'memo',
                  'traceId',
                  'state',
                  'snapshotHash',
                ];

                final table = [
                  header,
                  ...snapshots.map((e) => [
                        e.assetSymbol,
                        e.snapshotId,
                        e.type,
                        '${e.isPositive ? '+' : ''}${e.amount}',
                        if (e.type == SnapshotType.pending)
                          '${e.confirmations ?? 0}/${e.assetConfirmations ?? 0}'
                        else
                          '',
                        e.createdAt.toIso8601String(),
                        e.memo,
                        e.traceId ?? '',
                        e.state ?? '',
                        e.snapshotHash ?? '',
                      ]),
                ];
                final csv = const ListToCsvConverter().convert(table);
                final fileName =
                    'transactions_${filter.value.sortBy.name}_${filter.value.filterBy.name}.csv';
                await FileSaver.instance.saveFile(
                  fileName,
                  Uint8List.fromList(utf8.encode(csv)),
                  'csv',
                );
              });
            },
          ),
        ],
      );
}
