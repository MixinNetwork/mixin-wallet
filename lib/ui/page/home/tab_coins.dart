import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../db/mixin_database.dart';
import '../../../util/extension/extension.dart';
import '../../../util/r.dart';
import '../../route.dart';
import '../../widget/asset.dart';
import '../../widget/mixin_bottom_sheet.dart';
import '../../widget/search_asset_bottom_sheet.dart';
import 'empty.dart';

enum AssetSortType {
  amount,
  increase,
  decrease,
}

class CoinsSliverList extends StatelessWidget {
  const CoinsSliverList({
    required this.assetList,
    super.key,
  });

  final List<AssetResult> assetList;

  @override
  Widget build(BuildContext context) {
    if (assetList.isEmpty) {
      return SliverFillRemaining(
        child: EmptyLayout(content: context.l10n.noAsset),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final item = assetList[index];
          return _SwipeToHide(
            key: ValueKey(item.assetId),
            child: AssetWidget(data: item),
            onDismiss: () {
              final appServices = context.appServices
                ..updateAssetHidden(item.assetId, hidden: true);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(context.l10n.alreadyHidden(item.name)),
                action: SnackBarAction(
                  label: context.l10n.undo,
                  onPressed: () {
                    appServices.updateAssetHidden(item.assetId, hidden: false);
                  },
                ),
              ));
            },
          );
        },
        childCount: assetList.length,
      ),
    );
  }
}

class AssetHeader extends StatelessWidget {
  const AssetHeader({
    required this.sortType,
    super.key,
  });

  final AssetSortType sortType;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 40,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 16),
            Text(
              context.l10n.assets,
              style: TextStyle(
                color: context.colorScheme.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            InkResponse(
              radius: 24,
              onTap: () => showMixinBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (BuildContext context) =>
                      const SearchAssetBottomSheet()),
              child: SvgPicture.asset(
                R.resourcesIcSearchSvg,
                height: 24,
                width: 24,
                colorFilter: ColorFilter.mode(
                  context.colorScheme.primaryText,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 16),
            InkResponse(
              radius: 24,
              onTap: () {
                // TODO
                HomeRoute(sort: sortType.next.name).go(context);
              },
              child: SvgPicture.asset(
                R.resourcesAmplitudeSvg,
                height: 24,
                width: 24,
                colorFilter: ColorFilter.mode(
                  context.colorScheme.primaryText,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 2),
            SizedBox(
              width: 6,
              height: 10,
              child: SvgPicture.asset(sortType.iconAssetName),
            ),
            const SizedBox(width: 16),
          ],
        ),
      );
}

class _SwipeToHide extends StatelessWidget {
  const _SwipeToHide({
    required Key key,
    required this.child,
    required this.onDismiss,
  }) : super(key: key);

  final Widget child;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final Widget indicator = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Text(
        context.l10n.hide,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
    return Dismissible(
      key: ValueKey(key),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => onDismiss(),
      background: ColoredBox(
        color: context.colorScheme.red,
        child: Align(
          alignment: Alignment.centerRight,
          child: indicator,
        ),
      ),
      child: child,
    );
  }
}

extension SortTypeExt on AssetSortType {
  String get iconAssetName {
    switch (this) {
      case AssetSortType.amount:
        return R.resourcesAmplitudeNoneSvg;
      case AssetSortType.increase:
        return R.resourcesAmplitudeIncreaseSvg;
      case AssetSortType.decrease:
        return R.resourcesAmplitudeDecreaseSvg;
    }
  }

  AssetSortType get next {
    switch (this) {
      case AssetSortType.amount:
        return AssetSortType.increase;
      case AssetSortType.increase:
        return AssetSortType.decrease;
      case AssetSortType.decrease:
        return AssetSortType.amount;
    }
  }
}
