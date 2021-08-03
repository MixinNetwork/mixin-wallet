import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:very_good_analysis/very_good_analysis.dart';

import '../../util/constants.dart';
import '../../util/extension/extension.dart';
import '../../util/l10n.dart';
import '../router/mixin_routes.dart';
import 'brightness_observer.dart';
import 'mixin_bottom_sheet.dart';
import 'round_container.dart';

class AddressAddWidget extends HookWidget {
  const AddressAddWidget({Key? key, required this.assetId}) : super(key: key);

  final String assetId;

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

    final content = Container(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        child: Column(
          children: [
            MixinBottomSheetTitle(
              padding: EdgeInsets.zero,
              title: Row(children: [
                Text(context.l10n.addAddress),
              ]),
            ),
            const SizedBox(height: 10),
            RoundContainer(
                alignment: Alignment.center,
                child: TextField(
                  style: TextStyle(
                    color: context.theme.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    hintText: context.l10n.addAddressLabelHint,
                    border: InputBorder.none,
                  ),
                  controller: labelController,
                )),
            const SizedBox(height: 10),
            RoundContainer(
              child: Center(
                  child: TextField(
                style: TextStyle(
                  color: context.theme.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  hintText: context.l10n.address,
                  border: InputBorder.none,
                ),
                controller: addressController,
              )),
            ),
            const SizedBox(height: 10),
            memoEnable.value
                ? Column(children: [
                    RoundContainer(
                        child: Center(
                      child: TextField(
                        style: TextStyle(
                          color: context.theme.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          hintText: memoHint,
                          border: InputBorder.none,
                        ),
                        controller: memoController,
                      ),
                    )),
                    const SizedBox(height: 10),
                  ])
                : const SizedBox(),
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
            const Spacer(),
            Align(
              alignment: Alignment.bottomCenter,
              child: InkWell(
                  onTap: () async {
                    final address = addressController.text.trim();
                    final label = labelController.text.trim();
                    if (address.isEmpty || label.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text(context.l10n.emptyLabelOrAddress)));
                      return;
                    }
                    final uri = Uri.https('mixin.one', 'address', {
                      'action': 'add',
                      'asset': assetId,
                      'destination': address,
                      'tag': memoController.text.trim(),
                      'label': label,
                    });
                    if (!await canLaunch(uri.toString())) {
                      return;
                    }
                    await launch(uri.toString());
                    await showDialog<bool>(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => AlertDialog(
                              content: Text(context.l10n.finishVerifyPIN),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(context.l10n.cancel)),
                                TextButton(
                                    onPressed: () async {
                                      unawaited(context.appServices
                                          .updateAddresses(assetId));
                                      context.replace(withdrawalAddressesPath
                                          .toUri({'id': assetId}));
                                    },
                                    child: Text(context.l10n.sure)),
                              ],
                            ));
                  },
                  child: Container(
                      width: 160,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: addEnable.value
                            ? context.theme.accent
                            : const Color(0xffB2B3C7),
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        vertical: 11,
                        horizontal: 22,
                      ),
                      child: Text(context.l10n.save,
                          style: TextStyle(
                            fontSize: 16,
                            color: context.theme.background,
                          )))),
            ),
            const SizedBox(height: 70),
          ],
        ));

    // wrapping in a Scaffold to show SnackBar
    return SizedBox(
        height: MediaQuery.of(context).size.height - 100,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(topRadius),
            child: Scaffold(body: content)));
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
