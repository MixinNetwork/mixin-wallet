import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../db/mixin_database.dart';
import '../../db/web/construct_db.dart';
import '../../service/profile/profile_manager.dart';
import '../../util/constants.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/native_scroll.dart';
import '../../util/r.dart';
import '../router/mixin_routes.dart';
import '../widget/action_button.dart';
import '../widget/avatar.dart';
import '../widget/menu.dart';
import '../widget/mixin_appbar.dart';
import '../widget/mixin_bottom_sheet.dart';
import 'home/header.dart';
import 'home/tab_coins.dart';
import 'home/tab_collectibles.dart';

// sort type for coins.
const kQueryParameterSort = 'sort';

// the selected tab.
const kQueryParameterTab = 'tab';

enum _Tab {
  coins,
  collectibles,
}

class Home extends HookWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // assert(context.appServices.databaseInitialized);

    useMemoizedFuture(() => context.appServices.updateAssets());

    final sortParam =
        useQueryParameter(kQueryParameterSort, path: homeUri.path);

    final sortType = useMemoized(
        () =>
            AssetSortType.values.byNameOrNull(sortParam) ??
            AssetSortType.amount,
        [sortParam]);

    final assetResults = useMemoizedStream(
      () => context.appServices.assetResultsNotHidden().watch(),
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

    final bitcoinAsset = useMemoizedFuture(() async {
      var target = assetList.firstWhereOrNull((e) => e?.assetId == bitcoin);
      return target ??= await context.appServices.findOrSyncAsset(bitcoin);
    }, keys: [assetResults]).data;

    final tabParam = useQueryParameter(kQueryParameterTab, path: homeUri.path);
    final selectedTab = _Tab.values.byNameOrNull(tabParam) ?? _Tab.coins;
    return Scaffold(
      backgroundColor: context.theme.background,
      appBar: const _HomeAppBar(),
      body: NativeScrollBuilder(
        builder: (context, controller) => CustomScrollView(
          controller: controller,
          slivers: [
            SliverToBoxAdapter(
              child: Header(data: assetList, bitcoin: bitcoinAsset),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 10,
                color: const Color(0xFFF6F7FA),
              ),
            ),
            SliverToBoxAdapter(
              child: _TabSwitchBar(selectedTab: selectedTab),
            ),
            if (selectedTab == _Tab.coins) ...[
              SliverToBoxAdapter(child: AssetHeader(sortType: sortType)),
              CoinsSliverList(assetList: assetList),
            ] else ...[
              const CollectiblesGroupSliverGrid(),
            ],
          ],
        ),
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _HomeAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final account = auth?.account;
    return MixinAppBar(
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Center(
          child: InkResponse(
            radius: 24,
            onTap: () {
              if (isLoginByCredential) {
                return;
              }
              showMixinBottomSheet<void>(
                context: context,
                builder: (context) => const _AccountBottomSheet(),
              );
            },
            child: account == null
                ? const SizedBox()
                : Avatar(
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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48);
}

extension _SortAssets on List<AssetResult> {
  void sortBy(AssetSortType sort) {
    double assetAmplitude(AssetResult asset) {
      final invalid = sort == AssetSortType.increase
          ? double.negativeInfinity
          : double.infinity;
      if (asset.priceUsd.isZero) {
        return invalid;
      }
      return double.tryParse(asset.changeUsd) ?? invalid;
    }

    switch (sort) {
      case AssetSortType.amount:
        this.sort((a, b) {
          var result = b.amountOfUsd.compareTo(a.amountOfUsd);
          if (result != 0) return result;
          result = b.balance.asDecimal.compareTo(a.balance.asDecimal);
          if (result != 0) return result;
          result = b.priceUsd.asDecimal.compareTo(a.priceUsd.asDecimal);
          if (result != 0) return result;
          return 0;
        });
        break;
      case AssetSortType.decrease:
        this.sort((a, b) => assetAmplitude(a).compareTo(assetAmplitude(b)));
        break;
      case AssetSortType.increase:
        this.sort((a, b) => assetAmplitude(b).compareTo(assetAmplitude(a)));
        break;
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
            title: Row(
          children: [
            Avatar(
              avatarUrl: account.avatarUrl,
              userId: account.userId,
              name: account.fullName ?? '',
              size: 32,
            ),
            const SizedBox(width: 16),
            Text(
              account.fullName ?? '',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        )),
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
            final id = auth!.account.identityNumber;
            await profileBox.clear();
            await deleteDatabase(id);
            context.replace(authUri.path);
          },
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}

class _TabSwitchBar extends HookWidget implements PreferredSizeWidget {
  const _TabSwitchBar({
    Key? key,
    required this.selectedTab,
  }) : super(key: key);

  final _Tab selectedTab;

  @override
  Widget build(BuildContext context) {
    final controller = useTabController(
      initialLength: 2,
      initialIndex: selectedTab.index,
    );
    useEffect(() {
      void onTabChanged() {
        final params = Map<String, String>.from(context.queryParameters);
        params[kQueryParameterTab] = _Tab.values[controller.index].name;
        context.replace(homeUri.replace(queryParameters: params));
      }

      controller.addListener(onTabChanged);
      return () => controller.removeListener(onTabChanged);
    });
    return SizedBox(
      height: 60,
      child: TabBar(
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        labelColor: context.colorScheme.primaryText,
        unselectedLabelColor: const Color(0xFFBCBEC3),
        tabs: [
          Tab(text: context.l10n.coins),
          Tab(text: context.l10n.nfts),
        ],
        indicatorSize: TabBarIndicatorSize.label,
        indicatorWeight: 3,
        indicator: BoxDecoration(
          color: context.colorScheme.accent,
          borderRadius: BorderRadius.circular(6),
        ),
        indicatorPadding: const EdgeInsets.only(bottom: 16, top: 41),
        controller: controller,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
