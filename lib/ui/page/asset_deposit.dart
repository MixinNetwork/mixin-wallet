import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../db/converter/deposit_entry_converter.dart';
import '../../db/dao/extension.dart';
import '../../db/mixin_database.dart';
import '../../service/account_provider.dart';
import '../../util/constants.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/native_scroll.dart';
import '../../util/r.dart';
import '../../util/web/web_utils.dart';
import '../router/mixin_routes.dart';
import '../widget/action_button.dart';
import '../widget/buttons.dart';
import '../widget/dialog/deposit_choose_network_bottom_sheet.dart';
import '../widget/dialog/request_payment_bottom_sheet.dart';
import '../widget/dialog/request_payment_result_bottom_sheet.dart';
import '../widget/mixin_appbar.dart';
import '../widget/mixin_bottom_sheet.dart';
import '../widget/symbol.dart';
import '../widget/tip_tile.dart';

class AssetDeposit extends StatelessWidget {
  const AssetDeposit({super.key});

  @override
  Widget build(BuildContext context) =>
      _AssetDepositLoader(assetId: context.pathParameters['id']!);
}

class _DepositScaffold extends StatelessWidget {
  const _DepositScaffold({
    required this.body,
    this.asset,
  });

  final AssetResult? asset;
  final Widget body;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.colorScheme.background,
        appBar: MixinAppBar(
          leading: const MixinBackButton2(),
          backgroundColor: context.colorScheme.background,
          title: SelectableText(
            asset == null
                ? context.l10n.deposit
                : '${context.l10n.deposit} ${asset!.symbol}',
            style: TextStyle(
              color: context.colorScheme.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            enableInteractiveSelection: false,
          ),
          actions: <Widget>[
            ActionButton(
                name: R.resourcesIcQuestionSvg,
                color: Colors.black,
                onTap: () {
                  context.toExternal(depositHelpLink, openNewTab: true);
                }),
          ],
        ),
        body: body,
      );
}

class _AssetDepositLoader extends HookWidget {
  const _AssetDepositLoader({
    required this.assetId,
  });

  final String assetId;

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      if (assetId == omniUSDT) {
        scheduleMicrotask(() {
          context.replace(notFoundUri);
        });
        return null;
      }
      var cancel = false;
      scheduleMicrotask(() async {
        var asset = await context.appServices.updateAsset(assetId);
        while (!cancel &&
            (asset.getDestination() == null ||
                asset.getDestination()!.isEmpty)) {
          // delay 2 seconds to request again if we didn't get the address.
          // https://developers.mixin.one/document/wallet/api/asset
          await Future<void>.delayed(const Duration(milliseconds: 2000));
          asset = await context.appServices.updateAsset(assetId);
        }
      });
      return () {
        cancel = true;
      };
    }, [assetId]);

    final faitCurrency = useAccountFaitCurrency();
    final data = useMemoizedStream(
      () => context.appServices
          .assetResult(assetId, faitCurrency)
          .watchSingleOrNull(),
      keys: [assetId, faitCurrency],
    ).data;

    if (data == null) {
      return _DepositScaffold(
        body: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child:
                CircularProgressIndicator(color: context.colorScheme.surface),
          ),
        ),
      );
    }
    return _DepositScaffold(
      asset: data,
      body: _AssetDepositBody(asset: data),
    );
  }
}

class _AssetDepositBody extends HookWidget {
  const _AssetDepositBody({
    required this.asset,
  });

  final AssetResult asset;

  @override
  Widget build(BuildContext context) {
    final depositEntry = useState<DepositEntry?>(null);

    final depositEntries = useMemoized(
      () =>
          const DepositEntryConverter()
              .fromSql(asset.depositEntries)
              ?.reversed
              .toList() ??
          const [],
      [asset.assetId, asset.depositEntries],
    );

    useEffect(() {
      if (depositEntries.length > 1 && asset.assetId == bitcoin) {
        depositEntry.value = depositEntries.firstOrNull;
      } else {
        depositEntry.value = null;
      }
    }, [asset.assetId]);

    final tag =
        depositEntry.value != null ? depositEntry.value?.tag : asset.tag;
    final address = depositEntry.value != null
        ? depositEntry.value?.destination
        : asset.destination;

    useMemoized(() async {
      await Future<void>.delayed(Duration.zero);
      await showDepositChooseNetworkBottomSheet(context, asset: asset);
      if (tag == null || tag.isEmpty) {
        return;
      }
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _MemoWarningDialog(
          symbol: asset.symbol,
          onTap: () {
            scheduleMicrotask(() {
              Navigator.of(context).pop(true);
            });
          },
        ),
      );
    }, [asset.assetId]);

