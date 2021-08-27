import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../db/mixin_database.dart';
import '../../service/profile/profile_manager.dart';
import '../../util/extension/extension.dart';
import '../../util/r.dart';
import '../router/mixin_routes.dart';
import 'address_selection_widget.dart';
import 'asset_selection_list_widget.dart';
import 'avatar.dart';
import 'contact_selection_widget.dart';
import 'menu.dart';
import 'mixin_bottom_sheet.dart';
import 'symbol.dart';

Future<void> showTransferRouterBottomSheet({
  required BuildContext context,
  String? assetId,
}) async {
  final type = await showMixinBottomSheet<_SendRouter>(
    context: context,
    builder: (context) => const _SendToRouterBottomSheet(),
  );
  if (type == null) {
    return;
  }

  var destAssetId = assetId;
  if (destAssetId == null) {
    final asset = await showAssetSelectionBottomSheet(
      context: context,
      initialSelected: lastSelectedAddress,
    );
    destAssetId = asset?.assetId;
  }

  if (destAssetId == null) {
    return;
  }

  lastSelectedAddress = destAssetId;

  switch (type) {
    case _SendRouter.address:
      context.push(withdrawalPath.toUri({'id': destAssetId}));
      break;
    case _SendRouter.contact:
      context.push(transferPath.toUri({'id': destAssetId}));
      break;
  }
}

enum _SendRouter {
  address,
  contact,
}

class _SendToRouterBottomSheet extends StatelessWidget {
  const _SendToRouterBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MixinBottomSheetTitle(title: Text(context.l10n.sendTo)),
          const SizedBox(height: 8),
          MenuItemWidget(
            topRounded: true,
            bottomRounded: true,
            title: Text(context.l10n.address),
            leading: SvgPicture.asset(R.resourcesAddressSvg),
            onTap: () {
              Navigator.pop(context, _SendRouter.address);
            },
          ),
          const SizedBox(height: 10),
          MenuItemWidget(
            bottomRounded: true,
            topRounded: true,
            title: Text(context.l10n.contact),
            leading: SvgPicture.asset(R.resourcesContactSvg),
            onTap: () {
              Navigator.pop(context, _SendRouter.contact);
            },
          ),
          const SizedBox(height: 106),
        ],
      );
}

class TransferAssetItem extends StatelessWidget {
  const TransferAssetItem({
    Key? key,
    required this.asset,
    required this.onAssetChange,
  }) : super(key: key);

  final AssetResult asset;
  final AssetSelectCallback onAssetChange;

  @override
  Widget build(BuildContext context) => Material(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xfff8f8f8),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            showMixinBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => AssetSelectionListWidget(
                selectedAssetId: asset.assetId,
                onTap: onAssetChange,
              ),
            );
          },
          child: SizedBox(
            height: 56,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 20),
                SymbolIconWithBorder(
                  symbolUrl: asset.iconUrl,
                  chainUrl: asset.chainIconUrl,
                  size: 32,
                  chainBorder:
                      const BorderSide(color: Color(0xfff8f8f8), width: 1),
                  symbolBorder:
                      const BorderSide(color: Color(0xfff8f8f8), width: 2),
                  chainSize: 8,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Spacer(flex: 2),
                      Text(
                        asset.symbol.overflow,
                        style: TextStyle(
                          color: context.theme.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Spacer(flex: 1),
                      Text(
                        '${asset.balance} ${asset.symbol}',
                        style: TextStyle(
                          color: context.theme.secondaryText,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
                SvgPicture.asset(R.resourcesIcArrowDownSvg),
                const SizedBox(width: 20),
              ],
            ),
          ),
        ),
      );
}

class TransferContactWidget extends StatelessWidget {
  const TransferContactWidget({
    Key? key,
    required this.user,
    required this.onUserChanged,
  }) : super(key: key);

