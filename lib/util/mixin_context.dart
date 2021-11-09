import 'dart:convert';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;
import 'dart:ui';

Map<String, dynamic> getMixinContext() {
  // see https://developers.mixin.one/docs/js-bridge#getcontext
  if (js.context['webkit'] != null &&
      // ignore: avoid_dynamic_calls
      js.context['webkit']['messageHandlers'] != null &&
      // ignore: avoid_dynamic_calls
      js.context['webkit']['messageHandlers']['MixinContext'] != null) {
    final context =
        js.context.callMethod('prompt', ['MixinContext.getContext()']);
    return jsonDecode(context as String) as Map<String, dynamic>;
  } else if (js.context['MixinContext'] != null) {
    final mixinContext = js.context['MixinContext'] as js.JsObject;
    return jsonDecode(mixinContext.callMethod('getContext').toString())
        as Map<String, dynamic>;
  }
  return const {};
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

Locale getMixinLocaleOrPlatformLocale() =>
    getMixinLocale() ?? Locale(html.window.navigator.language);
