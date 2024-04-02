import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../db/dao/extension.dart';
import '../../db/mixin_database.dart';
import '../../service/account_provider.dart';
import '../../util/constants.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/logger.dart';
import '../../util/native_scroll.dart';
import '../../util/r.dart';
import '../../util/transak.dart';
import '../route.dart';
import 'chain_network_label.dart';
import 'mixin_bottom_sheet.dart';
import 'search_asset_bottom_sheet.dart';
import 'search_header_widget.dart';
import 'symbol.dart';
import 'text.dart';

class BuyAssetSelectionBottomSheet extends StatelessWidget {
  const BuyAssetSelectionBottomSheet({super.key});

  @override
  Widget build(BuildContext context) => AssetSelectionListWidget(
        onTap: (asset) async {
          if (asset == null) {
            return;
          }
          if (asset.getDestination().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(context.l10n.assetAddressGeneratingTip),
              ),
            );
          } else {
            final url = generateTransakPayUrl(asset);
            d('PayUrl: $url');
            await launchUrlString(url);
          }
          Navigator.of(context).pop();
        },
        source: (faitCurrency) async* {
          final assets =
              await context.appServices.findOrSyncAssets(supportedBuyCryptosId);
          yield assets;
        },
        onCancelPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            const HomeRoute().go(context);
          }
        },
      );
}

Future<AssetResult?> showSendAssetSelectionBottomSheet(
  BuildContext context, {
  String? initialSelected,
}) =>
    showMixinBottomSheet<AssetResult>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AssetSelectionListWidget(
        selectedAssetId: initialSelected,
        onTap: (asset) => Navigator.pop(context, asset),
        onCancelPressed: () => Navigator.pop(context),
        source: (faitCurrency) => context.mixinDatabase.assetDao
            .assetResultsWithBalance(faitCurrency)
            .watch(),
        emptyBuilder: (context) => Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(context.l10n.noAsset),
            ),
          ],
        )),
      ),
    );

Future<AssetResult?> showAssetWithSearchSelectionBottomSheet(
  BuildContext context, {
  String? initialSelected,
}) =>
    showMixinBottomSheet<AssetResult>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AssetWithNetworkSearchSelectionBottomSheet(
        initialSelected: initialSelected,
      ),
    );

class _AssetWithNetworkSearchSelectionBottomSheet extends HookWidget {
  const _AssetWithNetworkSearchSelectionBottomSheet({
    this.initialSelected,
  });

  final String? initialSelected;

