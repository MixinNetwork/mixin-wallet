import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';

import '../../db/mixin_database.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/l10n.dart';
import '../../util/r.dart';
import 'address_add_widget.dart';
import 'brightness_observer.dart';
import 'interactable_box.dart';
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
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SearchHeaderWidget(
              hintText: context.l10n.addressSearchHint,
              onChanged: (k) {
                filterKeywords.value = k.trim();
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: filterList.length,
              itemBuilder: (BuildContext context, int index) => _Item(
                address: filterList[index],
                selectedAddressId: selectedAddress?.addressId,
                onTap: () => Navigator.pop(context, filterList[index]),
                onDismiss: () {
                  // TODO delete address.
                  // context.appServices.client.addressApi.deleteAddressById(id, pin)
                },
              ),
            ),
          ),
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
                      onPressed: () {
                        showMixinBottomSheet(
                          context: context,
                          builder: (context) =>
                              AddressAddWidget(assetId: assetId),
                          isScrollControlled: true,
                        );
                      },
                      child: Text('+ ${context.l10n.addAddress}',
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

class _SwipeToDismiss extends StatelessWidget {
  const _SwipeToDismiss({
    required Key key,
    required this.child,
    required this.onDismiss,
    required this.enable,
  }) : super(key: key);

  final Widget child;
  final VoidCallback onDismiss;
  final bool enable;

  @override
  Widget build(BuildContext context) {
    if (!enable) {
      return child;
    }
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

class _Item extends StatelessWidget {
  const _Item({
    Key? key,
    required this.address,
    required this.selectedAddressId,
    required this.onTap,
    required this.onDismiss,
  }) : super(key: key);

  final Addresse address;
  final String? selectedAddressId;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) => _SwipeToDismiss(
        key: ValueKey(address.addressId),
        enable: selectedAddressId != address.addressId,
        onDismiss: onDismiss,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: InteractableBox(
            onTap: onTap,
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
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w600,
                          height: 1.4),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
        ),
      );
}
