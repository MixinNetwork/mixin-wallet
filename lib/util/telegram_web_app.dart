// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

class Telegram {
  Telegram() {
    final telegram = js.context['Telegram'] as js.JsObject;
    webApp = telegram['WebApp'] as js.JsObject;
  }

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
}