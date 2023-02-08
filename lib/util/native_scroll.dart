import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../service/profile/profile_manager.dart';
import 'web/src/native_scroll_web.dart'
    if (dart.library.io) 'web/src/native_scroll_io.dart' as impl;
import 'web/telegram_web_app.dart';

class NativeScrollBuilder extends HookWidget {
  const NativeScrollBuilder({Key? key, required this.builder})
      : super(key: key);

  final Widget Function(BuildContext context, ScrollController controller)
      builder;

  @override
  Widget build(BuildContext context) {
    final controller = useScrollController();
    if (isLoginByCredential && Telegram.instance.isMobilePlatform) {
      // telegram web app on mobile platform need use native scroll to intercept
      // scroll event.
      return impl.NativeScrollBuilder(builder: builder);
    }
    return builder(context, controller);
  }
}
