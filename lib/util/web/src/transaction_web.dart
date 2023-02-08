// ignore_for_file: avoid_dynamic_calls, avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:js' as js;

String buildTransaction(Map<String, dynamic> tx) {
  final mixinGo = js.context['mixinGo'];
  assert(mixinGo != null, 'mixinGo is null');
  final buildTransaction = mixinGo['buildTransaction'] as js.JsFunction;
  final raw = buildTransaction.apply([jsonEncode(tx)]);
  return raw as String;
}
