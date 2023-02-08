import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart';

import '../../generated/r.dart';
import '../../service/account_provider.dart';
import '../../service/profile/profile_manager.dart';
import '../../util/extension/extension.dart';
import '../../util/logger.dart';
import '../../util/native_scroll.dart';
import '../router/mixin_routes.dart';
import '../widget/buttons.dart';
import '../widget/dialog/currency_bottom_sheet.dart';
import '../widget/menu.dart';
import '../widget/mixin_appbar.dart';
import '../widget/toast.dart';

class Setting extends StatelessWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: MixinAppBar(
          leading: const MixinBackButton2(),
          title: SelectableText(
            context.l10n.settings,
            style: TextStyle(
              color: context.colorScheme.primaryText,
              fontSize: 18,
            ),
            enableInteractiveSelection: false,
          ),
          backgroundColor: context.colorScheme.background,
        ),
        backgroundColor: context.colorScheme.background,
        body: const _SettingsBody(),
      );
}

class _SettingsBody extends HookWidget {
  const _SettingsBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hideSmallAssets = useValueListenable(isSmallAssetsHidden);
    return NativeScrollBuilder(
      builder: (context, controller) => SingleChildScrollView(
        controller: controller,
        child: Column(
          children: [
            const SizedBox(height: 24),
            MenuItemWidget(
              topRounded: true,
              leading: SvgPicture.asset(R.resourcesAllTransactionsSvg),
              title: Text(context.l10n.allTransactions),
              onTap: () => context.push(transactionsUri),
            ),
            MenuItemWidget(
              bottomRounded: true,
              leading: SvgPicture.asset(R.resourcesHiddenSvg),
              title: Text(context.l10n.hiddenAssets),
              onTap: () => context.push(hiddenAssetsUri),
            ),
            const SizedBox(height: 10),
            MenuItemWidget(
              topRounded: true,
              bottomRounded: true,
              title: Text(context.l10n.hideSmallAssets),
              leading: SvgPicture.asset(R.resourcesHideAssetsSvg),
              trailing: Switch(
                value: hideSmallAssets,
                activeColor: const Color(0xff333333),
                onChanged: (bool value) => isSmallAssetsHidden.value = value,
              ),
            ),
            const SizedBox(height: 10),
            if (context.watch<AuthProvider>().isLoginByCredential) ...[
              const _CurrencyItem(),
              MenuItemWidget(
                title: Text(context.l10n.logs),
                topRounded: false,
                bottomRounded: false,
                onTap: () => context.push(pinLogsPath),
              ),
              MenuItemWidget(
                title: Text(context.l10n.changePin),
                topRounded: false,
                bottomRounded: true,
                onTap: () => context.push(changePinPath),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CurrencyItem extends StatelessWidget {
  const _CurrencyItem({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<AuthProvider>().account?.fiatCurrency;
    return MenuItemWidget(
      topRounded: true,
      bottomRounded: false,
      title: Text(context.l10n.currency),
      trailing: Text(
        currency ?? '',
        style: TextStyle(
          color: context.colorScheme.secondaryText,
          fontSize: 12,
        ),
      ),
      onTap: () async {
        d('currency: $currency');
        final selected = await showCurrencyBottomSheet(
          context,
          selectedCurrency: currency,
        );
        if (selected == null) {
          return;
        }
        final succeed = await runWithLoading(() async {
          final account = await context.appServices.client.accountApi
              .preferences(AccountUpdateRequest(fiatCurrency: selected.name));
          await context.read<AuthProvider>().updateAccount(account.data);
        });
        if (!succeed) {
          return;
        }
      },
    );
  }
}
