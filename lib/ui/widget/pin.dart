import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;

import '../../generated/r.dart';
import '../../service/profile/pin_session.dart';
import '../../util/extension/extension.dart';
import '../../util/logger.dart';
import 'buttons.dart';
import 'mixin_bottom_sheet.dart';
import 'toast.dart';

const _kPinCodeLength = 6;

void usePinVerificationEffect(PinInputController controller) {
  final context = useContext();
  useEffect(() {
    void onPinInput() {
      if (!controller.isFull) {
        return;
      }
      computeWithLoading(() async {
        final pin = controller.value;
        try {
          await context.appServices.client.accountApi
              .verifyPin(encryptPin(context, pin)!);
          Navigator.pop(context, pin);
        } catch (error, stacktrace) {
          e('verify pin error $error, $stacktrace');
          controller.clear();
          if (error is DioException) {
            final mixinError = error.optionMixinError;
            if (mixinError != null) {
              if (mixinError.code == sdk.tooManyRequest) {
                showErrorToast(context.l10n.errorPinCheckTooManyRequest);
                return;
              } else if (mixinError.code == sdk.pinIncorrect) {
                final count =
                    await context.appServices.getPinErrorRemainCount();
                showErrorToast(
                  context.l10n.errorPinIncorrectWithTimes(count, count),
                );
                return;
              }
            }
          }
          showErrorToast(error.toDisplayString(context));
        }
      });
    }

    controller.addListener(onPinInput);
    return () => controller.removeListener(onPinInput);
  }, [controller]);
}

class PinInputController extends ValueNotifier<String> {
  PinInputController() : super('');

  void clear() {
    value = '';
  }

  void append(int value) {
    if (isFull) {
      return;
    }
    assert(value >= 0 && value <= 9);
    this.value += value.toString();
  }

  void delete() {
    if (isEmpty) {
      return;
    }
    value = value.substring(0, value.length - 1);
  }

  bool get isFull => value.length == _kPinCodeLength;

  bool get isEmpty => value.isEmpty;
}

class PinField extends HookWidget {
  const PinField({
    required this.controller,
    super.key,
  });

  final PinInputController controller;

  @override
  Widget build(BuildContext context) {
    final pinText = useValueListenable(controller);
    final inputPinLength = pinText.length;
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          for (var i = 0; i < inputPinLength; i++)
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: context.theme.text,
                shape: BoxShape.circle,
              ),
            ),
          for (var i = inputPinLength; i < _kPinCodeLength; i++)
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.theme.secondaryText,
                ),
              ),
            ),
        ].separated(const SizedBox(width: 20)).toList(),
      ),
    );
  }
}

class PinInputNumPad extends HookWidget {
  const PinInputNumPad({
    required this.controller,
    super.key,
  });

  final PinInputController controller;

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: context.colorScheme.surface,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 8),
            for (var i = 0; i < 3; i++) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  for (var j = 0; j < 3; j++) ...[
                    if (j == 0) const SizedBox(width: 8),
                    Expanded(
                      child: _NumPadButton(
                        value: i * 3 + j + 1,
                        controller: controller,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ]
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(width: 8),
                const Spacer(),
                const SizedBox(width: 8),
                Expanded(
                  child: _NumPadButton(
                    value: 0,
                    controller: controller,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DeleteButton(controller: controller),
                ),
                const SizedBox(width: 8),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.controller});

  final PinInputController controller;

  @override
  Widget build(BuildContext context) => _ButtonWrapper(
        onTap: controller.delete,
        background: const Color(0xFF999999),
        child: Center(
          child: Image.asset(
            R.resourcesIcDeleteWebp,
            width: 26,
            height: 26,
          ),
        ),
      );
}

class _ButtonWrapper extends HookWidget {
  const _ButtonWrapper({
    required this.child,
    required this.onTap,
    this.background,
  });

