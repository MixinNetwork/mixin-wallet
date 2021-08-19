import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';

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
      backgroundColor: context.theme.background,
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
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              final aspect = constraints.maxWidth / constraints.maxHeight;
              return SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: aspect > 1
                        ? context.theme.background
                        : context.theme.accent,
                  ),
                  child: SvgPicture.asset(
                    R.resourcesAuthBgSvg,
                    fit: aspect > 1 ? BoxFit.fitHeight : BoxFit.fitWidth,
                    height: constraints.maxHeight,
                    width: constraints.maxWidth,
                    alignment: Alignment.bottomCenter,
                  ),
                ),
              );
            }),
          ),
          // To hide the bottom of picture 1-pixel gap.
          Transform.translate(
            offset: const Offset(0, -1),
            child: Container(height: 2, color: context.theme.background),
          ),
          Text(
            context.l10n.mixinWallet,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: context.theme.text,
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
                child: Text(
                  context.l10n.authSlogan.overflow,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.theme.text.withOpacity(0.8),
                    height: 1.25,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 46),
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
              primary: context.theme.accent,
              padding: const EdgeInsets.symmetric(
                vertical: 13,
                horizontal: 47,
              ),
            ),
            child: Text(context.l10n.authorize),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              context.l10n.authHint.overflow,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: context.theme.text.withOpacity(0.3),
              ),
            ),
          ),
          const SizedBox(height: 50),
        ],
      );
}
