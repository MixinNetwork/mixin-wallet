import 'dart:convert';
import 'dart:js_interop' as js;
import 'dart:js_interop_unsafe';
import 'dart:ui';

import 'package:web/web.dart';

Map<String, dynamic> getMixinContext() {
  // see https://developers.mixin.one/docs/js-bridge#getcontext
  if (js.globalContext['webkit'] != null &&
      // ignore: avoid_dynamic_calls
      js.globalContext
              .getProperty<js.JSObject>('webkit'.toJS)['messageHandlers'] !=
          null &&
      // ignore: avoid_dynamic_calls
      js.globalContext
              .getProperty<js.JSObject>('webkit'.toJS)
              .getProperty<js.JSObject>(
                  'messageHandlers'.toJS)['MixinContext'] !=
          null) {
    final context = js.globalContext.callMethod<js.JSString>(
        'prompt'.toJS, 'MixinContext.getContext()'.toJS);
    return jsonDecode(context.toDart) as Map<String, dynamic>;
  } else if (js.globalContext['MixinContext'] != null) {
    final mixinContext =
        js.globalContext.getProperty<js.JSObject>('MixinContext'.toJS);
    return jsonDecode(
            mixinContext.callMethod<js.JSString>('getContext'.toJS).toDart)
        as Map<String, dynamic>;
  }
  return const {};
}

bool isInMixinApp() {
  final mixinContext = getMixinContext();
  return mixinContext.isNotEmpty;
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
    getMixinLocale() ?? Locale(window.navigator.language);
