import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' hide encryptPin;

import '../../service/profile/pin_session.dart';
import '../../service/profile/profile_manager.dart';
import '../../util/extension/extension.dart';
import '../../util/logger.dart';
import '../router/mixin_routes.dart';
import '../widget/mixin_appbar.dart';
import '../widget/pin.dart';
import '../widget/toast.dart';

class CreatePinPage extends HookWidget {
  const CreatePinPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pinInputController = useMemoized(PinInputController.new);
    return Scaffold(
      backgroundColor: context.colorScheme.background,
      appBar: MixinAppBar(
        backgroundColor: context.colorScheme.background,
        title: SelectableText(
          context.l10n.createPin,
          style: TextStyle(
            color: context.colorScheme.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          enableInteractiveSelection: false,
        ),
        actions: [
          _PinCreateConfirmButton(controller: pinInputController),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            context.l10n.createPinTips,
            style: TextStyle(
              color: context.colorScheme.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 80),
          PinField(controller: pinInputController),
          const Spacer(),
          PinInputNumPad(controller: pinInputController),
        ],
      ),
    );
  }
}

class _PinCreateConfirmButton extends HookWidget {
  const _PinCreateConfirmButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final PinInputController controller;

  @override
  Widget build(BuildContext context) {
    final isFull = useListenable(controller).isFull;
    return TextButton(
      onPressed: !isFull
          ? null
          : () async {
              final pinCode = controller.value;
              final entry = showLoading();
              try {
                final account = await context.appServices.client.accountApi
                    .updatePin(PinRequest(pin: encryptPin(pinCode)!));
                await setAuth(auth!.copyWith(account: account.data));
                context.replace(homeUri);
              } catch (error, stacktrace) {
                e('create pin error $error $stacktrace');
                showErrorToast(error.toDisplayString(context));
              } finally {
                entry.dismiss();
              }
            },
      child: Text(
        context.l10n.confirm,
        style: TextStyle(
          color: isFull
              ? context.colorScheme.accent
              : context.colorScheme.thirdText,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
