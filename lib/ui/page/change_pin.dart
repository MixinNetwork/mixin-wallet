import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../util/extension/extension.dart';
import '../widget/buttons.dart';
import '../widget/mixin_appbar.dart';
import '../widget/pin.dart';
import '../widget/text.dart';
import '../widget/toast.dart';

class ChangePin extends HookWidget {
  const ChangePin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final step = useState(_ChangePinStep.verifyOldPin);

    final String title;
    switch (step.value) {
      case _ChangePinStep.verifyOldPin:
        title = context.l10n.verifyOldPin;
        break;
      case _ChangePinStep.createNewPin:
        title = context.l10n.createPin;
        break;
      case _ChangePinStep.confirmNewPin1:
        title = context.l10n.confirmPin;
        break;
      case _ChangePinStep.confirmNewPin2:
        title = context.l10n.confirmPin;
        break;
      case _ChangePinStep.confirmNewPin3:
        title = context.l10n.confirmPin;
        break;
    }

    return Scaffold(
      appBar: MixinAppBar(
        leading: MixinBackButton(
          onTap: () {
            switch (step.value) {
              case _ChangePinStep.confirmNewPin1:
                step.value = _ChangePinStep.createNewPin;
                break;
              case _ChangePinStep.confirmNewPin2:
                step.value = _ChangePinStep.confirmNewPin1;
                break;
              case _ChangePinStep.confirmNewPin3:
                step.value = _ChangePinStep.confirmNewPin2;
                break;
              case _ChangePinStep.verifyOldPin:
              case _ChangePinStep.createNewPin:
                context.pop();
                return;
            }
          },
        ),
        title: Column(
          children: [
            MixinText(
              title,
              style: TextStyle(
                color: context.colorScheme.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            MixinText(
              '${step.value.index + 1}/${_ChangePinStep.values.length}',
              style: TextStyle(
                color: context.colorScheme.secondaryText,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          _StepCircle(step: step.value.index),
        ],
        backgroundColor: context.colorScheme.background,
      ),
      backgroundColor: context.colorScheme.background,
      body: _PinInputLayout(
        step: step,
        doCreateNewPin: () {},
      ),
    );
  }
}

enum _ChangePinStep {
  verifyOldPin,
  createNewPin,
  confirmNewPin1,
  confirmNewPin2,
  confirmNewPin3,
}

class _PinInputLayout extends HookWidget {
  const _PinInputLayout({
    Key? key,
    required this.step,
    required this.doCreateNewPin,
  }) : super(key: key);
  final ValueNotifier<_ChangePinStep> step;

  final void Function() doCreateNewPin;

  @override
  Widget build(BuildContext context) {
    final pinInputController = useMemoized(PinInputController.new);

    final String message;
    switch (step.value) {
      case _ChangePinStep.verifyOldPin:
        message = context.l10n.changePinTip;
        break;
      case _ChangePinStep.createNewPin:
        message = context.l10n.setNewPinDesc;
        break;
      case _ChangePinStep.confirmNewPin1:
        message = '${context.l10n.pinConfirmHint}\n${context.l10n.pinLostHint}';
        break;
      case _ChangePinStep.confirmNewPin2:
        message =
            '${context.l10n.pinConfirmAgainHint}\n${context.l10n.thirdPinConfirmHint}';
        break;
      case _ChangePinStep.confirmNewPin3:
        message = context.l10n.fourthPinConfirmHint;
        break;
    }

    useEffect(() {
      pinInputController.clear();
      return null;
    }, [step.value]);

    final newPin = useRef<String>('');

    useEffect(() {
      void onConfirmNewPinFailed() {
        showErrorToast(context.l10n.pinNotMatch);
        step.value = _ChangePinStep.createNewPin;
      }

      void onPinInput() {
        if (!pinInputController.isFull) {
          return;
        }
        switch (step.value) {
          case _ChangePinStep.verifyOldPin:
            runWithLoading(() async {
              await Future<void>.delayed(const Duration(seconds: 1));
              step.value = _ChangePinStep.createNewPin;
            });
            break;
          case _ChangePinStep.createNewPin:
            newPin.value = pinInputController.value;
            step.value = _ChangePinStep.confirmNewPin1;
            break;
          case _ChangePinStep.confirmNewPin1:
            if (newPin.value != pinInputController.value) {
              onConfirmNewPinFailed();
              return;
            }
            step.value = _ChangePinStep.confirmNewPin2;
            break;
          case _ChangePinStep.confirmNewPin2:
            if (newPin.value != pinInputController.value) {
              onConfirmNewPinFailed();
              return;
            }
            step.value = _ChangePinStep.confirmNewPin3;
            break;
          case _ChangePinStep.confirmNewPin3:
            if (newPin.value != pinInputController.value) {
              onConfirmNewPinFailed();
              return;
            }
            doCreateNewPin();
            break;
        }
      }

      pinInputController.addListener(onPinInput);
      return () => pinInputController.removeListener(onPinInput);
    }, [pinInputController]);

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 100),
                    child: MixinText(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: context.colorScheme.primaryText,
                      ),
                    ),
                  ),
                ),
                PinField(controller: pinInputController),
                const Spacer(),
                PinInputNumPad(controller: pinInputController),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepCircle extends HookWidget {
  const _StepCircle({Key? key, required this.step}) : super(key: key);

  final int step;

  @override
  Widget build(BuildContext context) {
    const progressMax = 5;

    final controller = useAnimationController(
      duration: const Duration(milliseconds: 300),
      initialValue: step / progressMax,
    );
    useEffect(() {
      controller.animateTo(step / progressMax, curve: Curves.easeInOut);
      return null;
    }, [step]);

    useListenable(controller);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 4,
            value: controller.value,
            color: context.colorScheme.accent,
          ),
        ),
      ),
    );
  }
}
