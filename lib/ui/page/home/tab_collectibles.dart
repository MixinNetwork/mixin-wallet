import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../db/mixin_database.dart';
import '../../../service/env.dart';
import '../../../util/constants.dart';
import '../../../util/extension/extension.dart';
import '../../../util/hook.dart';
import '../../router/mixin_routes.dart';
import 'empty.dart';

class CollectiblesGroupSliverGrid extends HookWidget {
  const CollectiblesGroupSliverGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final update =
        useMemoizedFuture(() => context.appServices.updateCollectibles());

    final snapshot =
        useMemoizedStream(() => context.appServices.groupedCollectibles());

    if (snapshot.isNoneOrWaiting) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 200,
          child: Center(
            child: SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(
                  color: context.colorScheme.captionIcon),
            ),
          ),
        ),
      );
    }

    if (update.hasError) {
      return const SliverFillRemaining(
        child: _UnauthorizedWidget(),
      );
    }

    final collectibles = snapshot.data ?? const [];
    if (collectibles.isEmpty) {
      return SliverFillRemaining(
        child: EmptyLayout(content: context.l10n.noCollectiblesFound),
      );
    }

    return SliverPadding(
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
              return _CollectiblesGroupTile(items: collectibles[index].value);
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
    );
  }
}

class _CollectiblesGroupTile extends StatelessWidget {
  const _CollectiblesGroupTile({
    Key? key,
    required this.items,
  }) : super(key: key);

  final List<CollectibleItem> items;

  @override
  Widget build(BuildContext context) {
    final String subtitle;
    final String title;
    if (items.length > 1) {
      subtitle = context.l10n.collectionItemCount(items.length);
      title = items.first.collectionName ?? '';
    } else if (items.length == 1) {
      title = items.single.name ?? '';
      subtitle = '#${items.single.token}';
    } else {
      return const SizedBox.expand();
    }

    return InkWell(
      onTap: () {
        if (items.length == 1) {
          context.push(collectiblePath.toUri({'id': items.single.tokenId}));
        } else {
          context.push(
            collectiblesCollectionPath.toUri({'id': items.first.collectionId}),
          );
        }
      },
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
                  child: _GroupCover(items: items),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: context.colorScheme.primaryText,
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
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
}

class _GroupCover extends StatelessWidget {
  const _GroupCover({Key? key, required this.items}) : super(key: key);

  final List<CollectibleItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.expand();
    }
    switch (items.length) {
      case 0:
        return const SizedBox.expand();
      case 1:
        return _CollectibleItemImage(item: items[0]);
      case 2:
        return Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(child: _CollectibleItemImage(item: items[0])),
            const SizedBox(width: 1),
            Flexible(child: _CollectibleItemImage(item: items[1])),
          ],
        );
      case 3:
        return Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(child: _CollectibleItemImage(item: items[0])),
            const SizedBox(width: 1),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Flexible(child: _CollectibleItemImage(item: items[1])),
                  const SizedBox(height: 1),
                  Flexible(child: _CollectibleItemImage(item: items[2])),
                ],
              ),
            ),
          ],
        );
      default:
        return Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Flexible(child: _CollectibleItemImage(item: items[0])),
                  const SizedBox(height: 1),
                  Flexible(child: _CollectibleItemImage(item: items[1])),
                ],
              ),
            ),
            const SizedBox(width: 1),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Flexible(child: _CollectibleItemImage(item: items[2])),
                  const SizedBox(height: 1),
                  Flexible(child: _CollectibleItemImage(item: items[3])),
                ],
              ),
            ),
          ],
        );
    }
  }
}

class _CollectibleItemImage extends StatelessWidget {
  const _CollectibleItemImage({
    Key? key,
    required this.item,
  }) : super(key: key);

  final CollectibleItem item;

  // FIXME image load.
  @override
  Widget build(BuildContext context) => Image.network(
        item.mediaUrl ?? item.iconUrl ?? '',
        fit: BoxFit.cover,
      );
}

class _UnauthorizedWidget extends StatelessWidget {
  const _UnauthorizedWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 100),
          Text(
            context.l10n.collectiblesReadFailed,
            style: TextStyle(
              color: context.colorScheme.thirdText,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: () {
              final uri =
                  Uri.https('mixin-www.zeromesh.net', 'oauth/authorize', {
                'client_id': Env.clientId,
                'scope': authScope,
                'response_type': 'code',
              });
              context.toExternal(uri.toString());
            },
            child: Text(
              context.l10n.reauthorize,
              style: TextStyle(
                color: context.colorScheme.primaryText,
                fontSize: 14,
              ),
            ),
          ),
          const Spacer(flex: 164),
        ],
      );
}
