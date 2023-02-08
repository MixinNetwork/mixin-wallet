class Telegram {
  Telegram._internal();

  static Telegram instance = Telegram._internal();

  String? getTgInitData() => null;

  String? getTgUserId() => null;

  void hapticFeedback() {}

  Future<String?> showScanQrPopup(
    String text,
    bool Function(String result) callback,
  ) async =>
      null;

  String get platform => '';

  String get version => '';

  bool get isMobilePlatform => false;

  bool isVersionGreaterOrEqual(String version) => false;
}
