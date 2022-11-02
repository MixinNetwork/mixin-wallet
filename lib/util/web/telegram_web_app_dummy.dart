import '../../thirdy_party/vo/telegram_receiver.dart';

class Telegram {
  Telegram._internal();

  static Telegram instance = Telegram._internal();

  String? getTgInitData() => null;

  String? getTgUserId() => null;

  TelegramReceiver? getReceiver() => null;

  String? getStartParam() => null;

  void hapticFeedback() {}
}
