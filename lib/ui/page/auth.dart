import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../service/env.dart';
import '../../util/constants.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/logger.dart';
import '../../util/mixin_context.dart';
import '../../util/r.dart';
import '../../util/web/telegram_web_app.dart';
import '../router/mixin_routes.dart';
import '../widget/text.dart';
import '../widget/toast.dart';

class AuthPage extends HookWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loading = useState(false);

    final oauthCode = context.queryParameters['code'];

    useMemoizedFuture(() async {
      final tgInitData = Telegram.instance.getTgInitData();

      if ((tgInitData?.isEmpty ?? true) && (oauthCode?.isEmpty ?? true)) {
        return;
      }

      loading.value = true;
      try {
        if (tgInitData?.isNotEmpty ?? false) {
          d('tgInitData: $tgInitData');
          await context.appServices.loginByTelegram(tgInitData!);
        } else {
          await context.appServices.loginByMixinAuth(oauthCode!);
        }
        context.replace(homeUri);
      } catch (error, s) {
        e('$error, $s');
        showErrorToast(error.toDisplayString(context));
        loading.value = false;
      }
    }, keys: [oauthCode]);

    _useNativeForegroundClipboardCheck();

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
                  child: Opacity(
                    opacity: 0.9,
                    child: Image.asset(
                      R.resourcesAuthBgWebp,
                      fit: BoxFit.cover,
                      height: 360,
                      width: 360,
                    ),
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
                    fontSize: 16,
                    color: context.colorScheme.primaryText.withOpacity(0.5),
                    height: 1.75,
                  ),
                  enableInteractiveSelection: false,
                ),
              ),
            ),
          ),
          const SizedBox(height: 56),
          const _AuthorizeButton(),
          const SizedBox(height: 24),
          if (isInMixinApp())
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
            )
          else
            Column(
              children: [
                MixinText(
                  context.l10n.downloadMixinMessengerHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.colorScheme.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                TextButton(
                  onPressed: () {
                    launchUrlString('https://mixin.one/mm');
                  },
                  child: MixinText(
                    context.l10n.download,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.colorScheme.accent,
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 40),
        ],
      );
}

class _AuthorizeButton extends StatelessWidget {
  const _AuthorizeButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void onTap() {
      final uri = Uri.https('mixin-www.zeromesh.net', 'oauth/authorize', {
        'client_id': Env.clientId,
        'scope': authScope,
        'response_type': 'code',
      });
      launchUrl(uri);
    }

    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
          backgroundColor: context.colorScheme.primaryText,
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 24,
          ),
          minimumSize: const Size(110, 48),
          foregroundColor: context.colorScheme.background,
          shape: const StadiumBorder()),
      child: SelectableText(
        context.l10n.authorize,
        onTap: onTap,
        enableInteractiveSelection: false,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class CallbackWidgetsBindingObserver extends WidgetsBindingObserver {
  CallbackWidgetsBindingObserver({
    this.onAppLifecycleStateChanged,
  });

  final void Function(AppLifecycleState state)? onAppLifecycleStateChanged;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    onAppLifecycleStateChanged?.call(state);
  }
}

void _useNativeForegroundClipboardCheck() {
  final context = useContext();
  useEffect(() {
    final observer = CallbackWidgetsBindingObserver(
      onAppLifecycleStateChanged: (state) async {
        d('app lifecycle state changed: $state');
        if (state != AppLifecycleState.resumed) {
          return;
        }
        await Future<void>.delayed(const Duration(seconds: 2));
        final text = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
        if (text == null) {
          e('clipboard text is null.');
          return;
        }
        // check if match http://localhost:8001/#auth
        if (!text.startsWith('http://localhost:8001/#/auth')) {
          return;
        }
        final regex = RegExp('(?<=code=).*(?=&)');
        final code = regex.firstMatch(text)?.group(0);
        if (code == null) {
          e('code is null.');
          return;
        }
        await context.appServices.loginByMixinAuth(code);
        context.replace(homeUri);
      },
    );
    WidgetsBinding.instance.addObserver(observer);
    return () {
      WidgetsBinding.instance.removeObserver(observer);
    };
  }, []);
}
