//
// Generated file. Do not edit.
//

// ignore_for_file: directives_ordering
// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: depend_on_referenced_packages

import 'package:share_plus_web/share_plus_web.dart';
import 'package:url_launcher_web/url_launcher_web.dart';
import 'package:web_qrcode/web_qrcode_plugin.dart';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// ignore: public_member_api_docs
void registerPlugins(Registrar registrar) {
  SharePlusPlugin.registerWith(registrar);
  UrlLauncherPlugin.registerWith(registrar);
  WebQrcodePlugin.registerWith(registrar);
  registrar.registerMessageHandler();
}
