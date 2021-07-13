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
import 'interactable_box.dart';
import 'search_text_field_widget.dart';
import 'symbol.dart';

class AssetSelectionListWidget extends HookWidget {
  const AssetSelectionListWidget({
    Key? key,
    required this.onTap,
    this.selectedAsset,
  }) : super(key: key);

  final AssetResult? selectedAsset;
  final AssetSelectCallback onTap;

  @override
  Widget build(BuildContext context) {
    final assetResults = useMemoizedStream(
      () => context.appServices.assetResults().watch().map((event) => event
        ..sort(
          (a, b) => b.amountOfUsd.compareTo(a.amountOfUsd),
        )),
    ).requireData;

    var selectedAssetId = selectedAsset?.assetId;
    selectedAssetId ??= assetResults[0].assetId;

    final filterList = useState<List<AssetResult>>(assetResults);

    return Container(
      height: MediaQuery.of(context).size.height - 120,
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      child: Column(
        children: [
          SizedBox(
              height: 80,
              child: Stack(children: [
                Container(
                    padding: const EdgeInsets.only(right: 80),
                    child: Material(
                        child: SearchTextFieldWidget(
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
                      fontSize: 16,
                      controller: useTextEditingController(),
                      hintText: context.l10n.search,
                    ))),
                Align(
                    alignment: Alignment.centerRight,
                    child: InteractableBox(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(context.l10n.cancel,
                          style: TextStyle(
                            color: context.theme.text,
                            fontFamily: 'PingFang HK',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          )),
                    )),
              ])),
          Expanded(
              child: ListView.builder(
                  itemCount: filterList.value.length,
                  itemBuilder: (BuildContext context, int index) => _Item(
                        asset: filterList.value[index],
                        selectedAssetId: selectedAssetId,
                        onTap: onTap,
                      ))),
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
  Widget build(BuildContext context) => InteractableBox(
        child: SizedBox(
            height: 80,
            child: Row(children: [
              SymbolIcon(
                  symbolUrl: asset.iconUrl,
                  chainUrl: asset.chainIconUrl,
                  size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      asset.symbol.overflow,
                      style: TextStyle(
                        color: context.theme.text,
                        fontSize: 16,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
        onTap: () => onTap(asset.assetId),
      );
}

typedef AssetSelectCallback = void Function(String);
