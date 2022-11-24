import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../../db/mixin_database.dart';
import '../../util/extension/extension.dart';
import '../../util/native_scroll.dart';
import '../../util/r.dart';
import '../widget/action_button.dart';
import '../widget/asset_selection_list_widget.dart';
import '../widget/buttons.dart';
import '../widget/dialog/export_snapshots_csv_bottom_sheet.dart';
import '../widget/mixin_appbar.dart';
import '../widget/symbol.dart';
import '../widget/text.dart';
import '../widget/transactions/transaction_list.dart';
import '../widget/transactions/transactions_filter.dart';

class AllTransactions extends HookWidget {
  const AllTransactions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filter = useState(const TransactionFilter(
      filterBy: FilterBy.all,
      range: DateRange.all(),
    ));
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

  final TransactionFilter filter;

  @override
  Widget build(BuildContext context) => TransactionListBuilder(
        key: ValueKey(filter),
        loadMoreItemDb: (offset, limit) => context.mixinDatabase.snapshotDao
            .allSnapshots(
                offset: offset,
                limit: limit,
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

  final ValueNotifier<TransactionFilter> filter;

  @override
  Widget build(BuildContext context) => Wrap(
        children: [
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
          _DateTimeFilterWidget(filter: filter),
          _AssetsFilterWidget(filter: filter),
        ],
      );
}

enum DateRangeType {
  all,
  lastSevenDays,
  lastThirtyDays,
  lastNinetyDays,
  custom,
}

class DateRange with EquatableMixin {
  const DateRange._private(this.type);

  const DateRange.lastSevenDays() : this._private(DateRangeType.lastSevenDays);

  const DateRange.lastThirtyDays()
      : this._private(DateRangeType.lastThirtyDays);

  const DateRange.lastNinetyDays()
      : this._private(DateRangeType.lastNinetyDays);

  const DateRange.all() : this._private(DateRangeType.all);

  factory DateRange.custom(DateTime start, DateTime end) =>
      _CustomDateRange(DateTimeRange(start: start, end: end));

  final DateRangeType type;

  DateTimeRange? get range {
    switch (type) {
      case DateRangeType.all:
        return null;
      case DateRangeType.lastSevenDays:
        return DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 7)),
          end: DateTime.now(),
        );
      case DateRangeType.lastThirtyDays:
        return DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 30)),
          end: DateTime.now(),
        );
      case DateRangeType.lastNinetyDays:
        return DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 90)),
          end: DateTime.now(),
        );
      case DateRangeType.custom:
        throw UnimplementedError();
    }
  }

  @override
  List<Object?> get props => [type];
}

class _CustomDateRange extends DateRange {
  _CustomDateRange(this.range) : super._private(DateRangeType.custom);

  @override
  final DateTimeRange? range;

  @override
  List<Object?> get props => [range];
}

class TransactionFilter extends Equatable {
  const TransactionFilter({
    required this.filterBy,
    required this.range,
    this.asset,
  });

  final FilterBy filterBy;
  final DateRange range;
  final AssetResult? asset;

  @override
  List<Object?> get props => [filterBy, range, asset];

  TransactionFilter copyWith({
    FilterBy? filterBy,
    DateRange? range,
    AssetResult? asset,
  }) =>
      TransactionFilter(
        filterBy: filterBy ?? this.filterBy,
        range: range ?? this.range,
        asset: asset ?? this.asset,
      );

  TransactionFilter removeAsset() =>
      TransactionFilter(filterBy: filterBy, range: range);
}

class _DateTimeFilterWidget extends StatelessWidget {
  const _DateTimeFilterWidget({
    Key? key,
    required this.filter,
  }) : super(key: key);
  final ValueNotifier<TransactionFilter> filter;

