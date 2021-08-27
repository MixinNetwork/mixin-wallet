import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

Map<String, dynamic> getMixinContext() {
  final mixinContext = js.context['MixinContext'] as js.JsObject;
  js.context.callMethod('alert', ['mixinContext: $mixinContext']);
  return jsonDecode(mixinContext.callMethod('getContext').toString())
      as Map<String, dynamic>;
}

String getCountry() {
  try {
    final ctx = getMixinContext();
    final locale = ctx['locale'].toString();
    return locale.substring(locale.length - 2, locale.length);
  } catch (_) {
    return 'US';
  }
}
