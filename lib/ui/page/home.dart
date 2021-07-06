import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../db/mixin_database.dart';
import '../../service/auth/auth_manager.dart';
import '../../util/extension/extension.dart';
import '../../util/r.dart';
import '../router/mixin_router_delegate.dart';
import '../widget/avatar.dart';
import '../widget/interactable_box.dart';
import '../widget/mixin_appbar.dart';
import '../widget/symbol.dart';

class Home extends HookWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    assert(context.appServices.databaseInitialized);

    useEffect(() {
      context.appServices.updateAssets();
    });

    final assets = useStream<List<Tuple2<AssetResult, Fiat>>>(useMemoized(
      () {
        CombineLatestStream.combine2<List<AssetResult>, List<Fiat>,
            List<Tuple2<AssetResult, Fiat>>>(
          context.appServices.watchAssets(),
          context.appServices.watchFiats(),
          (assets, fiats) {
            final fiat = fiats.cast<Fiat?>().firstWhere(
                (element) => element?.code == auth!.account.fiatCurrency,
                orElse: () => null);

            if (fiat == null) return [];

            return assets.map((e) => Tuple2(e, fiat)).toList()
              ..sort((a, b) {
                Decimal converter(AssetResult asset) =>
                    asset.balance.asDecimal * asset.priceUsd.asDecimal;
                return converter(b.item1).compareTo(converter(a.item1));
              });
          },
        );
      },
    ), initialData: []).requireData;

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
            child: _Header(data: assets),
          ),
          const SliverToBoxAdapter(
            child: _AssetHeader(),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) => _Item(
                data: assets[index].item1,
                currentFiat: assets[index].item2,
              ),
              childCount: assets.length,
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
  Widget build(BuildContext context) => Container(
        height: 50,
        color: context.theme.accent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            color: context.theme.background,
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 20),
                child: Text(
                  context.l10n.assets,
                  style: TextStyle(
                    color: context.theme.text,
                    fontSize: 16,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(top: 8, right: 8),
                child: InteractableBox(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SvgPicture.asset(R.resourcesHamburgerMenuSvg),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _Header extends HookWidget {
  const _Header({
    Key? key,
    required this.data,
  }) : super(key: key);

  final List<Tuple2<AssetResult, Fiat>> data;

  @override
  Widget build(BuildContext context) {
    final balance = useMemoized(
        () => data
            .fold<Decimal>(
                0.0.asDecimal,
                (previousValue, element) =>
                    previousValue +
                    (element.item1.balance.asDecimal *
                        element.item1.priceUsd.asDecimal *
                        element.item2.rate.asDecimal))
            .toString(),
        [data]);

    final balanceOfBtc = useMemoized(
        () => data
            .fold<Decimal>(
                0.0.asDecimal,
                (previousValue, element) =>
                    previousValue +
                    (element.item1.balance.asDecimal *
                        element.item1.priceBtc.asDecimal))
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                currentCurrencyNumberFormat.currencySymbol,
                style: TextStyle(
                  color: context.theme.background,
                  fontSize: 14,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
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
                onTap: () {},
              ),
              const SizedBox(width: 20),
              _Button(
                icon: SvgPicture.asset(R.resourcesReceiveSvg),
                text: Text(context.l10n.receive),
                onTap: () {},
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
  Widget build(BuildContext context) => InteractableBox(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0x19ffffff),
          ),
          alignment: Alignment.center,
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

class _Item extends StatelessWidget {
  const _Item({
    Key? key,
    required this.data,
    required this.currentFiat,
  }) : super(key: key);

  final AssetResult data;
  final Fiat currentFiat;

  @override
  Widget build(BuildContext context) => Container(
        height: 70,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: GestureDetector(
          onTap: () {
            context.read<MixinRouterDelegate>().pushNewUri(
                  MixinRouterDelegate.assetDetailPath
                      .toUri({'id': data.assetId}),
                );
          },
          child: Row(
            children: [
              SymbolIcon(symbolUrl: data.iconUrl, chainUrl: data.chainIconUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    '${data.balance} ${data.symbol}'.overflow,
                    style: TextStyle(
                      color: context.theme.text,
                      fontSize: 16,
                      fontFamily: 'Nunito',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    context.l10n.approxOf((data.balance.asDecimal *
                            data.priceUsd.asDecimal *
                            currentFiat.rate.asDecimal)
                        .currencyFormat),
                    style: TextStyle(
                      color: context.theme.secondaryText,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                PercentageChange(
                  valid: data.priceUsd.isZero,
                  changeUsd: data.changeUsd,
                ),
                Text(
                  (data.priceUsd.asDecimal * currentFiat.rate.asDecimal)
                        .currencyFormat,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: context.theme.secondaryText,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
