import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;

import '../../db/mixin_database.dart';
import '../../service/profile/profile_manager.dart';
import '../../util/constants.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/r.dart';
import '../router/mixin_routes.dart';
import '../widget/action_button.dart';
import '../widget/asset.dart';
import '../widget/asset_selection_list_widget.dart';
import '../widget/avatar.dart';
import '../widget/buttons.dart';
import '../widget/chart_assets.dart';
import '../widget/menu.dart';
import '../widget/mixin_appbar.dart';
import '../widget/mixin_bottom_sheet.dart';
import '../widget/search_asset_bottom_sheet.dart';
import '../widget/transfer.dart';

enum _AssetSortType {
  amount,
  increase,
  decrease,
}

const _kQueryParameterSort = 'sort';

class Home extends HookWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    assert(context.appServices.databaseInitialized);

    useMemoizedFuture(() => context.appServices.updateAssets());

    final sortParam =
        useQueryParameter(_kQueryParameterSort, path: homeUri.path);

    final sortType = useMemoized(
        () =>
            sdk.EnumToString.fromString(_AssetSortType.values, sortParam) ??
            _AssetSortType.amount,
        [sortParam]);

    final assetResults = useMemoizedStream(
      () => context.appServices.assetResults().watch(),
      initialData: <AssetResult>[],
    ).requireData;

    final hideSmallAssets = useValueListenable(isSmallAssetsHidden);

    final assetList = useMemoized(() {
      if (!hideSmallAssets) {
        return assetResults..sortBy(sortType);
      }
      return assetResults
          .where((element) => element.amountOfUsd >= Decimal.one)
          .toList()
        ..sortBy(sortType);
    }, [hideSmallAssets, assetResults, sortType]);

    final account = auth!.account;

    return Scaffold(
      backgroundColor: context.theme.background,
      appBar: MixinAppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: InkResponse(
              radius: 24,
              onTap: () => showMixinBottomSheet(
                context: context,
                builder: (context) => const _AccountBottomSheet(),
              ),
              child: Avatar(
                avatarUrl: account.avatarUrl,
                userId: account.userId,
                name: account.fullName ?? '',
                size: 32,
              ),
            ),
          ),
        ),
        actions: [
          ActionButton(
            name: R.resourcesSettingSvg,
            size: 24,
            onTap: () => context.push(settingPath),
          )
        ],
        backgroundColor: context.colorScheme.background,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _Header(data: assetList, sortType: sortType),
          ),
          if (assetList.isEmpty)
            const SliverFillRemaining(child: _AssetsEmptyLayout())
          else
            SliverList(
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
                            appServices.updateAssetHidden(item.assetId,
                                hidden: false);
                          },
                        ),
                      ));
                    },
                  );
                },
                childCount: assetList.length,
              ),
            ),
        ],
      ),
    );
  }
}

class _AssetHeader extends StatelessWidget {
  const _AssetHeader({
    Key? key,
    required this.sortType,
  }) : super(key: key);

