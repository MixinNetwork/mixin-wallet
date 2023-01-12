// ignore: avoid_web_libraries_in_flutter
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