    return NativeScrollBuilder(
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          if (usdtAssets.containsKey(asset.assetId))
            _UsdtChooseLayout(asset: asset),
          if (depositEntries.length > 1 && asset.assetId == bitcoin)
            _DepositEntryChooseLayout(
              asset: asset,
              entries: depositEntries,
              onSelected: (entry) => depositEntry.value = entry,
              selectedAddress: address!,
            ),
          if (tag != null && tag.isNotEmpty)
            _MemoLayout(asset: asset, tag: tag),
          if (address != null && address.isNotEmpty)
            _AddressLayout(
              asset: asset,
              address: address,
              showDepositNotice: tag != null && tag.isNotEmpty,
            )
          else
            const _AddressLoadingWidget(),
          const SizedBox(height: 8),
          TipListLayout(
            children: [
              for (final tip in asset.getTip(context))
                TipTile(
                  text: tip,
                  foregroundColor: context.colorScheme.thirdText,
                  fontWeight: FontWeight.w600,
                ),
              TipTile(
                text: context.l10n.depositConfirmation(asset.confirmations),
                highlight: asset.confirmations.toString(),
                foregroundColor: context.colorScheme.thirdText,
                fontWeight: FontWeight.w600,
              ),
              if (asset.needShowReserve)
                TipTile(
                  text: context.l10n
                      .depositReserve('${asset.reserve} ${asset.symbol}'),
                  highlight: '${asset.reserve} ${asset.symbol}',
                  foregroundColor: context.colorScheme.thirdText,
                  fontWeight: FontWeight.w600,
                ),
            ],
          ),
          const SizedBox(height: 32),
          if (address != null && address.isNotEmpty)
            Center(
              child: MixinPrimaryTextButton(
                onTap: () async {
                  final result = await showMixinBottomSheet<List<String>>(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => RequestPaymentBottomSheet(
                      asset: asset,
                      address: address,
                      tag: tag,
                    ),
                  );
                  if (result == null || result.isEmpty) {
                    return;
                  }
                  assert(result.length == 2, 'Invalid result');
                  final amount = result[0];
                  final memo = result[1];

                  final userId =
                      context.read<AuthProvider>().value!.account.userId;

                  await showRequestPaymentResultBottomSheet(
                    context,
                    asset: asset,
                    address: address,
                    tag: tag,
                    amount: amount,
                    memo: memo,
                    recipient: userId,
                  );
                },
                text: context.l10n.requestPayment,
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _MemoLayout extends StatelessWidget {
  _MemoLayout({
    required this.asset,
    required this.tag,
  }) : assert(asset.needShowMemo);

  final AssetResult asset;

  final String tag;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          _HeaderText(context.l10n.memo),
          const SizedBox(height: 8),
          _CopyableText(tag),
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: SelectableText(
              context.l10n.depositMemoNotice,
              enableInteractiveSelection: false,
              style: TextStyle(
                fontSize: 13,
                color: context.colorScheme.red,
              ),
            ),
          ),
          const SizedBox(height: 32),
          _QrcodeImage(data: tag, asset: asset),
          const SizedBox(height: 24),
        ],
      );
}

class _MemoWarningDialog extends StatelessWidget {
  const _MemoWarningDialog({
    required this.symbol,
    required this.onTap,
  });

  final String symbol;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Center(
      child: Material(
          color: context.theme.background,
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
              width: 300,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),
                    Text(context.l10n.notice,
                        style: TextStyle(
                          color: context.colorScheme.primaryText,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(height: 16),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 32),
                        child: Text(context.l10n.depositNotice(symbol),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFFF6550),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ))),
                    const SizedBox(height: 32),
                    ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateColor.resolveWith(
                              (states) => const Color(0xFF4B7CDD)),
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 24,
                          )),
                          minimumSize:
                              MaterialStateProperty.all(const Size(110, 48)),
                          foregroundColor: MaterialStateProperty.all(
                              context.colorScheme.background),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50))),
                        ),
                        onPressed: onTap,
                        child: SelectableText(
                          context.l10n.ok,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          onTap: onTap,
                          enableInteractiveSelection: false,
                        )),
                    const SizedBox(height: 32)
                  ]))));
}

class _AddressLayout extends StatelessWidget {
  const _AddressLayout({
    required this.asset,
    required this.address,
    required this.showDepositNotice,
  });

  final AssetResult asset;
  final String address;

