import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../generated/r.dart';
import '../../service/profile/profile_manager.dart';
import '../../util/extension/extension.dart';
import '../../util/native_scroll.dart';
import '../route.dart';
import '../widget/buttons.dart';
import '../widget/menu.dart';
import '../widget/mixin_appbar.dart';

class Setting extends StatelessWidget {
  const Setting({super.key});

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
  const _SettingsBody();

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
              onTap: () => const AllTransactionsRoute().go(context),
            ),
            MenuItemWidget(
              bottomRounded: true,
              leading: SvgPicture.asset(R.resourcesHiddenSvg),
              title: Text(context.l10n.hiddenAssets),
              onTap: () => const HiddenAssetsRoute().go(context),
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
          ],
        ),
      ),
    );
  }
}
