import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../db/mixin_database.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../router/mixin_routes.dart';
import '../widget/buttons.dart';
import '../widget/mixin_appbar.dart';

class CollectiblesCollection extends HookWidget {
  const CollectiblesCollection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final collectionId = usePathParameter(
      'id',
      path: collectiblesCollectionPath,
    );

    useEffect(() {
      context.appServices.refreshCollection([collectionId], force: true);
    }, [collectionId]);

    final collectionSnapshot = useMemoizedStream(
      () => context.appServices.collection(collectionId),
      keys: [collectionId],
    );
    if (collectionSnapshot.isNoneOrWaiting) {
      return Scaffold(
        appBar: AppBar(leading: const MixinBackButton2()),
        body: Center(
          child: SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(
              color: context.colorScheme.surface,
            ),
          ),
        ),
      );
    }
    final collection = collectionSnapshot.data;
    if (collection == null) {
      return Scaffold(
        appBar: AppBar(leading: const MixinBackButton2()),
        body: Center(
          child: Text(
            context.l10n.noCollectionFound,
            style: TextStyle(color: context.colorScheme.primaryText),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: MixinAppBar(
        leading: const MixinBackButton2(),
        title: SelectableText(
          collection.name,
          style: TextStyle(
            color: context.colorScheme.primaryText,
            fontSize: 18,
          ),
          enableInteractiveSelection: false,
        ),
        backgroundColor: context.colorScheme.background,
      ),
      backgroundColor: context.colorScheme.background,
      body: _Body(collection: collection),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    Key? key,
    required this.collection,
    required this.count,
  }) : super(key: key);

  final Collection collection;

  final int count;

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned(
            height: 88,
            top: 0,
            left: 0,
            right: 0,
            child: Container(color: context.colorScheme.background),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 62),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: context.colorScheme.background,
                    width: 4,
                  ),
                ),
                width: 80,
                height: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Image.network(collection.iconUrl),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                collection.name,
                style: TextStyle(
                  color: context.colorScheme.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.collectionItemCount(count),
                style: TextStyle(
                  color: context.colorScheme.secondaryText,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  collection.description,
                  style: TextStyle(
                    color: context.colorScheme.secondaryText,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 33),
            ],
          ),
        ],
      );
}

class _Body extends HookWidget {
  const _Body({Key? key, required this.collection}) : super(key: key);

  final Collection collection;

  @override
  Widget build(BuildContext context) {
    final snapshot = useMemoizedStream(
        () => context.mixinDatabase.collectibleDao
            .collectibleItemByCollectionId(collection.collectionId)
            .watch(),
        keys: [collection]);
    if (snapshot.isNoneOrWaiting) {
      return Center(
        child: SizedBox.square(
          dimension: 18,
          child: CircularProgressIndicator(color: context.colorScheme.surface),
        ),
      );
    }
    final collectibles = snapshot.data ?? const [];
    debugPrint('collectibles: $collection $collectibles');
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _GroupHeader(
            collection: collection,
            count: collectibles.length,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverLayoutBuilder(builder: (context, constraints) {
            final itemWidth = (constraints.crossAxisExtent - 15) / 2;
            // temHeight = imageHeight + other height(title, subtitle, padding)
            // imageHeight = itemWidth - 16.
            final itemHeight = itemWidth + 44;
            return SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= collectibles.length) {
                    return null;
                  }
                  return _CollectiblesItemTile(item: collectibles[index]);
                },
                childCount: collectibles.length,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: itemWidth / itemHeight,
                crossAxisSpacing: 15,
                mainAxisSpacing: 16,
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _CollectiblesItemTile extends StatelessWidget {
  const _CollectiblesItemTile({
    Key? key,
    required this.item,
  }) : super(key: key);

  final CollectibleItem item;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => context.push(collectiblePath.toUri({'id': item.tokenId})),
        borderRadius: BorderRadius.circular(8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black.withOpacity(0.1),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(
                      item.mediaUrl ?? item.iconUrl ?? '',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  item.name ?? '',
                  enableInteractiveSelection: false,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: context.colorScheme.primaryText,
                  ),
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                SelectableText(
                  '#${item.token}',
                  enableInteractiveSelection: false,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.colorScheme.thirdText,
                  ),
                  maxLines: 1,
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      );
}
