import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

import 'dart:ui';

Map<String, dynamic> getMixinContext() {
  final mixinContext = js.context['MixinContext'];
  if (mixinContext == null) {
    return <String, dynamic>{};
  }
  final mixinContextObj = mixinContext as js.JsObject;
  return jsonDecode(mixinContextObj.callMethod('getContext').toString())
      as Map<String, dynamic>;
}

Locale? getMixinLocale() {
  final ctx = getMixinContext();
  if (ctx.isEmpty) return null;

  final locale = ctx['locale'];
  if (locale == null) return null;

  final list = (locale as String).split('-');
  if (list.isEmpty) return null;

  if (list.length > 1) {
    return Locale.fromSubtags(languageCode: list[0], countryCode: list[1]);
  } else {
    return Locale.fromSubtags(languageCode: list[0]);
  }
}
