// ignore_for_file: avoid_web_libraries_in_flutter, avoid_dynamic_calls

import 'dart:html';

import 'package:flutter/foundation.dart';

import '../../mixin_context.dart';
import 'telegram_web_app.dart';

void fixSafariIndexDb() {
  // fix safari indexedDb bug: https://bugs.webkit.org/show_bug.cgi?id=226547
  window.indexedDB!.open('dummy');
}

/// https://github.com/zenorocha/clipboard.js/blob/master/src/actions/copy.js
void setClipboardText(String text) {
  final fakeElement = _createCopyFakeElement(text)..select();
  document.body?.append(fakeElement);
  _select(fakeElement);
  _copyCommand();
  fakeElement.remove();
}

// https://github.com/flutter/engine/pull/29166
// iOS 15.0 safari crash.
String? getFallbackFontFamily() {
  final userAgent = window.navigator.userAgent;
  if (defaultTargetPlatform == TargetPlatform.iOS &&
      userAgent.contains('OS 15_') &&
      !userAgent.contains('OS 15_0')) {
    // apply -apple-system font when version is not iOS 15.0, since
    // iOS 15.1 fixed this crash.
    return '-apple-system, BlinkMacSystemFont';
  }
  if (defaultTargetPlatform == TargetPlatform.macOS &&
      userAgent.contains('OS X 10_15_6')) {
    // use sans-serif as fallback font for OS X 10_15_6,
    // since there is an crash for iPad 15.6 or macOS 11.6.
    return 'sans-serif';
  }
  return null;
}

void _select(TextAreaElement element) {
  final isReadOnly = element.hasAttribute('readonly');

  if (!isReadOnly) {
    element.setAttribute('readonly', '');
  }

  element
    ..select()
    ..setSelectionRange(0, element.value?.length ?? 0);

  if (!isReadOnly) {
    element.removeAttribute('readonly');
  }
}

/// https://github.com/zenorocha/clipboard.js/blob/master/src/common/create-fake-element.js
TextAreaElement _createCopyFakeElement(String value) {
  final isRtl = document.documentElement?.getAttribute('dir') == 'rtl';
  final fakeElement = TextAreaElement()
    // Prevent zooming on iOS
    ..style.fontSize = '12pt'
    // Reset box model
    ..style.border = '0'
    ..style.padding = '0'
    // Move element out of screen horizontally
    ..style.position = 'absolute'
    ..style.setProperty(isRtl ? 'right' : 'left', '-9999px');

  // Move element to the same position vertically
  final yPosition =
      window.pageYOffset | (document.documentElement?.scrollTop ?? 0);
  fakeElement
    ..style.top = '${yPosition}px'
    ..setAttribute('readonly', '')
    ..value = value;
  return fakeElement;
}

bool _copyCommand() {
  try {
    return document.execCommand('copy');
  } catch (error, stack) {
    window.alert('$error, $stack');
    // ignore
    return false;
  }
}

String locationOrigin() => window.location.origin;

bool? _isInAndroidWebView;

bool isInAndroidWebView() => _isInAndroidWebView ??= _checkIsInAndroidWebView();

bool _checkIsInAndroidWebView() {
  if (defaultTargetPlatform != TargetPlatform.android) {
    return false;
  }
  // https://developer.chrome.com/docs/multidevice/user-agent/#webview_user_agent
  final userAgent = window.navigator.userAgent;
  return userAgent.contains('wv');
}

bool isInWebView() {
  if (isInMixinApp()) {
    return true;
  }
  if (isInAndroidWebView()) {
    return true;
  }

  // check if in telegram webapp
  final tgInitData = Telegram.instance.getTgInitData();
  if (tgInitData != null && tgInitData.isNotEmpty) {
    return true;
  }

  if (defaultTargetPlatform == TargetPlatform.iOS) {
    // check if in iOS webview
    final userAgent = window.navigator.userAgent;
    if (!userAgent.toLowerCase().contains('safari/')) {
      return true;
    }
  }

  return false;
}
