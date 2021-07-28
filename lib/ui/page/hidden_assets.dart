import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../widget/asset.dart';
import '../widget/mixin_appbar.dart';

class HiddenAssets extends StatelessWidget {
  const HiddenAssets({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: MixinAppBar(
          title: Text(context.l10n.hiddenAssets),
          backButtonColor: Colors.white,
        ),
        backgroundColor: context.theme.background,
        body: Column(
          children: const [
            ListRoundedHeaderContainer(height: 16),
            Expanded(child: _HiddenAssetsList()),
          ],
        ),
      );
}

class _HiddenAssetsList extends HookWidget {
  const _HiddenAssetsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final assets = useMemoizedStream(
        () => context.appServices.hiddenAssetResult().watch());
    if (assets.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    final data = assets.data!;
    return ListView.builder(
      itemBuilder: (context, index) {
        final item = data[index];
        return _SwipeToUnHide(
          key: ValueKey(item.assetId),
          onDismiss: () {
            context.appServices.updateAssetHidden(item.assetId, hidden: false);
          },
          child: AssetWidget(data: item),
        );
      },
      itemCount: data.length,
    );
  }
}

class _SwipeToUnHide extends StatelessWidget {
  const _SwipeToUnHide({
    required Key key,
    required this.child,
    required this.onDismiss,
    this.confirmDismiss,
  }) : super(key: key);

  final Widget child;
  final VoidCallback onDismiss;
  final ConfirmDismissCallback? confirmDismiss;

  @override
  Widget build(BuildContext context) {
    final Widget indicator = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Text(
        context.l10n.show,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
    return Dismissible(
      key: ValueKey(key),
      onDismissed: (direction) => onDismiss(),
      confirmDismiss: confirmDismiss,
      background: Container(
        color: context.theme.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: indicator,
        ),
      ),
      secondaryBackground: Container(
        color: context.theme.red,
        child: Align(
          alignment: Alignment.centerRight,
          child: indicator,
        ),
      ),
      child: child,
    );
  }
}
