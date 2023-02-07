import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;

import '../../../db/mixin_database.dart';
import '../../../service/account_provider.dart';
import '../../../service/profile/profile_manager.dart';
import '../../../util/extension/extension.dart';
import '../../../util/hook.dart';
import '../../../util/native_scroll.dart';
import '../../../util/r.dart';
import '../address_add_widget.dart';
import '../external_action_confirm.dart';
import '../mixin_bottom_sheet.dart';
import '../search_header_widget.dart';
import 'address_pin_bottom_sheet.dart';

class AddressSelectionWidget extends HookWidget {
  const AddressSelectionWidget({
    Key? key,
    required this.assetId,
    required this.chainId,
    this.selectedAddress,
  }) : super(key: key);

  final String assetId;
  final String chainId;
  final Addresse? selectedAddress;

  @override
  Widget build(BuildContext context) {
    useMemoizedFuture(
      () => context.appServices.updateAddresses(assetId),
      keys: [assetId],
    );

    final addresses = useMemoizedStream(
          () => context.appServices.addresses(assetId).watch(),
          keys: [assetId],
        ).data ??
        const [];

    final filterKeywords = useState('');
    final filterList = useMemoized(() {
      if (filterKeywords.value.isEmpty) {
        return addresses;
      }
      return addresses
          .where(
            (e) =>
                e.label.containsIgnoreCase(filterKeywords.value) ||
                e.displayAddress().containsIgnoreCase(filterKeywords.value),
          )
          .toList();
    }, [filterKeywords.value, addresses]);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: SearchHeaderWidget(
            hintText: context.l10n.addressSearchHint,
            onChanged: (k) {
              filterKeywords.value = k.trim();
            },
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: NativeScrollBuilder(
            builder: (context, controller) => ListView.builder(
              controller: controller,
              itemCount: filterList.length,
              itemBuilder: (BuildContext context, int index) => _AddressItem(
                address: filterList[index],
                selectedAddressId: selectedAddress?.addressId,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 24,
            ),
            minimumSize: const Size(110, 48),
          ),
          onPressed: () {
            showMixinBottomSheet<void>(
              context: context,
              builder: (context) =>
                  AddressAddWidget(assetId: assetId, chainId: chainId),
              isScrollControlled: true,
            );
          },
          child: Text(
            '+ ${context.l10n.addAddress}',
            style: TextStyle(
              fontSize: 16,
              color: context.colorScheme.primaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 36),
      ],
    );
  }
}

class _AddressItem extends StatelessWidget {
  const _AddressItem({
    Key? key,
    required this.address,
    required this.selectedAddressId,
  }) : super(key: key);

  final Addresse address;
  final String? selectedAddressId;

  @override
  Widget build(BuildContext context) => _AddressPopupMenuWrapper(
        address: address,
        child: _AddressSelectionItemTile(
          onTap: () => Navigator.pop(context, address),
          title: Row(
            children: [
              Text(address.label.overflow),
              const Spacer(),
              Text(
                DateFormat.yMMMMd()
                    .add_Hms()
                    .format(address.updatedAt.toLocal()),
                style: TextStyle(
                  fontSize: 12,
                  color: context.colorScheme.secondaryText,
                ),
              ),
            ],
          ),
          subtitle: Text(address.displayAddress().overflow),
          selected: address.addressId == selectedAddressId,
        ),
      );
}

enum _AddressPopupMenuAction {
  delete,
}

class _AddressPopupMenuWrapper extends StatefulWidget {
  const _AddressPopupMenuWrapper({
    Key? key,
    required this.child,
    required this.address,
  }) : super(key: key);

  final Widget child;
  final Addresse address;

  @override
  State<_AddressPopupMenuWrapper> createState() =>
      _AddressPopupMenuWrapperState();
}

class _AddressPopupMenuWrapperState extends State<_AddressPopupMenuWrapper> {
  Future<void> showPopupMenu({Offset? popupOffset}) async {
    const padding = EdgeInsets.all(8.0);
    final popupMenuTheme = PopupMenuTheme.of(context);
    final button = context.findRenderObject()! as RenderBox;
    final overlay =
        Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    final offset =
        popupOffset ?? Offset(0.0, button.size.height - (padding.vertical / 2));
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(offset, ancestor: overlay),
        button.localToGlobal(button.size.topLeft(Offset.zero) + offset,
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    final action = await showMenu<_AddressPopupMenuAction>(
      context: context,
      elevation: popupMenuTheme.elevation,
      items: [
        PopupMenuItem(
          value: _AddressPopupMenuAction.delete,
          child: Text(context.l10n.delete),
        ),
      ],
      position: position,
      shape: popupMenuTheme.shape,
      color: popupMenuTheme.color,
    );
    switch (action) {
      case null:
        return;
      case _AddressPopupMenuAction.delete:
        await _deleteAddress();
        break;
    }
  }

  Addresse get address => widget.address;

  Future<bool> _confirmDeleteAddress() async {
    if (context.read<AuthProvider>().isLoginByCredential) {
      return showDeleteAddressByPinBottomSheet(
        context,
        address: address,
      );
    } else {
      // https: //mixin.one/address?action=delete&asset=xxx&address=xxx
      final uri = Uri.https('mixin.one', 'address', {
        'action': 'delete',
        'asset': address.assetId,
        'address': address.addressId,
      });
      return showAndWaitingExternalAction(
          context: context,
          uri: uri,
          hint: Text(context.l10n.delete),
          action: () async {
            try {
              await context.appServices.client.addressApi
                  .getAddressById(address.addressId);
              return false;
            } catch (error) {
              if (error is DioError) {
                final mixinError = error.error as sdk.MixinError;
                if (mixinError.code == 404) {
                  return true;
                }
              }
              rethrow;
            }
          });
    }
  }

  Future<void> _deleteAddress() async {
    final delete = await _confirmDeleteAddress();
    if (delete) {
      await context.appServices.mixinDatabase.addressDao.deleteAddress(address);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _AddressSelectionItemTile extends StatelessWidget {
  const _AddressSelectionItemTile({
    Key? key,
    required this.onTap,
    required this.title,
    required this.subtitle,
    required this.selected,
  }) : super(key: key);

  final VoidCallback onTap;
  final Widget title;
  final Widget subtitle;

  final bool selected;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: GestureDetector(
          onLongPressStart: (details) {
            debugPrint('offset: ${details.localPosition}');
            context
                .findAncestorStateOfType<_AddressPopupMenuWrapperState>()
                ?.showPopupMenu(popupOffset: details.localPosition);
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 72),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (selected)
                    Padding(
                      padding: const EdgeInsets.only(left: 0, right: 10),
                      child: SvgPicture.asset(
                        R.resourcesIcCheckSvg,
                        width: 24,
                        height: 24,
                      ),
                    )
                  else
                    const SizedBox(width: 34),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DefaultTextStyle.merge(
                          style: TextStyle(
                            color: context.colorScheme.primaryText,
                            fontSize: 16,
                            height: 1.2,
                          ),
                          child: title,
                        ),
                        const SizedBox(height: 2),
                        DefaultTextStyle.merge(
                          softWrap: true,
                          style: TextStyle(
                            color: context.colorScheme.thirdText,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                          ),
                          child: subtitle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
