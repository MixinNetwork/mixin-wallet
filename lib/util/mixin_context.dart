import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

Map<String, dynamic> getMixinContext() {
  final mixinContext = js.context['MixinContext'];
  if (mixinContext == null) {
    return <String, dynamic>{};
  }
  final mixinContextObj = mixinContext as js.JsObject;
  return jsonDecode(mixinContextObj.callMethod('getContext').toString())
      as Map<String, dynamic>;
}
