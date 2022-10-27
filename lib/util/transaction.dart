// ignore_for_file: avoid_dynamic_calls, avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:js' as js;

import 'package:flutter/cupertino.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;

import '../ui/widget/external_action_confirm.dart';
import '../ui/widget/toast.dart';
import 'extension/extension.dart';
import 'logger.dart';

String buildTransaction(Map<String, dynamic> tx) {
  final mixinGo = js.context['mixinGo'];
  assert(mixinGo != null, 'mixinGo is null');
  final buildTransaction = mixinGo['buildTransaction'] as js.JsFunction;
  final raw = buildTransaction.apply([jsonEncode(tx)]);
  return raw as String;
}

Future<bool> showAndWaitingNftTransaction(
  BuildContext context,
  String codeId,
) =>
    showAndWaitingExternalAction(
      context: context,
      uri: Uri.parse('mixin://codes/$codeId'),
      action: () async {
        try {
          final response =
              await context.appServices.client.accountApi.code(codeId);
          final data = response.data as sdk.CollectibleRequest?;
          if (data == null) {
            e('failed to get code: $codeId');
            return true;
          }
          if (data.state != 'initial') {
            await context.appServices.sendRawTransaction(data.rawTransaction);
            return true;
          }
        } catch (error, stacktrace) {
          e('wait action: $error $stacktrace');
          showErrorToast(error.toDisplayString(context));
          return true;
        }
        return false;
      },
      hint: Text(context.l10n.waitingActionDone),
    );
