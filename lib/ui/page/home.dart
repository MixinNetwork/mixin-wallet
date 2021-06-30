import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../util/extension/extension.dart';
import '../../util/l10n.dart';
import '../router/mixin_router_delegate.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setApplicationSwitcherDescription(
        ApplicationSwitcherDescription(
      label: L10n.current.test,
    ));
    return Scaffold(
      appBar: AppBar(title: const Text('home')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                context
                    .read<MixinRouterDelegate>()
                    .pushNewUri(MixinRouterDelegate.withdrawalUri);
              },
              child: const Text('go withdrawal'),
            ),
            TextButton(
              onPressed: () => context.read<MixinRouterDelegate>().pushNewUri(
                    MixinRouterDelegate.assetDetailPath.toUri({'id': 'foo'}),
                  ),
              child: const Text('go assetDetail'),
            ),
            TextButton(
              onPressed: () => context.read<MixinRouterDelegate>().pushNewUri(
                    MixinRouterDelegate.snapshotDetailPath.toUri({'id': 'foo'}),
                  ),
              child: const Text('go snapshotDetail'),
            ),
            TextButton(
              onPressed: () => context.read<MixinRouterDelegate>().pushNewUri(
                    MixinRouterDelegate.assetDepositPath.toUri({'id': 'foo'}),
                  ),
              child: const Text('go assetDeposit'),
            ),
          ],
        ),
      ),
    );
  }
}
