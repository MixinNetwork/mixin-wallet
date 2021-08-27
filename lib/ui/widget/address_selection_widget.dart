import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart';

import '../../db/mixin_database.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/l10n.dart';
import '../../util/r.dart';
import 'address_add_widget.dart';
import 'brightness_observer.dart';
import 'external_action_confirm.dart';
import 'mixin_bottom_sheet.dart';
import 'search_header_widget.dart';

Future<Addresse?> showAddressSelectionBottomSheet({
  required BuildContext context,
  required String assetId,
  required String chainId,
  Addresse? selectedAddress,
}) =>
    showMixinBottomSheet<Addresse>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddressSelectionWidget(
        assetId: assetId,
        selectedAddress: selectedAddress,
        chainId: chainId,
      ),
    );

class _AddressSelectionWidget extends HookWidget {
  const _AddressSelectionWidget({
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

    return SizedBox(
      height: MediaQuery.of(context).size.height - 100,
      child: Column(
        children: [
          const SizedBox(height: 16),
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
            child: ListView.builder(
              itemCount: filterList.length,
              itemBuilder: (BuildContext context, int index) => _AddressItem(
                address: filterList[index],
                selectedAddressId: selectedAddress?.addressId,
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
              debugPrint('click');
              showMixinBottomSheet(
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
      ),
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
  Widget build(BuildContext context) => _SwipeToDismiss(
        key: ValueKey(address.addressId),
        onDismiss: () {
          context.appServices.mixinDatabase.addressDao.deleteAddress(address);
        },
        confirmDismiss: (direction) {
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
                    final mixinError = error.error as MixinError;
                    if (mixinError.code == 404) {
                      return true;
                    }
                  }
                  rethrow;
                }
              });
        },
        child: AddressSelectionItemTile(
          onTap: () => Navigator.pop(context, address),
          title: Text(address.label.overflow),
          subtitle: Text(address.displayAddress().overflow),
          selected: address.addressId == selectedAddressId,
          leading: SvgPicture.asset(
            R.resourcesTransactionNetSvg,
            height: 44,
            width: 44,
          ),
        ),
      );
}

class AddressSelectionItemTile extends StatelessWidget {
  const AddressSelectionItemTile({
    Key? key,
    required this.leading,
    required this.onTap,
    required this.title,
    required this.subtitle,
    required this.selected,
  }) : super(key: key);

  final Widget leading;
  final VoidCallback onTap;
  final Widget title;
  final Widget subtitle;

  final bool selected;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox.square(
                dimension: 44,
                child: ClipOval(
                  child: leading,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DefaultTextStyle(
                    style: TextStyle(
                        color: context.theme.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.4),
                    child: title,
                  ),
                  const SizedBox(height: 4),
                  DefaultTextStyle(
                    softWrap: true,
                    style: TextStyle(
                      color: context.theme.secondaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                    child: subtitle,
                  ),
                ],
              )),
              const SizedBox(width: 48),
              if (selected)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: SvgPicture.asset(
                    R.resourcesIcCheckSvg,
                    width: 20,
                    height: 20,
                  ),
                )
            ],
          ),
        ),
      );
}

class _SwipeToDismiss extends StatelessWidget {
  const _SwipeToDismiss({
    required Key key,
    required this.child,
    required this.onDismiss,
    this.confirmDismiss,
  }) : super(key: key);

  final Widget child;
  final VoidCallback onDismiss;
  final ConfirmDismissCallback? confirmDismiss;

  @override
  Widget build(BuildContext context) {
    final Widget indicator = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Text(
        context.l10n.delete,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
    return Dismissible(
      key: ValueKey(key),
      onDismissed: (direction) => onDismiss(),
      confirmDismiss: confirmDismiss,
      background: Container(
        color: context.theme.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: indicator,
        ),
      ),
      secondaryBackground: Container(
        color: context.theme.red,
        child: Align(
          alignment: Alignment.centerRight,
          child: indicator,
        ),
      ),
      child: child,
    );
  }
}
