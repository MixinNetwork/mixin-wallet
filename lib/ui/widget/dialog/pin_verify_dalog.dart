import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../service/profile/pin_session.dart';
import '../../../util/extension/extension.dart';
import '../../../util/logger.dart';
import '../mixin_bottom_sheet.dart';
import '../pin.dart';
import '../toast.dart';

/// return: verified succeed pin code. null if canceled.
Future<String?> showPinVerifyDialog(BuildContext context) =>
    showMixinBottomSheet<String>(
      context: context,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height - 70,
        child: const _PinVerifyDialog(),
      ),
      isScrollControlled: true,
    );

class _PinVerifyDialog extends HookWidget {
  const _PinVerifyDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = useMemoized(PinInputController.new);
    useEffect(() {
      void onPinInput() {
        if (!controller.isFull) {
          return;
        }
        computeWithLoading(() async {
          final pin = controller.value;
          try {
            await context.appServices.client.accountApi
                .verifyPin(encryptPin(pin)!);
            Navigator.pop(context, pin);
          } catch (error, stacktrace) {
            e('verify pin error $error, $stacktrace');
            controller.clear();
            showErrorToast(error.toDisplayString(context));
          }
        });
      }

      controller.addListener(onPinInput);
      return () => controller.removeListener(onPinInput);
    }, [controller]);

    return Column(
      children: [
        SizedBox(
          height: 72,
          child: Center(
            child: Text(
              context.l10n.address,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        PinField(controller: controller),
        const Spacer(),
        PinInputNumPad(controller: controller),
      ],
    );
  }
}
