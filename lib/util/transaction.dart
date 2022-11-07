// ignore_for_file: avoid_dynamic_calls, avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:js' as js;

import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;

import '../db/mixin_database.dart';
import '../ui/widget/external_action_confirm.dart';
import '../ui/widget/toast.dart';
import 'extension/extension.dart';
import 'logger.dart';

bool isSignedToken(List<CollectibleOutputData> outputs) {
  var signed = Decimal.zero;
  for (final output in outputs) {
    if (output.state == sdk.CollectibleOutput.kStateSigned) {
      signed += Decimal.parse(output.amount);
    }
  }
  return signed > Decimal.zero;
}

Future<String> buildTransaction({
  required List<CollectibleOutputData> outputs,
  required CollectibleItem item,
  required User user,
  required sdk.Client client,
}) async {
  final txInputs = <dynamic>[];
  final txOutputs = <dynamic>[];

  var inputAmount = Decimal.zero;

  late CollectibleOutputData utxo;
  for (final output in outputs) {
    utxo = output;
    inputAmount += Decimal.parse(output.amount);
    txInputs.add({
      'hash': output.transactionHash,
      'index': output.outputIndex,
    });
    if (inputAmount >= Decimal.one) {
      break;
    }
  }

  if (inputAmount < Decimal.one) {
    throw Exception('Insufficient balance');
  }

  final tx = {
    'version': 2,
    'asset': item.mixinId,
    'extra': item.nfo,
  };

  final ghostKey = (await client.outputApi.loadGhostKeys(
    [
      sdk.OutputRequest(
        receivers: [user.userId],
        index: 0,
      ),
      sdk.OutputRequest(
        receivers: (jsonDecode(utxo.receivers) as List).cast(),
        index: 1,
      ),
    ],
  ))
      .data;

  final output = {
    'mask': ghostKey[0].mask,
    'keys': ghostKey[0].keys,
    'amount': '1',
    'script': _buildThresholdScript(1),
  };
  txOutputs.add(output);
  if (inputAmount > Decimal.one) {
    final utxo = outputs.first;
    final change = {
      'mask': ghostKey[1].mask,
      'keys': ghostKey[1].keys,
      'amount': (inputAmount - Decimal.one).toString(),
      'script': _buildThresholdScript(utxo.receiversThreshold),
    };
    txOutputs.add(change);
  }

  tx['inputs'] = txInputs;
  tx['outputs'] = txOutputs;

  d('transaction: $tx');

  return _buildTransaction(tx);
}

String _buildTransaction(Map<String, dynamic> tx) {
  final mixinGo = js.context['mixinGo'];
  assert(mixinGo != null, 'mixinGo is null');
  final buildTransaction = mixinGo['buildTransaction'] as js.JsFunction;
  final raw = buildTransaction.apply([jsonEncode(tx)]);
  return raw as String;
}

String _buildThresholdScript(int threshold) {
  var s = threshold.toRadixString(16);
  if (s.length == 1) {
    s = '0$s';
  }
  if (s.length > 2) {
    throw Exception('invalid threshold: $threshold');
  }
  return 'fffe$s';
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
          // multisigs might be cancelled
          e('wait action: $error $stacktrace');
          showErrorToast(error.toDisplayString(context));
          rethrow;
        }
        return false;
      },
      hint: Text(context.l10n.waitingActionDone),
    );
