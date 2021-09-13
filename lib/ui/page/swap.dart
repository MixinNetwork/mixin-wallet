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
      final supportedIds =
          (await swapClient.getAssets()).data.map((e) => e.uuid).toList();
      return context.appServices.findOrSyncAssets(supportedIds);
    }).data;

    final source = context.queryParameters['source'];
    AssetResult? sourceAsset;
    if (source != null) {
      sourceAsset = supportedAssets
          ?.where((e) => e.assetId.equalsIgnoreCase(source))
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
                initialSource: sourceAsset),
      ),
    );
  }
}

class _Body extends HookWidget {
  const _Body({
    Key? key,
    required this.swapClient,
    required this.supportedAssets,
    this.initialSource,
  }) : super(key: key);

  final Client swapClient;
  final List<AssetResult> supportedAssets;
  final AssetResult? initialSource;

  @override
  Widget build(BuildContext context) {
    assert(supportedAssets.length > 1);
    final sourceAsset = useState(initialSource ?? supportedAssets[0]);
    final destAsset = useState(getInitialDest());
    final routeData = useState<RouteData?>(null);
    final sourceTextController = useTextEditingController();
    final destTextController = useTextEditingController();
    final sourceFocusNode = useFocusNode(debugLabel: 'source input');
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
        final routeDataResp = (await swapClient.getRoutes(
                sourceAsset.value.assetId,
                destAsset.value.assetId,
                sourceTextController.text))
            .data;
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
          ),
          const SizedBox(height: 12),
          Row(children: [
            const SizedBox(width: 16),
            InkResponse(
                radius: 40,
                onTap: () {
                  final tmp = sourceAsset.value;
                  sourceAsset.value = destAsset.value;
                  destAsset.value = tmp;
                  sourceTextController.text = '';
                  destTextController.text = '';
                  routeData.value = null;
                },
                child: SizedBox.square(
                    dimension: 40,
                    child: ClipOval(
                        child: DecoratedBox(
                      decoration: const BoxDecoration(
                        color: Color(0xfff8f8f8),
                      ),
                      child: Center(
                          child: SvgPicture.asset(
                        R.resourcesIcSwitchSvg,
                        color: context.colorScheme.primaryText,
                      )),
                    )))),
          ]),
          const SizedBox(height: 12),
          _AssetItem(
            asset: destAsset,
            textController: destTextController,
            supportedAssets: supportedAssets,
            readOnly: true,
          ),
          const SizedBox(height: 12),
          if (routeData.value != null)
            TipTile(
              text: '${context.l10n.slippage} $slippageDisplay',
              highlight: slippageDisplay,
              highlightColor: colorOfSlippage(context, slippage),
            ),
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
                        action: () async {
                          try {
                            await MixSwap.client.getOrder(traceId);
                            return true;
                          } catch (e) {
                            return false;
                          }
                        },
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
          const SizedBox(height: 36),
        ]));
  }

  AssetResult getInitialDest() {
    if (initialSource == null) {
      return supportedAssets[1];
    } else {
      if (supportedAssets[0].assetId.equalsIgnoreCase(initialSource!.assetId)) {
        return supportedAssets[1];
      } else {
        return supportedAssets[0];
      }
    }
  }

  Color colorOfSlippage(BuildContext context, double slippage) => slippage > 5
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
    this.focusNode,
  }) : super(key: key);

  final ValueNotifier<AssetResult> asset;
  final TextEditingController textController;
  final List<AssetResult> supportedAssets;
  final bool readOnly;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    void showAssetListBottomSheet(ValueNotifier<AssetResult> asset) {
      showMixinBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => AssetSelectionListWidget(
          onTap: (AssetResult assetResult) {
            asset.value = assetResult;
          },
          selectedAssetId: asset.value.assetId,
          assetResultList: supportedAssets,
        ),
      );
    }

    return RoundContainer(
      height: 64,
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      child: Row(children: [
        InkWell(
            onTap: () => showAssetListBottomSheet(asset),
            child: SymbolIconWithBorder(
              symbolUrl: asset.value.iconUrl,
              chainUrl: asset.value.chainIconUrl,
              size: 40,
              chainBorder: const BorderSide(color: Color(0xfff8f8f8), width: 1),
              symbolBorder:
                  const BorderSide(color: Color(0xfff8f8f8), width: 2),
              chainSize: 8,
            )),
        const SizedBox(width: 10),
        InkWell(
            onTap: () => showAssetListBottomSheet(asset),
            child: Text(
              asset.value.symbol,
              style: TextStyle(
                color: context.colorScheme.primaryText,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            )),
        const SizedBox(width: 10),
        SvgPicture.asset(R.resourcesIcArrowDownSvg),
        const SizedBox(width: 10),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
                height: 38,
                child: _AmountTextField(
                  focusNode: focusNode,
                  controller: textController,
                  readOnly: readOnly,
                )),
            const SizedBox(height: 7),
            Text(
              '${asset.value.balance} ${context.l10n.balance}',
              style: TextStyle(
                color: context.colorScheme.secondaryText,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.end,
            ),
          ],
        )),
        const SizedBox(width: 20),
      ]),
    );
  }
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
