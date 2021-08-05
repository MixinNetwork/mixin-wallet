import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';

import '../../db/mixin_database.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/l10n.dart';
import '../../util/r.dart';
import '../router/mixin_routes.dart';
import 'action_button.dart';
import 'brightness_observer.dart';
import 'mixin_bottom_sheet.dart';
import 'search_header_widget.dart';

/// The result might be [User] or [Addresse].
Future<Addresse?> showAddressSelectionBottomSheet({
  required BuildContext context,
  required String assetId,
  Addresse? selectedAddress,
}) =>
    showMixinBottomSheet<Addresse>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddressSelectionWidget(
        assetId: assetId,
        selectedAddress: selectedAddress,
      ),
    );

class _AddressSelectionWidget extends HookWidget {
  const _AddressSelectionWidget({
    Key? key,
    required this.assetId,
    this.selectedAddress,
  }) : super(key: key);

  final String assetId;
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
          const SizedBox(height: 10),
          Row(
            children: [
              const SizedBox(width: 10),
              ActionButton(
                name: R.resourcesIcSetSvg,
                size: 24,
                onTap: () {
                  context.push(withdrawalAddressesPath.toUri({'id': assetId}));
                },
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SearchHeaderWidget(
                  hintText: context.l10n.addressSearchHint,
                  onChanged: (k) {
                    filterKeywords.value = k.trim();
                  },
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: filterList.length,
              itemBuilder: (BuildContext context, int index) => _AddressItem(
                address: filterList[index],
                selectedAddressId: selectedAddress?.addressId,
              ),
            ),
          ),
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
  Widget build(BuildContext context) => AddressSelectionItemTile(
        onTap: () => Navigator.pop(context, address),
        title: Text(address.label.overflow),
        subtitle: Text(address.displayAddress().overflow),
        selected: address.addressId == selectedAddressId,
        leading: SvgPicture.asset(
          R.resourcesTransactionNetSvg,
          height: 44,
          width: 44,
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
  Widget build(BuildContext context) => Material(
      color: context.theme.background,
      child: InkWell(
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
      ));
}
