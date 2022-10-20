import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/native_scroll.dart';
import '../widget/asset.dart';
import '../widget/buttons.dart';
import '../widget/mixin_appbar.dart';

class HiddenAssets extends StatelessWidget {
  const HiddenAssets({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: MixinAppBar(
          leading: const MixinBackButton2(),
          title: SelectableText(
            context.l10n.hiddenAssets,
            style: TextStyle(
              color: context.colorScheme.primaryText,
              fontSize: 18,
            ),
            enableInteractiveSelection: false,
          ),
          backgroundColor: context.colorScheme.background,
        ),
        backgroundColor: context.colorScheme.background,
        body: const _HiddenAssetsList(),
      );
}

class _HiddenAssetsList extends HookWidget {
  const _HiddenAssetsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final assets = useMemoizedStream(
        () => context.appServices.hiddenAssetResult().watch());
    if (assets.connectionState == ConnectionState.waiting) {
      return Center(
        child: CircularProgressIndicator(
          color: context.colorScheme.surface,
        ),
      );
    }
    final data = assets.data!;
    return NativeScrollBuilder(
      builder: (context, controller) => ListView.builder(
        controller: controller,
        itemBuilder: (context, index) {
          final item = data[index];
          return _SwipeToUnHide(
            key: ValueKey(item.assetId),
            onDismiss: () {
              final appServices = context.appServices
                ..updateAssetHidden(item.assetId, hidden: false);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(context.l10n.alreadyHidden(item.name)),
                action: SnackBarAction(
                  label: context.l10n.undo,
                  onPressed: () {
                    appServices.updateAssetHidden(item.assetId, hidden: true);
                  },
                ),
              ));
            },
            child: AssetWidget(data: item),
          );
        },
        itemCount: data.length,
      ),
    );
  }
}

class _SwipeToUnHide extends StatelessWidget {
  const _SwipeToUnHide({
    required Key key,
    required this.child,
    required this.onDismiss,
  }) : super(key: key);

  final Widget child;
  final VoidCallback onDismiss;

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
      background: ColoredBox(
        color: context.theme.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: indicator,
        ),
      ),
      secondaryBackground: ColoredBox(
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
