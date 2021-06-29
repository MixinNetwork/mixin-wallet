// ignore_for_file: avoid_web_libraries_in_flutter
library web_util;

import 'dart:html';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void configureApp() {
  setUrlStrategy(PathUrlStrategy());
}

void replaceUrl(String? url) => window.location.replace(url);
