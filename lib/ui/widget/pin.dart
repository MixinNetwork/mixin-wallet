import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;

import '../../generated/r.dart';
import '../../service/profile/pin_session.dart';
import '../../util/extension/extension.dart';
import '../../util/logger.dart';
import '../../util/web/telegram_web_app.dart';
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
              .verifyPin(encryptPin(pin)!);
          Navigator.pop(context, pin);
        } catch (error, stacktrace) {
          e('verify pin error $error, $stacktrace');
          controller.clear();
          if (error is DioError) {
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
  const PinField({Key? key, required this.controller}) : super(key: key);

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
    Key? key,
    required this.controller,
  }) : super(key: key);

  final PinInputController controller;

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          for (var i = 0; i < 3; i++)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                for (var j = 0; j < 3; j++)
                  Expanded(
                    child: _NumPadButton(
                      value: i * 3 + j + 1,
                      controller: controller,
                    ),
                  ),
              ],
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Spacer(),
              Expanded(
                child: _NumPadButton(
                  value: 0,
                  controller: controller,
                ),
              ),
              Expanded(
                child: _NumPadButton(
                  value: -1,
                  controller: controller,
                ),
              ),
            ],
          ),
        ],
      );
}

class _NumPadButton extends HookWidget {
  const _NumPadButton({
    Key? key,
    required this.value,
    required this.controller,
  }) : super(key: key);

  final int value;
  final PinInputController controller;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 60,
        child: TextButton(
          onPressed: () {
            if (value == -1) {
              controller.delete();
            } else {
              controller.append(value);
            }
            Telegram.instance.hapticFeedback();
          },
          child: value == -1
              ? SvgPicture.asset(R.resourcesDeleteArrowSvg)
              : Text(
                  value.toString(),
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

class PinVerifyDialogScaffold extends HookWidget {
  const PinVerifyDialogScaffold({
    Key? key,
    required this.header,
    required this.tip,
    required this.onVerified,
    required this.onErrorConfirmed,
    this.title,
  }) : super(key: key);

  final Widget? title;

  final Widget header;

  final Widget tip;

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
        final pin = controller.value;
        verifying.value = true;
        try {
          await context.appServices.client.accountApi
              .verifyPin(encryptPin(pin)!);
          await onVerified(context, pin);
        } catch (error, stacktrace) {
          e('verify pin error $error, $stacktrace');
          if (error is DioError) {
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
        tip,
        const SizedBox(height: 32),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: bottom,
        ),
      ],
    );
  }
}
