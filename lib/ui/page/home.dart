import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
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
import '../widget/asset.dart';
import '../widget/avatar.dart';
import '../widget/mixin_appbar.dart';
import '../widget/mixin_bottom_sheet.dart';
import '../widget/mixin_elevated_button.dart';
import '../widget/search_asset_bottom_sheet.dart';

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

    return Scaffold(
      backgroundColor: context.theme.background,
      appBar: MixinAppBar(
        leading: Center(
          child: Avatar(
            avatarUrl: auth!.account.avatarUrl,
            userId: auth!.account.userId,
            name: auth!.account.fullName!,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _Header(data: assetResults),
          ),
          const SliverToBoxAdapter(
            child: _AssetHeader(),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final item = assetResults[index];
                return _SwipeToHide(
                  key: ValueKey(item.assetId),
                  child: AssetWidget(data: item),
                  onDismiss: () {
                    context.appServices
                        .updateAssetHidden(item.assetId, hidden: true);
                  },
                );
              },
              childCount: assetResults.length,
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
  Widget build(BuildContext context) => ListRoundedHeaderContainer(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 20),
              child: Text(
                context.l10n.assets,
                style: TextStyle(
                  color: context.theme.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 8),
              child: Row(
                children: [
                  InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => showMixinBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (BuildContext context) =>
                            const SearchAssetBottomSheet()),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SvgPicture.asset(
                        R.resourcesIcSearchSvg,
                        height: 24,
                        width: 24,
                        color: context.theme.icon,
                      ),
                    ),
                  ),
                  InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      showMixinBottomSheet(
                        context: context,
                        builder: (context) => const _MenuBottomSheet(),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SvgPicture.asset(
                        R.resourcesHamburgerMenuSvg,
                        height: 24,
                        width: 24,
                        color: context.theme.icon,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
        () => data
            .fold<Decimal>(
                0.0.asDecimal,
                (previousValue, AssetResult element) =>
                    previousValue + element.amountOfCurrentCurrency)
            .toString(),
        [data]);

    final balanceOfBtc = useMemoized(
        () => data
            .fold<Decimal>(0.0.asDecimal,
                (previousValue, element) => previousValue + element.amountOfBtc)
            .toString(),
        [data]);

    return Container(
      height: 203,
      color: context.theme.accent,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Text(
            context.l10n.totalBalance,
            style: TextStyle(
              color: context.theme.background,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
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
                    color: context.theme.background,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Text(
                balance.currencyFormatWithoutSymbol,
                style: TextStyle(
                  color: context.theme.background,
                  fontSize: 48,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            context.l10n.approxBalanceOfBtc(balanceOfBtc),
            style: const TextStyle(
              color: Color(0x7fffffff),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Button(
                icon: SvgPicture.asset(R.resourcesSendSvg),
                text: Text(context.l10n.send),
                onTap: () {
                  context.push(withdrawalPath.toUri({'id': bitcoin}));
                },
              ),
              const SizedBox(width: 20),
              _Button(
                icon: SvgPicture.asset(R.resourcesReceiveSvg),
                text: Text(context.l10n.receive),
                onTap: () {
                  context.push(assetDepositPath.toUri({'id': bitcoin}));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    Key? key,
    required this.icon,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  final Widget icon;
  final Widget text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => MixinElevatedButton(
        onTap: onTap,
        primary: const Color(0x19ffffff),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 32,
          ),
          child: DefaultTextStyle(
            style: TextStyle(
              color: context.theme.background,
              fontSize: 16,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(width: 6),
                text,
              ],
            ),
          ),
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
      onDismissed: (direction) => onDismiss(),
      background: Container(
        color: context.theme.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: indicator,
        ),
      ),
      secondaryBackground: Container(
        color: context.theme.red,
        child: Align(
          alignment: Alignment.centerRight,
          child: indicator,
        ),
      ),
      child: child,
    );
  }
}

class _MenuBottomSheet extends HookWidget {
  const _MenuBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hideSmallAssets = useState(false);
    return Column(
      children: [
        MixinBottomSheetTitle(title: Text(context.l10n.assets)),
        const SizedBox(height: 9),
        _MenuItem(
          topRounded: true,
          leading: SvgPicture.asset(R.resourcesAllTransactionsSvg),
          title: Text(context.l10n.allTransactions),
          onTap: () => context.push(transactionsUri),
        ),
        _MenuItem(
          bottomRounded: true,
          leading: SvgPicture.asset(R.resourcesHiddenSvg),
          title: Text(context.l10n.hiddenAssets),
          onTap: () => context.push(hiddenAssetsUri),
        ),
        const SizedBox(height: 11),
        _MenuItem(
          topRounded: true,
          bottomRounded: true,
          title: Text(context.l10n.hideSmallAssets),
          leading: SvgPicture.asset(R.resourcesHideAssetsSvg),
          trailing: Switch(
            value: hideSmallAssets.value,
            activeColor: const Color(0xff333333),
            onChanged: (bool value) => hideSmallAssets.value = value,
          ),
        )
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    Key? key,
    required this.title,
    required this.leading,
    this.topRounded = false,
    this.bottomRounded = false,
    this.trailing,
    this.onTap,
  }) : super(key: key);

  final Widget title;
  final Widget leading;
  final Widget? trailing;

  final VoidCallback? onTap;

  final bool topRounded;
  final bool bottomRounded;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: topRounded ? const Radius.circular(12) : Radius.zero,
            bottom: bottomRounded ? const Radius.circular(12) : Radius.zero,
          ),
          color: const Color(0xfff8f8f8),
        ),
        padding: EdgeInsets.only(
          top: topRounded ? 10 : 0,
          bottom: bottomRounded ? 10 : 0,
        ),
        child: Material(
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              height: 64,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 20),
                  SizedBox.square(dimension: 24, child: leading),
                  const SizedBox(width: 10),
                  DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: context.theme.text,
                    ),
                    child: title,
                  ),
                  const Spacer(),
                  if (trailing != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: trailing,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
}
