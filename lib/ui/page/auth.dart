import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../service/env.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/logger.dart';
import '../../util/r.dart';
import '../router/mixin_routes.dart';

class AuthPage extends HookWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loading = useState(false);
    final oauthCode = context.queryParameters['code'];

    useMemoizedFuture(() async {
      if (oauthCode?.isEmpty ?? true) return;
      loading.value = true;
      try {
        await context.appServices.login(oauthCode!);
        context.replace(homeUri);
      } catch (error, s) {
        e('$error, $s');
        loading.value = false;
      }
    }, keys: [oauthCode]);

    return Scaffold(
      backgroundColor: context.colorScheme.background,
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: loading.value ? _ProgressBody() : const _AuthBody(),
        ),
      ),
    );
  }
}

class _ProgressBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(
            height: 30,
          ),
          Text(context.l10n.authTips),
        ],
      );
}

class _AuthBody extends StatelessWidget {
  const _AuthBody({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: Image.asset(
                    R.resourcesAuthBgWebp,
                    fit: BoxFit.cover,
                    height: 360,
                    width: 360,
                  ),
                ),
                Center(
                  child: Image.asset(
                    R.resourcesLogoWebp,
                    width: 96,
                    height: 96,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            context.l10n.mixinWallet,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28,
              color: context.colorScheme.primaryText,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: LayoutBuilder(
              builder: (context, constraints) => ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 0,
                  maxWidth: math.min(constraints.maxWidth, 315.0),
                ),
                child: SelectableText(
                  context.l10n.authSlogan,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.colorScheme.secondaryText,
                    height: 1.25,
                  ),
                  enableInteractiveSelection: false,
                ),
              ),
            ),
          ),
          const SizedBox(height: 56),
          ElevatedButton(
            onPressed: () {
              final uri =
                  Uri.https('mixin-www.zeromesh.net', 'oauth/authorize', {
                'client_id': Env.clientId,
                'scope':
                    'PROFILE:READ+ASSETS:READ+CONTACTS:READ+SNAPSHOTS:READ',
                'response_type': 'code',
              });
              context.toExternal(uri);
            },
            style: ElevatedButton.styleFrom(
                primary: context.colorScheme.primaryText,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                minimumSize: const Size(110, 48),
                onPrimary: context.colorScheme.background,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50))),
            child: SelectableText(
              context.l10n.authorize,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              enableInteractiveSelection: false,
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 46),
            child: SelectableText(
              context.l10n.authHint,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: context.colorScheme.primaryText.withOpacity(0.3),
              ),
              enableInteractiveSelection: false,
            ),
          ),
          const SizedBox(height: 56),
        ],
      );
}
