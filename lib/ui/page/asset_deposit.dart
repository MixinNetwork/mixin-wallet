import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../db/converter/deposit_entry_converter.dart';
import '../../db/mixin_database.dart';
import '../../util/constants.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/r.dart';
import '../../util/web/web_utils_dummy.dart'
    if (dart.library.html) '../../util/web/web_utils.dart';
import '../router/mixin_routes.dart';
import '../widget/action_button.dart';
import '../widget/buttons.dart';
import '../widget/mixin_appbar.dart';
import '../widget/symbol.dart';

class AssetDeposit extends StatelessWidget {
  const AssetDeposit({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      _AssetDepositLoader(assetId: context.pathParameters['id']!);
}

class _DepositScaffold extends StatelessWidget {
  const _DepositScaffold({
    Key? key,
    this.asset,
    required this.body,
  }) : super(key: key);

  final AssetResult? asset;
  final Widget body;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.colorScheme.background,
        appBar: MixinAppBar(
          leading: const MixinBackButton2(),
          backgroundColor: context.colorScheme.background,
          title: Text(
            asset == null
                ? context.l10n.deposit
                : '${context.l10n.deposit} ${asset!.symbol}',
            style: TextStyle(
              color: context.colorScheme.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
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
    Key? key,
    required this.assetId,
  }) : super(key: key);

  final String assetId;

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      var cancel = false;
      scheduleMicrotask(() async {
        var asset = await context.appServices.updateAsset(assetId);
        while (!cancel &&
            (asset.destination == null || asset.destination!.isEmpty)) {
          // delay 2 seconds to request again if we didn't get the address.
          // https://developers.mixin.one/document/wallet/api/asset
          await Future.delayed(const Duration(milliseconds: 2000));
          asset = await context.appServices.updateAsset(assetId);
        }
      });
      return () {
        cancel = true;
      };
    }, [assetId]);

    final data = useMemoizedStream(
      () => context.appServices.assetResult(assetId).watchSingleOrNull(),
      keys: [assetId],
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
  const _AssetDepositBody({Key? key, required this.asset}) : super(key: key);

  final AssetResult asset;

  @override
  Widget build(BuildContext context) {
    final depositEntry = useState<DepositEntry?>(null);

    useEffect(() {
      depositEntry.value = null;
    }, [asset.assetId]);

    final tag =
        depositEntry.value != null ? depositEntry.value?.tag : asset.tag;
    final address = depositEntry.value != null
        ? depositEntry.value?.destination
        : asset.destination;

    final depositEntries = useMemoized(
      () =>
          const DepositEntryConverter().mapToDart(asset.depositEntries) ??
          const [],
      [asset.depositEntries],
    );

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        if (usdtAssets.containsKey(asset.assetId))
          _UsdtChooseLayout(asset: asset),
        if (depositEntries.length > 1)
          _DepositEntryChooseLayout(
            asset: asset,
            entries: depositEntries,
            onSelected: (entry) => depositEntry.value = entry,
            selectedAddress: address!,
          ),
        if (tag != null && tag.isNotEmpty) _MemoLayout(asset: asset, tag: tag),
        if (address != null && address.isNotEmpty)
          _AddressLayout(asset: asset, address: address)
        else
          const _AddressLoadingWidget(),
        if (tag != null && tag.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _DepositDescriptionTile(
              text: context.l10n.depositNotice(asset.symbol),
            ),
          ),
        _DepositDescriptionTile(text: asset.getTip(context)),
        const SizedBox(height: 8),
        _DepositDescriptionTile(
          text: context.l10n.depositConfirmation(asset.confirmations),
        ),
        const SizedBox(height: 8),
        if (asset.needShowReserve)
          _DepositDescriptionTile(
              text: context.l10n
                  .depositReserve('${asset.reserve} ${asset.symbol}')),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _MemoLayout extends StatelessWidget {
  _MemoLayout({
    Key? key,
    required this.asset,
    required this.tag,
  })  : assert(asset.needShowMemo),
        super(key: key);

  final AssetResult asset;

  final String tag;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 32),
          _HeaderText(context.l10n.memo),
          const SizedBox(height: 16),
          _CopyableText(tag),
          const SizedBox(height: 27),
          _QrcodeImage(data: tag, asset: asset),
          const SizedBox(height: 11),
        ],
      );
}

class _AddressLayout extends StatelessWidget {
  const _AddressLayout({
    Key? key,
    required this.asset,
    required this.address,
  }) : super(key: key);

  final AssetResult asset;
  final String address;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 32),
          _HeaderText(context.l10n.address),
          const SizedBox(height: 16),
          _CopyableText(address),
          const SizedBox(height: 27),
          _QrcodeImage(data: address, asset: asset),
          const SizedBox(height: 11),
        ],
      );
}

class _AddressLoadingWidget extends StatelessWidget {
  const _AddressLoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 32),
          _HeaderText(context.l10n.address),
          SizedBox(
            height: 284,
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
  const _HeaderText(this.text, {Key? key}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: context.colorScheme.primaryText,
          ),
        ),
      );
}

class _CopyableText extends StatelessWidget {
  const _CopyableText(this.text, {Key? key}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: SelectableText(
              text,
              style: TextStyle(
                color: context.colorScheme.primaryText,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkResponse(
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
          )
        ],
      );
}

class _QrcodeImage extends StatelessWidget {
  const _QrcodeImage({
    Key? key,
    required this.data,
    required this.asset,
  }) : super(key: key);

  final String data;

  final AssetResult asset;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 230,
        height: 230,
        child: Stack(
          alignment: Alignment.center,
          children: [
            QrImage(
              data: data,
              size: 230,
            ),
            SymbolIconWithBorder(
              symbolUrl: asset.iconUrl,
              chainUrl: asset.chainIconUrl,
              size: 44,
              chainSize: 10,
            ),
          ],
        ),
      );
}

class _DepositDescriptionTile extends StatelessWidget {
  const _DepositDescriptionTile({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: context.colorScheme.thirdText,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: SelectableText(
              text,
              style: TextStyle(
                color: context.colorScheme.thirdText,
                fontSize: 14,
              ),
            ),
          ),
        ],
      );
}

class _UsdtChooseLayout extends StatelessWidget {
  const _UsdtChooseLayout({Key? key, required this.asset}) : super(key: key);

  final AssetResult asset;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          _HeaderText(context.l10n.networkType),
          const SizedBox(height: 16),
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
        ],
      );
}

class _DepositEntryChooseLayout extends StatelessWidget {
  const _DepositEntryChooseLayout({
    Key? key,
    required this.entries,
    required this.onSelected,
    required this.asset,
    required this.selectedAddress,
  }) : super(key: key);

  final List<DepositEntry> entries;

  final _AddressTypeCallback onSelected;
  final AssetResult asset;
  final String selectedAddress;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          _HeaderText(context.l10n.networkType),
          const SizedBox(height: 16),
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
                    entry.destination,
                    asset.destination,
                  ),
                ),
            ],
          ),
        ],
      );
}

class _NetworkTypeItem extends StatelessWidget {
  const _NetworkTypeItem({
    Key? key,
    required this.selected,
    required this.onTap,
    required this.name,
  }) : super(key: key);

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
            child: Text(
              name,
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

String _getDestinationType(String? checkedDestination, String? destination) {
  if (checkedDestination == destination) {
    return 'Bitcoin';
  } else {
    return 'Bitcoin (Segwit)';
  }
}

typedef _AddressTypeCallback = void Function(DepositEntry);
