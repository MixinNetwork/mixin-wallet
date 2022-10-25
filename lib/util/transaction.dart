// ignore_for_file: avoid_dynamic_calls, avoid_web_libraries_in_flutter

import 'dart:convert';

import 'dart:js' as js;

String buildTransaction(Map<String, dynamic> tx) {
  final mixinGo = js.context['mixinGo'];
  final raw = mixinGo.buildTransaction(jsonEncode(tx));
  return raw as String;
}