  final bool showDepositNotice;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          _HeaderText(context.l10n.address),
          const SizedBox(height: 8),
          _CopyableText(address),
          if (showDepositNotice)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SelectableText(
                  context.l10n.depositNotice(asset.symbol),
                  enableInteractiveSelection: false,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.colorScheme.red,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 32),
          _QrcodeImage(data: address, asset: asset),
          const SizedBox(height: 32),
        ],
      );
}

class _AddressLoadingWidget extends StatelessWidget {
  const _AddressLoadingWidget();

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          _HeaderText(context.l10n.address),
          SizedBox(
            height: 200,
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: context.colorScheme.surface,
                ),
              ),
            ),
          ),
        ],
      );
}

class _HeaderText extends StatelessWidget {
  const _HeaderText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: SelectableText(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: context.colorScheme.secondaryText,
          ),
          enableInteractiveSelection: false,
        ),
      );
}

class _CopyableText extends StatelessWidget {
  const _CopyableText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SelectableText(
              text,
              style: TextStyle(
                color: context.colorScheme.primaryText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Transform.translate(
            offset: const Offset(0, -2),
            child: InkResponse(
              radius: 24,
              child: SvgPicture.asset(
                R.resourcesIcCopySvg,
                width: 24,
                height: 24,
              ),
              onTap: () {
                setClipboardText(text);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text(context.l10n.copyToClipboard)));
              },
            ),
          )
        ],
      );
}

class _QrcodeImage extends StatelessWidget {
  const _QrcodeImage({
    required this.data,
    required this.asset,
  });

  final String data;

  final AssetResult asset;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 160,
        height: 160,
        child: Stack(
          alignment: Alignment.center,
          children: [
            QrImage(
              data: data,
              size: 160,
              padding: EdgeInsets.zero,
            ),
            Container(
              padding: const EdgeInsets.all(0.5),
              decoration: BoxDecoration(
                color: context.colorScheme.background,
                shape: BoxShape.circle,
              ),
              child: SymbolIconWithBorder(
                symbolUrl: asset.iconUrl,
                chainUrl: asset.chainIconUrl,
                chainBorder: BorderSide(
                  color: context.colorScheme.background,
                  width: 1.5,
                ),
                size: 24,
                chainSize: 5,
              ),
            ),
          ],
        ),
      );
}

class _UsdtChooseLayout extends StatelessWidget {
  const _UsdtChooseLayout({required this.asset});

  final AssetResult asset;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _HeaderText(context.l10n.networkType),
          const SizedBox(height: 12),
          Wrap(
            direction: Axis.horizontal,
            spacing: 12,
            runSpacing: 16,
            children: [
              for (final assetId in usdtAssets.keys)
                _NetworkTypeItem(
                  selected: assetId == asset.assetId,
                  onTap: () {
                    context.replace(
                      assetDepositPath.toUri({'id': assetId}),
                    );
                  },
                  name: usdtAssets[assetId]!,
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      );
}

class _DepositEntryChooseLayout extends StatelessWidget {
  const _DepositEntryChooseLayout({
    required this.entries,
    required this.onSelected,
    required this.asset,
    required this.selectedAddress,
  });

  final List<DepositEntry> entries;

  final void Function(DepositEntry) onSelected;
  final AssetResult asset;
  final String selectedAddress;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _HeaderText(context.l10n.networkType),
          const SizedBox(height: 12),
          Wrap(
            direction: Axis.horizontal,
            spacing: 12,
            runSpacing: 16,
            children: [
              for (final entry in entries)
                _NetworkTypeItem(
                  selected: selectedAddress == entry.destination,
                  onTap: () => onSelected(entry),
                  name: _getDestinationType(
                    entry.properties,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      );
}

class _NetworkTypeItem extends StatelessWidget {
  const _NetworkTypeItem({
    required this.selected,
    required this.onTap,
    required this.name,
  });

  final bool selected;
  final VoidCallback onTap;
  final String name;

  @override
  Widget build(BuildContext context) {
    final boardRadius = BorderRadius.circular(36);
    return Material(
      color: selected
          ? context.colorScheme.primaryText
          : context.colorScheme.surface,
      borderRadius: boardRadius,
      child: InkWell(
        borderRadius: boardRadius,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: SelectableText(
              name,
              enableInteractiveSelection: false,
              onTap: onTap,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: selected
                    ? context.colorScheme.background
                    : context.colorScheme.secondaryText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _getDestinationType(List<String>? properties) {
  if (properties == null) {
    return '';
  }
  if (properties.contains('SegWit')) {
    return 'Bitcoin (Segwit)';
  } else {
    return 'Bitcoin';
  }
}
