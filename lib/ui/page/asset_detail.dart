import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;

import '../../db/mixin_database.dart';
import '../../service/profile/profile_manager.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/r.dart';
import '../router/mixin_routes.dart';
import '../widget/action_button.dart';
import '../widget/buttons.dart';
import '../widget/mixin_appbar.dart';
import '../widget/mixin_bottom_sheet.dart';
import '../widget/symbol.dart';
import '../widget/transactions/transaction_list.dart';
import '../widget/transactions/transactions_filter.dart';
import '../widget/transfer.dart';

const _kQueryParamSortBy = 'sort';
const _kQueryParamFilterBy = 'filter';

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

    final filter = useMemoized(
        () => SnapshotFilter(
              sdk.EnumToString.fromString(SortBy.values,
                      context.queryParameters[_kQueryParamSortBy]) ??
                  SortBy.time,
              sdk.EnumToString.fromString(FilterBy.values,
                      context.queryParameters[_kQueryParamFilterBy]) ??
                  FilterBy.all,
            ),
        [
          context.queryParameters[_kQueryParamSortBy],
          context.queryParameters[_kQueryParamFilterBy],
        ]);

    if (data == null) {
      return const SizedBox();
    }

    return _AssetDetailPage(asset: data, filter: filter);
  }
}

class _AssetDetailPage extends StatelessWidget {
  const _AssetDetailPage({
    Key? key,
    required this.asset,
    required this.filter,
  }) : super(key: key);

  final AssetResult asset;

  final SnapshotFilter filter;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.colorScheme.background,
        appBar: MixinAppBar(
          backgroundColor: context.colorScheme.background,
          title: SelectableText(
            asset.name,
            style: TextStyle(
              color: context.colorScheme.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            enableInteractiveSelection: false,
          ),
          leading: const MixinBackButton2(),
          actions: [
            Center(
              child: ActionButton(
                  name: R.resourcesAlertSvg,
                  size: 24,
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
        body: _AssetDetailBody(asset: asset, filter: filter),
      );
}

class _AssetDetailBody extends StatelessWidget {
  const _AssetDetailBody({
    Key? key,
    required this.asset,
    required this.filter,
  }) : super(key: key);

  final AssetResult asset;

  final SnapshotFilter filter;

  @override
  Widget build(BuildContext context) => TransactionListBuilder(
        key: ValueKey(filter),
        refreshSnapshots: (offset, limit) => context.appServices
            .updateAssetSnapshots(asset.assetId, offset: offset, limit: limit),
        loadMoreItemDb: (offset, limit) => context.mixinDatabase.snapshotDao
            .snapshots(asset.assetId,
                offset: offset,
                limit: limit,
                orderByAmount: filter.sortBy == SortBy.amount,
                types: filter.filterBy.snapshotTypes)
            .get(),
        builder: (context, snapshots) {
          if (snapshots.isEmpty) {
            return Column(
              children: [
                _AssetHeader(asset: asset, filter: filter),
                const Expanded(child: EmptyTransaction()),
              ],
            );
          }
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _AssetHeader(asset: asset, filter: filter),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => TransactionItem(item: snapshots[index]),
                  childCount: snapshots.length,
                ),
              ),
            ],
          );
        },
      );
}

class _AssetHeader extends StatelessWidget {
  const _AssetHeader({
    Key? key,
    required this.asset,
    required this.filter,
  }) : super(key: key);

  final AssetResult asset;

  final SnapshotFilter filter;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          SymbolIconWithBorder(
            symbolUrl: asset.iconUrl,
            chainUrl: asset.chainIconUrl,
            size: 58,
            chainSize: 14,
            chainBorder:
                BorderSide(color: context.colorScheme.background, width: 2),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: SelectableText.rich(
              TextSpan(children: [
                TextSpan(
                  text: asset.balance.numberFormat().overflow,
                  style: TextStyle(
                    fontSize: 32,
                    color: context.colorScheme.primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(text: ' '),
                TextSpan(
                  text: asset.symbol.overflow,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.colorScheme.thirdText,
                  ),
                ),
              ]),
              textAlign: TextAlign.center,
              enableInteractiveSelection: false,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            asset.amountOfCurrentCurrency.currencyFormat,
            style: TextStyle(
              fontSize: 14,
              color: context.colorScheme.thirdText,
            ),
            enableInteractiveSelection: false,
          ),
          const SizedBox(height: 24),
          _HeaderButtonBar(asset: asset),
          const SizedBox(height: 24),
          _AssetTransactionsHeader(filter: filter),
        ],
      );
}

class _HeaderButtonBar extends StatelessWidget {
  const _HeaderButtonBar({Key? key, required this.asset}) : super(key: key);

  final AssetResult asset;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 38),
        child: HeaderButtonBarLayout(buttons: [
          HeaderButton.text(
            text: context.l10n.send,
            onTap: () => showTransferRouterBottomSheet(
              context: context,
              assetId: asset.assetId,
            ),
          ),
          HeaderButton.text(
            text: context.l10n.receive,
            onTap: () {
              lastSelectedAddress = asset.assetId;
              context.push(assetDepositPath.toUri({'id': asset.assetId}));
            },
          ),
          HeaderButton.text(
            text: context.l10n.buy,
            onTap: () {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text(context.l10n.comingSoon)),
                );
            },
          ),
          HeaderButton.text(
            text: context.l10n.swap,
            onTap: () {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text(context.l10n.comingSoon)),
                );
            },
          ),
        ]),
      );
}

class _AssetTransactionsHeader extends StatelessWidget {
  const _AssetTransactionsHeader({
    Key? key,
    required this.filter,
  }) : super(key: key);

  final SnapshotFilter filter;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 40,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 16),
            Text(
              context.l10n.transactions,
              style: TextStyle(
                color: context.colorScheme.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            InkResponse(
              onTap: () async {
                final filter = await showFilterBottomSheetDialog(
                  context,
                  initial: this.filter,
                );
                if (filter == null) {
                  return;
                }
                context.push(Uri.parse(context.url).replace(queryParameters: {
                  _kQueryParamSortBy:
                      sdk.EnumToString.convertToString(filter.sortBy),
                  _kQueryParamFilterBy:
                      sdk.EnumToString.convertToString(filter.filterBy),
                }));
              },
              radius: 20,
              child: SvgPicture.asset(
                R.resourcesFilterSvg,
                color: context.colorScheme.primaryText,
                height: 24,
                width: 24,
              ),
            ),
            const SizedBox(width: 16),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MixinBottomSheetTitle(
            title: Row(children: [
              SymbolIconWithBorder(
                symbolUrl: asset.iconUrl,
                chainUrl: asset.chainIconUrl,
                size: 32,
                chainSize: 14,
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
                Text(asset.assetKey?.overflow ?? ''),
                const SizedBox(height: 10),
                Text(
                  context.l10n.transactionsAssetKeyWarning,
                  style: TextStyle(
                    color: context.colorScheme.red,
                    fontSize: 14,
                  ),
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
                  color: context.colorScheme.thirdText,
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
                  color: context.colorScheme.primaryText,
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
