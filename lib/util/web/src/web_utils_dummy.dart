import 'package:flutter/services.dart';

void fixSafariIndexDb() {}

void setClipboardText(String text) {
  Clipboard.setData(ClipboardData(text: text));
}

String? getFallbackFontFamily() => null;

String locationOrigin() => 'https://mixinwallet.com';

bool isInAndroidWebView() => false;

bool isInWebView() => false;
