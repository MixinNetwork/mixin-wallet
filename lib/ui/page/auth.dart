import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mixin_wallet/util/logger.dart';
import 'package:provider/provider.dart';

import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/r.dart';
import '../router/mixin_router_delegate.dart';

// TODO should config for production or staging env
const clientId = 'd0a44d9d-bb19-403c-afc5-ea26ea88123b';
const clientSecret =
    '29c9774449f38accd015638d463bc4f70242ecc39e154b939d47017ca9316420';

class AuthPage extends HookWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loading = useState(false);
    final oauthCode = context.queryParameters['code'];

    useMemoizedFuture(() async {
      if (oauthCode?.isEmpty ?? true) return null;
      loading.value = true;
      try {
        await context.appServices.login(oauthCode!);
        context
            .read<MixinRouterDelegate>()
            .replaceLast(MixinRouterDelegate.homeUri);
      } catch (error, s) {
        e('$error, $s');
        loading.value = false;
      }
    }, keys: [oauthCode]);

    return Scaffold(
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: loading.value
              ? const CircularProgressIndicator()
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, top: 80, right: 8, bottom: 20),
                      child: SvgPicture.asset(R.resourcesAuthLogoSvg),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    const Text(
                      'Mixin Wallet',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 30.0, right: 30),
                      child: Text(
                        'Mixin Wallet is a user-friendly, secure and powerful multi-chain digital wallet.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: () {
                        final uri = Uri.parse(
                            'https://mixin.one/oauth/authorize?client_id=$clientId&scope=PROFILE:READ+ASSETS:READ+CONTACTS:READ+SNAPSHOTS:READ&response_type=code');
                        context.read<MixinRouterDelegate>().replaceLast(uri);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: context.theme.accent,
                        padding: const EdgeInsets.only(
                            left: 32, top: 18, bottom: 18, right: 32),
                      ),
                      child: const Text('LOGIN'),
                    ),
                    const SizedBox(height: 30),
                    const Padding(
                      padding: EdgeInsets.only(left: 30.0, right: 30),
                      child: Text(
                        'Read-only authorization cannot use your assets, please rest assured',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
