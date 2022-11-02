// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

import '../../thirdy_party/vo/telegram_receiver.dart';
import '../logger.dart';

class Telegram {
  Telegram._internal() {
    final telegram = js.context['Telegram'] as js.JsObject;
    webApp = telegram['WebApp'] as js.JsObject;
  }

  static Telegram instance = Telegram._internal();

  late js.JsObject webApp;
  TelegramReceiver? telegramReceiver;

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

  TelegramReceiver? getReceiver() {
    if (telegramReceiver != null) {
      return telegramReceiver;
    }
    final initDataUnsafe = webApp['initDataUnsafe'] as js.JsObject;
    final receiverObj = initDataUnsafe['receiver'];
    if (receiverObj == null) {
      return null;
    }
    final receiver = receiverObj as js.JsObject;
    final id = receiver['id'] as int;
    final isBot = receiver['is_bot'] as bool?;
    final firstName = receiver['first_name'] as String;
    final lastName = receiver['last_name'] as String?;
    final photoUrl = receiver['photo_url'] as String?;
    return telegramReceiver ??= TelegramReceiver(
        id: id,
        isBot: isBot,
        firstName: firstName,
        lastName: lastName,
        photoUrl: photoUrl);
  }

  String? getStartParam() {
    final initDataUnsafe = webApp['initDataUnsafe'] as js.JsObject;
    final startParam = initDataUnsafe['start_param'];
    if (startParam == null) {
      return null;
    }
    return startParam as String;
  }

  void hapticFeedback() {
    try {
      (webApp['HapticFeedback'] as js.JsObject)
          .callMethod('impactOccurred', ['light']);
    } catch (error, stacktrace) {
      e('hapticFeedback error $error, $stacktrace');
    }
  }
}
