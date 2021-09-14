import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mixswap_sdk_dart/mixswap_sdk_dart.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import '../../db/mixin_database.dart';
import '../../service/mix_swap.dart';
import '../../util/constants.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/r.dart';
import '../brightness_theme_data.dart';
import '../router/mixin_routes.dart';
import '../widget/asset_selection_list_widget.dart';
import '../widget/buttons.dart';
import '../widget/external_action_confirm.dart';
import '../widget/mixin_appbar.dart';
import '../widget/mixin_bottom_sheet.dart';
import '../widget/round_container.dart';
import '../widget/symbol.dart';
import '../widget/tip_tile.dart';

class Swap extends HookWidget {
  const Swap({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final swapClient = MixSwap.client;
    final supportedAssets = useMemoizedFuture(() async {
      var supportedIds = supportedAssetIds;
      if (supportedIds == null || supportedIds.isEmpty) {
        supportedIds =
            (await swapClient.getAssets()).data.map((e) => e.uuid).toList();
      } else {
        unawaited(_updateSupportedAssets(swapClient));
      }
      return context.appServices.findOrSyncAssets(supportedIds);
    }).data;

    final source = context.queryParameters['source'];
    AssetResult? sourceAsset;
    if (source != null) {
      sourceAsset = supportedAssets
          ?.where((e) => e.assetId.equalsIgnoreCase(source))
          .firstOrNull;
    } else if (sourceAssetId != null) {
      sourceAsset = supportedAssets
          ?.where((e) => e.assetId.equalsIgnoreCase(sourceAssetId))
          .firstOrNull;
    }
    AssetResult? destAsset;
    if (destAssetId != null) {
      destAsset = supportedAssets
          ?.where((e) => e.assetId.equalsIgnoreCase(destAssetId))
          .firstOrNull;
    }

    return Scaffold(
      backgroundColor: context.colorScheme.background,
      appBar: MixinAppBar(
        leading: const MixinBackButton2(),
        backgroundColor: context.colorScheme.background,
        title: SelectableText(
          context.l10n.swap,
          style: TextStyle(
            color: context.colorScheme.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          enableInteractiveSelection: false,
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: (supportedAssets == null || supportedAssets.isEmpty)
            ? const Center(child: CircularProgressIndicator())
            : _Body(
                swapClient: swapClient,
                supportedAssets: supportedAssets,
                initialSource: sourceAsset,
                initialDest: destAsset),
      ),
    );
  }

  Future<void> _updateSupportedAssets(Client swapClient) async {
    final assetIds =
        (await swapClient.getAssets()).data.map((e) => e.uuid).toList();
    await setSupportedAssetIds(assetIds);
  }
}

class _Body extends HookWidget {
  const _Body({
    Key? key,
    required this.swapClient,
    required this.supportedAssets,
    this.initialSource,
    this.initialDest,
  }) : super(key: key);

  final Client swapClient;
  final List<AssetResult> supportedAssets;
  final AssetResult? initialSource;
  final AssetResult? initialDest;

  @override
  Widget build(BuildContext context) {
    assert(supportedAssets.length > 1);
    final sourceAsset = useState(initialSource ?? _getInitialSource());
    final destAsset = useState(initialDest ?? _getInitialDest());
    final routeData = useState<RouteData?>(null);
    final sourceTextController = useTextEditingController();
    final destTextController = useTextEditingController();
    final sourceFocusNode = useFocusNode(debugLabel: 'source input');
    final showLoading = useState(false);
    final slippageKeys = [
      sourceAsset.value,
      destAsset.value,
      sourceTextController.text,
      destTextController.text
    ];
    final slippage =
        useMemoized(() => calcSlippage(routeData.value), slippageKeys);
    final slippageDisplay =
        useMemoized(() => displaySlippage(slippage), slippageKeys);

    Future<void> updateAmount(
      String text,
      FocusNode inputFocusNode,
      TextEditingController effectedController,
    ) async {
      final amount = double.tryParse(text) ?? 0;
      if (amount == 0) {
        effectedController.text = '';
        routeData.value = null;
        return;
      }

      if (inputFocusNode.hasFocus) {
        showLoading.value = true;
        final routeDataResp = (await swapClient.getRoutes(
                sourceAsset.value.assetId,
                destAsset.value.assetId,
                sourceTextController.text))
            .data;
        showLoading.value = false;
        effectedController.text = routeDataResp.bestSourceReceiveAmount;
        routeData.value = routeDataResp;
      }
    }

    final sourceTextStream = useValueNotifierConvertSteam(sourceTextController);
    useEffect(() {
      final listen = sourceTextStream
          .map((event) => event.text)
          .distinct()
          .debounceTime(const Duration(milliseconds: 500))
          .map((String text) =>
              updateAmount(text, sourceFocusNode, destTextController))
          .listen((_) {});

      return listen.cancel;
    });

    return Container(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(topRadius)),
          color: context.colorScheme.background,
        ),
        child: Column(children: [
          const SizedBox(height: 20),
          _AssetItem(
            asset: sourceAsset,
            textController: sourceTextController,
            supportedAssets: supportedAssets,
            readOnly: false,
            focusNode: sourceFocusNode,
            onSelected: () => sourceTextController.text = '',
          ),
          const SizedBox(height: 12),
          Row(children: [
            const SizedBox(width: 16),
            InkResponse(
                radius: 40,
                onTap: () async {
                  final tmp = sourceAsset.value;
                  sourceAsset.value = destAsset.value;
                  destAsset.value = tmp;
                  sourceTextController.text = '';
                  destTextController.text = '';
                  routeData.value = null;
                  await setSourceAssetId(sourceAsset.value.assetId);
                  await setDestAssetId(destAsset.value.assetId);
                },
                child: Center(
                  child: SizedBox.square(
                    dimension: 40,
                    child: SvgPicture.asset(
                      R.resourcesIcSwitchSvg,
                      color: context.colorScheme.primaryText,
                    ),
                  ),
                )),
            Expanded(
                child: SelectableText.rich(
              '${context.l10n.balance} ${sourceAsset.value.balance} ${sourceAsset.value.symbol}'
                  .highlight(
                TextStyle(
                  color: context.colorScheme.thirdText,
                  fontSize: 12,
                ),
                '${sourceAsset.value.balance} ${sourceAsset.value.symbol}',
                TextStyle(
                    color: context.colorScheme.primaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
              textAlign: TextAlign.right,
              enableInteractiveSelection: false,
            )),
            const SizedBox(width: 16),
          ]),
          const SizedBox(height: 12),
          _AssetItem(
            asset: destAsset,
            textController: destTextController,
            supportedAssets: supportedAssets,
            readOnly: true,
            showLoading: showLoading.value,
            onSelected: () => sourceTextController.text = '',
          ),
          const SizedBox(height: 12),
          if (routeData.value != null)
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: TipTile(
                  text: '${context.l10n.slippage} $slippageDisplay',
                  highlight: slippageDisplay,
                  highlightColor: _colorOfSlippage(context, slippage),
                )),
          const Spacer(),
          HookBuilder(
              builder: (context) => _SwapButton(
                    enable: routeData.value != null &&
                        slippage <= supportMaxSlippage,
                    onTap: () async {
                      if (routeData.value == null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: Text(context.l10n.emptyAmount)));
                        return;
                      }
                      if (slippage > supportMaxSlippage) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: Text(context.l10n
                                .slippageOver('$supportMaxSlippage%'))));
                        return;
                      }

                      final traceId = const Uuid().v4();
                      final memo = buildMixSwapMemo(destAsset.value.assetId);

                      final uri = Uri.https('mixin.one', 'pay', {
                        'amount': sourceTextController.text,
                        'trace': traceId,
                        'asset': sourceAsset.value.assetId,
                        'recipient': mixSwapUserId,
                        'memo': memo,
                      });

                      final ret = await showAndWaitingExternalAction(
                        context: context,
                        uri: uri,
                        action: () => context.appServices
                            .updateSnapshotByTraceId(traceId: traceId),
                        hint: Text(context.l10n.waitingActionDone),
                      );

                      if (ret) {
                        context.push(swapDetailPath.toUri({'id': traceId}),
                            queryParameters: {
                              'source': sourceAsset.value.assetId,
                              'dest': destAsset.value.assetId,
                              'amount': sourceTextController.text,
                            });
                      }
                    },
                  )),
          const SizedBox(height: 16),
        ]));
  }

  AssetResult _getInitialSource() =>
      supportedAssets
          .where((e) => e.assetId.equalsIgnoreCase(defaultSourceId))
          .firstOrNull ??
      supportedAssets[0];

  AssetResult _getInitialDest() =>
      supportedAssets
          .where((e) => e.assetId.equalsIgnoreCase(defaultDestId))
          .firstOrNull ??
      supportedAssets[1];

  Color _colorOfSlippage(BuildContext context, double slippage) => slippage > 5
      ? lightBrightnessThemeData.red
      : slippage > 1
          ? lightBrightnessThemeData.warning
          : lightBrightnessThemeData.green;
}

