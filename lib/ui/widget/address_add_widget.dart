import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../service/account_provider.dart';
import '../../util/constants.dart';
import '../../util/extension/extension.dart';
import '../../util/r.dart';
import 'action_button.dart';
import 'dialog/address_pin_bottom_sheet.dart';
import 'external_action_confirm.dart';
import 'mixin_bottom_sheet.dart';
import 'round_container.dart';

class AddressAddWidget extends HookWidget {
  const AddressAddWidget({
    required this.assetId,
    super.key,
    this.chainId,
  });

  final String assetId;
  final String? chainId;

  @override
  Widget build(BuildContext context) {
    final memoEnable = useState<bool>(true);
    final addEnable = useState<bool>(false);
    final memoEnableTextFirst = context.l10n.addAddressMemo;
    final memoDisableTextFirst = context.l10n.addAddressNoMemo;
    final memoHint =
        assetId == ripple ? context.l10n.tagHint : context.l10n.memoHint;
    final memoEnableTextSecond = assetId == ripple
        ? context.l10n.addAddressTagAction
        : context.l10n.addAddressMemoAction;
    final memoDisableTextSecond = assetId == ripple
        ? context.l10n.addAddressNoTagAction
        : context.l10n.addAddressNoMemoAction;
    final memoTextFirst = useState<String>(memoEnableTextFirst);
    final memoTextSecond = useState<String>(memoEnableTextSecond);

    final memoController = useTextEditingController();
    final labelController = useTextEditingController();
    final addressController = useTextEditingController();
    void checkAddEnable() {
      addEnable.value =
          labelController.text.isNotEmpty && addressController.text.isNotEmpty;
    }

    watchTextChange(labelController, checkAddEnable);
    watchTextChange(addressController, checkAddEnable);

    final content = Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 8),
            RoundContainer(
                height: 64,
                alignment: Alignment.center,
                child: TextField(
                  style: TextStyle(
                    color: context.colorScheme.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    hintText: context.l10n.addAddressLabelHint,
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: context.colorScheme.thirdText,
                    ),
                  ),
                  controller: labelController,
                )),
            const SizedBox(height: 10),
            RoundContainer(
              height: 64,
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    style: TextStyle(
                      color: context.colorScheme.primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      hintText: context.l10n.address,
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: context.colorScheme.thirdText,
                      ),
                    ),
                    controller: addressController,
                  )),
                  ActionButton(
                    name: R.resourcesScanningSvg,
                    onTap: () async {},
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
            if (memoEnable.value)
              Column(children: [
                RoundContainer(
                    height: 64,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            style: TextStyle(
                              color: context.colorScheme.primaryText,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: InputDecoration(
                              hintText: memoHint,
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                color: context.colorScheme.thirdText,
                              ),
                            ),
                            controller: memoController,
                          ),
                        ),
                        ActionButton(
                          name: R.resourcesScanningSvg,
                          onTap: () async {},
                        ),
                      ],
                    )),
                const SizedBox(height: 10),
              ]),
            Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    child: InkWell(
                        onTap: () {
                          memoEnable.value = !memoEnable.value;
                          if (!memoEnable.value) {
                            memoController.clear();
                          }
                          memoTextFirst.value = memoEnable.value
                              ? memoEnableTextFirst
                              : memoDisableTextFirst;
                          memoTextSecond.value = memoEnable.value
                              ? memoEnableTextSecond
                              : memoDisableTextSecond;
                        },
                        child: Text.rich(
                            TextSpan(text: memoTextFirst.value, children: [
                          TextSpan(
                            text: memoTextSecond.value,
                            style: const TextStyle(
                                color: Color.fromRGBO(75, 124, 211, 1)),
                          )
                        ]))))),
            const SizedBox(height: 16),
            if (chainId == eos)
              Text.rich(TextSpan(
                  style: TextStyle(
                    color: context.colorScheme.thirdText,
                    fontSize: 13,
                    height: 2,
                  ),
                  children: [
                    TextSpan(text: '${context.l10n.addAddressNotSupportTip} '),
                    TextSpan(
                        text: context.l10n.eosContractAddress,
                        style: TextStyle(
                          color: context.theme.text,
                          fontWeight: FontWeight.bold,
                        ))
                  ])),
            const Spacer(),
            _SaveButton(
              enable: addEnable.value,
              onTap: () async {
                final address = addressController.text.trim();
                final label = labelController.text.trim();
                if (address.isEmpty || label.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text(context.l10n.emptyLabelOrAddress)));
                  return;
                }
                final tag = memoController.text.trim();

                if (context.read<AuthProvider>().isLoginByCredential) {
                  final succeed = await showAddAddressByPinBottomSheet(
                    context,
                    assetId: assetId,
                    destination: address,
                    tag: tag,
                    label: label,
                  );
                  if (succeed) {
                    Navigator.of(context).pop();
                  }
                } else {
                  final uri = Uri.https('mixin.one', 'address', {
                    'action': 'add',
                    'asset': assetId,
                    'destination': address,
                    'tag': tag,
                    'label': label,
                  });

                  final succeed = await showAndWaitingExternalAction(
                    context: context,
                    uri: uri,
                    action: () async {
                      final addressList =
                          await context.appServices.updateAddresses(assetId);
                      final index = addressList.indexWhere((e) =>
                          e.destination.toLowerCase() ==
                              address.toLowerCase() &&
                          e.tag == tag);
                      return index != -1;
                    },
                    hint: Text(context.l10n.waitingActionDone),
                  );
                  if (succeed) {
                    Navigator.pop(context);
                  }
                }
              },
            ),
            const SizedBox(height: 36),
          ],
        ));

    // wrapping in a Scaffold to show SnackBar
    return SizedBox(
        height: MediaQuery.of(context).size.height - 100,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(topRadius),
            child: Column(
              children: [
                MixinBottomSheetTitle(title: Text(context.l10n.addAddress)),
                Expanded(child: content),
              ],
            )));
  }

  void watchTextChange(
      TextEditingController controller, VoidCallback notifyChanged) {
    useEffect(() {
      controller.addListener(notifyChanged);
      return () {
        controller.removeListener(notifyChanged);
      };
    }, [controller]);
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.onTap,
    required this.enable,
  });

  final VoidCallback onTap;

  final bool enable;

  @override
  Widget build(BuildContext context) => ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateColor.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return context.colorScheme.primaryText.withOpacity(0.2);
            }
            return context.colorScheme.primaryText;
          }),
          padding: WidgetStateProperty.all(const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 24,
          )),
          minimumSize: WidgetStateProperty.all(const Size(110, 48)),
          foregroundColor:
              WidgetStateProperty.all(context.colorScheme.background),
          shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
        ),
        onPressed: enable ? onTap : null,
        child: SelectableText(
          context.l10n.save,
          onTap: enable ? onTap : null,
          style: TextStyle(
            fontSize: 16,
            color: context.theme.background,
          ),
          enableInteractiveSelection: false,
        ),
      );
}
