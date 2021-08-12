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
import '../widget/asset_selection_list_widget.dart';
import '../widget/mixin_appbar.dart';
import '../widget/mixin_bottom_sheet.dart';
import '../widget/round_container.dart';
import '../widget/symbol.dart';

class AssetDeposit extends StatelessWidget {
  const AssetDeposit({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => _AssetDepositLoader(key: key);
}

class _AssetDepositLoader extends HookWidget {
  const _AssetDepositLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO query assets from database
    // The asset id of CNB is: 965e5c6e-434c-3fa9-b780-c50f43cd955c
    final assetId = context.pathParameters['id']!;

    useMemoizedFuture(() => context.appServices.updateAsset(assetId),
        keys: [assetId]);

    final data = useMemoizedStream(
      () => context.appServices.assetResult(assetId).watchSingleOrNull(),
      keys: [assetId],
    ).data;

    // useEffect(() {
    //   if (notFound) {
    //     context
    //         .read<MixinRouterDelegate>()
    //         .pushNewUri(notFoundUri);
    //   }
    // }, [notFound]);

    if (data == null) {
      return const SizedBox();
    }
    return _AssetDepositPage(asset: data);
  }
}

String _getDestinationType(String? checkedDestination, String? destination) {
  if (checkedDestination == destination) {
    return 'Bitcoin';
  } else {
    return 'Bitcoin (Segwit)';
  }
}

class _AssetDepositPage extends HookWidget {
  const _AssetDepositPage({
    Key? key,
    required this.asset,
  }) : super(key: key);

  final AssetResult asset;

  @override
  Widget build(BuildContext context) {
    final assetState = useState(this.asset);
    final asset = assetState.value;

    final depositEntries =
        const DepositEntryConverter().mapToDart(asset.depositEntries);
    final checkedDestination = useState<String>(asset.destination!);
    final checkedTag = useState<String?>(asset.tag);
    return Scaffold(
      backgroundColor: context.theme.accent,
      appBar: MixinAppBar(
        title: Text(context.l10n.deposit),
        backButtonColor: Colors.white,
        actions: <Widget>[
          ActionButton(
              name: R.resourcesIcQuestionSvg,
              color: Colors.white,
              onTap: () {
                context.toExternal(depositHelpLink, openNewTab: true);
              }),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(topRadius)),
          color: context.theme.background,
        ),
        child: Column(children: [
          const SizedBox(height: 20),
          InkWell(
            onTap: () {
              showMixinBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => AssetSelectionListWidget(
                  onTap: (AssetResult assetResult) {
                    context.replace(
                        assetDepositPath.toUri({'id': assetResult.assetId}));
                    assetState.value = assetResult;
                    checkedDestination.value = assetResult.destination!;
                    checkedTag.value = assetResult.tag;
                  },
                  selectedAssetId: asset.assetId,
                ),
              );
            },
            child: RoundContainer(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                children: [
                  SymbolIconWithBorder(
                    symbolUrl: asset.iconUrl,
                    chainUrl: asset.chainIconUrl,
                    size: 32,
                    chainSize: 8,
                  ),
                  const SizedBox(width: 10),
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
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          '${asset.balance}${asset.symbol}',
                          style: TextStyle(
                            color: context.theme.secondaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SvgPicture.asset(R.resourcesIcArrowDownSvg),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (depositEntries != null && depositEntries.length > 1)
            Column(
              children: [
                InkWell(
                    onTap: () {
                      showMixinBottomSheet(
                          context: context,
                          builder: (context) => _AddressTypeBottomSheet(
                                depositEntries: depositEntries,
                                destination: asset.destination ?? '',
                                checkedDestination: checkedDestination.value,
                                onTap: (depositEntry) {
                                  checkedDestination.value =
                                      depositEntry.destination;
                                  checkedTag.value = depositEntry.tag;
                                  Navigator.pop(context);
                                },
                              ));
                    },
                    child: RoundContainer(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _getDestinationType(
                                  checkedDestination.value, asset.destination),
                              style: TextStyle(
                                color: context.theme.text,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: SvgPicture.asset(R.resourcesIcArrowDownSvg),
                          )
                        ],
                      ),
                    )),
                const SizedBox(height: 10),
              ],
            )
          else
            const SizedBox(),
          _Item(
            asset: asset,
            title: context.l10n.address,
            desc: checkedDestination.value,
          ),
          const SizedBox(height: 10),
          if (asset.needShowMemo)
            _Item(
              asset: asset,
              title: context.l10n.memo,
              desc: checkedTag.value ?? '',
            )
          else
            const SizedBox(),
          const SizedBox(height: 10),
          if (asset.needShowMemo)
            Column(
              children: [
                RoundContainer(
                    height: null,
                    radius: 8,
                    padding: const EdgeInsets.symmetric(
                        vertical: 13, horizontal: 16),
                    color: const Color(0xfffcf1f2),
                    child: Text(
                      context.l10n.depositNotice(asset.symbol),
                      style: TextStyle(
                        color: context.theme.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    )),
                const SizedBox(height: 10)
              ],
            )
          else
            const SizedBox(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(asset.getTip(context),
                  style: TextStyle(
                    color: context.theme.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  )),
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Text(context.l10n.depositConfirmation(asset.confirmations),
                style: TextStyle(
                  color: context.theme.secondaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                )),
          ),
          const SizedBox(height: 50),
        ]),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    Key? key,
    required this.asset,
    required this.title,
    required this.desc,
  }) : super(key: key);

  final AssetResult asset;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 56,
      ),
      child: RoundContainer(
        height: null,
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(left: 20, top: 12, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        color: context.theme.secondaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      )),
                  const SizedBox(height: 4),
                  Text(desc,
                      softWrap: true,
                      style: TextStyle(
                        color: context.theme.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      )),
                ],
              ),
            )),
            Row(
              children: [
                SizedBox(
                    width: 48,
                    height: 48,
                    child: Material(
                        child: ActionButton(
                      name: R.resourcesIcCopySvg,
                      padding: const EdgeInsets.all(12),
                      onTap: () {
                        setClipboardText(desc);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: Text(context.l10n.copyToClipboard)));
                      },
                    ))),
                SizedBox(
                    width: 48,
                    height: 48,
                    child: Material(
                        child: ActionButton(
                      name: R.resourcesIcQrCodeSvg,
                      padding: const EdgeInsets.all(12),
                      onTap: () {
                        showMixinBottomSheet(
                          context: context,
                          builder: (context) => _QRBottomSheetContent(
                            data: desc,
                            asset: asset,
                          ),
                          isScrollControlled: true,
                        );
                      },
                    ))),
                const SizedBox(width: 12)
              ],
            ),
          ],
        ),
      ));
}

