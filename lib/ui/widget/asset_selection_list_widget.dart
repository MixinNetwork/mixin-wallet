import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../db/dao/extension.dart';
import '../../db/mixin_database.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/logger.dart';
import '../../util/native_scroll.dart';
import '../../util/r.dart';
import '../../util/transak.dart';
import '../../wyre/wyre_constants.dart';
import '../router/mixin_routes.dart';
import 'chain_network_label.dart';
import 'mixin_bottom_sheet.dart';
import 'search_header_widget.dart';
import 'symbol.dart';
import 'text.dart';

class BuyAssetSelectionBottomSheet extends StatelessWidget {
  const BuyAssetSelectionBottomSheet({Key? key}) : super(key: key);

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
        source: () async* {
          final assets =
              await context.appServices.findOrSyncAssets(supportedCryptosId);
          yield assets;
        },
        useSearchApi: false,
        onCancelPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.replace(homeUri);
          }
        },
      );
}

Future<AssetResult?> showAssetSelectionBottomSheet({
  required BuildContext context,
  String? initialSelected,
  AssetSourceLoader? source,
  Set<String> ignoreAssets = const {},
  bool useSearchApi = false,
}) =>
    showMixinBottomSheet<AssetResult>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AssetSelectionListWidget(
        selectedAssetId: initialSelected,
        onTap: (asset) {
          Navigator.pop(context, asset);
        },
        source: source,
        ignoreAssets: ignoreAssets,
        useSearchApi: useSearchApi,
        onCancelPressed: () => Navigator.pop(context),
      ),
    );

typedef AssetSourceLoader = Stream<List<AssetResult>> Function();

class AssetSelectionListWidget extends HookWidget {
  const AssetSelectionListWidget({
    Key? key,
    required this.onTap,
    this.selectedAssetId,
    this.source,
    this.ignoreAssets = const {},
    this.useSearchApi = false,
    this.hasNullChoose = false,
    required this.onCancelPressed,
  }) : super(key: key);

  final String? selectedAssetId;
  final AssetSelectCallback onTap;

  final AssetSourceLoader? source;

  /// The assets which was ignore and not show in the list.
  final Set<String> ignoreAssets;

  final bool useSearchApi;

  final VoidCallback onCancelPressed;

  /// Show a null choose item in the list.
  final bool hasNullChoose;

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
            .toList();
      },
      [filterKeyword, assetResults],
    );
    useEffect(() {
      if (!useSearchApi) {
        return null;
      }
      // ignore: strict_raw_type
      CancelableOperation? lastRequest;
      final listen = keywordStream
          .where((event) => event.isNotEmpty)
          .debounceTime(const Duration(milliseconds: 500))
          .map(
        (String keyword) {
          debugPrint('search keyword: $keyword');
          return CancelableOperation.fromFuture(
            context.appServices.searchAndUpdateAsset(keyword),
          );
        },
      ).listen((event) {
        lastRequest?.cancel();
        lastRequest = event;
      });
      return () {
        listen.cancel();
        lastRequest?.cancel();
      };
    }, [keywordStream, useSearchApi]);

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
          Expanded(
            child: NativeScrollBuilder(
              builder: (context, controller) => ListView.builder(
                controller: controller,
                itemCount:
                    hasNullChoose ? filterList.length + 1 : filterList.length,
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
            ),
          ),
        ],
      ),
    );
  }
}

class _NoChooseItem extends StatelessWidget {
  const _NoChooseItem({
    Key? key,
    required this.onTap,
    required this.selected,
  }) : super(key: key);

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
                        ChainNetworkLabel(chainId: asset.chainId),
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