  final _AssetSortType sortType;

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
              onTap: () => showMixinBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (BuildContext context) =>
                      const SearchAssetBottomSheet()),
              child: SvgPicture.asset(
                R.resourcesIcSearchSvg,
                height: 24,
                width: 24,
                color: context.colorScheme.primaryText,
              ),
            ),
            const SizedBox(width: 16),
            InkResponse(
              radius: 24,
              onTap: () {
                context.replace(homeUri.replace(queryParameters: {
                  _kQueryParameterSort:
                      sdk.EnumToString.convertToString(sortType.next)
                }));
              },
              child: SvgPicture.asset(
                R.resourcesAmplitudeSvg,
                height: 24,
                width: 24,
                color: context.colorScheme.primaryText,
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

class _Header extends HookWidget {
  const _Header({
    Key? key,
    required this.data,
    required this.sortType,
  }) : super(key: key);

  final List<AssetResult> data;

  final _AssetSortType sortType;

  @override
  Widget build(BuildContext context) {
    final balance = useMemoized(
        () => data.fold<Decimal>(
            0.0.asDecimal,
            (previousValue, AssetResult element) =>
                previousValue + element.amountOfCurrentCurrency),
        [data]);

    final balanceOfBtc = useMemoized(
        () => data
            .fold<Decimal>(0.0.asDecimal,
                (previousValue, element) => previousValue + element.amountOfBtc)
            .toString(),
        [data]);

    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                currentCurrencyNumberFormat.currencySymbol,
                style: TextStyle(
                  color: context.colorScheme.thirdText,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              balance.currencyFormatWithoutSymbol,
              style: TextStyle(
                color: context.colorScheme.primaryText,
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.balanceOfBtc(balanceOfBtc),
          style: TextStyle(
            color: context.colorScheme.thirdText,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: data.length <= 1 || balance == Decimal.zero
              ? const SizedBox()
              : Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: AssetsAnalysisChartLayout(assets: data),
                ),
        ),
        const SizedBox(height: 32),
        const _ButtonBar(),
        const SizedBox(height: 24),
        _AssetHeader(sortType: sortType),
      ],
    );
  }
}

class _ButtonBar extends StatelessWidget {
  const _ButtonBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: HeaderButtonBarLayout(
          buttons: [
            HeaderButton.text(
              text: context.l10n.send,
              onTap: () => showTransferRouterBottomSheet(context: context),
            ),
            HeaderButton.text(
              text: context.l10n.receive,
              onTap: () async {
                final asset = await showAssetSelectionBottomSheet(
                  context: context,
                  initialSelected: lastSelectedAddress,
                );
                if (asset == null) {
                  return;
                }
                lastSelectedAddress = asset.assetId;
                context.push(assetDepositPath.toUri({'id': asset.assetId}));
              },
            ),
            HeaderButton.text(
              text: context.l10n.buy,
              onTap: () {
                if (kReleaseMode) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(content: Text(context.l10n.comingSoon)),
                    );
                } else {
                  context.push(buyPath.toUri({'id': erc20USDT}));
                }
              },
            ),
            HeaderButton.text(
              text: context.l10n.swap,
              onTap: () => context.push(swapPath),
            ),
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
      background: Container(
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

class _AssetsEmptyLayout extends StatelessWidget {
  const _AssetsEmptyLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 100),
          SvgPicture.asset(
            R.resourcesEmptyTransactionGreySvg,
            width: 80,
            height: 80,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.noAsset,
            style: TextStyle(
              color: context.colorScheme.thirdText,
              fontSize: 14,
            ),
          ),
          const Spacer(flex: 164),
        ],
      );
}

extension _SortAssets on List<AssetResult> {
  void sortBy(_AssetSortType sort) {
    double _assetAmplitude(AssetResult asset) {
      final invalid = sort == _AssetSortType.increase
          ? double.negativeInfinity
          : double.infinity;
      if (asset.priceUsd.isZero) {
        return invalid;
      }
      return double.tryParse(asset.changeUsd) ?? invalid;
    }

    switch (sort) {
      case _AssetSortType.amount:
        this.sort((a, b) => b.amountOfUsd.compareTo(a.amountOfUsd));
        break;
      case _AssetSortType.decrease:
        this.sort((a, b) => _assetAmplitude(a).compareTo(_assetAmplitude(b)));
        break;
      case _AssetSortType.increase:
        this.sort((a, b) => _assetAmplitude(b).compareTo(_assetAmplitude(a)));
        break;
    }
  }
}

extension _SortTypeExt on _AssetSortType {
  String get iconAssetName {
    switch (this) {
      case _AssetSortType.amount:
        return R.resourcesAmplitudeNoneSvg;
      case _AssetSortType.increase:
        return R.resourcesAmplitudeIncreaseSvg;
      case _AssetSortType.decrease:
        return R.resourcesAmplitudeDecreaseSvg;
    }
  }

  _AssetSortType get next {
    switch (this) {
      case _AssetSortType.amount:
        return _AssetSortType.increase;
      case _AssetSortType.increase:
        return _AssetSortType.decrease;
      case _AssetSortType.decrease:
        return _AssetSortType.amount;
    }
  }
}

class _AccountBottomSheet extends StatelessWidget {
  const _AccountBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final account = auth?.account;
    // might be null when use clicked DeAuthorize button.
    if (account == null) {
      return const SizedBox();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MixinBottomSheetTitle(
          title: Avatar(
            avatarUrl: account.avatarUrl,
            userId: account.userId,
            name: account.fullName ?? '',
            size: 32,
          ),
        ),
        const SizedBox(height: 8),
        MenuItemWidget(
          topRounded: true,
          bottomRounded: true,
          title: Text(
            context.l10n.removeAuthorize,
            style: TextStyle(
              color: context.colorScheme.red,
            ),
          ),
          onTap: () async {
            await profileBox.clear();
            context.replace(authUri.path);
          },
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}
