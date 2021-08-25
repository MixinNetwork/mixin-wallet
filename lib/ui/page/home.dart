import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../db/mixin_database.dart';
import '../../service/profile/profile_manager.dart';
import '../../util/constants.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/r.dart';
import '../router/mixin_routes.dart';
import '../widget/action_button.dart';
import '../widget/asset.dart';
import '../widget/chart_assets.dart';
import '../widget/mixin_appbar.dart';
import '../widget/mixin_bottom_sheet.dart';
import '../widget/search_asset_bottom_sheet.dart';
import '../widget/transfer.dart';

class Home extends HookWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    assert(context.appServices.databaseInitialized);

    useMemoizedFuture(() => context.appServices.updateAssets());

    final assetResults = useMemoizedStream(
      () => context.appServices.assetResults().watch().map((event) => event
        ..sort(
          (a, b) => b.amountOfUsd.compareTo(a.amountOfUsd),
        )),
      initialData: <AssetResult>[],
    ).requireData;

    final hideSmallAssets = useValueListenable(isSmallAssetsHidden);

    final assetList = useMemoized(() {
      if (!hideSmallAssets) {
        return assetResults;
      }
      return assetResults
          .where((element) => element.amountOfUsd >= Decimal.one)
          .toList();
    }, [hideSmallAssets, assetResults]);

    return Scaffold(
      backgroundColor: context.theme.background,
      appBar: MixinAppBar(
        leading: Center(
          child: Image.asset(
            R.resourcesMixinLogoPng,
            width: 32,
            height: 32,
          ),
        ),
        title: Text(
          context.l10n.mixinWallet,
          style: TextStyle(
            color: context.colorScheme.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
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
            child: _Header(data: assetList),
          ),
          const SliverToBoxAdapter(
            child: _AssetHeader(),
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
                      context.appServices
                          .updateAssetHidden(item.assetId, hidden: true);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(context.l10n.alreadyHidden(item.name)),
                        action: SnackBarAction(
                          label: context.l10n.undo,
                          onPressed: () {
                            context.appServices
                                .updateAssetHidden(item.assetId, hidden: false);
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
  }) : super(key: key);

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
            // TODO sort
            const SizedBox(width: 16),
          ],
        ),
      );
}

class _Header extends HookWidget {
  const _Header({
    Key? key,
    required this.data,
  }) : super(key: key);

  final List<AssetResult> data;

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
              padding: const EdgeInsets.only(top: 12),
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
          context.l10n.approxBalanceOfBtc(balanceOfBtc),
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
      ],
    );
  }
}

class _ButtonBar extends StatelessWidget {
  const _ButtonBar({Key? key}) : super(key: key);

  Widget _divider(BuildContext context) => Container(
        width: 2,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(1),
        ),
      );

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Material(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 40,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _Button(
                    child: Text(context.l10n.send),
                    onTap: () =>
                        showTransferRouterBottomSheet(context: context),
                  ),
                ),
                _divider(context),
                Expanded(
                  child: _Button(
                    child: Text(context.l10n.receive),
                    onTap: () =>
                        context.push(assetDepositPath.toUri({'id': bitcoin})),
                  ),
                ),
                _divider(context),
                Expanded(
                  child: _Button(
                    child: Text(context.l10n.buy),
                    onTap: () {},
                  ),
                ),
                _divider(context),
                Expanded(
                  child: _Button(
                    child: Text(context.l10n.swap),
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _Button extends HookWidget {
  const _Button({
    Key? key,
    required this.child,
    required this.onTap,
  }) : super(key: key);

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final animator = useAnimationController(
      duration: const Duration(milliseconds: 150),
      initialValue: 1,
      lowerBound: 0.3,
      upperBound: 1,
    );
    useAnimation(animator);
    return GestureDetector(
      onTap: onTap,
      onTapDown: (_) => animator.reverse(),
      onTapUp: (_) => animator.forward(),
      onTapCancel: animator.forward,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: DefaultTextStyle(
          style: TextStyle(
            color: context.colorScheme.primaryText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          child: Opacity(
            opacity: animator.value,
            child: child,
          ),
        ),
      ),
    );
  }
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