  @override
  Widget build(BuildContext context) {
    final keywordStreamController = useStreamController<String>();
    final keywordStream = useMemoized(
        () => keywordStreamController.stream.map((e) => e.trim()).distinct());
    final hasKeyword =
        useMemoizedStream(() => keywordStream.map((event) => event.isNotEmpty))
                .data ??
            false;
    const notSupportDepositAssets = {omniUSDT};
    return SizedBox(
      height: MediaQuery.of(context).size.height - 100,
      child: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 8),
            child: SearchHeaderWidget(
              hintText: context.l10n.search,
              onChanged: keywordStreamController.add,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: IndexedStack(
              index: hasKeyword ? 1 : 0,
              children: [
                _AllAssetList(
                  initialSelected: initialSelected,
                  ignoreAssets: notSupportDepositAssets,
                ),
                SearchAssetList(
                  keywordStream: keywordStream,
                  ignoreAssets: notSupportDepositAssets,
                  itemBuilder: (context, asset) => _Item(
                    asset: asset,
                    onTap: (asset) => Navigator.pop(context, asset),
                    selectedAssetId: initialSelected,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AllAssetList extends HookWidget {
  const _AllAssetList({
    required this.initialSelected,
    required this.ignoreAssets,
  });

  final String? initialSelected;

  final Set<String> ignoreAssets;

  @override
  Widget build(BuildContext context) {
    final faitCurrency = useAccountFaitCurrency();
    final assets = useMemoizedStream(
            () => context.mixinDatabase.assetDao
                .assetResults(faitCurrency)
                .watch()
                .map(
                  (event) => event
                      .where(
                        (element) => !ignoreAssets.contains(element.assetId),
                      )
                      .toList(),
                ),
            keys: [faitCurrency]).data ??
        const [];

    return NativeScrollBuilder(
      builder: (context, controller) => ListView.builder(
        controller: controller,
        itemCount: assets.length,
        itemBuilder: (BuildContext context, int index) => _Item(
          asset: assets[index],
          onTap: (asset) => Navigator.pop(context, asset),
          selectedAssetId: initialSelected,
        ),
      ),
    );
  }
}

typedef AssetSourceLoader = Stream<List<AssetResult>> Function(
  String faitCurrency,
);

class AssetSelectionListWidget extends HookWidget {
  const AssetSelectionListWidget({
    required this.onTap,
    required this.onCancelPressed,
    required this.source,
    super.key,
    this.selectedAssetId,
    this.hasNullChoose = false,
    this.emptyBuilder,
  });

  final String? selectedAssetId;
  final AssetSelectCallback onTap;

  final AssetSourceLoader source;

  final VoidCallback onCancelPressed;

  /// Show a null choose item in the list.
  final bool hasNullChoose;

  final WidgetBuilder? emptyBuilder;

  @override
  Widget build(BuildContext context) {
    final faitCurrency = useAccountFaitCurrency();
    final assetResults = useMemoizedStream(
          () => source(faitCurrency),
          keys: [source, faitCurrency],
        ).data ??
        const [];

    final keywordStreamController = useStreamController<String>();
    final keywordStream = useMemoized(
      () => keywordStreamController.stream.map((e) => e.trim()).distinct(),
      [keywordStreamController],
    );
    final filterKeyword = useMemoizedStream(() => keywordStream.throttleTime(
              const Duration(milliseconds: 100),
              trailing: true,
              leading: false,
            )).data ??
        '';

    final filterList = useMemoized(
      () {
        if (filterKeyword.isEmpty) {
          return assetResults;
        }
        return assetResults
            .where(
              (e) =>
                  e.symbol.containsIgnoreCase(filterKeyword) ||
                  e.name.containsIgnoreCase(filterKeyword) ||
                  (e.chainName?.containsIgnoreCase(filterKeyword) ?? false),
            )
            .sortedByKeyword(filterKeyword);
      },
      [filterKeyword, assetResults],
    );

    final Widget body;
    if (assetResults.isEmpty && filterKeyword.isEmpty) {
      body = emptyBuilder?.call(context) ?? const SizedBox.shrink();
    } else {
      body = NativeScrollBuilder(
        builder: (context, controller) => ListView.builder(
          controller: controller,
          itemCount: hasNullChoose ? filterList.length + 1 : filterList.length,
          itemBuilder: (BuildContext context, int index) {
            if (!hasNullChoose) {
              return _Item(
                asset: filterList[index],
                selectedAssetId: selectedAssetId,
                onTap: onTap,
              );
            } else {
              if (index == 0) {
                return _NoChooseItem(
                  onTap: () => onTap(null),
                  selected: selectedAssetId == null,
                );
              } else {
                return _Item(
                  asset: filterList[index - 1],
                  selectedAssetId: selectedAssetId,
                  onTap: onTap,
                );
              }
            }
          },
        ),
      );
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height - 100,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              child: SearchHeaderWidget(
                hintText: context.l10n.search,
                onChanged: keywordStreamController.add,
                onCancelPressed: onCancelPressed,
              )),
          const SizedBox(height: 10),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _NoChooseItem extends StatelessWidget {
  const _NoChooseItem({
    required this.onTap,
    required this.selected,
  });

  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) => Material(
      color: context.theme.background,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          child: Row(children: [
            const SizedBox(width: 52),
            MixinText(context.l10n.allAssets),
            const Spacer(),
            if (selected)
              Align(
                alignment: Alignment.centerRight,
                child: SvgPicture.asset(R.resourcesIcCheckSvg),
              ),
          ]),
        ),
      ));
}

class _Item extends StatelessWidget {
  const _Item({
    required this.asset,
    required this.selectedAssetId,
    required this.onTap,
  });

  final AssetResult asset;
  final String? selectedAssetId;
  final AssetSelectCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
      color: context.theme.background,
      child: InkWell(
        onTap: () {
          onTap(asset);
        },
        child: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            child: Row(children: [
              SymbolIconWithBorder(
                  symbolUrl: asset.iconUrl,
                  chainUrl: asset.chainIconUrl,
                  size: 40,
                  chainSize: 14,
                  chainBorder: BorderSide(
                    color: context.colorScheme.background,
                    width: 1,
                  )),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: MixinText(
                            asset.name.overflow,
                            style: TextStyle(
                              color: context.theme.text,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        ChainNetworkLabel(asset: asset),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${asset.balance} ${asset.symbol}',
                      style: TextStyle(
                        color: context.theme.secondaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              if (selectedAssetId == asset.assetId)
                Align(
                  alignment: Alignment.centerRight,
                  child: SvgPicture.asset(R.resourcesIcCheckSvg),
                ),
            ])),
      ));
}

typedef AssetSelectCallback = void Function(AssetResult?);

extension _AssetListSort on Iterable<AssetResult> {
  // sort asset result by keyword the same as AssetDao.searchAssetResults.
  List<AssetResult> sortedByKeyword(String keyword) => sortedBy<num>(
        (e) {
          if (e.symbol.equalsIgnoreCase(keyword)) {
            return 1;
          }
          if (e.name.equalsIgnoreCase(keyword)) {
            return 1;
          }
          if (e.symbol.startsWithIgnoreCase(keyword)) {
            return 100 + e.symbol.length;
          }
          if (e.name.startsWithIgnoreCase(keyword)) {
            return 100 + e.name.length;
          }
          if (e.symbol.containsIgnoreCase(keyword)) {
            return 200 + e.symbol.length;
          }
          if (e.name.containsIgnoreCase(keyword)) {
            return 200 + e.name.length;
          }
          return 1000;
        },
      );
}