class _AssetItem extends HookWidget {
  const _AssetItem({
    Key? key,
    required this.asset,
    required this.textController,
    required this.supportedAssets,
    required this.readOnly,
    required this.onSelected,
    this.showLoading = false,
    this.focusNode,
  }) : super(key: key);

  final ValueNotifier<AssetResult> asset;
  final TextEditingController textController;
  final List<AssetResult> supportedAssets;
  final VoidCallback onSelected;
  final bool readOnly;
  final bool showLoading;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    void showAssetListBottomSheet(ValueNotifier<AssetResult> asset) {
      showMixinBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => AssetSelectionListWidget(
          onTap: (AssetResult assetResult) async {
            asset.value = assetResult;
            if (readOnly) {
              await setDestAssetId(assetResult.assetId);
            } else {
              await setSourceAssetId(assetResult.assetId);
            }
            onSelected.call();
          },
          selectedAssetId: asset.value.assetId,
          assetResultList: supportedAssets,
        ),
      );
    }

    return RoundContainer(
      height: 64,
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      child: Row(children: [
        InkWell(
            onTap: () => showAssetListBottomSheet(asset),
            child: Row(children: [
              SymbolIconWithBorder(
                symbolUrl: asset.value.iconUrl,
                chainUrl: asset.value.chainIconUrl,
                size: 40,
                chainBorder: const BorderSide(
                  color: Color(0xfff8f8f8),
                  width: 1.5,
                ),
                chainSize: 14,
              ),
              const SizedBox(width: 10),
              Text(
                asset.value.symbol,
                style: TextStyle(
                  color: context.colorScheme.primaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 10),
              SvgPicture.asset(R.resourcesIcArrowDownSvg),
              const SizedBox(width: 10),
            ])),
        if (!readOnly)
          _SourceAmountArea(
              amountTextField: _AmountTextField(
                focusNode: focusNode,
                controller: textController,
                readOnly: false,
              ),
              asset: asset)
        else
          _DestAmountArea(
              showLoading: showLoading,
              amountTextField: _AmountTextField(
                focusNode: focusNode,
                controller: textController,
                readOnly: true,
              )),
      ]),
    );
  }
}

