// ignore_for_file: avoid_web_libraries_in_flutter
library web_util;

import 'dart:html';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void configureApp() {
  setUrlStrategy(PathUrlStrategy());
}

void replaceUrl(String? url) {
  if (url == null) return;
  final uri = Uri.tryParse(url);
  if (uri?.host.isNotEmpty == true) {
    return window.location.replace(url);
  }
  window.location.replace(url);
  // window.history.replaceState(null, '', url);
}
