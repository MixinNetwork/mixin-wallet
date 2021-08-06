// ignore_for_file: avoid_web_libraries_in_flutter, avoid_dynamic_calls

import 'dart:html';

void fixSafariIndexDb() {
  // fix safari indexedDb bug: https://bugs.webkit.org/show_bug.cgi?id=226547
  window.indexedDB!.open('dummy', version: 10);
}
