import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:very_good_analysis/very_good_analysis.dart';

import '../../util/extension/extension.dart';
import '../../util/l10n.dart';
import '../../util/logger.dart';
import '../../util/r.dart';
import '../router/mixin_routes.dart';
import 'brightness_observer.dart';
import 'interactable_box.dart';
import 'mixin_bottom_sheet.dart';
import 'round_container.dart';

class AddressAddWidget extends HookWidget {
  const AddressAddWidget({Key? key, required this.assetId}) : super(key: key);

  final String assetId;

  @override
  Widget build(BuildContext context) {
    final memoSwitchEnable = useState<bool>(true);

    final memoController = useTextEditingController();
    final labelController = useTextEditingController();
    final addressController = useTextEditingController();

    return Container(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        height: MediaQuery.of(context).size.height - 100,
        child: Column(
          children: [
            MixinBottomSheetTitle(
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
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: context.l10n.addAddressLabelHint,
                    border: InputBorder.none,
                  ),
                  controller: labelController,
                )),
            const SizedBox(height: 10),
            RoundContainer(
              child: Row(children: [
                Expanded(
                    child: TextField(
                  style: TextStyle(
                    color: context.theme.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: context.l10n.address,
                    border: InputBorder.none,
                  ),
                  controller: addressController,
                )),
                const SizedBox(width: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: SvgPicture.asset(R.resourcesIcScanSvg),
                ),
              ]),
            ),
            const SizedBox(height: 10),
            RoundContainer(
              child: Row(children: [
                Expanded(
                    child: TextField(
                  style: TextStyle(
                    color: context.theme.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  enabled: memoSwitchEnable.value,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: memoSwitchEnable.value
                        ? context.l10n.memoOptional
                        : context.l10n.memoNo,
                    border: InputBorder.none,
                  ),
                  controller: memoController,
                )),
                const SizedBox(width: 20),
                Align(
                    alignment: Alignment.centerRight,
                    child: Switch(
                      value: memoSwitchEnable.value,
                      onChanged: (value) {
                        memoSwitchEnable.value = value;
                        if (!value) {
                          memoController.clear();
                        }
                      },
                    )),
              ]),
            ),
            const SizedBox(height: 10),
            Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  context.l10n.memoHint,
                  softWrap: true,
                  style: TextStyle(
                    color: context.theme.secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                )),
            const Spacer(),
            Align(
              alignment: Alignment.bottomCenter,
              child: InteractableBox(
                  onTap: () async {
                    final address = addressController.text.trim();
                    final label = labelController.text.trim();
                    if (address.isEmpty || label.isEmpty) {
                      // TODO toast
                      i('Empty address or label');
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
                        color: const Color(0xffB2B3C7),
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
  }
}
