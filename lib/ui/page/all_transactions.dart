import 'dart:async';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../../db/mixin_database.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/native_scroll.dart';
import '../../util/r.dart';
import '../router/mixin_routes.dart';
import '../widget/action_button.dart';
import '../widget/asset_selection_list_widget.dart';
import '../widget/buttons.dart';
import '../widget/dialog/export_snapshots_csv_bottom_sheet.dart';
import '../widget/mixin_appbar.dart';
import '../widget/mixin_bottom_sheet.dart';
import '../widget/symbol.dart';
import '../widget/text.dart';
import '../widget/transactions/transaction_list.dart';
import '../widget/transactions/transactions_filter.dart';

extension _AllTransactionsFilter on BuildContext {
  void updateFilter(TransactionFilter filter) {
    final range = filter.range.range;
    replace(transactionsUri.replace(queryParameters: {
      'filterBy': filter.filterBy.name,
      'rangeType': filter.range.type.name,
      if (filter.range.type == DateRangeType.custom) ...{
        'start': range!.start.toIso8601String(),
        'end': range.end.toIso8601String(),
      },
      if (filter.assetId != null) 'asset': filter.assetId,
    }));
  }
}

class AllTransactions extends HookWidget {
  const AllTransactions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filterBy = useQueryParameter('filterBy', path: transactionsUri.path);
    final rangeType =
        useQueryParameter('rangeType', path: transactionsUri.path);
    final start = useQueryParameter('start', path: transactionsUri.path);
    final end = useQueryParameter('end', path: transactionsUri.path);
    final assetId = useQueryParameter('asset', path: transactionsUri.path);

    final filter = useMemoized(() {
      final type =
          DateRangeType.values.byNameOrNull(rangeType) ?? DateRangeType.all;
      final DateRange range;
      switch (type) {
        case DateRangeType.all:
          range = const DateRange.all();
          break;
        case DateRangeType.lastSevenDays:
          range = const DateRange.lastSevenDays();
          break;
        case DateRangeType.lastThirtyDays:
          range = const DateRange.lastThirtyDays();
          break;
        case DateRangeType.lastNinetyDays:
          range = const DateRange.lastNinetyDays();
          break;
        case DateRangeType.custom:
          final startDate = DateTime.tryParse(start);
          final endDate = DateTime.tryParse(end);
          if (startDate != null && endDate != null) {
            range = DateRange.custom(startDate, endDate);
          } else {
            range = const DateRange.all();
          }
          break;
      }
      return TransactionFilter(
        filterBy: FilterBy.values.byNameOrNull(filterBy) ?? FilterBy.all,
        range: range,
        assetId: assetId.isEmpty ? null : assetId,
      );
    }, [filterBy, rangeType, start, end, assetId]);
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
          Expanded(child: _AllTransactionsBody(filter: filter)),
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
        loadMoreItemDb: (offset, limit) {
          final range = filter.range.range;
          return context.mixinDatabase.snapshotDao.allSnapshotsInDateTimeRange(
            offset: offset,
            limit: limit,
            types: filter.filterBy.snapshotTypes,
            assetId: filter.assetId,
            start: range?.start,
            end: range?.end,
          );
        },
        refreshSnapshots: (offset, limit) {
          if (filter.assetId != null) {
            return context.appServices.updateAssetSnapshots(
              filter.assetId!,
              limit: limit,
              offset: offset,
            );
          }
          return context.appServices
              .updateAllSnapshots(offset: offset, limit: limit);
        },
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
                onTap: () {
                  context.push(transactionsSnapshotDetailPath.toUri(
                    {'id': snapshots[index].snapshotId},
                  ));
                },
              ),
            ),
          );
        },
      );
}

class _FilterDropdownMenus extends StatelessWidget {
  const _FilterDropdownMenus({Key? key, required this.filter})
      : super(key: key);

  final TransactionFilter filter;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: double.infinity,
          minWidth: double.infinity,
        ),
        child: Wrap(
          runSpacing: 20,
          runAlignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          children: [
            _AssetsFilterWidget(filter: filter),
            _TransactionTypeFilterWidget(filter: filter),
            _DateTimeFilterWidget(filter: filter),
          ],
        ),
      );
}

class _TransactionTypeFilterWidget extends StatelessWidget {
  const _TransactionTypeFilterWidget({
    Key? key,
    required this.filter,
  }) : super(key: key);

  final TransactionFilter filter;

  @override
  Widget build(BuildContext context) => _FilterPopupMenuWidget<FilterBy>(
        itemBuilder: (context) => [
          for (final type in FilterBy.values)
            PopupMenuItem(
              value: type,
              child: Text(type.l10n(context)),
            ),
        ],
        onSelected: (filterBy) =>
            context.updateFilter(filter.copyWith(filterBy: filterBy)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${context.l10n.filterBy}:',
              style: TextStyle(
                color: context.colorScheme.secondaryText,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              filter.filterBy.l10n(context),
              style: TextStyle(
                color: context.colorScheme.primaryText,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 10),
            SvgPicture.asset(
              R.resourcesIcArrowDownSvg,
              width: 24,
              height: 24,
            ),
          ],
        ),
      );
}

enum DateRangeType {
  all,
  lastSevenDays,
  lastThirtyDays,
  lastNinetyDays,
  custom
}

