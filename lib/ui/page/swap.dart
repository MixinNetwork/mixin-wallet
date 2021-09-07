import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mixswap_sdk_dart/mixswap_sdk_dart.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import '../../db/mixin_database.dart';
import '../../util/constants.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/r.dart';
import '../widget/action_button.dart';
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
    final swapClient = Client(null);
    final supportedAssets = useMemoizedFuture(() async {
      final supportedIds =
          (await swapClient.getAssets()).data.map((e) => e.uuid).toList();
      return context.appServices.findOrSyncAssets(supportedIds);
    }).data;
    if (supportedAssets == null || supportedAssets.isEmpty) {
      return const SizedBox();
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
        actions: [
          ActionButton(
            name: R.resourcesTransactionSvg,
            size: 24,
            onTap: () {},
          )
        ],
      ),
      body: _Body(swapClient: swapClient, supportedAssets: supportedAssets),
    );
  }
}

class _Body extends HookWidget {
  const _Body({
    Key? key,
    required this.swapClient,
    required this.supportedAssets,
  }) : super(key: key);

  final Client swapClient;
  final List<AssetResult> supportedAssets;

  @override
  Widget build(BuildContext context) {
    assert(supportedAssets.length > 1);
    final sourceAsset = useState(supportedAssets[0]);
    final destAsset = useState(supportedAssets[1]);
    final bestReceiveAmount = useState('');
    final sourceTextController = useTextEditingController();
    final destTextController = useTextEditingController();
    final sourceFocusNode = useFocusNode(debugLabel: 'source input');
    final destFocusNode = useFocusNode(debugLabel: 'dest input');

    Future<void> updateAmount(
      String text,
      FocusNode inputFocusNode,
      TextEditingController effectedController,
    ) async {
      final amount = double.tryParse(text) ?? 0;
      if (amount == 0) {
        effectedController.text = '';
        bestReceiveAmount.value = '';
        return;
      }

      if (inputFocusNode.hasFocus) {
        final routeData = (await swapClient.getRoutes(sourceAsset.value.assetId,
                destAsset.value.assetId, sourceTextController.text))
            .data;
        effectedController.text = routeData.bestSourceReceiveAmount;
        bestReceiveAmount.value = routeData.bestSourceReceiveAmount;
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
              focusNode: sourceFocusNode,
              textController: sourceTextController,
              supportedAssets: supportedAssets),
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
                  bestReceiveAmount.value = '';
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
              focusNode: destFocusNode,
              textController: destTextController,
              supportedAssets: supportedAssets),
          const SizedBox(height: 8),
          TipTile(text: '${context.l10n.networkFee} '),
          const Spacer(),
          HookBuilder(
              builder: (context) => _SwapButton(
                    enable: bestReceiveAmount.value.isNotEmpty,
                    onTap: () async {
                      if (bestReceiveAmount.value.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: Text(context.l10n.emptyAmount)));
                        return;
                      }

                      final traceId = const Uuid().v4();
                      final memo = buildMixSwapMemo(destAsset.value.assetId);

                      final uri = Uri.https('mixin.one', 'pay', {
                        'amount': sourceTextController.text,
                        'trace': traceId,
                        'asset': sourceAsset.value.assetId,
                        'recipient': '6a4a121d-9673-4a7e-a93e-cb9ca4bb83a2',
                        'memo': memo,
                      });

                      final succeed = await showAndWaitingExternalAction(
                        context: context,
                        uri: uri,
                        action: () =>
                            context.appServices.updateSnapshotByTraceId(
                          traceId: traceId,
                        ),
                        hint: Text(context.l10n.waitingActionDone),
                      );

                      if (succeed) {
                        context.pop();
                      }
                    },
                  )),
          const SizedBox(height: 36),
        ]));
  }

  String buildMixSwapMemo(
    String targetUuid, {
    String routeId = '0',
    double? atLeastReceive,
  }) {
    final memoBuffer = StringBuffer('0|')
      ..write(targetUuid)
      ..write('|')
      ..write(routeId);
    if (atLeastReceive != null) {
      memoBuffer
        ..write('|')
        ..write(atLeastReceive);
    }
    return base64Encode(utf8.encode(memoBuffer.toString()));
  }
}

class _AssetItem extends HookWidget {
  const _AssetItem({
    Key? key,
    required this.asset,
    required this.focusNode,
    required this.textController,
    required this.supportedAssets,
  }) : super(key: key);

  final ValueNotifier<AssetResult> asset;
  final FocusNode focusNode;
  final TextEditingController textController;
  final List<AssetResult> supportedAssets;

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
    required this.focusNode,
    required this.controller,
  }) : super(key: key);

  final FocusNode focusNode;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => TextField(
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
