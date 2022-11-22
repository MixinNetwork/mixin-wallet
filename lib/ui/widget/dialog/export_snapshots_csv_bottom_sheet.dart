import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../generated/r.dart';
import '../../../util/extension/extension.dart';
import '../buttons.dart';
import '../mixin_bottom_sheet.dart';
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
            onTap: () {},
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