extension DateRangeTypeExtension on DateRangeType {
  String l10n(BuildContext context) {
    switch (this) {
      case DateRangeType.all:
        return context.l10n.noLimit;
      case DateRangeType.lastSevenDays:
        return context.l10n.lastSevenDays;
      case DateRangeType.lastThirtyDays:
        return context.l10n.lastThirtyDays;
      case DateRangeType.lastNinetyDays:
        return context.l10n.lastNinetyDays;
      case DateRangeType.custom:
        return context.l10n.customDateRange;
    }
  }
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
    this.assetId,
  });

  final FilterBy filterBy;
  final DateRange range;
  final String? assetId;

  @override
  List<Object?> get props => [filterBy, range, assetId];

  TransactionFilter copyWith({
    FilterBy? filterBy,
    DateRange? range,
    String? assetId,
  }) =>
      TransactionFilter(
        filterBy: filterBy ?? this.filterBy,
        range: range ?? this.range,
        assetId: assetId ?? this.assetId,
      );

  TransactionFilter removeAsset() =>
      TransactionFilter(filterBy: filterBy, range: range);
}

class _DateTimeFilterWidget extends StatelessWidget {
  const _DateTimeFilterWidget({
    Key? key,
    required this.filter,
  }) : super(key: key);
  final TransactionFilter filter;

  @override
  Widget build(BuildContext context) {
    final dateRange = filter.range;
    return _FilterPopupMenuWidget<DateRangeType>(
      itemBuilder: (BuildContext context) => [
        for (final type in DateRangeType.values)
          PopupMenuItem(
            value: type,
            child: Text(type.l10n(context)),
          ),
      ],
      onSelected: (item) async {
        switch (item) {
          case DateRangeType.all:
            context.updateFilter(
              filter.copyWith(range: const DateRange.all()),
            );
            break;
          case DateRangeType.lastSevenDays:
            context.updateFilter(
              filter.copyWith(range: const DateRange.lastSevenDays()),
            );
            break;
          case DateRangeType.lastThirtyDays:
            context.updateFilter(
              filter.copyWith(range: const DateRange.lastThirtyDays()),
            );
            break;
          case DateRangeType.lastNinetyDays:
            context.updateFilter(
              filter.copyWith(range: const DateRange.lastNinetyDays()),
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
            context.updateFilter(
              filter.copyWith(range: DateRange.custom(range[0]!, range[1]!)),
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
            MixinText(
              context.l10n.date,
              style: TextStyle(
                color: context.colorScheme.thirdText,
              ),
            ),
            const SizedBox(width: 10),
            if (dateRange.type == DateRangeType.custom)
              MixinText(
                '${DateFormat.yMMMMd().format(dateRange.range!.start.toLocal())} - '
                '${DateFormat.yMMMMd().format(dateRange.range!.end.toLocal())}',
              )
            else
              MixinText(dateRange.type.l10n(context)),
            const SizedBox(width: 10),
            SvgPicture.asset(
              R.resourcesIcArrowDownSvg,
              width: 24,
              height: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _AssetsFilterWidget extends HookWidget {
  const _AssetsFilterWidget({
    Key? key,
    required this.filter,
  }) : super(key: key);

  final TransactionFilter filter;

  @override
  Widget build(BuildContext context) {
    final asset = useMemoizedFuture(
      () async {
        if (filter.assetId == null) {
          return null;
        }
        return context.appServices.findOrSyncAsset(filter.assetId!);
      },
      keys: [filter.assetId],
    ).data;

    Future<void> handleSelection() async {
      const itemNullChoose = Object();

      final selected = await showMixinBottomSheet<dynamic>(
        context: context,
        isScrollControlled: true,
        builder: (context) => AssetSelectionListWidget(
          selectedAssetId: filter.assetId,
          hasNullChoose: true,
          onTap: (asset) {
            if (asset == null) {
              Navigator.pop(context, itemNullChoose);
              return;
            }
            Navigator.pop(context, asset.assetId);
          },
          onCancelPressed: () => Navigator.pop(context),
        ),
      );
      if (selected == null) {
        return;
      }
      if (selected == itemNullChoose) {
        context.updateFilter(filter.removeAsset());
      } else {
        assert(selected is String, 'selected is $selected');
        context.updateFilter(filter.copyWith(assetId: selected as String));
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
          if (asset == null)
            _NoAssetFilterWidget(onTap: handleSelection)
          else
            _AssetItemWidget(
              asset: asset,
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
    required this.onTap,
  }) : super(key: key);

  final AssetResult asset;

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
          )
        ],
      );
}

class _FilterPopupMenuWidget<T> extends HookWidget {
  const _FilterPopupMenuWidget({
    Key? key,
    required this.itemBuilder,
    required this.child,
    this.onCanceled,
    this.onSelected,
  }) : super(key: key);

  final PopupMenuItemBuilder<T> itemBuilder;

  final Widget child;

  final PopupMenuCanceled? onCanceled;

  final PopupMenuItemSelected<T>? onSelected;

  @override
  Widget build(BuildContext context) {
    final isMounted = useIsMounted();
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        const padding = EdgeInsets.all(8.0);
        final popupMenuTheme = PopupMenuTheme.of(context);
        final button = context.findRenderObject()! as RenderBox;
        final overlay = Navigator.of(context)
            .overlay!
            .context
            .findRenderObject()! as RenderBox;
        final offset = Offset(0.0, button.size.height - (padding.vertical / 2));
        final position = RelativeRect.fromRect(
          Rect.fromPoints(
            button.localToGlobal(offset, ancestor: overlay),
            button.localToGlobal(button.size.bottomRight(Offset.zero) + offset,
                ancestor: overlay),
          ),
          Offset.zero & overlay.size,
        );
        final item = await showMenu<T?>(
          context: context,
          elevation: popupMenuTheme.elevation,
          items: itemBuilder(context),
          position: position,
          shape: popupMenuTheme.shape,
          color: popupMenuTheme.color,
        );
        if (!isMounted()) {
          return;
        }
        if (item == null) {
          onCanceled?.call();
          return;
        }
        onSelected?.call(item);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: child,
      ),
    );
  }
}
