import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';

import '../../db/mixin_database.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/l10n.dart';
import '../../util/r.dart';
import 'brightness_observer.dart';
import 'search_header_widget.dart';
import 'symbol.dart';

class AssetSelectionListWidget extends HookWidget {
  const AssetSelectionListWidget({
    Key? key,
    required this.onTap,
    this.selectedAssetId,
  }) : super(key: key);

  final String? selectedAssetId;
  final AssetSelectCallback onTap;

  @override
  Widget build(BuildContext context) {
    final assetResults = useMemoizedStream(
      () => context.appServices.assetResults().watch().map((event) => event
        ..sort(
          (a, b) => b.amountOfUsd.compareTo(a.amountOfUsd),
        )),
    ).requireData;

    var selectedAssetId = this.selectedAssetId;
    selectedAssetId ??= assetResults[0].assetId;

    final filterList = useState<List<AssetResult>>(assetResults);

    return Container(
      height: MediaQuery.of(context).size.height - 100,
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          SearchHeaderWidget(
            hintText: context.l10n.search,
            onChanged: (k) {
              if (k.isNotEmpty) {
                filterList.value = assetResults
                    .where((e) =>
                        e.symbol.containsIgnoreCase(k) ||
                        e.name.containsIgnoreCase(k))
                    .toList();
              } else {
                filterList.value = assetResults;
              }
            },
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: filterList.value.length,
              itemBuilder: (BuildContext context, int index) => _Item(
                asset: filterList.value[index],
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
  Widget build(BuildContext context) => SizedBox(
        height: 80,
        child: GestureDetector(
            onTap: () {
              onTap(asset);
              Navigator.pop(context);
            },
            behavior: HitTestBehavior.opaque,
            child: Row(children: [
              SymbolIconWithBorder(
                symbolUrl: asset.iconUrl,
                chainUrl: asset.chainIconUrl,
                size: 44,
                chainSize: 10,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      asset.symbol.overflow,
                      style: TextStyle(
                        color: context.theme.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
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
              selectedAssetId == asset.assetId
                  ? Align(
                      alignment: Alignment.centerRight,
                      child: SvgPicture.asset(R.resourcesIcCheckSvg),
                    )
                  : const SizedBox(),
            ])),
      );
}

typedef AssetSelectCallback = void Function(AssetResult);
