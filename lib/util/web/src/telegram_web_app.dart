// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

import '../../logger.dart';

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

  String? getTgUserId() {
    final initDataUnsafe = webApp['initDataUnsafe'] as js.JsObject;
    final user = initDataUnsafe['user'];
    if (user == null) {
      return null;
    }
    return (user as js.JsObject)['id'] as String;
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

  bool isVersionGreaterOrEqual(String version) {
    final currentVersionParts = this.version.split('.');
    final versionParts = version.split('.');
    for (var i = 0; i < versionParts.length; i++) {
      final currentVersionPart = int.tryParse(currentVersionParts[i]);
      final vPart = int.tryParse(versionParts[i]);
      if (currentVersionPart == null || vPart == null) {
        return false;
      }
      if (currentVersionPart > vPart) {
        return true;
      } else if (currentVersionPart < vPart) {
        return false;
      }
    }
    return false;
  }

  String get platform => webApp['platform'] as String;

  String get version => webApp['version'] as String;
}
