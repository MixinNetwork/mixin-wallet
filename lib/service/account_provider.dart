import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart';
import 'package:provider/provider.dart';

import '../util/logger.dart';
import 'profile/auth.dart';
import 'profile/profile_manager.dart';

class AuthProvider extends ChangeNotifier implements ValueListenable<Auth?> {
  AuthProvider() : super();

  Auth? _value = profileBox.get('auth') as Auth?;

  @override
  Auth? get value => _value;

  Future<void> updateAccount(Account account) async {
    if (value == null) {
      e('update account, but auth state not found.');
      return;
    }
    await setAuth(value?.copyWith(account: account));
  }

  Future<void> clear() async {
    await setAuth(null);
  }

  Future<void> setAuth(Auth? auth) {
    _value = auth;
    notifyListeners();
    return profileBox.put('auth', auth);
  }

  bool get isLoginByCredential => value?.credential != null;

  String? get accessToken => value?.accessToken;

  bool get isLogin => accessToken != null || value?.credential != null;

  Account? get account => value?.account;
}

String useAccountFaitCurrency() {
  final context = useContext();
  final authProvider = context.read<AuthProvider>();

  final fait = useState<String>(
    useMemoized(() => authProvider.value!.account.fiatCurrency),
  );
  useEffect(() {
    void listener() {
      final fiatCurrency = authProvider.value?.account.fiatCurrency;
      if (fiatCurrency == null) {
        // this might happen when user logout.
        e('fiatCurrency is null.');
        return;
      }
      fait.value = fiatCurrency;
    }

    authProvider.addListener(listener);
    return () {
      authProvider.removeListener(listener);
    };
  }, [authProvider]);
  return fait.value;
}
