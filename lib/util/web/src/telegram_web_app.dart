// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

import '../../../ui/widget/toast.dart';
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

  void showScanQrPopup(bool Function(String result) callback) {
    try {
      webApp.callMethod('showScanQrPopup', [null, js.allowInterop(callback)]);
    } catch (error, stacktrace) {
      wtf('showScanQrPopup error $error, $stacktrace');
      showErrorToast('showScanQrPopup error $error $stacktrace');
    }
  }

  String get platform => webApp['platform'] as String;

  String get version => webApp['version'] as String;
}
