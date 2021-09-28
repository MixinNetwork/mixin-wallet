import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../util/l10n.dart';
import '../widget/brightness_observer.dart';
import '../widget/buttons.dart';
import '../widget/mixin_appbar.dart';

class SwapTransactions extends HookWidget {
  const SwapTransactions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => DefaultTabController(
      length: 2,
      child: Scaffold(
          backgroundColor: context.colorScheme.background,
          appBar: MixinAppBar(
            backgroundColor: context.colorScheme.background,
            title: Text(
              context.l10n.transferDetail,
              style: TextStyle(
                color: context.colorScheme.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            leading: const MixinBackButton2(),
            bottom: TabBar(
                indicatorColor: context.colorScheme.primaryText,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: context.colorScheme.primaryText,
                tabs: [
                  Tab(text: context.l10n.incomplete),
                  Tab(text: context.l10n.completed),
                ]),
          ),
          body: const TabBarView(children: [
            _TabContent(),
            _TabContent(),
          ])));
}

class _TabContent extends StatelessWidget {
  const _TabContent({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => const SizedBox();
}
