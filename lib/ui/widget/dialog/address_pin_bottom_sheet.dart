import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;

import '../../../db/mixin_database.dart';
import '../../../service/profile/pin_session.dart';
import '../../../util/constants.dart';
import '../../../util/extension/extension.dart';
import '../../../util/hook.dart';
import '../../../util/logger.dart';
import '../mixin_bottom_sheet.dart';
import '../pin.dart';
import '../symbol.dart';
import '../toast.dart';

Future<bool> showDeleteAddressByPinBottomSheet(
  BuildContext context, {
  required Addresse address,
}) async {
  final api = context.appServices.client.addressApi;
  final pin = await _showAddressPinBottomSheet(
    context,
    assetId: address.assetId,
    type: _AddressModifyType.delete,
    address: address.destination,
    label: address.label,
    tag: address.tag,
  );
  if (pin == null) {
    return false;
  }
  try {
    await computeWithLoading(
        () => api.deleteAddressById(address.addressId, encryptPin(pin)!));
    return true;
  } catch (error, stacktrace) {
    e('delete address error: $error, $stacktrace');
    showErrorToast(error.toDisplayString(context));
    return false;
  }
}

Future<bool> showAddAddressByPinBottomSheet(
  BuildContext context, {
  required String assetId,
  required String destination,
  required String label,
  required String? tag,
}) async {
  final api = context.appServices.client.addressApi;
  final pin = await _showAddressPinBottomSheet(
    context,
    assetId: assetId,
    type: _AddressModifyType.add,
    address: destination,
    label: label,
    tag: tag,
  );
  if (pin == null) {
    return false;
  }
  try {
    await computeWithLoading(() async {
      final response = await api.addAddress(sdk.AddressRequest(
        assetId: assetId,
        pin: encryptPin(pin)!,
        destination: destination,
        tag: tag,
        label: label,
      ));
      await context.mixinDatabase.addressDao
          .insertAllOnConflictUpdate([response.data]);
    });
    return true;
  } catch (error, stack) {
    e('add address error: $error, $stack');
    showErrorToast(error.toDisplayString(context));
    return false;
  }
}

enum _AddressModifyType {
  add,
  delete,
}

Future<String?> _showAddressPinBottomSheet(
  BuildContext context, {
  required String assetId,
  required _AddressModifyType type,
  required String address,
  required String label,
  required String? tag,
}) async {
  final pin = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: false,
    enableDrag: false,
    builder: (context) => Column(
      children: [
        const Spacer(),
        Material(
          color: context.colorScheme.background,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(topRadius),
          ),
          child: _AddressPinBottomSheetContent(
            assetId: assetId,
            type: type,
            address: address,
            label: label,
            tag: tag,
          ),
        ),
      ],
    ),
  );
  return pin;
}

class _AddressPinBottomSheetContent extends HookWidget {
  const _AddressPinBottomSheetContent({
    Key? key,
    required this.assetId,
    required this.type,
    required this.address,
    required this.label,
    required this.tag,
  }) : super(key: key);

  final String assetId;
  final _AddressModifyType type;
  final String label;
  final String address;
  final String? tag;

  @override
  Widget build(BuildContext context) {
    final controller = useMemoized(PinInputController.new);
    final asset = useMemoizedStream(
      () => context.appServices.assetResult(assetId).watchSingleOrNull(),
      keys: [assetId],
    ).data;
    usePinVerificationEffect(controller);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        MixinBottomSheetTitle(
          title: Text(
            type == _AddressModifyType.add
                ? context.l10n.addWithdrawalAddress(asset?.symbol ?? '')
                : context.l10n.deleteWithdrawalAddress(asset?.symbol ?? ''),
          ),
        ),
        const SizedBox(height: 20),
        if (asset != null)
          SymbolIconWithBorder(
            symbolUrl: asset.iconUrl,
            chainUrl: asset.chainIconUrl,
            size: 70,
            chainSize: 24,
          )
        else
          const SizedBox(height: 70),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: context.colorScheme.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            (tag?.isEmpty ?? true) ? address : '$address$tag',
            style: TextStyle(
              color: context.colorScheme.secondaryText,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        PinField(controller: controller),
        const SizedBox(height: 16),
        Text(
          type == _AddressModifyType.add
              ? context.l10n.addAddressByPinTip
              : context.l10n.deleteAddressByPinTip,
          style: TextStyle(
            color: context.colorScheme.secondaryText,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 32),
        PinInputNumPad(controller: controller),
      ],
    );
  }
}