  final Widget child;
  final VoidCallback onTap;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final tapDown = useState(false);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (details) {
        tapDown.value = true;
      },
      onTapUp: (details) {
        tapDown.value = false;
      },
      onTapCancel: () {
        tapDown.value = false;
      },
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: tapDown.value
              ? context.colorScheme.captionIcon
              : background ?? context.colorScheme.background,
          borderRadius: BorderRadius.circular(8),
        ),
        height: 50,
        child: child,
      ),
    );
  }
}

class _NumPadButton extends StatelessWidget {
  const _NumPadButton({
    required this.value,
    required this.controller,
  });

  final int value;
  final PinInputController controller;

  @override
  Widget build(BuildContext context) => _ButtonWrapper(
        onTap: () {
          if (value < 0 || value > 9) {
            e('Invalid value: $value');
            return;
          }
          controller.append(value);
        },
        child: Center(
          child: Text(
            value.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              color: context.theme.text,
            ),
          ),
        ),
      );
}

typedef PinPostVerification = Future<void> Function(
    BuildContext context, String pin);

typedef PinVerification = Future<void> Function(
    BuildContext context, String pin);

class PinVerifyDialogScaffold extends HookWidget {
  const PinVerifyDialogScaffold({
    required this.header,
    required this.tip,
    required this.onVerified,
    required this.onErrorConfirmed,
    super.key,
    this.title,
    this.verification,
  });

  final Widget? title;

  final Widget header;

  final Widget? tip;

  final PinVerification? verification;

  final PinPostVerification onVerified;

  final void Function()? onErrorConfirmed;

  @override
  Widget build(BuildContext context) {
    final controller = useMemoized(PinInputController.new);
    final verifying = useState(false);
    final errorMessage = useState<String?>(null);
    useEffect(() {
      Future<void> onPinInput() async {
        if (!controller.isFull) {
          return;
        }
        if (verifying.value) {
          assert(false, 'verifying, but pin is full. ${controller.value}');
          return;
        }
        final pin = controller.value;
        verifying.value = true;
        try {
          if (verification == null) {
            await context.appServices.client.accountApi
                .verifyPin(encryptPin(context, pin)!);
          } else {
            await verification!(context, pin);
          }
          await onVerified(context, pin);
        } catch (error, stacktrace) {
          e('verify pin error $error, $stacktrace');
          if (error is DioException) {
            final mixinError = error.optionMixinError;
            if (mixinError != null) {
              if (mixinError.code == sdk.tooManyRequest) {
                errorMessage.value = context.l10n.errorPinCheckTooManyRequest;
              } else if (mixinError.code == sdk.pinIncorrect) {
                final count =
                    await context.appServices.getPinErrorRemainCount();
                errorMessage.value =
                    context.l10n.errorPinIncorrectWithTimes(count, count);
              }
            }
          }
          errorMessage.value ??= error.toDisplayString(context);
          controller.clear();
        } finally {
          verifying.value = false;
        }
      }

      controller.addListener(onPinInput);
      return () => controller.removeListener(onPinInput);
    }, [controller]);

    final Widget bottom;
    if (verifying.value) {
      bottom = SizedBox(
        height: 100,
        child: Center(
          child: SizedBox.square(
            dimension: 30,
            child: CircularProgressIndicator(
              color: context.colorScheme.accent,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    } else if (errorMessage.value != null) {
      bottom = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              errorMessage.value!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colorScheme.red,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 20),
          MixinPrimaryTextButton(
            onTap: () {
              if (onErrorConfirmed != null) {
                onErrorConfirmed!();
                return;
              }
              errorMessage.value = null;
            },
            text: context.l10n.confirm,
          ),
          const SizedBox(height: 32),
        ],
      );
    } else {
      bottom = PinInputNumPad(controller: controller);
    }
    return Column(
      children: [
        MixinBottomSheetTitle(
          title: title ?? const SizedBox.shrink(),
          action: BottomSheetCloseButton(enable: !verifying.value),
        ),
        header,
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: PinField(controller: controller),
        ),
        if (tip != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: tip,
          ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: bottom,
        ),
      ],
    );
  }
}