class _QRBottomSheetContent extends StatelessWidget {
  const _QRBottomSheetContent({
    Key? key,
    required this.data,
    required this.asset,
  }) : super(key: key);

  final String data;
  final AssetResult asset;

  @override
  Widget build(BuildContext context) => Container(
        height: 480,
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        child: Column(
          children: [
            SizedBox(
                height: 70,
                child: Row(
                  children: [
                    Text(context.l10n.address,
                        style: TextStyle(
                          color: context.theme.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        )),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ActionButton(
                          name: R.resourcesIcCircleCloseSvg,
                          onTap: () {
                            Navigator.pop(context);
                          }),
                    ),
                  ],
                )),
            const SizedBox(height: 55),
            Stack(
              alignment: AlignmentDirectional.center,
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
            const SizedBox(height: 5),
            SelectableText(data,
                style: TextStyle(
                  color: context.theme.secondaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                )),
            const SizedBox(height: 64),
          ],
        ),
      );
}

class _AddressTypeBottomSheet extends StatelessWidget {
  const _AddressTypeBottomSheet({
    Key? key,
    required this.depositEntries,
    required this.destination,
    required this.checkedDestination,
    required this.onTap,
  }) : super(key: key);

  final List<DepositEntry> depositEntries;
  final String destination;
  final String checkedDestination;
  final _AddressTypeCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
        height: 310,
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        child: Column(
          children: [
            MixinBottomSheetTitle(
              padding: EdgeInsets.zero,
              title: Row(children: [
                Text(context.l10n.address),
              ]),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                _AddressTypeItem(
                    depositEntry: depositEntries[0],
                    destination: destination,
                    checkedDestination: checkedDestination,
                    onTap: onTap,
                    isTop: true),
                _AddressTypeItem(
                    depositEntry: depositEntries[1],
                    destination: destination,
                    checkedDestination: checkedDestination,
                    onTap: onTap,
                    isTop: false),
              ],
            ),
          ],
        ),
      );
}

class _AddressTypeItem extends StatelessWidget {
  const _AddressTypeItem({
    Key? key,
    required this.depositEntry,
    required this.destination,
    required this.checkedDestination,
    required this.onTap,
    required this.isTop,
  }) : super(key: key);

  final DepositEntry depositEntry;
  final String destination;
  final String checkedDestination;
  final _AddressTypeCallback onTap;
  final bool isTop;

  @override
  Widget build(BuildContext context) {
    const radius = Radius.circular(12);
    final borderRadius = isTop
        ? const BorderRadius.vertical(top: radius)
        : const BorderRadius.vertical(bottom: radius);
    return SizedBox(
        height: 74,
        child: Material(
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          child: InkWell(
              customBorder: RoundedRectangleBorder(
                borderRadius: borderRadius,
              ),
              onTap: () {
                if (checkedDestination != depositEntry.destination) {
                  onTap(depositEntry);
                }
              },
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                          _getDestinationType(
                              destination, depositEntry.destination),
                          style: TextStyle(
                            color: context.theme.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          )),
                      const Spacer(),
                      if (depositEntry.destination == checkedDestination)
                        Align(
                          alignment: Alignment.centerRight,
                          child: SvgPicture.asset(R.resourcesIcCheckSvg),
                        ),
                    ],
                  ))),
        ));
  }
}

typedef _AddressTypeCallback = void Function(DepositEntry);
