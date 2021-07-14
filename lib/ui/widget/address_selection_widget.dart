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
import 'brightness_observer.dart';
import 'interactable_box.dart';
import 'search_header_widget.dart';

class AddressSelectionWidget extends HookWidget {
  const AddressSelectionWidget({
    Key? key,
    required this.onTap,
    required this.assetId,
    this.selectedAddress,
  }) : super(key: key);

  final String assetId;
  final Address? selectedAddress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    useMemoizedFuture(() => context.appServices.updateAddresses(assetId));

    final addresses =
        useMemoizedStream(() => context.appServices.addresses(assetId).watch())
            .data;

    var selectedAddressId = selectedAddress?.addressId;
    if (selectedAddressId == null &&
        addresses != null &&
        addresses.isNotEmpty) {
      selectedAddressId = addresses[0].addressId;
    }

    final filterList = useState<List<Addresse>?>(addresses);

    return Container(
      height: MediaQuery.of(context).size.height - 120,
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      child: Column(
        children: [
          SearchHeaderWidget(
            hintText: context.l10n.addressSearchHint,
            onChanged: (k) {
              if (k.isNotEmpty) {
                filterList.value = addresses
                    ?.where((e) =>
                        e.label.containsIgnoreCase(k) == true ||
                        e.displayAddress().containsIgnoreCase(k) == true)
                    .toList();
              } else {
                filterList.value = addresses;
              }
            },
          ),
          addresses != null && addresses.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                      itemCount: filterList.value?.length ?? 0,
                      itemBuilder: (BuildContext context, int index) => _Item(
                            address: filterList.value![index],
                            selectedAddressId: selectedAddressId,
                            onTap: onTap,
                          )))
              : const SizedBox(),
          const Spacer(),
          Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                  width: 160,
                  height: 44,
                  child: TextButton(
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              const EdgeInsets.symmetric(
                                  horizontal: 22, vertical: 11)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      side: BorderSide(
                                          color: context.theme.accent)))),
                      onPressed: () {},
                      child: Text(context.l10n.addAddress,
                          style: TextStyle(
                            fontSize: 16,
                            color: context.theme.accent,
                          ))))),
          const SizedBox(height: 70),
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
  Widget build(BuildContext context) => InteractableBox(
        child: SizedBox(
            child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: const Color(0xfff8f8f8),
            ),
            child: const SizedBox(),
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
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Expanded(
                  child: Text(
                    address.displayAddress(),
                    style: TextStyle(
                      color: context.theme.secondaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          selectedAddressId == address.addressId
              ? Align(
                  alignment: Alignment.centerRight,
                  child: SvgPicture.asset(R.resourcesIcCheckSvg),
                )
              : const SizedBox(),
        ])),
        onTap: () => onTap,
      );
}
