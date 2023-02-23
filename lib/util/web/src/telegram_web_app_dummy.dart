class Telegram {
  Telegram._internal();

  static Telegram instance = Telegram._internal();

  String? getTgInitData() => null;

  int? getTgUserId([String? initData]) => null;

  void hapticFeedback() {}

  Future<String?> showScanQrPopup() async => null;

  String get platform => '';

  String get version => '';
}
