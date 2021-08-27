import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart';

import '../../../util/extension/extension.dart';
import '../filters.dart';
import '../mixin_bottom_sheet.dart';

Future<SnapshotFilter?> showFilterBottomSheetDialog(
  BuildContext context, {
  required SnapshotFilter initial,
}) =>
    showMixinBottomSheet<SnapshotFilter>(
      context: context,
      builder: (context) => _FilterBottomSheetDialog(initial),
      isScrollControlled: true,
    );

enum SortBy { time, amount }
enum FilterBy { all, transfer, deposit, withdrawal, fee, rebate, raw }

extension FilterBySnapshots on FilterBy {
  List<String> get snapshotTypes {
    switch (this) {
      case FilterBy.all:
        return const [];
      case FilterBy.transfer:
        return const [SnapshotType.transfer, SnapshotType.pending];
      case FilterBy.deposit:
        return const [SnapshotType.deposit];
      case FilterBy.withdrawal:
        return const [SnapshotType.withdrawal];
      case FilterBy.fee:
        return const [SnapshotType.fee];
      case FilterBy.rebate:
        return const [SnapshotType.rebate];
      case FilterBy.raw:
        return const [SnapshotType.raw];
    }
  }
}

class SnapshotFilter extends Equatable {
  const SnapshotFilter(this.sortBy, this.filterBy);

  final SortBy sortBy;
  final FilterBy filterBy;

  @override
  List<Object?> get props => [sortBy, filterBy];
}

class _FilterBottomSheetDialog extends HookWidget {
  const _FilterBottomSheetDialog(this.initialFilter, {Key? key})
      : super(key: key);

  final SnapshotFilter initialFilter;

  @override
  Widget build(BuildContext context) {
    final sortBy = useState(initialFilter.sortBy);
    final filterBy = useState(initialFilter.filterBy);
    return SingleChildScrollView(
      child: SizedBox(
        height: math.max(
          MediaQuery.of(context).size.height - 251,
          521,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MixinBottomSheetTitle(
                title: Text(context.l10n.filterTitle),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 10),
              _FilterSectionTitle(context.l10n.sortBy),
              const SizedBox(height: 20),
              _SortBySection(sortBy),
              const SizedBox(height: 30),
              _FilterSectionTitle(context.l10n.filterBy),
              const SizedBox(height: 20),
              _FilterBySection(filterBy),
              const Spacer(),
              Center(
                child: _Button(
                  text: Text(context.l10n.filterApply),
                  onTap: () {
                    Navigator.pop(
                        context,
                        SnapshotFilter(
                          sortBy.value,
                          filterBy.value,
                        ));
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterSectionTitle extends StatelessWidget {
  const _FilterSectionTitle(this.title, {Key? key}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF222222),
        ),
      );
}

class _SortBySection extends StatelessWidget {
  const _SortBySection(this.sortValue, {Key? key}) : super(key: key);

  final ValueNotifier<SortBy> sortValue;

  @override
  Widget build(BuildContext context) {
    void onChanged(SortBy value) => sortValue.value = value;
    return Wrap(
      direction: Axis.horizontal,
      runSpacing: 12,
      spacing: 20,
      children: [
        FilterWidget(
          value: SortBy.time,
          groupValue: sortValue.value,
          onChanged: onChanged,
          child: Text(context.l10n.time),
        ),
        FilterWidget(
          value: SortBy.amount,
          groupValue: sortValue.value,
          onChanged: onChanged,
          child: Text(context.l10n.amount),
        ),
      ],
    );
  }
}

class _FilterBySection extends StatelessWidget {
  const _FilterBySection(this.filterValue, {Key? key}) : super(key: key);

  final ValueNotifier<FilterBy> filterValue;

  @override
  Widget build(BuildContext context) {
    void onChanged(FilterBy value) => filterValue.value = value;
    return DefaultTextStyle(
      style: const TextStyle(fontSize: 16, color: Color(0xFF222222)),
      child: Wrap(
        direction: Axis.horizontal,
        runSpacing: 20,
        spacing: 20,
        children: [
          FilterWidget(
            value: FilterBy.all,
            groupValue: filterValue.value,
            onChanged: onChanged,
            child: Text(context.l10n.filterAll),
          ),
          FilterWidget(
            value: FilterBy.transfer,
            groupValue: filterValue.value,
            onChanged: onChanged,
            child: Text(context.l10n.transfer),
          ),
          FilterWidget(
            value: FilterBy.deposit,
            groupValue: filterValue.value,
            onChanged: onChanged,
            child: Text(context.l10n.deposit),
          ),
          FilterWidget(
            value: FilterBy.withdrawal,
            groupValue: filterValue.value,
            onChanged: onChanged,
            child: Text(context.l10n.withdrawal),
          ),
          FilterWidget(
            value: FilterBy.fee,
            groupValue: filterValue.value,
            onChanged: onChanged,
            child: Text(context.l10n.fee),
          ),
          FilterWidget(
            value: FilterBy.rebate,
            groupValue: filterValue.value,
            onChanged: onChanged,
            child: Text(context.l10n.rebate),
          ),
          FilterWidget(
            value: FilterBy.raw,
            groupValue: filterValue.value,
            onChanged: onChanged,
            child: Text(context.l10n.raw),
          ),
        ],
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    Key? key,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  final Widget text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: context.colorScheme.primaryText,
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 24,
            ),
            minimumSize: const Size(110, 48),
            onPrimary: context.colorScheme.background,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50))),
        onPressed: onTap,
        child: DefaultTextStyle(
          style: TextStyle(
            color: context.colorScheme.background,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          child: text,
        ),
      );
}
