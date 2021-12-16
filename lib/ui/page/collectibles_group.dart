import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../db/mixin_database.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../router/mixin_routes.dart';
import '../widget/buttons.dart';
import '../widget/mixin_appbar.dart';

class CollectiblesGroup extends HookWidget {
  const CollectiblesGroup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final group = usePathParameter('id', path: collectiblesGroupPath);
    return Scaffold(
      appBar: MixinAppBar(
        leading: const MixinBackButton2(),
        title: SelectableText(
          group,
          style: TextStyle(
            color: context.colorScheme.primaryText,
            fontSize: 18,
          ),
          enableInteractiveSelection: false,
        ),
        backgroundColor: context.colorScheme.background,
      ),
      backgroundColor: context.colorScheme.background,
      body: _Body(group: group),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.loose,
        children: [
          Positioned(
            height: 88,
            top: 0,
            left: 0,
            right: 0,
            child: Container(color: Colors.blue),
          ),
          Column(
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
                  child: Container(color: Colors.red),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'GroupTitle',
                style: TextStyle(
                  color: context.colorScheme.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '14 items',
                style: TextStyle(
                  color: context.colorScheme.secondaryText,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Efdot is a colorblind visual artist creating in an abstract-meets-figurative style. His playful and meditative drawing practices produce vivid, ',
                  style: TextStyle(
                    color: context.colorScheme.secondaryText,
                    fontSize: 16,
                  ),
                  // TODO(bin): add ellipsis
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 33),
            ],
          ),
        ],
      );
}

class _Body extends HookWidget {
  const _Body({
    Key? key,
    required this.group,
  }) : super(key: key);

  final String group;

  @override
  Widget build(BuildContext context) {
    final snapshot = useMemoizedStream(
        () => context.mixinDatabase.collectibleDao
            .collectibleItemByGroup(group)
            .watch(),
        keys: [group]);
    if (snapshot.isNoneOrWaiting) {
      return Center(
        child: SizedBox.square(
          dimension: 18,
          child: CircularProgressIndicator(color: context.colorScheme.surface),
        ),
      );
    }
    final collectibles = snapshot.data ?? const [];
    debugPrint('collectibles: $group $collectibles');
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: _GroupHeader()),
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
                Text(
                  item.name ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: context.colorScheme.primaryText,
                  ),
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  item.metaHash,
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
