import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart';
import 'package:provider/provider.dart';

import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../router/mixin_router_delegate.dart';

// TODO should config for production or staging env
const clientId = 'd0a44d9d-bb19-403c-afc5-ea26ea88123b';
const clientSecret =
    '29c9774449f38accd015638d463bc4f70242ecc39e154b939d47017ca9316420';

class Auth extends HookWidget {
  const Auth({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMounted = useIsMounted();
    final loading = useState(false);

    useAsyncEffect(() async {
      final oauthCode = context.queryParameters['code'];
      if (oauthCode?.isEmpty ?? true) return;

      loading.value = true;
      // CORS
      await Future.delayed(const Duration(seconds: 3));
      context
          .read<MixinRouterDelegate>()
          .replaceLast(MixinRouterDelegate.homeUri);
      return;
      try {
        final response = await Client(
          httpLogLevel: HttpLogLevel.none,
          dioOptions: BaseOptions(headers: {
            'Access-Control-Allow-Origin': '*',
          }),
        ).oauthApi.post(OauthRequest(clientId, clientSecret, oauthCode!));
        if (!isMounted()) return;
        if (!response.data.scope.contains('ASSETS:READ SNAPSHOTS:READ')) {
          return;
        }

        final accessToken = response.data.accessToken;
        final box = Hive.box('settings');
        await box.put('access_token', accessToken);

        context
            .read<MixinRouterDelegate>()
            .replaceLast(MixinRouterDelegate.homeUri);
      } finally {
        loading.value = false;
      }
    }, cleanup: () {});
    return Scaffold(
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: loading.value
              ? const CircularProgressIndicator()
              : TextButton(
                  onPressed: () {
                    final uri = Uri.parse(
                        'https://mixin.one/oauth/authorize?client_id=$clientId&scope=PROFILE:READ+ASSETS:READ+CONTACTS:READ+SNAPSHOTS:READ&response_type=code');
                    context.read<MixinRouterDelegate>().replaceLast(uri);
                  },
                  child: const Text('login'),
                ),
        ),
      ),
    );
  }
}
