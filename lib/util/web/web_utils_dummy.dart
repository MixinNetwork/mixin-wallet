import 'package:flutter/services.dart';

void fixSafariIndexDb() {}

void setClipboardText(String text) {
  Clipboard.setData(ClipboardData(text: text));
}
