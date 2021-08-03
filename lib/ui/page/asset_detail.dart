import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';

import '../../db/mixin_database.dart';
import '../../util/constants.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/r.dart';
import '../router/mixin_routes.dart';
import '../widget/action_button.dart';
import '../widget/mixin_appbar.dart';
import '../widget/mixin_bottom_sheet.dart';
import '../widget/mixin_elevated_button.dart';
import '../widget/over_scroller.dart';
import '../widget/symbol.dart';
import '../widget/transactions/transaction_list.dart';
import '../widget/transactions/transactions_filter.dart';

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
    //         .pushNewUri(notFoundUri);
    //   }
    // }, [notFound]);

    useEffect(() {
      if (data != null) {
        context.appServices.refreshPendingDeposits(data);
      }
    }, [data?.assetId]);

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
        backgroundColor: context.theme.background,
        appBar: MixinAppBar(
          backButtonColor: Colors.white,
          title: Text(asset.name),
          actions: [
            Center(
              child: ActionButton(
                  name: R.resourcesAlertSvg,
                  color: Colors.white,
                  size: 20,
                  onTap: () {
                    showMixinBottomSheet(
                      context: context,
                      builder: (context) =>
                          _AssetDescriptionBottomSheet(asset: asset),
                    );
                  }),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: _AssetDetailBody(asset: asset),
            ),
            _BottomBar(asset: asset),
          ],
        ),
      );
}

class _AssetDetailBody extends HookWidget {
  const _AssetDetailBody({
    Key? key,
    required this.asset,
  }) : super(key: key);

  final AssetResult asset;

  @override
  Widget build(BuildContext context) {
    final filter = useState(const SnapshotFilter(SortBy.time, FilterBy.all));
    return TransactionListBuilder(
      key: ValueKey(filter.value),
      refreshSnapshots: (offset, limit) => context.appServices
          .updateSnapshots(asset.assetId, offset: offset, limit: limit),
      loadMoreItemDb: (offset, limit) => context.mixinDatabase.snapshotDao
          .snapshots(asset.assetId,
              offset: offset,
              limit: limit,
              orderByAmount: filter.value.sortBy == SortBy.amount,
              types: filter.value.filterBy.snapshotTypes)
          .get(),
      builder: (context, snapshots) => ColoredOverScrollTopWidget(
        background: context.theme.accent,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _AssetHeader(asset: asset),
            ),
            SliverToBoxAdapter(
              child: _AssetTransactionsHeader(filter: filter),
            ),
            if (snapshots.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 130),
                  child: EmptyTransaction(),
                ),
              ),
            if (snapshots.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => TransactionItem(item: snapshots[index]),
                  childCount: snapshots.length,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AssetHeader extends StatelessWidget {
  const _AssetHeader({Key? key, required this.asset}) : super(key: key);

  final AssetResult asset;

  @override
  Widget build(BuildContext context) => Container(
        color: context.theme.accent,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 18),
            SymbolIconWithBorder(
              symbolUrl: asset.iconUrl,
              chainUrl: asset.chainIconUrl,
              size: 60,
              chainSize: 18,
              chainBorder: const BorderSide(color: Colors.white, width: 1.14),
              symbolBorder: const BorderSide(color: Colors.white, width: 1.67),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SelectableText.rich(
                TextSpan(children: [
                  TextSpan(
                      text: asset.balance.numberFormat().overflow,
                      style: const TextStyle(
                        fontSize: 34,
                        color: Colors.white,
                      )),
                  const TextSpan(text: ' '),
                  TextSpan(
                      text: asset.symbol.overflow,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.4),
                      )),
                ]),
                textAlign: TextAlign.center,
                enableInteractiveSelection: false,
              ),
            ),
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
    required this.filter,
  }) : super(key: key);

  final ValueNotifier<SnapshotFilter> filter;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 54,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                color: context.theme.accent,
                height: 20,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(topRadius),
                ),
                color: context.theme.background,
              ),
              child: Material(
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(width: 20),
                      Text(
                        context.l10n.transactions,
                        style: TextStyle(
                          color: BrightnessData.themeOf(context).text,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      InkResponse(
                        onTap: () async {
                          final filter = await showFilterBottomSheetDialog(
                            context,
                            initial: this.filter.value,
                          );
                          if (filter == null) {
                            return;
                          }
                          this.filter.value = filter;
                        },
                        radius: 20,
                        child: SvgPicture.asset(
                          R.resourcesFilterSvg,
                          color: BrightnessData.themeOf(context).text,
                          height: 24,
                          width: 24,
                        ),
                      ),
                      const SizedBox(width: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    Key? key,
    required this.asset,
  }) : super(key: key);

  final AssetResult asset;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            const Spacer(),
            MixinElevatedButton(
              fixedSize: const Size(140, 44),
              primary: context.theme.accent,
              child: Text(context.l10n.send),
              onTap: () =>
                  context.push(withdrawalPath.toUri({'id': asset.assetId})),
            ),
            const SizedBox(width: 20),
            MixinElevatedButton(
              fixedSize: const Size(140, 44),
              primary: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                side: BorderSide(color: context.theme.accent),
              ),
              child: Text(
                context.l10n.receive,
                style: TextStyle(
                  color: context.theme.accent,
                ),
              ),
              onTap: () =>
                  context.push(assetDepositPath.toUri({'id': asset.assetId})),
            ),
            const Spacer(),
          ],
        ),
      );
}

class _AssetDescriptionBottomSheet extends StatelessWidget {
  const _AssetDescriptionBottomSheet({
    Key? key,
    required this.asset,
  }) : super(key: key);

  final AssetResult asset;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MixinBottomSheetTitle(
            title: Row(children: [
              SymbolIconWithBorder(
                symbolUrl: asset.iconUrl,
                chainUrl: asset.chainIconUrl,
                size: 20,
                chainSize: 8,
              ),
              const SizedBox(width: 10),
              Text(asset.name)
            ]),
          ),
          _AssetBottomSheetTile(
            title: Text(context.l10n.symbol),
            subtitle: Text(asset.symbol),
          ),
          _AssetBottomSheetTile(
            title: Text(context.l10n.chain),
            subtitle: Text(asset.chainName ?? ''),
          ),
          _AssetBottomSheetTile(
            title: Text(context.l10n.contract),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(asset.assetKey ?? ''),
                const SizedBox(height: 10),
                Text(
                  context.l10n.transactionsAssetKeyWarning,
                  style:
                      const TextStyle(color: Color(0xFFe86b67), fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      );
}

class _AssetBottomSheetTile extends StatelessWidget {
  const _AssetBottomSheetTile({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  final Widget title;
  final Widget subtitle;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 20,
              fit: FlexFit.tight,
              child: DefaultTextStyle(
                style: TextStyle(
                  color: context.theme.secondaryText,
                  fontSize: 16,
                  height: 1.2,
                ),
                textAlign: TextAlign.end,
                child: title,
              ),
            ),
            const Spacer(flex: 5),
            Flexible(
              flex: 65,
              fit: FlexFit.tight,
              child: DefaultTextStyle(
                style: TextStyle(
                  fontSize: 16,
                  color: context.theme.text,
                  height: 1.2,
                ),
                child: subtitle,
              ),
            ),
            const Spacer(flex: 10),
          ],
        ),
      );
}
