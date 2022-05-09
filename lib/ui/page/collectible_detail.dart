import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../db/mixin_database.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../router/mixin_routes.dart';
import '../widget/buttons.dart';
import '../widget/mixin_appbar.dart';

class CollectibleDetail extends HookWidget {
  const CollectibleDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tokenId = usePathParameter('id', path: collectiblePath);
    final snapshot = useMemoizedStream(
      () => context.mixinDatabase.collectibleDao
          .collectibleItemByTokenId(tokenId)
          .watchSingleOrNull(),
      keys: [tokenId],
    );
    useMemoized(() {
      context.appServices.refreshCollectiblesTokenIfNotExist([tokenId]);
    }, [tokenId]);

    if (snapshot.isNoneOrWaiting) {
      return _CollectibleDetailScaffold(
        item: null,
        child: Center(
          child: SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(
              color: context.colorScheme.surface,
            ),
          ),
        ),
      );
    }
    final collectible = snapshot.data;
    if (collectible == null) {
      return _CollectibleDetailScaffold(
        item: null,
        child: Center(
          child: SelectableText(
            context.l10n.noCollectiblesFound,
            style: TextStyle(color: context.colorScheme.primaryText),
            enableInteractiveSelection: false,
          ),
        ),
      );
    }
    return _CollectibleDetailScaffold(
      item: collectible,
      child: Align(
        alignment: Alignment.topCenter,
        child: _Body(item: collectible),
      ),
    );
  }
}

class _CollectibleDetailScaffold extends StatelessWidget {
  const _CollectibleDetailScaffold({
    Key? key,
    required this.item,
    required this.child,
  }) : super(key: key);

  final CollectibleItem? item;

  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: MixinAppBar(
          leading: const MixinBackButton2(),
          title: SelectableText(
            item == null ? '' : '${item?.name} #${item?.token}',
            style: TextStyle(
              color: context.colorScheme.primaryText,
              fontSize: 18,
            ),
            maxLines: 1,
            enableInteractiveSelection: false,
          ),
          backgroundColor: context.colorScheme.background,
        ),
        backgroundColor: context.colorScheme.background,
        body: child,
      );
}

class _Body extends StatelessWidget {
  const _Body({
    Key? key,
    required this.item,
  }) : super(key: key);

  final CollectibleItem item;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(item.mediaUrl ?? ''),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SelectableText(
                item.name ?? '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.primaryText,
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 6),
              SelectableText(
                '#${item.token}',
                style: TextStyle(
                  fontSize: 14,
                  color: context.colorScheme.thirdText,
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 12),
              SelectableText(
                item.description ?? '',
                style: TextStyle(
                  fontSize: 16,
                  color: context.colorScheme.secondaryText,
                ),
              ),
            ],
          ),
        ),
      );
}
