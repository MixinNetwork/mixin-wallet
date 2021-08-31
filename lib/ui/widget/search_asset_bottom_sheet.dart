import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:rxdart/rxdart.dart';

import '../../db/mixin_database.dart';
import '../../service/profile/profile_manager.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../router/mixin_routes.dart';
import 'asset.dart';
import 'search_header_widget.dart';
import 'symbol.dart';

class SearchAssetBottomSheet extends HookWidget {
  const SearchAssetBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final keywordStreamController = useStreamController<String>();
    final keywordStream =
        useMemoized(() => keywordStreamController.stream.distinct());
    final hasKeyword =
        useMemoizedStream(() => keywordStream.map((event) => event.isNotEmpty))
                .data ??
            false;

    return SizedBox(
      height: MediaQuery.of(context).size.height - 100,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 8),
            child: SearchHeaderWidget(
              hintText: context.l10n.search,
              onChanged: keywordStreamController.add,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: IndexedStack(
              index: hasKeyword ? 1 : 0,
              children: [
                const _EmptyKeywordAssetList(),
                _SearchAssetList(keywordStream: keywordStream),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyKeywordAssetList extends HookWidget {
  const _EmptyKeywordAssetList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final assetIds = useMemoizedFuture(() async {
          await context.appServices.updateTopAssetIds();
          return topAssetIds;
        }).data ??
        topAssetIds;

    final topAssets = useMemoizedStream(
                () => context.appServices.watchAssetResultsOfIn(assetIds),
                keys: topAssetIds)
            .data ??
        [];

    final histories = useMemoizedStream(
          () => context.appServices.watchAssetResultsOfIn(searchAssetHistory),
        ).data ??
        [];

    final slivers = [
      if (histories.isNotEmpty)
        SliverToBoxAdapter(child: _SubTitle(context.l10n.recentSearches)),
      if (histories.isNotEmpty)
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) => _Item(
              data: histories[index],
            ),
            childCount: histories.length,
          ),
        ),
      if (topAssets.isNotEmpty)
        SliverToBoxAdapter(child: _SubTitle(context.l10n.assetTrending)),
      if (topAssets.isNotEmpty)
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) => _Item(
              data: topAssets[index],
            ),
            childCount: topAssets.length,
          ),
        ),
    ];

    if (slivers.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return CustomScrollView(
      slivers: slivers,
    );
  }
}

class _SubTitle extends StatelessWidget {
  const _SubTitle(
    this.title, {
    Key? key,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      );
}

class _SearchAssetList extends HookWidget {
  const _SearchAssetList({
    Key? key,
    required this.keywordStream,
  }) : super(key: key);

  final Stream<String> keywordStream;

  @override
  Widget build(BuildContext context) {
    useMemoizedStream(
      () => keywordStream
          .where((event) => event.isNotEmpty)
          .debounceTime(const Duration(milliseconds: 200))
          .map(
            (String keyword) =>
                unawaited(context.appServices.searchAndUpdateAsset(keyword)),
          ),
    );

    final keyword = useMemoizedStream(() => keywordStream.throttleTime(
          const Duration(milliseconds: 100),
          trailing: true,
          leading: false,
        )).data;

    final searchList = useMemoizedStream(() {
          if (keyword?.isEmpty ?? true) return Stream.value(<AssetResult>[]);
          return context.appServices.searchAssetResults(keyword!).watch();
        }, keys: [keyword]).data ??
        [];

    return ListView.builder(
      itemCount: searchList.length,
      itemBuilder: (BuildContext context, int index) => _Item(
        data: searchList[index],
        replaceHistory: true,
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    Key? key,
    required this.data,
    this.replaceHistory = false,
  }) : super(key: key);

  final AssetResult data;
  final bool replaceHistory;

  @override
  Widget build(BuildContext context) => Material(
      color: context.theme.background,
      child: InkWell(
        onTap: () {
          if (replaceHistory) {
            putSearchAssetHistory(data.assetId);
          }
          context.push(assetDetailPath.toUri({'id': data.assetId}));
        },
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              const SizedBox(width: 20),
              SymbolIconWithBorder(
                symbolUrl: data.iconUrl,
                chainUrl: data.chainIconUrl,
                size: 44,
                chainSize: 10,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      data.symbol.overflow,
                      style: TextStyle(
                        color: context.theme.text,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      data.name.overflow,
                      style: TextStyle(
                        color: context.theme.secondaryText,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              AssetPrice(data: data),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ));
}