  @override
  Widget build(BuildContext context) {
    final dateRange = filter.value.range;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: PopupMenuButton<DateRangeType>(
        position: PopupMenuPosition.under,
        itemBuilder: (BuildContext context) => [
          PopupMenuItem(
            value: DateRangeType.all,
            child: MixinText(context.l10n.noLimit),
          ),
          PopupMenuItem(
            value: DateRangeType.lastSevenDays,
            child: MixinText(context.l10n.lastSevenDays),
          ),
          PopupMenuItem(
            value: DateRangeType.lastThirtyDays,
            child: MixinText(context.l10n.lastThirtyDays),
          ),
          PopupMenuItem(
            value: DateRangeType.lastNinetyDays,
            child: MixinText(context.l10n.lastNinetyDays),
          ),
          PopupMenuItem(
            value: DateRangeType.custom,
            child: MixinText(context.l10n.customDateRange),
          ),
        ],
        onSelected: (item) async {
          switch (item) {
            case DateRangeType.all:
              filter.value = filter.value.copyWith(
                range: const DateRange.all(),
              );
              break;
            case DateRangeType.lastSevenDays:
              filter.value = filter.value.copyWith(
                range: const DateRange.lastSevenDays(),
              );
              break;
            case DateRangeType.lastThirtyDays:
              filter.value = filter.value.copyWith(
                range: const DateRange.lastThirtyDays(),
              );
              break;
            case DateRangeType.lastNinetyDays:
              filter.value = filter.value.copyWith(
                range: const DateRange.lastNinetyDays(),
              );
              break;
            case DateRangeType.custom:
              final range = await showCalendarDatePicker2Dialog(
                context: context,
                config: CalendarDatePicker2WithActionButtonsConfig(
                  firstDate: DateTime(2016),
                  lastDate: DateTime.now(),
                  calendarType: CalendarDatePicker2Type.range,
                  selectedDayHighlightColor: context.colorScheme.accent,
                  lastMonthIcon: SvgPicture.asset(
                    R.resourcesBackBlackSvg,
                    width: 24,
                    height: 24,
                  ),
                  nextMonthIcon: RotatedBox(
                    quarterTurns: 2,
                    child: SvgPicture.asset(
                      R.resourcesBackBlackSvg,
                      width: 24,
                      height: 24,
                    ),
                  ),
                  toggleIcon: SvgPicture.asset(
                    R.resourcesIcArrowDownSvg,
                    width: 24,
                    height: 24,
                  ),
                  okButton: MixinText(
                    context.l10n.confirm,
                    style: TextStyle(
                      color: context.colorScheme.accent,
                    ),
                  ),
                  cancelButton: MixinText(
                    context.l10n.cancel,
                    style: TextStyle(
                      color: context.colorScheme.secondaryText,
                    ),
                  ),
                ),
                dialogSize: const Size(320, 400),
              );
              if (range == null || range.length < 2) {
                return;
              }
              filter.value = filter.value.copyWith(
                range: DateRange.custom(range[0]!, range[1]!),
              );
              break;
          }
        },
        child: DefaultTextStyle.merge(
          style: TextStyle(
            fontSize: 16,
            color: context.colorScheme.primaryText,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 20),
              MixinText(
                context.l10n.date,
                style: TextStyle(
                  color: context.colorScheme.thirdText,
                ),
              ),
              const SizedBox(width: 10),
              if (dateRange.type == DateRangeType.all)
                MixinText(context.l10n.noLimit)
              else if (dateRange.type == DateRangeType.custom)
                MixinText(
                  '${DateFormat.yMMMMd().format(dateRange.range!.start.toLocal())} - '
                  '${DateFormat.yMMMMd().format(dateRange.range!.end.toLocal())}',
                )
              else if (dateRange.type == DateRangeType.lastSevenDays)
                MixinText(context.l10n.lastSevenDays)
              else if (dateRange.type == DateRangeType.lastThirtyDays)
                MixinText(context.l10n.lastThirtyDays)
              else if (dateRange.type == DateRangeType.lastNinetyDays)
                MixinText(context.l10n.lastNinetyDays),
              const SizedBox(width: 10),
              SvgPicture.asset(
                R.resourcesIcArrowDownSvg,
                width: 24,
                height: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssetsFilterWidget extends StatelessWidget {
  const _AssetsFilterWidget({Key? key, required this.filter}) : super(key: key);

  final ValueNotifier<TransactionFilter> filter;

  @override
  Widget build(BuildContext context) {
    final assetItem = filter.value.asset;

    Future<void> handleSelection() async {
      final selected = await showAssetSelectionBottomSheet(
        context: context,
        initialSelected: assetItem?.assetId,
      );
      if (selected == null) {
        return;
      }
      filter.value = filter.value.copyWith(
        asset: selected,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 20),
          MixinText(
            context.l10n.assets,
            style: TextStyle(
              fontSize: 16,
              color: context.colorScheme.thirdText,
            ),
          ),
          const SizedBox(width: 10),
          if (assetItem == null)
            _NoAssetFilterWidget(onTap: handleSelection)
          else
            _AssetItemWidget(
              asset: assetItem,
              onClear: () {
                filter.value = filter.value.removeAsset();
              },
              onTap: handleSelection,
            ),
        ],
      ),
    );
  }
}

class _NoAssetFilterWidget extends StatelessWidget {
  const _NoAssetFilterWidget({Key? key, required this.onTap}) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              MixinText(
                context.l10n.allAssets,
                style: TextStyle(
                  fontSize: 16,
                  color: context.colorScheme.primaryText,
                ),
              ),
              const SizedBox(width: 4),
              SvgPicture.asset(R.resourcesIcArrowDownSvg),
            ],
          ),
        ),
      );
}

class _AssetItemWidget extends StatelessWidget {
  const _AssetItemWidget({
    Key? key,
    required this.asset,
    required this.onClear,
    required this.onTap,
  }) : super(key: key);

  final AssetResult asset;

  final VoidCallback onClear;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  SymbolIconWithBorder(
                    symbolUrl: asset.iconUrl,
                    chainUrl: asset.chainIconUrl,
                    size: 24,
                    chainSize: 10,
                  ),
                  const SizedBox(width: 10),
                  MixinText(
                    asset.name,
                    style: TextStyle(
                      color: context.colorScheme.primaryText,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 4),
                  SvgPicture.asset(R.resourcesIcArrowDownSvg),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          ActionButton(
            name: R.resourcesCloseSvg,
            onTap: onClear,
          ),
        ],
      );
}
