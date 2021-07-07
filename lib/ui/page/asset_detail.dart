import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';

import '../../db/mixin_database.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/r.dart';
import '../widget/interactable_box.dart';
import '../widget/mixin_appbar.dart';
import '../widget/symbol.dart';
import '../widget/transactions/transaction_list.dart';

class AssetDetail extends StatelessWidget {
  const AssetDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const _AssetDetailLoader();
}

class _AssetDetailLoader extends HookWidget {
  const _AssetDetailLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final assetId = context.pathParameters['id']!;

    useMemoizedFuture(() => context.appServices.updateAsset(assetId),
        keys: [assetId]);

    final data = useMemoizedStream(
      () => context.appServices.assetResult(assetId).watchSingleOrNull(),
      keys: [assetId],
    ).data;

    // useEffect(() {
    //   if (notFound) {
    //     context
    //         .read<MixinRouterDelegate>()
    //         .pushNewUri(MixinRouterDelegate.notFoundUri);
    //   }
    // }, [notFound]);

    if (data == null) {
      return const SizedBox();
    }

    return _AssetDetailPage(asset: data);
  }
}

class _AssetDetailPage extends StatelessWidget {
  const _AssetDetailPage({Key? key, required this.asset}) : super(key: key);

  final AssetResult asset;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: BrightnessData.themeOf(context).background,
        appBar: const MixinAppBar(),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _AssetHeader(asset: asset),
            ),
            const SliverToBoxAdapter(
              child: _AssetTransactionsHeader(),
            ),
            _TransactionsList(assetId: asset.assetId),
          ],
        ),
      );
}

class _AssetHeader extends StatelessWidget {
  const _AssetHeader({Key? key, required this.asset}) : super(key: key);

  final AssetResult asset;

  @override
  Widget build(BuildContext context) => Container(
        color: context.theme.accent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 18),
            SymbolIcon(
              symbolUrl: asset.iconUrl,
              chainUrl: asset.chainIconUrl,
              size: 60,
              chinaSize: 18,
            ),
            const SizedBox(height: 18),
            Text.rich(TextSpan(children: [
              TextSpan(
                  text: asset.balance,
                  style: const TextStyle(
                    fontFamily: 'Mixin Condensed',
                    fontSize: 48,
                    color: Colors.white,
                  )),
              const WidgetSpan(child: SizedBox(width: 2)),
              TextSpan(
                  text: asset.symbol,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.4),
                  )),
            ])),
            const SizedBox(height: 2),
            Text(
              context.l10n.approxOf(
                asset.amountOfCurrentCurrency.currencyFormat,
              ),
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 38),
          ],
        ),
      );
}

class _AssetTransactionsHeader extends StatelessWidget {
  const _AssetTransactionsHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        color: context.theme.accent,
        height: 64,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            color: Colors.white,
          ),
          child: Center(
            child: Row(
              children: [
                const SizedBox(width: 20),
                Text(
                  context.l10n.transactions,
                  style: TextStyle(
                    color: BrightnessData.themeOf(context).text,
                    fontSize: 16,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                InteractableBox(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SvgPicture.asset(
                      R.resourcesFilterSvg,
                      color: BrightnessData.themeOf(context).text,
                      height: 24,
                      width: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),
          ),
        ),
      );
}

class _TransactionsList extends HookWidget {
  const _TransactionsList({Key? key, required this.assetId}) : super(key: key);

  final String assetId;

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      context.appServices.updateSnapshots(assetId);
    }, [assetId]);
    return TransactionList(
        loadMoreItemNetwork: (offset) =>
            context.appServices.snapshots(assetId).get(),
        loadMoreItemDb: (offset) =>
            context.appServices.snapshots(assetId).get());
  }
}