class _SourceAmountArea extends StatelessWidget {
  const _SourceAmountArea({
    Key? key,
    required this.amountTextField,
    required this.asset,
  }) : super(key: key);

  final ValueNotifier<AssetResult> asset;
  final Widget amountTextField;

  @override
  Widget build(BuildContext context) => Expanded(
          child: Align(
        alignment: Alignment.centerRight,
        child: amountTextField,
      ));
}

class _DestAmountArea extends StatelessWidget {
  const _DestAmountArea({
    Key? key,
    required this.showLoading,
    required this.amountTextField,
  }) : super(key: key);

  final bool showLoading;
  final Widget amountTextField;

  @override
  Widget build(BuildContext context) => Expanded(
      child: Align(
          alignment: Alignment.centerRight,
          child: AnimatedSwitcher(
              duration: Duration.zero,
              child: showLoading
                  ? SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        color: context.colorScheme.thirdText,
                        strokeWidth: 2,
                      ))
                  : amountTextField)));
}

class _AmountTextField extends StatelessWidget {
  const _AmountTextField({
    Key? key,
    required this.controller,
    required this.readOnly,
    this.focusNode,
  }) : super(key: key);

  final FocusNode? focusNode;
  final TextEditingController controller;
  final bool readOnly;

  @override
  Widget build(BuildContext context) => TextField(
        readOnly: readOnly,
        focusNode: focusNode,
        autofocus: !readOnly,
        style: TextStyle(
          color: context.colorScheme.primaryText,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        maxLines: 1,
        decoration: InputDecoration(
          hintText: '0.000',
          border: InputBorder.none,
          hintStyle: TextStyle(
            color: context.colorScheme.thirdText,
            fontWeight: FontWeight.w400,
          ),
        ),
        controller: controller,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}'))
        ],
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.end,
      );
}

class _SwapButton extends StatelessWidget {
  const _SwapButton({
    Key? key,
    required this.onTap,
    required this.enable,
  }) : super(key: key);

  final VoidCallback onTap;
  final bool enable;

  @override
  Widget build(BuildContext context) => Material(
        borderRadius: BorderRadius.circular(72),
        color: enable ? const Color(0xFF333333) : const Color(0x33333333),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(72),
          child: SizedBox(
            width: 110,
            height: 48,
            child: Center(
              child: Text(
                context.l10n.swap,
                style: TextStyle(
                  fontSize: 16,
                  color: context.colorScheme.background,
                ),
              ),
            ),
          ),
        ),
      );
}
