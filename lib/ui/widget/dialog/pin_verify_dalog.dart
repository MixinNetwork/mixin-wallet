import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../util/constants.dart';
import '../../../util/extension/extension.dart';
import '../mixin_bottom_sheet.dart';
import '../pin.dart';

/// return: verified succeed pin code. null if canceled.
Future<String?> showPinVerifyDialog(BuildContext context) =>
    showModalBottomSheet<String>(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Material(
          color: context.colorScheme.background,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(topRadius),
          ),
          child: const _PinVerifyDialog(),
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(topRadius),
        ),
      ),
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
    );

class _PinVerifyDialog extends HookWidget {
  const _PinVerifyDialog();

  @override
  Widget build(BuildContext context) {
    final controller = useMemoized(PinInputController.new);
    usePinVerificationEffect(controller);
    return Column(
      children: [
        MixinBottomSheetTitle(
          title: Text(context.l10n.verify),
          action: const BottomSheetCloseButton(),
        ),
        PinField(controller: controller),
        const SizedBox(height: 32),
        PinInputNumPad(controller: controller),
      ],
    );
  }
}
