import 'dart:convert';
import 'dart:typed_data';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:csv/csv.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart';

import '../../../generated/r.dart';
import '../../../util/extension/extension.dart';
import '../../../util/logger.dart';
import '../buttons.dart';
import '../mixin_bottom_sheet.dart';
import '../toast.dart';
import '../transactions/transactions_filter.dart';

Future<void> showExportSnapshotsCsvBottomSheet(BuildContext context) async {
  await showMixinBottomSheet<void>(
    context: context,
    builder: (context) => const _ExportSnapshotsBottomSheet(),
  );
}

enum _DateRange {
  lastSevenDays,
  lastThirtyDays,
  lastNinetyDays,
  custom,
}

extension _DateRangeExt on _DateRange {
  DateTime get startDate {
    final now = DateTime.now();
    switch (this) {
      case _DateRange.lastSevenDays:
        return now.subtract(const Duration(days: 7));
      case _DateRange.lastThirtyDays:
        return now.subtract(const Duration(days: 30));
      case _DateRange.lastNinetyDays:
        return now.subtract(const Duration(days: 90));
      case _DateRange.custom:
        return now;
    }
  }
}

extension _DateTimeExt on DateTime {
  DateTime get startOfDay => DateTime(year, month, day);

  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);
}

class _ExportSnapshotsBottomSheet extends HookWidget {
  const _ExportSnapshotsBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filterBy = useState(FilterBy.all);
    final dateRange = useState(_DateRange.lastSevenDays);
    final customDateRange = useState<DateTimeRange?>(null);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MixinBottomSheetTitle(
          title: Text(context.l10n.exportTransactionsData),
        ),
        Row(
          children: [
            const SizedBox(width: 20),
            Text(
              context.l10n.filterBy,
              style: TextStyle(
                fontSize: 16,
                height: 1,
                color: context.colorScheme.thirdText,
              ),
            ),
            const SizedBox(width: 10),
            DropdownButton<FilterBy>(
              value: filterBy.value,
              borderRadius: BorderRadius.circular(4),
              icon: SvgPicture.asset(
                R.resourcesIcArrowDownSvg,
                width: 24,
                height: 24,
              ),
              style: TextStyle(
                color: context.colorScheme.primaryText,
                fontSize: 16,
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
              onChanged: (value) => filterBy.value = value!,
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 20),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                context.l10n.dateRange,
                style: TextStyle(
                  fontSize: 16,
                  height: 1,
                  color: context.colorScheme.thirdText,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                DropdownButton<_DateRange>(
                  value: dateRange.value,
                  borderRadius: BorderRadius.circular(4),
                  icon: SvgPicture.asset(
                    R.resourcesIcArrowDownSvg,
                    width: 24,
                    height: 24,
                  ),
                  style: TextStyle(
                    color: context.colorScheme.primaryText,
                    fontSize: 16,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: _DateRange.lastSevenDays,
                      child: Text(context.l10n.lastSevenDays),
                    ),
                    DropdownMenuItem(
                      value: _DateRange.lastThirtyDays,
                      child: Text(context.l10n.lastThirtyDays),
                    ),
                    DropdownMenuItem(
                      value: _DateRange.lastNinetyDays,
                      child: Text(context.l10n.lastNinetyDays),
                    ),
                    DropdownMenuItem(
                      value: _DateRange.custom,
                      child: Text(context.l10n.customDateRange),
                    ),
                  ],
                  onChanged: (value) async {
                    if (value == _DateRange.custom) {
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
                        ),
                        dialogSize: const Size(320, 400),
                      );
                      if (range == null || range.length < 2) {
                        return;
                      }
                      customDateRange.value = DateTimeRange(
                        start: range[0]!,
                        end: range[1]!,
                      );
                    } else {
                      customDateRange.value = null;
                    }
                    dateRange.value = value!;
                  },
                ),
                if (customDateRange.value != null)
                  Text(
                    '${DateFormat.yMMMMd().format(customDateRange.value!.start.toLocal())} - '
                    '${DateFormat.yMMMMd().format(customDateRange.value!.end.toLocal())}',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1,
                      color: context.colorScheme.primaryText,
                    ),
                  ),
              ],
            ),
          ],
        ),
        const Spacer(),
        Center(
          child: MixinPrimaryTextButton(
            text: context.l10n.export,
            onTap: () async {
              d('export filter to svg');

              final startDateTime =
                  (customDateRange.value?.start ?? dateRange.value.startDate)
                      .toLocal();
              final endDateTime =
                  (customDateRange.value?.end ?? DateTime.now()).toLocal();

              await computeWithLoading(() async {
                final snapshots = await context.mixinDatabase.snapshotDao
                    .allSnapshotsInDateTimeRange(
                  startDateTime.startOfDay,
                  endDateTime.endOfDay,
                  types: filterBy.value.snapshotTypes,
                );

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
                final fileName = 'transactions_${filterBy.value.name}_'
                    '${DateFormat('yyyy_MM_dd').format(startDateTime)}_'
                    '${DateFormat('yyyy_MM_dd').format(endDateTime)}.csv';
                await FileSaver.instance.saveFile(
                  fileName,
                  Uint8List.fromList(utf8.encode(csv)),
                  'csv',
                );
              });
            },
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
