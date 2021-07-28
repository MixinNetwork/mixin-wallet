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

Future<Addresse?> showAddressSelectionBottomSheet({
  required BuildContext context,
  required String assetId,
  Addresse? selectedAddress,
}) =>
    showMixinBottomSheet<Addresse>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddressSelectionWidget(
        assetId: assetId,
        selectedAddress: selectedAddress,
      ),
    );

class AddressSelectionWidget extends HookWidget {
  const AddressSelectionWidget({
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
              itemBuilder: (BuildContext context, int index) => _Item(
                address: filterList[index],
                selectedAddressId: selectedAddress?.addressId,
                onTap: () => Navigator.pop(context, filterList[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    Key? key,
    required this.address,
    required this.selectedAddressId,
    required this.onTap,
  }) : super(key: key);

  final Addresse address;
  final String? selectedAddressId;
  final VoidCallback onTap;

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
              ClipOval(
                child: SvgPicture.asset(
                  R.resourcesTransactionNetSvg,
                  height: 44,
                  width: 44,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    address.label.overflow,
                    style: TextStyle(
                        color: context.theme.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.4),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.displayAddress(),
                    softWrap: true,
                    style: TextStyle(
                      color: context.theme.secondaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                ],
              )),
              const SizedBox(width: 48),
              selectedAddressId == address.addressId
                  ? Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: SvgPicture.asset(
                        R.resourcesIcCheckSvg,
                        width: 20,
                        height: 20,
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ));
}