  final User? user;
  final void Function(User) onUserChanged;

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (user != null) {
      child = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 2),
          Text(
            user!.fullName?.overflow ?? '',
            style: TextStyle(
              color: context.theme.text,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(flex: 1),
          Text(
            user!.identityNumber,
            style: TextStyle(
              color: context.theme.secondaryText,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(flex: 2),
        ],
      );
    } else {
      child = Text(
        context.l10n.selectFromContacts,
        style: TextStyle(
          color: context.theme.secondaryText,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      );
    }
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: const Color(0xfff8f8f8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final selected = await showContactSelectionBottomSheet(
              context: context, selectedUser: user);
          if (selected != null) {
            onUserChanged(selected);
          }
        },
        child: SizedBox(
          height: 56,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 20),
              if (user != null)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Avatar(
                      size: 32,
                      avatarUrl: user!.avatarUrl,
                      userId: user!.userId,
                      borderWidth: 0,
                      name: user!.fullName ?? '?'),
                ),
              Expanded(
                child: child,
              ),
              SvgPicture.asset(R.resourcesIcArrowDownSvg),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class TransferAddressWidget extends StatelessWidget {
  const TransferAddressWidget({
    Key? key,
    required this.address,
    required this.onAddressChanged,
    required this.asset,
  }) : super(key: key);

  final Addresse? address;
  final void Function(Addresse) onAddressChanged;
  final AssetResult asset;

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (address != null) {
      child = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 2),
          Text(
            address!.label.overflow,
            style: TextStyle(
              color: context.theme.text,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(flex: 1),
          Text(
            address!.displayAddress().formatAddress(),
            style: TextStyle(
              color: context.theme.secondaryText,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(flex: 2),
        ],
      );
    } else {
      child = Text(
        context.l10n.selectFromAddressBook,
        style: TextStyle(
          color: context.theme.secondaryText,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      );
    }
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: const Color(0xfff8f8f8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final selected = await showAddressSelectionBottomSheet(
            context: context,
            selectedAddress: address,
            assetId: asset.assetId,
          );
          if (selected != null) {
            onAddressChanged(selected);
          }
        },
        child: SizedBox(
          height: 56,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 20),
              Expanded(
                child: child,
              ),
              SvgPicture.asset(R.resourcesIcArrowDownSvg),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class TransferAmountWidget extends HookWidget {
  const TransferAmountWidget({
    Key? key,
    required this.asset,
    required this.amount,
  }) : super(key: key);

  final AssetResult asset;
  final ValueNotifier<String> amount;

  @override
  Widget build(BuildContext context) {
    final fiatInputMode = useState(false);

    useEffect(() {
      if (asset.priceUsd.isZero) {
        fiatInputMode.value = false;
      }
    }, [asset.priceUsd.isZero]);

    final controller = useTextEditingController();
    final input = useValueListenable(controller).text;

    final currency = auth!.account.fiatCurrency;

    final inputFocusNode = useFocusNode(debugLabel: 'amount input');

    final String equivalent;
    if (fiatInputMode.value) {
      assert(!asset.priceUsd.isZero);
      equivalent =
          '${(input.asDecimalOrZero / asset.usdUnitPrice).currencyFormatCoin}'
          ' ${asset.symbol}';
    } else {
      equivalent =
          '${(input.asDecimalOrZero * asset.usdUnitPrice).currencyFormatWithoutSymbol}'
          ' $currency';
    }

    useEffect(() {
      void updateAmount() {
        if (fiatInputMode.value) {
          if (controller.text.isEmpty) {
            amount.value = '';
          } else {
            assert(!asset.priceUsd.isZero);
            amount.value =
                (controller.text.asDecimalOrZero / asset.usdUnitPrice)
                    .currencyFormatCoin;
          }
        } else {
          amount.value = controller.text;
        }
      }

      controller.addListener(updateAmount);
      fiatInputMode.addListener(updateAmount);
      return () {
        controller.removeListener(updateAmount);
        fiatInputMode.removeListener(updateAmount);
      };
    }, [controller, fiatInputMode]);

    return Material(
      borderRadius: BorderRadius.circular(12),
      color: const Color(0xfff8f8f8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: inputFocusNode.requestFocus,
                behavior: HitTestBehavior.translucent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(children: [
                      IntrinsicWidth(
                          child: TextField(
                        focusNode: inputFocusNode,
                        style: TextStyle(
                          color: context.theme.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        decoration: InputDecoration(
                          hintText: input.isNotEmpty
                              ? ''
                              : '0.00 ${fiatInputMode.value ? currency : asset.symbol}',
                          border: InputBorder.none,
                        ),
                        controller: controller,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(
                              fiatInputMode.value
                                  ? r'^\d*\.?\d{0,2}'
                                  : r'^\d*\.?\d{0,8}')),
                        ],
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                      )),
                      Text(
                        input.isNotEmpty
                            ? (fiatInputMode.value ? currency : asset.symbol)
                            : '',
                        style: TextStyle(
                          color: context.theme.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ]),
                    Text(
                      equivalent,
                      style: TextStyle(
                        color: context.theme.secondaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            if (!asset.priceUsd.isZero)
              Align(
                alignment: Alignment.centerRight,
                child: InkResponse(
                  radius: 24,
                  onTap: () {
                    fiatInputMode.value = !fiatInputMode.value;
                  },
                  child: SvgPicture.asset(R.resourcesIcSwitchSvg),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class TransferMemoWidget extends HookWidget {
  const TransferMemoWidget({
    Key? key,
    required this.onMemoInput,
  }) : super(key: key);

  final void Function(String) onMemoInput;

  @override
  Widget build(BuildContext context) {
    final inputController = useTextEditingController();
    useEffect(() {
      void onTextChanged() {
        onMemoInput(inputController.text.trim());
      }

      inputController.addListener(onTextChanged);
      return () {
        inputController.removeListener(onTextChanged);
      };
    }, [inputController]);
    return Material(
      color: const Color(0xFFF8F8F8),
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 56,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: TextField(
              controller: inputController,
              style: TextStyle(
                color: context.theme.text,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                  hintText: context.l10n.withdrawalMemoHint,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero),
            ),
          ),
        ),
      ),
    );
  }
}
