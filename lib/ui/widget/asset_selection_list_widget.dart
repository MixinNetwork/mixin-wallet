import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';

import '../../db/mixin_database.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/r.dart';
import '../../wyre/wyre_constants.dart';
import 'mixin_bottom_sheet.dart';
import 'search_header_widget.dart';
import 'symbol.dart';

Future<AssetResult?> showBuyAssetSelectionBottomSheet({
  required BuildContext context,
  String? initialSelected,
}) =>
    showAssetSelectionBottomSheet(
        initialSelected: initialSelected,
        context: context,
        source: () async* {
          final assets =
              await context.appServices.findOrSyncAssets(supportedCryptosId);
          yield assets;
        });

Future<AssetResult?> showAssetSelectionBottomSheet({
  required BuildContext context,
  String? initialSelected,
  AssetSourceLoader? source,
  Set<String> ignoreAssets = const {},
}) =>
    showMixinBottomSheet<AssetResult>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AssetSelectionListWidget(
        selectedAssetId: initialSelected,
        onTap: (_) {},
        source: source,
        ignoreAssets: ignoreAssets,
      ),
    );

typedef AssetSourceLoader = Stream<List<AssetResult>> Function();

// TODO(boyan): Refactor use navigator pop to receive assets, instead of onTap callback.
class AssetSelectionListWidget extends HookWidget {
  const AssetSelectionListWidget({
    Key? key,
    required this.onTap,
    this.selectedAssetId,
    this.source,
    this.ignoreAssets = const {},
  }) : super(key: key);

  final String? selectedAssetId;
  final AssetSelectCallback onTap;

  final AssetSourceLoader? source;

  /// The assets which was ignore and not show in the list.
  final Set<String> ignoreAssets;

  @override
  Widget build(BuildContext context) {
    final assetResults = useMemoizedStream(() {
          if (source != null) {
            return source!.call();
          }
          return context.appServices.assetResults().watch().map((event) => event
            ..removeWhere((element) => ignoreAssets.contains(element.assetId))
            ..sort(
              (a, b) => b.amountOfUsd.compareTo(a.amountOfUsd),
            ));
        }, keys: [ignoreAssets, source]).data ??
        const [];

    var selectedAssetId = this.selectedAssetId;
    selectedAssetId ??= assetResults.firstOrNull?.assetId;

    final filterKeyword = useState('');

    final filterList = useMemoized(
      () {
        final k = filterKeyword.value;
        if (k.isEmpty) {
          return assetResults;
        }
        return assetResults
            .where(
              (e) =>
                  e.symbol.containsIgnoreCase(k) ||
                  e.name.containsIgnoreCase(k) ||
                  (e.chainName?.containsIgnoreCase(k) ?? false),
            )
            .toList();
      },
      [filterKeyword.value, assetResults],
    );

    return SizedBox(
      height: MediaQuery.of(context).size.height - 100,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              child: SearchHeaderWidget(
                hintText: context.l10n.search,
                onChanged: (k) {
                  filterKeyword.value = k.trim();
                },
              )),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: filterList.length,
              itemBuilder: (BuildContext context, int index) => _Item(
                asset: filterList[index],
                selectedAssetId: selectedAssetId,
                onTap: onTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    Key? key,
    required this.asset,
    required this.selectedAssetId,
    required this.onTap,
  }) : super(key: key);

  final AssetResult asset;
  final String? selectedAssetId;
  final AssetSelectCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
      color: context.theme.background,
      child: InkWell(
        onTap: () {
          onTap(asset);
          Navigator.pop(context, asset);
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
                    Text(
                      asset.name.overflow,
                      style: TextStyle(
                        color: context.theme.text,
                        fontSize: 16,
                      ),
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

typedef AssetSelectCallback = void Function(AssetResult);
