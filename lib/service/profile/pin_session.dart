import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;

import '../../util/logger.dart';
import 'profile_manager.dart';

String? encryptPin(String code) {
  assert(code.isNotEmpty, 'code is empty');

  final credential = auth?.credential;
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
