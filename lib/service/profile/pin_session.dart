import 'package:flutter/cupertino.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;

import '../../util/extension/extension.dart';
import '../../util/logger.dart';
import '../account_provider.dart';

String? encryptPin(BuildContext context, String code) {
  assert(code.isNotEmpty, 'code is empty');

  final credential = context.read<AuthProvider>().value?.credential;
  if (credential == null) {
    e('credential is null');
    return null;
  }
  final iterator = DateTime.now().millisecondsSinceEpoch * 1000000;
  return sdk.encryptPin(
    code,
    credential.pinToken,
    credential.privateKey,
    iterator,
  );
}
