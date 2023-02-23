// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:js' as js;

import '../../extension/extension.dart';
import '../../logger.dart';
import '../../version.dart';

class Telegram {
  Telegram._internal() {
    final telegram = js.context['Telegram'] as js.JsObject;
    webApp = telegram['WebApp'] as js.JsObject;
  }

  static Telegram instance = Telegram._internal();

  late js.JsObject webApp;

  String? getTgInitData() {
    final initData = webApp['initData'];
    if (initData == null) {
      return null;
    }
    return initData as String;
  }

  int? getTgUserId([String? initData]) {
    final initDataString = initData ?? getTgInitData();

    if (initDataString == null) {
      e('tg init data is null');
      return null;
    }

    final data = Uri.splitQueryString(initDataString);
    final userJson = data['user'];
    if (userJson == null) {
      e('tg init data user is null');
      return null;
    }
    final user = jsonDecode(userJson) as Map<String, dynamic>?;
    if (user == null) {
      e('tg init data user is null');
      return null;
    }
    final userId = user['id'] as int?;
    return userId;
  }

  void hapticFeedback() {
    try {
      (webApp['HapticFeedback'] as js.JsObject)
          .callMethod('impactOccurred', ['light']);
    } catch (error, stacktrace) {
      e('hapticFeedback error $error, $stacktrace');
    }
  }

  bool showScanQrPopup(String text, bool Function(String result) callback) {
    try {
      final function = webApp['showScanQrPopup'] as js.JsFunction?;
      if (function == null) {
        wtf('showScanQrPopup is null');
        return false;
      }
      final params = js.JsObject.jsify({'text': text});
      function.apply([params, js.allowInterop(callback)], thisArg: webApp);
      return true;
    } catch (error, stacktrace) {
      wtf('showScanQrPopup error $error, $stacktrace');
      return false;
    }
  }

  bool isVersionGreaterOrEqual(String version) =>
      isCurrentVersionGreaterOrEqualThan(this.version, version);

  String get platform => webApp['platform'] as String;

  String get version => webApp['version'] as String;

  bool get isMobilePlatform {
    final platform = this.platform;
    return platform.equalsIgnoreCase('android') ||
        platform.equalsIgnoreCase('ios');
  }
}
