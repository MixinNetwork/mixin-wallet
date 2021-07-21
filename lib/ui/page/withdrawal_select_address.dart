import 'dart:async';
import 'dart:ui';

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
import '../../util/logger.dart';
import '../../util/r.dart';
import '../router/mixin_routes.dart';
import '../widget/address_add_widget.dart';
import '../widget/brightness_observer.dart';
import '../widget/interactable_box.dart';
import '../widget/mixin_bottom_sheet.dart';
import '../widget/search_header_widget.dart';

class WithDrawSelectAddress extends StatelessWidget {
  const WithDrawSelectAddress({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final assetId = context.pathParameters['id']!;
    final selectedAddress = context.queryParameters['address'];
    return _AddressSelectionWidget(
      assetId: assetId,
      selectedAddress: selectedAddress,
    );
  }
}

class _AddressSelectionWidget extends HookWidget {
  const _AddressSelectionWidget({
    Key? key,
    required this.assetId,
    this.selectedAddress,
  }) : super(key: key);

  final String assetId;
  final String? selectedAddress;

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
              onCancel: () {
                context.pop();
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: filterList.length,
              itemBuilder: (BuildContext context, int index) => _Item(
                address: filterList[index],
                selectedAddressId: selectedAddress,
                onTap: () => context.replace(
                  withdrawalPath.toUri({'id': assetId}).replace(
                    queryParameters: {
                      'address': filterList[index].addressId,
                    },
                  ),
                ),
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

typedef DeleteResultCallback = void Function(bool deleted);

class _DeleteConfirmOverlay extends HookWidget {
  const _DeleteConfirmOverlay({
    Key? key,
    required this.address,
    required this.dismiss,
  }) : super(key: key);

  final Addresse address;

  final DeleteResultCallback dismiss;

  @override
  Widget build(BuildContext context) {
    final canceled = useState(false);

    useEffect(() {
      scheduleMicrotask(() async {
        while (!canceled.value) {
          try {
            final result = await context.appServices.client.addressApi
                .getAddressById(address.addressId);
            i('result: ${result.data}');
          } catch (error, stack) {
            if (error is DioError) {
              final mixinError = error.error as MixinError;
              if (mixinError.code == 404) {}
            }
            i('failed: $error, $stack');
            if (!canceled.value) {
              dismiss(true);
            }
            break;
          }
          await Future.delayed(const Duration(milliseconds: 2000));
        }
      });
      return () => canceled.value = true;
    }, [address.addressId]);

    return Stack(
      fit: StackFit.expand,
      children: [
        const ModalBarrier(
          dismissible: false,
          color: Colors.black45,
          barrierSemanticsDismissible: false,
        ),
        Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.theme.background,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SizedBox(
              width: 200,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  CircularProgressIndicator(
                    color: context.theme.text,
                    strokeWidth: 2,
                  ),
                  const SizedBox(height: 14),
                  Text(context.l10n.delete,
                      style: TextStyle(
                        color: context.theme.text,
                        fontSize: 16,
                        height: 1.4,
                      )),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: InteractableBox(
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.theme.accent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.only(
                            top: 12, bottom: 14, left: 54, right: 55),
                        child: Center(
                          child: Text(
                            context.l10n.cancel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        canceled.value = true;
                        dismiss(false);
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SwipeToDismiss extends StatelessWidget {
  const _SwipeToDismiss({
    required Key key,
    required this.child,
    required this.onDismiss,
    required this.enable,
    this.confirmDismiss,
  }) : super(key: key);

  final Widget child;
  final VoidCallback onDismiss;
  final bool enable;
  final ConfirmDismissCallback? confirmDismiss;

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
  Widget build(BuildContext context) => _SwipeToDismiss(
        key: ValueKey(address.addressId),
        enable: selectedAddressId != address.addressId,
        onDismiss: () {
          context.appServices.mixinDatabase.addressDao.deleteAddress(address);
        },
        confirmDismiss: (direction) {
          final completer = Completer<bool>();

          OverlayEntry? entry;
          entry = OverlayEntry(
              builder: (context) => _DeleteConfirmOverlay(
                    address: address,
                    dismiss: (deleted) {
                      entry?.remove();
                      completer.complete(deleted);
                    },
                  ));
          Overlay.of(context)?.insert(entry);

          // https: //mixin.one/address?action=delete&asset=xxx&address=xxx
          final uri = Uri.https('mixin.one', 'address', {
            'action': 'delete',
            'asset': address.assetId,
            'address': address.addressId,
          });
          context.toExternal(uri, openNewTab: true);
          return completer.future;
        },
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
